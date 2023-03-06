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

import AID "../toniq-labs/util/AccountIdentifier";
import Env "../Env";
import ExtCore "../toniq-labs/ext/Core";
import Types "types";
import Utils "../utils";

module {
  public class Factory(this : Principal, deps : Types.Dependencies, consts : Types.Constants) {

    /*********
    * STATE *
    *********/

    var _transactions : Buffer.Buffer<Types.Transaction> = Buffer.Buffer(0);
    var _tokenSettlement : TrieMap.TrieMap<Types.TokenIndex, Types.Settlement> = TrieMap.TrieMap(ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    var _tokenListing : TrieMap.TrieMap<Types.TokenIndex, Types.Listing> = TrieMap.TrieMap(ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    var _frontends : TrieMap.TrieMap<Text, Types.Frontend> = TrieMap.TrieMap(Text.equal, Text.hash);

    public func getChunkCount(chunkSize : Nat) : Nat {
      var count = _transactions.size() / chunkSize;
      if (_transactions.size() % chunkSize != 0) {
        count += 1;
      };
      count;
    };

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      let start = chunkSize * chunkIndex;
      let transactionChunk = Buffer.toArray(Buffer.subBuffer(_transactions, start, Nat.min(chunkSize, _transactions.size() - start)));

      if (chunkIndex == 0) {
        return ?#v1({
          transactionCount = _transactions.size();
          transactionChunk;
          tokenSettlement = Iter.toArray(_tokenSettlement.entries());
          tokenListing = Iter.toArray(_tokenListing.entries());
          frontends = Iter.toArray(_frontends.entries());
        });
      }
      else if (chunkIndex <= getChunkCount(chunkSize)) {
        return ?#v1_chunk({ transactionChunk });
      }
      else {
        null;
      };
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        // TODO: remove after upgrade vvv
        case (?#legacy(state)) {
          _transactions := Buffer.fromArray(state._transactionsState);
          _tokenSettlement := TrieMap.fromEntries(state._tokenSettlementState.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _tokenListing := TrieMap.fromEntries(state._tokenListingState.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _frontends := TrieMap.fromEntries(state._frontendsState.vals(), Text.equal, Text.hash);
        };
        // TODO: remove after upgrade ^^^
        case (?#v1(data)) {
          _transactions := Buffer.Buffer<Types.Transaction>(data.transactionCount);
          _transactions.append(Buffer.fromArray(data.transactionChunk));
          _tokenSettlement := TrieMap.fromEntries(data.tokenSettlement.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _tokenListing := TrieMap.fromEntries(data.tokenListing.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _frontends := TrieMap.fromEntries(data.frontends.vals(), Text.equal, Text.hash);
        };
        case (?#v1_chunk(data)) {
          _transactions.append(Buffer.fromArray(data.transactionChunk));
        };
        case (null) {};
      };
    };

    /********************
    * PUBLIC INTERFACE *
    ********************/

    public func lock(caller : Principal, tokenid : Types.TokenIdentifier, price : Nat64, address : Types.AccountIdentifier, _subaccountNOTUSED : Types.SubAccount, frontendIdentifier : ?Text) : async Result.Result<Types.AccountIdentifier, Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(tokenid, this) == false) {
        return #err(#InvalidToken(tokenid));
      };

      let token = ExtCore.TokenIdentifier.getIndex(tokenid);

      if (_isLocked(token)) {
        return #err(#Other("Listing is locked"));
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
      let paymentAddress : Types.AccountIdentifier = AID.fromPrincipal(this, ?subaccount);
      _tokenListing.put(
        token,
        {
          seller = listing.seller;
          price = listing.price;
          locked = ?(Time.now() + Env.escrowDelay);
          sellerFrontend = listing.sellerFrontend;
          buyerFrontend = frontendIdentifier;
        },
      );

      // check if there is a previous settlement that has never been settled
      switch (_tokenSettlement.get(token)) {
        case (?settlement) {
          let resp : Result.Result<(), Types.CommonError> = await settle(caller, tokenid);
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

    public func settle(caller : Principal, tokenid : Types.TokenIdentifier) : async Result.Result<(), Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(tokenid, this) == false) {
        return #err(#InvalidToken(tokenid));
      };
      let token : Types.TokenIndex = ExtCore.TokenIdentifier.getIndex(tokenid);

      var settlement = switch (_tokenSettlement.get(token)) {
        case (?settlement) { settlement };
        case (null) {
          return #err(#Other("Nothing to settle"));
        };
      };

      let response = await consts.LEDGER_CANISTER.account_balance({
        account = addHash(fromPrincipal(this, ?settlement.subaccount));
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
      let bal : Nat64 = response.e8s - (10000 * Nat64.fromNat(Env.royalties.size() + 3));
      var rem = bal;

      // disbursement of royalties
      for (f in Env.royalties.vals()) {
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
      });
      _tokenListing.delete(token);
      _tokenSettlement.delete(token);

      return #ok();
    };

    public func list(caller : Principal, request : Types.ListRequest) : async Result.Result<(), Types.CommonError> {
      // marketplace is open either when marketDelay has passed or collection sold out
      if (Time.now() < Env.publicSaleStart + Env.marketDelay) {
        if (deps._Sale.getSold() < deps._Sale.getTotalToSell()) {
          return #err(#Other("You can not list yet"));
        };
      };
      if (ExtCore.TokenIdentifier.isPrincipal(request.token, this) == false) {
        return #err(#InvalidToken(request.token));
      };
      let token = ExtCore.TokenIdentifier.getIndex(request.token);

      if (_isLocked(token)) {
        return #err(#Other("Listing is locked"));
      };

      switch (_tokenSettlement.get(token)) {
        case (?settlement) {
          let resp : Result.Result<(), Types.CommonError> = await settle(caller, request.token);
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
      if (ExtCore.TokenIdentifier.isPrincipal(token, this) == false) {
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

    public func transactions() : [Types.Transaction] {
      Buffer.toArray(_transactions);
    };

    public func settlements() : [(Types.TokenIndex, Types.AccountIdentifier, Nat64)] {
      //Lock to admin?
      var result : Buffer.Buffer<(Types.TokenIndex, Types.AccountIdentifier, Nat64)> = Buffer.Buffer(0);
      for ((token, listing) in _tokenListing.entries()) {
        if (_isLocked(token)) {
          switch (_tokenSettlement.get(token)) {
            case (?settlement) {
              result.add((token, AID.fromPrincipal(this, ?settlement.subaccount), settlement.price));
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
      var res : (Nat64, Nat64, Nat64) = Array.foldLeft<Types.Transaction, (Nat64, Nat64, Nat64)>(
        Buffer.toArray(_transactions),
        (0, 0, 0),
        func(b : (Nat64, Nat64, Nat64), a : Types.Transaction) : (Nat64, Nat64, Nat64) {
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

    public func cronSettlements(caller : Principal) : async () {
      // only failed settlments are settled here
      //  even though the result is ignored, if settle traps the catch block is executed
      // it doesn't matter if this is executed multiple times on the same settlement, `settle` checks if it's already settled
      label settleLoop while (true) {
        switch (unlockedSettlements().keys().next()) {
          case (?tokenindex) {
            try {
              ignore (await settle(caller, ExtCore.TokenIdentifier.fromPrincipal(this, tokenindex)));
            } catch (e) {};
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

    public func putFrontend(caller : Principal, identifier : Text, frontend : Types.Frontend) {
      assert (caller == consts.minter);
      assert (validFrontendFee(frontend));
      _frontends.put(identifier, frontend);
    };

    public func deleteFrontend(caller : Principal, identifier : Text) {
      assert (caller == consts.minter);
      _frontends.delete(identifier);
    };

    public func frontends() : [(Text, Types.Frontend)] {
      Iter.toArray(_frontends.entries());
    };

    /********************
    * INTERNAL METHODS *
    ********************/

    func validFrontendFee(frontend : Types.Frontend) : Bool {
      frontend.fee <= 500 and frontend.fee >= 0
    };

    func getFrontend(identifier : ?Text) : Types.Frontend {
      let defaultFrontend : Types.Frontend = {
        fee = Env.defaultMarketplaceFee.1;
        accountIdentifier = Env.defaultMarketplaceFee.0;
      };

      // disbursement of marketplace fee
      let frontend : Types.Frontend = switch (
        do ? {
          switch (_frontends.get(identifier!)) {
            case (?frontend) frontend;
            case _ defaultFrontend;
          };
        },
      ) {
        case (?frontend) { frontend };
        case _ defaultFrontend;
      };
    };

    // getters & setters
    public func transactionsSize() : Nat {
      _transactions.size();
    };

    public func getTransactions() : Buffer.Buffer<Types.Transaction> {
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
