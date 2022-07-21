import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Root "mo:cap/Root";

import AID "../toniq-labs/util/AccountIdentifier";
import Buffer "../Buffer";
import Types "Types";
import Utils "../Utils";

module {
  public class Factory (this : Principal, state : Types.State, deps : Types.Dependencies, consts : Types.Constants) {

/*********
* STATE *
*********/

    private var _saleTransactions: Buffer.Buffer<Types.SaleTransaction> = Utils.bufferFromArray<Types.SaleTransaction>(state._saleTransactionsState);
    private var _salesSettlements : HashMap.HashMap<Types.AccountIdentifier, Types.Sale> = HashMap.fromIter(state._salesSettlementsState.vals(), 0, AID.equal, AID.hash);
    private var _failedSales : Buffer.Buffer<(Types.AccountIdentifier, Types.SubAccount)> = Utils.bufferFromArray<(Types.AccountIdentifier, Types.SubAccount)>(state._failedSalesState);
    private var _tokensForSale: Buffer.Buffer<Types.TokenIndex> = Utils.bufferFromArray<Types.TokenIndex>(state._tokensForSaleState);
    private var _whitelist : Buffer.Buffer<Types.AccountIdentifier> = Utils.bufferFromArray<Types.AccountIdentifier>(state._whitelistState);
    private var _soldIcp : Nat64 = state._soldIcpState;

    public func toStable() : {
      _saleTransactionsState : [Types.SaleTransaction];
      _salesSettlementsState : [(Types.AccountIdentifier, Types.Sale)];
      _failedSalesState : [(Types.AccountIdentifier, Types.SubAccount)];
      _tokensForSaleState : [Types.TokenIndex];
      _whitelistState : [Types.AccountIdentifier];
      _soldIcpState : Nat64;
    } {
      return {
        _saleTransactionsState = _saleTransactions.toArray();
        _salesSettlementsState = Iter.toArray(_salesSettlements.entries());
        _failedSalesState = _failedSales.toArray();
        _tokensForSaleState = _tokensForSale.toArray();
        _whitelistState = _whitelist.toArray();
        _soldIcpState = _soldIcp;
      }
    };


/*************
* CONSTANTS *
*************/

    let price : Nat64 = 500000000;
    let whitelistprice : Nat64 = 300000000;
    let saleStart : Time.Time = 1642906800000000000;
    let whitelistEnd : Time.Time = 1642950000000000000;

/********************
* PUBLIC INTERFACE *
********************/

    // updates
    public func initMint(caller : Principal) : () {
      assert(caller == deps._Tokens.getMinter() and deps._Tokens.getNextTokenId() == 0);
      //Mint
      while(deps._Tokens.getNextTokenId() < 2009) {
        deps._Tokens.putTokenMetadata(deps._Tokens.getNextTokenId(), #nonfungible({
          // we start with asset 1, as index 0
          // contains the seed animation and is not being shuffled
          metadata = ?Utils.nat32ToBlob(deps._Tokens.getNextTokenId()+1);
        }));
        deps._Tokens.transferTokenToUser(deps._Tokens.getNextTokenId(), "0000");
        deps._Tokens.incrementSupply();
        deps._Tokens.incrementNextTokenId();
      };
      //Whitelist
      let whitelist_adresses = ["7ada07a0a64bff17b8e057b0d51a21e376c76607a16da88cd3f75656bc6b5b0b"];
      setWhitelist(whitelist_adresses);
      //Airdrop
      var airdrop : [(Types.AccountIdentifier, Types.TokenIndex)] = [("05bf8280738163ef12ecb600f8a0e889738fb2808f7154b45107633c00116c18", 737)];
      for(a in airdrop.vals()){
          deps._Tokens.transferTokenToUser(a.1, a.0);
      };
      //For sale
      setTokensForSale([1913,455,210,772,2008]);
    };

    public func reserve(amount : Nat64, quantity : Nat64, address : Types.AccountIdentifier, subaccount : Types.SubAccount) : Result.Result<(Types.AccountIdentifier, Nat64), Text> {
      var c : Nat = 0;
      var failed : Bool = true;
      while(c < 29) {
        if (failed) {
          if (subaccount[c] > 0) { 
            failed := false;
          };
        };
        c += 1;
      };
      if (failed) {
        return #err("Invalid subaccount");
      };
      var _wlr : Bool = false;
      if (Time.now() < saleStart) {
        return #err("The sale has not started yet");
      };
      if (quantity != 1) {
        return #err("Quantity error!");
      };
      if (Time.now() >= whitelistEnd) {
        if (_tokensForSale.size() == 0) {
          return #err("No more NFTs available right now!");
        };
      } else {
        if (isWhitelisted(address)) {
          _wlr := true;
        } else {
          return #err("No more NFTs available right now for non whitelisted users. These will become available soon!");
        };
      };
      var total : Nat64 = (price * quantity);
      if (_wlr == true) {
        total := whitelistprice;
      };
      if (total > amount) {
        return #err("Price mismatch!");
      };

      let paymentAddress : Types.AccountIdentifier = AID.fromPrincipal(Principal.fromText("jdfjg-amcja-wo3zr-6li5k-o4e5f-ymqfk-f4xk2-37o3d-2mezb-45y3t-5qe"), ?subaccount);
      if (Option.isSome(deps._Marketplace.findUsedPaymentAddress(paymentAddress))) {
        return #err("Payment address has been used");
      };

      let tokens : [Types.TokenIndex] = nextTokens(quantity);
      if (tokens.size() == 0) {
        return #err("Not enough NFTs available!");
      };
      if (tokens.size() != Nat64.toNat(quantity)) {
        _tokensForSale.append(Utils.bufferFromArray(tokens));
        return #err("Quantity error");
      };
      if (_wlr == true) {
        removeFromWhitelist(address);
      };
      
      deps._Marketplace.addUsedPaymentAddress(paymentAddress, Principal.fromText("jdfjg-amcja-wo3zr-6li5k-o4e5f-ymqfk-f4xk2-37o3d-2mezb-45y3t-5qe"), subaccount);
      _salesSettlements.put(paymentAddress, {
        tokens = tokens;
        price = total;
        subaccount = subaccount;
        buyer = address;
        expires = (Time.now() + consts.ESCROWDELAY);
      });
      #ok((paymentAddress, total));
    };

    public func retreive(caller : Principal, paymentaddress : Types.AccountIdentifier) : async Result.Result<(), Text> {
      switch(_salesSettlements.get(paymentaddress)) {
        case(?settlement){
          let response : Types.ICPTs = await consts.LEDGER_CANISTER.account_balance_dfx({account = paymentaddress});
          switch(_salesSettlements.get(paymentaddress)) {
            case(?settlement){
              if (response.e8s >= settlement.price){
                deps._Marketplace.putPayments(Principal.fromText("jdfjg-amcja-wo3zr-6li5k-o4e5f-ymqfk-f4xk2-37o3d-2mezb-45y3t-5qe"), switch(deps._Marketplace.getPayments(Principal.fromText("jdfjg-amcja-wo3zr-6li5k-o4e5f-ymqfk-f4xk2-37o3d-2mezb-45y3t-5qe"))) {
                  case(?p) { p.add(settlement.subaccount); p};
                  case(_) Utils.bufferFromArray<Types.SubAccount>([settlement.subaccount]);
                });
                for (a in settlement.tokens.vals()){
                  deps._Tokens.transferTokenToUser(a, settlement.buyer);
                };
                _saleTransactions.add({
                  tokens = settlement.tokens;
                  seller = Principal.fromText("jdfjg-amcja-wo3zr-6li5k-o4e5f-ymqfk-f4xk2-37o3d-2mezb-45y3t-5qe");
                  price = settlement.price;
                  buyer = settlement.buyer;
                  time = Time.now();
                });
                _soldIcp += settlement.price;
                _salesSettlements.delete(paymentaddress);
                // start custom
                let event : Root.IndefiniteEvent = {
                  operation = "mint";
                  details = [
                    ("to", #Text(settlement.buyer)),
                    ("price_decimals", #U64(8)),
                    ("price_currency", #Text("ICP")),
                    ("price", #U64(settlement.price)),
                    // there can only be one token in tokens due to the reserve function
                    ("token_id", #Text(Utils.indexToIdentifier(settlement.tokens[0], this))),
                    ];
                  caller;
                };
                ignore deps._Cap.insert(event);
                // end custom
                return #ok();
              } else {
                if (settlement.expires < Time.now()) {
                  _failedSales.add((settlement.buyer, settlement.subaccount));
                  _tokensForSale.append(Utils.bufferFromArray(settlement.tokens));
                  _salesSettlements.delete(paymentaddress);
                  if (settlement.price == whitelistprice) {
                    addToWhitelist(settlement.buyer);
                  };
                  return #err("Expired");
                } else {
                  return #err("Insufficient funds sent");
                }
              };
            };
            case(_) return #err("Nothing to settle");
          };
        };
        case(_) return #err("Nothing to settle");
      };
    };

    // queries
    public func salesSettlements() : [(Types.AccountIdentifier, Types.Sale)] {
      Iter.toArray(_salesSettlements.entries());
    };

    public func failedSales() : [(Types.AccountIdentifier, Types.SubAccount)] {
      _failedSales.toArray();
    };

    public func saleTransactions() : [Types.SaleTransaction] {
      _saleTransactions.toArray();
    };

    public func salesStats(address : Types.AccountIdentifier) : (Time.Time, Nat64, Nat) {
      if (Time.now() >= whitelistEnd) {
        (saleStart, price, _tokensForSale.size());
      } else {
        if (isWhitelisted(address)) {
          (saleStart, whitelistprice, _tokensForSale.size());        
        } else {
          (saleStart, price, _tokensForSale.size());        
        };
      };
    };

/*******************
* INTERNAL METHODS *
*******************/

    public func setWhitelist(whitelistAddresses: [Types.AccountIdentifier]) {
      _whitelist := Utils.bufferFromArray<Types.AccountIdentifier>(whitelistAddresses);
    };

    public func setTokensForSale(tokensForSale: [Types.TokenIndex]) {
      _tokensForSale := Utils.bufferFromArray<Types.TokenIndex>(tokensForSale);
    };

    func nextTokens(qty : Nat64) : [Types.TokenIndex] {
      if (_tokensForSale.size() >= Nat64.toNat(qty)) {
        let ret : Buffer.Buffer<Types.TokenIndex> = Buffer.Buffer(Nat64.toNat(qty));
        while(ret.size() < Nat64.toNat(qty)) {        
          var token : Types.TokenIndex = _tokensForSale.get(0);
          _tokensForSale := _tokensForSale.filter(func(x : Types.TokenIndex) : Bool { x != token } );
          ret.add(token);
        };
        ret.toArray();
      } else {
        [];
      }
    };

    func isWhitelisted(address : Types.AccountIdentifier) : Bool {
      Option.isSome(_whitelist.find(func (a : Types.AccountIdentifier) : Bool { a == address }));
    };

    func removeFromWhitelist(address : Types.AccountIdentifier) : () {
      var found : Bool = false;
      _whitelist := _whitelist.filter(func (a : Types.AccountIdentifier) : Bool { 
        if (found) { 
          return true; 
        } else { 
          if (a != address) return true;
          found := true;
          return false;
        } 
      });
    };

    func addToWhitelist(address : Types.AccountIdentifier) : () {
      _whitelist.add(address);
    };
  }
}