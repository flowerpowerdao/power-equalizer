import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import TrieMap "mo:base/TrieMap";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

import Encoding "mo:encoding/Binary";
import Root "mo:cap/Root";

import AID "../toniq-labs/util/AccountIdentifier";
import Env "../Env";
import ExtCore "../toniq-labs/ext/Core";
import Types "types";
import Utils "../utils";

module {
  public class Factory(this : Principal, state : Types.StableState, deps : Types.Dependencies, consts : Types.Constants) {

    /*********
    * STATE *
    *********/

    private var _transactions : Buffer.Buffer<Types.Transaction> = Utils.bufferFromArray(state._transactionsState);
    private var _tokenSettlement : TrieMap.TrieMap<Types.TokenIndex, Types.Settlement> = TrieMap.fromEntries(state._tokenSettlementState.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _tokenListing : TrieMap.TrieMap<Types.TokenIndex, Types.Listing> = TrieMap.fromEntries(state._tokenListingState.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);

    public func toStable() : Types.StableState {
      return {
        _transactionsState = Buffer.toArray(_transactions);
        _tokenSettlementState = Iter.toArray(_tokenSettlement.entries());
        _tokenListingState = Iter.toArray(_tokenListing.entries());
      };
    };

    // *** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    public func lock(caller : Principal, tokenid : Types.TokenIdentifier, price : Nat64, address : Types.AccountIdentifier, _subaccountNOTUSED : Types.SubAccount) : async Result.Result<Types.AccountIdentifier, Types.CommonError> {
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
          locked = ?(Time.now() + Env.ecscrowDelay);
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
              }
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

      let response : Types.ICPTs = await consts.LEDGER_CANISTER.account_balance_dfx({
        account = AID.fromPrincipal(this, ?settlement.subaccount);
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

      var bal : Nat64 = settlement.price - (10000 * Nat64.fromNat(Env.salesFees.size() + 1));
      var rem = bal;

      // disbursement of fees
      for (f in Env.salesFees.vals()) {
        var _fee : Nat64 = bal * f.1 / 100000;
        deps._Disburser.addDisbursement({
          to = f.0;
          fromSubaccount = settlement.subaccount;
          amount = _fee;
          tokenIndex = token;
        });
        rem := rem - _fee : Nat64;
      };

      // disbursement to the previous token owner
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
              _tokenListing.put(
                token,
                {
                  seller = caller;
                  price = price;
                  locked = null;
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

    public func toAddress(p : Text, sa : Nat) : Types.AccountIdentifier {
      AID.fromPrincipal(Principal.fromText(p), ?Utils.natToSubAccount(sa));
    };

    // *** ** ** ** ** ** ** ** ** * * INTERNAL METHODS * ** ** ** ** ** ** ** ** ** ** /

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
