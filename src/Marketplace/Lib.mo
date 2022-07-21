import Array "mo:base/Array";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Encoding "mo:encoding/Binary";
import Root "mo:cap/Root";

import AID "../toniq-labs/util/AccountIdentifier";
import Buffer "../Buffer";
import ExtCore "../toniq-labs/Ext/Core";
import Types "Types";
import Utils "../Utils";

module {
  public class Factory(this: Principal, state : Types.State, deps : Types.Dependencies, consts : Types.Constants ) {
    
    /*********
    * STATE *
    *********/

    private var _transactions : Buffer.Buffer<Types.Transaction> = Utils.bufferFromArray(state._transactionsState);	
    private var _tokenSettlement : HashMap.HashMap<Types.TokenIndex, Types.Settlement> = HashMap.fromIter(state._tokenSettlementState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _payments : HashMap.HashMap<Principal, Buffer.Buffer<Types.SubAccount>> = Utils.BufferHashMapFromIter(state._paymentsState.vals(), 0, Principal.equal, Principal.hash);
    private var _tokenListing : HashMap.HashMap<Types.TokenIndex, Types.Listing> = HashMap.fromIter(state._tokenListingState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    private var _usedPaymentAddressess : Buffer.Buffer<(Types.AccountIdentifier, Principal, Types.SubAccount)> = Utils.bufferFromArray<(Types.AccountIdentifier, Principal, Types.SubAccount)>(state._usedPaymentAddressessState);
    private var _disbursements : List.List<(Types.TokenIndex, Types.AccountIdentifier, Types.SubAccount, Nat64)> = List.fromArray(state._disbursementsState);
    private var _nextSubAccount : Nat  = state._nextSubAccountState;
    
    public func toStable () : {
      _transactionsState : [Types.Transaction];
      _tokenSettlementState : [(Types.TokenIndex, Types.Settlement)];
      _usedPaymentAddressessState : [(Types.AccountIdentifier, Principal, Types.SubAccount)];
      _paymentsState : [(Principal, [Types.SubAccount])];
      _tokenListingState : [(Types.TokenIndex, Types.Listing)];
      _disbursementsState : [(Types.TokenIndex, Types.AccountIdentifier, Types.SubAccount, Nat64)];
      _nextSubAccountState : Nat
    } {
      return {
        _tokenSettlementState = Iter.toArray(_tokenSettlement.entries());
        _transactionsState = _transactions.toArray();
        _paymentsState = Iter.toArray(Iter.map<(Principal, Buffer.Buffer<Types.SubAccount>), (Principal, [Types.SubAccount])>(
          _payments.entries(), 
          func (payment) {
            return (payment.0, payment.1.toArray());
        }));
        _usedPaymentAddressessState = _usedPaymentAddressess.toArray();
        _tokenListingState = Iter.toArray(_tokenListing.entries());
        _disbursementsState = List.toArray(_disbursements);
        _nextSubAccountState = _nextSubAccount;
      }
    };
    
    /*************
    * CONSTANTS *
    *************/

    let salesFees : [(Types.AccountIdentifier, Nat64)] = [
      ("9dd5c70ada66e593cc5739c3177dc7a40530974f270607d142fc72fce91b1d25", 7500), //Royalty Fee 
      ("9dd5c70ada66e593cc5739c3177dc7a40530974f270607d142fc72fce91b1d25", 1000), //Entrepot Fee 
    ];


    /********************
    * PUBLIC INTERFACE *
    ********************/

    public func lock(caller : Principal, tokenid : Types.TokenIdentifier, price : Nat64, address : Types.AccountIdentifier, _subaccountNOTUSED : Types.SubAccount) : async Result.Result<Types.AccountIdentifier, Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(tokenid, this) == false) {
        return #err(#InvalidToken(tokenid));
      };
      let token = ExtCore.TokenIdentifier.getIndex(tokenid);
      if (_isLocked(token)) {					
        return #err(#Other("Listing is locked"));				
      };
      let subaccount = _getNextSubAccount();
      switch(_tokenListing.get(token)) {
        case (?listing) {
          if (listing.price != price) {
            return #err(#Other("Price has changed!"));
          } else {
            let paymentAddress : Types.AccountIdentifier = AID.fromPrincipal(this, ?subaccount);
            _tokenListing.put(token, {
              seller = listing.seller;
              price = listing.price;
              locked = ?(Time.now() + consts.ESCROWDELAY);
            });
            switch(_tokenSettlement.get(token)) {
              case(?settlement){
                let resp : Result.Result<(), Types.CommonError> = await settle(caller, tokenid);
                switch(resp) {
                  case(#ok) {
                    return #err(#Other("Listing has sold"));
                  };
                  case(#err _) {
                    //Atomic protection
                    if (Option.isNull(_tokenListing.get(token))) return #err(#Other("Listing has sold"));
                  };
                };
              };
              case(_){};
            };
            _tokenSettlement.put(token, {
              seller = listing.seller;
              price = listing.price;
              subaccount = subaccount;
              buyer = address;
            });
            return #ok(paymentAddress);
          };
        };
        case (_) {
          return #err(#Other("No listing!"));				
        };
      };
    };

    public func settle(caller : Principal, tokenid : Types.TokenIdentifier) : async Result.Result<(), Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(tokenid, this) == false) {
        return #err(#InvalidToken(tokenid));
      };
      let token = ExtCore.TokenIdentifier.getIndex(tokenid);
      switch(_tokenSettlement.get(token)) {
        case(?settlement){
          let response : Types.ICPTs = await consts.LEDGER_CANISTER.account_balance_dfx({account = AID.fromPrincipal(this, ?settlement.subaccount)});
          switch(_tokenSettlement.get(token)) {
            case(?settlement){
              if (response.e8s >= settlement.price){
                switch (deps._Tokens.getOwnerFromRegistry(token)) {
                  case (?token_owner) {
                    var bal : Nat64 = settlement.price - (10000 * Nat64.fromNat(salesFees.size() + 1));
                    var rem = bal;
                    for(f in salesFees.vals()){
                      var _fee : Nat64 = bal * f.1 / 100000;
                      _addDisbursement((token, f.0, settlement.subaccount, _fee));
                      rem := rem -  _fee : Nat64;
                    };
                    _addDisbursement((token, token_owner, settlement.subaccount, rem));
                    let event : Root.IndefiniteEvent = {
                      operation = "sale";
                      details = [
                        ("to", #Text(settlement.buyer)),
                        ("from", #Principal(settlement.seller)),
                        ("price_decimals", #U64(8)),
                        ("price_currency", #Text("ICP")),
                        ("price", #U64(settlement.price)),
                        ("token_id", #Text(tokenid))
                      ];
                      caller;
                    };
                    ignore deps._Cap.insert(event);
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
                  case (_) {
                    return #err(#InvalidToken(tokenid));
                  };
                };
              } else {
                if (_isLocked(token)) {					
                  return #err(#Other("Insufficient funds sent"));
                } else {
                  _tokenSettlement.delete(token);
                  return #err(#Other("Nothing to settle"));				
                };
              };
            };
            case(_) return #err(#Other("Nothing to settle"));
          };
        };
        case(_) return #err(#Other("Nothing to settle"));
      };
    };

    public func list(caller : Principal, request : Types.ListRequest) : async Result.Result<(), Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(request.token, this) == false) {
        return #err(#InvalidToken(request.token));
      };
      let token = ExtCore.TokenIdentifier.getIndex(request.token);
      if (_isLocked(token)) {					
        return #err(#Other("Listing is locked"));				
      };
      switch(_tokenSettlement.get(token)) {
        case(?settlement){
          let resp : Result.Result<(), Types.CommonError> = await settle(caller, request.token);
          switch(resp) {
            case(#ok) return #err(#Other("Listing as sold"));
            case(#err _) {};
          };
        };
        case(_){};
      };
      let owner = AID.fromPrincipal(caller, request.from_subaccount);
      switch (deps._Tokens.getOwnerFromRegistry(token)) {
        case (?token_owner) {
          if(AID.equal(owner, token_owner) == false) {
            return #err(#Other("Not authorized"));
          };
          switch(request.price) {
            case(?price) {
              _tokenListing.put(token, {
                seller = caller;
                price = price;
                locked = null;
              });
            };
            case(_) {
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

    public func clearPayments(seller : Principal, payments : [Types.SubAccount]) : async () {
      let removedPayments : Buffer.Buffer<Types.SubAccount> = Buffer.Buffer(0);
      for (p in payments.vals()){
        let response : Types.ICPTs = await consts.LEDGER_CANISTER.account_balance_dfx({account = AID.fromPrincipal(seller, ?p)});
        if (response.e8s < 10_000){
          removedPayments.add(p);
        };
      };
      switch(_payments.get(seller)) {
        case(?sellerPayments) {
          var newPayments : Buffer.Buffer<Types.SubAccount> = Buffer.Buffer(0);
          for (p in sellerPayments.vals()){
            if (Option.isNull(removedPayments.find(func(a : Types.SubAccount) : Bool {
              Array.equal(a, p, Nat8.equal);
            }))) {
              newPayments.add(p);
            };
          };
          _payments.put(seller, newPayments)
        };
        case(_){};
      };
    };

    public func disburse() : async () {
      var _cont : Bool = true;
      while(_cont){
        var last = List.pop(_disbursements);
        switch(last.0){
          case(?d) {
            _disbursements := last.1;
            try {
              var bh = await consts.LEDGER_CANISTER.send_dfx({
                memo = Encoding.BigEndian.toNat64(Blob.toArray(Principal.toBlob(Principal.fromText(ExtCore.TokenIdentifier.fromPrincipal(this, d.0)))));
                amount = { e8s = d.3 };
                fee = { e8s = 10000 };
                from_subaccount = ?d.2;
                to = d.1;
                created_at_time = null;
              });
            } catch (e) {
              _disbursements := List.push(d, _disbursements);
            };
          };
          case(_) {
            _cont := false;
          };
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
      _transactions.toArray();
    };

    public func settlements() : [(Types.TokenIndex, Types.AccountIdentifier, Nat64)] {
      //Lock to admin?
      var result : Buffer.Buffer<(Types.TokenIndex, Types.AccountIdentifier, Nat64)> = Buffer.Buffer(0);
      for((token, listing) in _tokenListing.entries()) {
        if(_isLocked(token)){
          switch(_tokenSettlement.get(token)) {
            case(?settlement) {
              result.add((token, AID.fromPrincipal(settlement.seller, ?settlement.subaccount), settlement.price));
            };
            case(_) {};
          };
        };
      };
      result.toArray();
    };

    public func payments(caller : Principal) : ?[Types.SubAccount] {
      let buffer = _payments.get(caller);
      switch (buffer) {
        case (?buffer) {?buffer.toArray()};
        case (_) {null};
      }
    };

    public func listings() : [(Types.TokenIndex, Types.Listing, Types.Metadata)] {
      var results : Buffer.Buffer<(Types.TokenIndex, Types.Listing, Types.Metadata)> = Buffer.Buffer(0);
      for(a in _tokenListing.entries()) {
        results.add((a.0, a.1, #nonfungible({ metadata = null })));
      };
      results.toArray();
    };

    public func allSettlements() : [(Types.TokenIndex, Types.Settlement)] {
      Iter.toArray(_tokenSettlement.entries())
    };

    public func allPayments() : [(Principal, [Types.SubAccount])] {
      let transformedPayments : Iter.Iter<(Principal, [Types.SubAccount])> = Iter.map<(Principal, Buffer.Buffer<Types.SubAccount>), (Principal, [Types.SubAccount])>(
        _payments.entries(), 
        func (payment) {
          return (payment.0, payment.1.toArray());
      });
      Iter.toArray(transformedPayments)
    };

    public func stats() : (Nat64, Nat64, Nat64, Nat64, Nat, Nat, Nat) {
      var res : (Nat64, Nat64, Nat64) = Array.foldLeft<Types.Transaction, (Nat64, Nat64, Nat64)>(_transactions.toArray(), (0,0,0), func (b : (Nat64, Nat64, Nat64), a : Types.Transaction) : (Nat64, Nat64, Nat64) {
        var total : Nat64 = b.0 + a.price;
        var high : Nat64 = b.1;
        var low : Nat64 = b.2;
        if (high == 0 or a.price > high) high := a.price; 
        if (low == 0 or a.price < low) low := a.price; 
        (total, high, low);
      });
      var floor : Nat64 = 0;
      for (a in _tokenListing.entries()){
        if (floor == 0 or a.1.price < floor) floor := a.1.price;
      };
      (res.0, res.1, res.2, floor, _tokenListing.size(), deps._Tokens.registrySize(), _transactions.size());
    };

    /***********************
    * GETTERS AND SETTERS *
    ***********************/
    
    public func transactionsSize () : Nat {
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

    public func putPayments(principal: Principal, payments: Buffer.Buffer<Types.SubAccount>) {
      return _payments.put(principal, payments);
    };

    public func getPayments(principal: Principal) : ?Buffer.Buffer<Types.SubAccount>{
      return _payments.get(principal);
    };

    public func findUsedPaymentAddress(paymentAddress : Types.AccountIdentifier) : ?(Types.AccountIdentifier, Principal, Types.SubAccount) {
      return _usedPaymentAddressess.find(
        func (a : (Types.AccountIdentifier, Principal, Types.SubAccount)) : Bool { 
          a.0 == paymentAddress
        }
      );
    };

    public func addUsedPaymentAddress(paymentAddress : Types.AccountIdentifier, principal: Principal, subaccount: Types.SubAccount) {
      _usedPaymentAddressess.add((paymentAddress, principal, subaccount));
    };

    func _isLocked(token : Types.TokenIndex) : Bool {
      switch(_tokenListing.get(token)) {
        case(?listing){
          switch(listing.locked) {
            case(?time) {
              if (time > Time.now()) {
                return true;
              } else {					
                return false;
              }
            };
            case(_) {
              return false;
            };
          };
        };
        case(_) return false;
      };
    };

    func _natToSubAccount(n : Nat) : Types.SubAccount {
      let n_byte = func(i : Nat) : Nat8 {
        assert(i < 32);
        let shift : Nat = 8 * (32 - 1 - i);
        Nat8.fromIntWrap(n / 2**shift)
      };
      Array.tabulate<Nat8>(32, n_byte)
    };

    func _getNextSubAccount() : Types.SubAccount {
      var _saOffset = 4294967296;
      _nextSubAccount += 1;
      return _natToSubAccount(_saOffset+_nextSubAccount);
    };

    func _addDisbursement(d : (Types.TokenIndex, Types.AccountIdentifier, Types.SubAccount, Nat64)) : () {
      _disbursements := List.push(d, _disbursements);
    };

  }
}