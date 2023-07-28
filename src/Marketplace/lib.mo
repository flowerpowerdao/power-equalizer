import Ledger "canister:ledger";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import TrieMap "mo:base/TrieMap";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

import { fromPrincipal; addHash; fromText } "mo:accountid/AccountIdentifier";
import Encoding "mo:encoding/Binary";
import Root "mo:cap/Root";
import Fuzz "mo:fuzz";

import AID "../toniq-labs/util/AccountIdentifier";
import ExtCore "../toniq-labs/ext/Core";
import Types "types";
import RootTypes "../types";
import Utils "../utils";

module {
  public class Factory(config : RootTypes.Config, deps : Types.Dependencies) {

    /*********
    * STATE *
    *********/

    var _transactions : Buffer.Buffer<Types.TransactionV2> = Buffer.Buffer(0);
    var _tokenSettlement : TrieMap.TrieMap<Types.TokenIndex, Types.Settlement> = TrieMap.TrieMap(ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    var _tokenListing : TrieMap.TrieMap<Types.TokenIndex, Types.Listing> = TrieMap.TrieMap(ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    public func getChunkCount(chunkSize : Nat) : Nat {
      var count = _transactions.size() / chunkSize;
      if (_transactions.size() % chunkSize != 0) {
        count += 1;
      };
      Nat.max(1, count);
    };

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      let start = Nat.min(_transactions.size(), chunkSize * chunkIndex);
      let count = Nat.min(chunkSize, _transactions.size() - start);
      let transactionChunk = if (_transactions.size() == 0 or count == 0) {
        []
      }
      else {
        Buffer.toArray(Buffer.subBuffer(_transactions, start, count));
      };

      if (chunkIndex == 0) {
        return ?#v2({
          transactionCount = _transactions.size();
          transactionChunk;
          tokenSettlement = Iter.toArray(_tokenSettlement.entries());
          tokenListing = Iter.toArray(_tokenListing.entries());
        });
      } else if (chunkIndex < getChunkCount(chunkSize)) {
        return ?#v2_chunk({ transactionChunk });
      } else {
        null;
      };
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      func txV1toV2(transaction : Types.Transaction) : Types.TransactionV2 {
        {
          transaction with
          sellerFrontend = null;
          buyerFrontend = null;
        }
      };

      switch (chunk) {
        // v1 -> v2
        case (?#v1(data)) {
          _transactions := Buffer.Buffer<Types.TransactionV2>(data.transactionCount);
          _transactions.append(Buffer.fromArray(Array.map(data.transactionChunk, txV1toV2)));
          _tokenSettlement := TrieMap.fromEntries(data.tokenSettlement.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _tokenListing := TrieMap.fromEntries(data.tokenListing.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
        };
        case (?#v1_chunk(data)) {
          _transactions.append(Buffer.fromArray(Array.map(data.transactionChunk, txV1toV2)));
        };
        case (?#v2(data)) {
          _transactions := Buffer.Buffer<Types.TransactionV2>(data.transactionCount);
          _transactions.append(Buffer.fromArray(data.transactionChunk));
          _tokenSettlement := TrieMap.fromEntries(data.tokenSettlement.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _tokenListing := TrieMap.fromEntries(data.tokenListing.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
        };
        case (?#v2_chunk(data)) {
          _transactions.append(Buffer.fromArray(data.transactionChunk));
        };
        case (null) {};
      };
    };

    public func grow(n : Nat) : Nat {
      let fuzz = Fuzz.Fuzz();

      for (i in Iter.range(1, n)) {
        _transactions.add({
          token = fuzz.text.randomAlphanumeric(32);
          seller = fuzz.principal.randomPrincipal(10);
          price = fuzz.nat64.random();
          buyer = fuzz.text.randomAlphanumeric(32);
          time = fuzz.int.randomRange(1670000000000000000, 2670000000000000000);
          sellerFrontend = null;
          buyerFrontend = null;
        });
      };

      _transactions.size();
    };

    /********************
    * PUBLIC INTERFACE *
    ********************/

    public func lock(caller : Principal, tokenid : Types.TokenIdentifier, price : Nat64, address : Types.AccountIdentifier, frontendIdentifier : ?Text) : async* Result.Result<Types.AccountIdentifier, Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(tokenid, config.canister) == false) {
        return #err(#InvalidToken(tokenid));
      };

      let token = ExtCore.TokenIdentifier.getIndex(tokenid);

      if (_isLocked(token)) {
        return #err(#Other("Listing is locked"));
      };

      if (not validFrontendIndentifier(frontendIdentifier)) {
        return #err(#Other("Unknown frontend identifier"));
      };

      let listing = switch (_tokenListing.get(token)) {
        case (?listing) { listing };
        case (null) {
          return #err(#Other("No listing!"));
        };
      };

      if (listing.price != price) {
        return #err(#Other("Price has changed!"));
      };

      let subaccount = deps._Sale.getNextSubAccount();
      let paymentAddress : Types.AccountIdentifier = AID.fromPrincipal(config.canister, ?subaccount);
      _tokenListing.put(
        token,
        {
          listing with
          locked = ?(Time.now() + Utils.toNanos(Option.get(config.escrowDelay, #minutes(2))));
          sellerFrontend = listing.sellerFrontend;
          buyerFrontend = frontendIdentifier;
        },
      );

      // check if there is a previous settlement that has never been settled
      switch (_tokenSettlement.get(token)) {
        case (?settlement) {
          let resp : Result.Result<(), Types.CommonError> = await* settle(caller, tokenid);
          switch (resp) {
            case (#ok) {
              return #err(#Other("Listing has sold"));
            };
            case (#err _) {
              // Atomic protection
              if (Option.isNull(_tokenListing.get(token))) {
                return #err(#Other("Listing has sold"));
              };
            };
          };
        };
        case (null) {};
      };
      _tokenSettlement.put(
        token,
        {
          seller = listing.seller;
          price = listing.price;
          subaccount = subaccount;
          buyer = address;
          sellerFrontend = listing.sellerFrontend;
          buyerFrontend = frontendIdentifier;
        },
      );
      return #ok(paymentAddress);
    };

    public func settle(caller : Principal, tokenid : Types.TokenIdentifier) : async* Result.Result<(), Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(tokenid, config.canister) == false) {
        return #err(#InvalidToken(tokenid));
      };
      let token : Types.TokenIndex = ExtCore.TokenIdentifier.getIndex(tokenid);

      var settlement = switch (_tokenSettlement.get(token)) {
        case (?settlement) { settlement };
        case (null) {
          return #err(#Other("Nothing to settle"));
        };
      };

      let response = await Ledger.account_balance({
        account = Blob.fromArray(addHash(fromPrincipal(config.canister, ?settlement.subaccount)));
      });

      // because of the await above, we check again if there is a settlement available for the token
      settlement := switch (_tokenSettlement.get(token)) {
        case (?settlement) { settlement };
        case (null) {
          return #err(#Other("Nothing to settle"));
        };
      };

      if (response.e8s < settlement.price) {
        if (_isLocked(token)) {
          return #err(#Other("Insufficient funds sent"));
        } else {
          _tokenSettlement.delete(token);
          return #err(#Other("Nothing to settle"));
        };
      };

      let tokenOwner = switch (deps._Tokens.getOwnerFromRegistry(token)) {
        case (?tokenOwner) { tokenOwner };
        case (null) {
          return #err(#InvalidToken(tokenid));
        };
      };

      // deduct 3 extra transaction fees for marketplace(seller + buyer) fee and disbursment to seller
      let bal : Nat64 = response.e8s - (10000 * Nat64.fromNat(config.royalties.size() + 3));
      var rem = bal;

      // disbursement of royalties
      for (f in config.royalties.vals()) {
        let _fee : Nat64 = bal * f.1 / 100000;
        deps._Disburser.addDisbursement({
          to = f.0;
          fromSubaccount = settlement.subaccount;
          amount = _fee;
          tokenIndex = token;
        });
        rem -= _fee : Nat64;
      };

      // disburse seller frontend fee
      let sellerFrontend = getFrontend(settlement.sellerFrontend);
      let sellerFrontendFee = bal * sellerFrontend.fee / 100000;
      deps._Disburser.addDisbursement({
        to = sellerFrontend.accountIdentifier;
        fromSubaccount = settlement.subaccount;
        amount = sellerFrontendFee;
        tokenIndex = token;
      });
      rem -= sellerFrontendFee;

      // disburse buyer frontend fee
      let buyerFrontend = getFrontend(settlement.buyerFrontend);
      let buyerFrontendFee = bal * buyerFrontend.fee / 100000;
      deps._Disburser.addDisbursement({
        to = buyerFrontend.accountIdentifier;
        fromSubaccount = settlement.subaccount;
        amount = buyerFrontendFee;
        tokenIndex = token;
      });
      rem -= buyerFrontendFee;

      // disbursement to seller
      deps._Disburser.addDisbursement({
        to = tokenOwner;
        fromSubaccount = settlement.subaccount;
        amount = rem;
        tokenIndex = token;
      });

      // add event to CAP
      let event : Root.IndefiniteEvent = {
        operation = "sale";
        details = [
          ("to", #Text(settlement.buyer)),
          ("from", #Principal(settlement.seller)),
          ("price_decimals", #U64(8)),
          ("price_currency", #Text("ICP")),
          ("price", #U64(settlement.price)),
          ("token_id", #Text(tokenid)),
        ];
        caller;
      };
      ignore deps._Cap.insert(event);

      // transfer token to new owner
      deps._Tokens.transferTokenToUser(token, settlement.buyer);

      _transactions.add({
        token = tokenid;
        seller = settlement.seller;
        price = settlement.price;
        buyer = settlement.buyer;
        time = Time.now();
        buyerFrontend = settlement.buyerFrontend;
        sellerFrontend = settlement.sellerFrontend;
      });
      _tokenListing.delete(token);
      _tokenSettlement.delete(token);

      return #ok();
    };

    public func list(caller : Principal, request : Types.ListRequest) : async* Result.Result<(), Types.CommonError> {
      // marketplace is open either when marketDelay has passed or collection sold out
      let marketDelay = Utils.toNanos(Option.get(config.marketDelay, #days(2)));
      if (Time.now() < config.publicSaleStart + marketDelay) {
        if (deps._Sale.getSold() < deps._Sale.getTotalToSell()) {
          return #err(#Other("You can not list yet"));
        };
      };
      if (ExtCore.TokenIdentifier.isPrincipal(request.token, config.canister) == false) {
        return #err(#InvalidToken(request.token));
      };
      let token = ExtCore.TokenIdentifier.getIndex(request.token);

      if (_isLocked(token)) {
        return #err(#Other("Listing is locked"));
      };

      if (not validFrontendIndentifier(request.frontendIdentifier)) {
        return #err(#Other("Unknown frontend identifier"));
      };

      switch (_tokenSettlement.get(token)) {
        case (?settlement) {
          let resp : Result.Result<(), Types.CommonError> = await* settle(caller, request.token);
          switch (resp) {
            case (#ok) {
              return #err(#Other("Listing is sold"));
            };
            case (#err _) {};
          };
        };
        case (_) {};
      };

      let owner = AID.fromPrincipal(caller, request.from_subaccount);
      switch (deps._Tokens.getOwnerFromRegistry(token)) {
        case (?token_owner) {
          if (AID.equal(owner, token_owner) == false) {
            return #err(#Other("Not authorized"));
          };
          switch (request.price) {
            case (?price) {
              if (price < 1_000_000) {
                return #err(#Other("Price too low. Minimum price is 0.01 ICP "));
              };
              _tokenListing.put(
                token,
                {
                  seller = caller;
                  price = price;
                  locked = null;
                  sellerFrontend = request.frontendIdentifier;
                  buyerFrontend = null;
                },
              );
            };
            case (_) {
              _tokenListing.delete(token);
            };
          };
          if (Option.isSome(_tokenSettlement.get(token))) {
            _tokenSettlement.delete(token);
          };
          return #ok;
        };
        case (_) {
          return #err(#InvalidToken(request.token));
        };
      };
    };

    public func details(token : Types.TokenIdentifier) : Result.Result<(Types.AccountIdentifier, ?Types.Listing), Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(token, config.canister) == false) {
        return #err(#InvalidToken(token));
      };
      let tokenind = ExtCore.TokenIdentifier.getIndex(token);
      switch (deps._Tokens.getBearer(tokenind)) {
        case (?token_owner) {
          return #ok((token_owner, _tokenListing.get(tokenind)));
        };
        case (_) {
          return #err(#InvalidToken(token));
        };
      };
    };

    public func transactions() : [Types.TransactionV2] {
      Buffer.toArray(_transactions);
    };

    public func settlements() : [(Types.TokenIndex, Types.AccountIdentifier, Nat64)] {
      //Lock to admin?
      var result : Buffer.Buffer<(Types.TokenIndex, Types.AccountIdentifier, Nat64)> = Buffer.Buffer(0);
      for ((token, listing) in _tokenListing.entries()) {
        if (_isLocked(token)) {
          switch (_tokenSettlement.get(token)) {
            case (?settlement) {
              result.add((token, AID.fromPrincipal(config.canister, ?settlement.subaccount), settlement.price));
            };
            case (_) {};
          };
        };
      };
      Buffer.toArray(result);
    };

    public func listings() : [(Types.TokenIndex, Types.Listing, Types.Metadata)] {
      var results : Buffer.Buffer<(Types.TokenIndex, Types.Listing, Types.Metadata)> = Buffer.Buffer(0);
      for (a in _tokenListing.entries()) {
        results.add((a.0, a.1, #nonfungible({ metadata = null })));
      };
      Buffer.toArray(results);
    };

    public func allSettlements() : [(Types.TokenIndex, Types.Settlement)] {
      Iter.toArray(_tokenSettlement.entries());
    };

    public func stats() : (Nat64, Nat64, Nat64, Nat64, Nat, Nat, Nat) {
      var res : (Nat64, Nat64, Nat64) = Array.foldLeft<Types.TransactionV2, (Nat64, Nat64, Nat64)>(
        Buffer.toArray(_transactions),
        (0, 0, 0),
        func(b : (Nat64, Nat64, Nat64), a : Types.TransactionV2) : (Nat64, Nat64, Nat64) {
          var total : Nat64 = b.0 + a.price;
          var high : Nat64 = b.1;
          var low : Nat64 = b.2;
          if (high == 0 or a.price > high) high := a.price;
          if (low == 0 or a.price < low) low := a.price;
          (total, high, low);
        },
      );
      var floor : Nat64 = 0;
      for (a in _tokenListing.entries()) {
        if (floor == 0 or a.1.price < floor) floor := a.1.price;
      };
      (res.0, res.1, res.2, floor, _tokenListing.size(), deps._Tokens.registrySize(), _transactions.size());
    };

    public func cronSettlements(caller : Principal) : async* () {
      // only failed settlments are settled here
      //  even though the result is ignored, if settle traps the catch block is executed
      // it doesn't matter if this is executed multiple times on the same settlement, `settle` checks if it's already settled
      label settleLoop while (true) {
        switch (unlockedSettlements().keys().next()) {
          case (?tokenindex) {
            try {
              ignore (await* settle(caller, ExtCore.TokenIdentifier.fromPrincipal(config.canister, tokenindex)));
            } catch (e) {
              break settleLoop;
            };
          };
          case null break settleLoop;
        };
      };
    };

    public func pendingCronJobs() : Nat {
      unlockedSettlements().size(); // those are the settlements that exceeded their 2 min lock time
    };

    public func toAccountIdentifier(p : Text, sa : Nat) : Types.AccountIdentifier {
      AID.fromPrincipal(Principal.fromText(p), ?Utils.natToSubAccount(sa));
    };

    public func frontends() : [(Text, Types.Frontend)] {
      Array.map<(Text, Types.AccountIdentifier, Nat64), (Text, Types.Frontend)>(config.marketplaces, func((id, accountIdentifier, fee)) {
        (id, { accountIdentifier; fee; });
      });
    };

    /********************
    * INTERNAL METHODS *
    ********************/

    func getFrontend(identifierOpt : ?Text) : Types.Frontend {
      let identifier = Option.get(identifierOpt, config.marketplaces[0].0);

      for (marketplace in config.marketplaces.vals()) {
        if (marketplace.0 == identifier) {
          return { accountIdentifier = marketplace.1; fee = marketplace.2; };
        };
      };

      return {
        accountIdentifier = config.marketplaces[0].1;
        fee = config.marketplaces[0].2;
      };
    };

    func validFrontendIndentifier(frontendIdentifier : ?Text) : Bool {
      switch (frontendIdentifier) {
        case (?identifier) {
          for (marketplace in config.marketplaces.vals()) {
            if (marketplace.0 == identifier) {
              return true;
            };
          };
          return false;
        };
        case (null) {};
      };
      true;
    };

    // getters & setters
    public func transactionsSize() : Nat {
      _transactions.size();
    };

    public func getTransactions() : Buffer.Buffer<Types.TransactionV2> {
      return _transactions;
    };

    public func tokenListingSize() : Nat {
      return _tokenListing.size();
    };

    public func getListingFromTokenListing(token : Types.TokenIndex) : ?Types.Listing {
      return _tokenListing.get(token);
    };

    // private methods
    func _isLocked(token : Types.TokenIndex) : Bool {
      switch (_tokenListing.get(token)) {
        case (?listing) {
          switch (listing.locked) {
            case (?time) {
              if (time > Time.now()) {
                return true;
              } else {
                return false;
              };
            };
            case (_) {
              return false;
            };
          };
        };
        case (_) return false;
      };
    };

    func unlockedSettlements() : TrieMap.TrieMap<Types.TokenIndex, Types.Settlement> {
      TrieMap.mapFilter<Types.TokenIndex, Types.Settlement, Types.Settlement>(
        _tokenSettlement,
        ExtCore.TokenIndex.equal,
        ExtCore.TokenIndex.hash,
        func(a : (Types.TokenIndex, Types.Settlement)) : ?Types.Settlement {
          if (_isLocked(a.0)) {
            null;
          } else {
            ?a.1;
          };
        },
      );
    };
  };
};
