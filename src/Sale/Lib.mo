import AID "../toniq-labs/util/AccountIdentifier";
import Buffer "../Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat16";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Root "mo:cap/Root";
import Time "mo:base/Time";
import Types "Types";
import Utils "../Utils";

module {
  public class Factory (this : Principal, state : Types.State, deps : Types.Dependencies, consts : Types.Constants) {

/*********
* STATE *
*********/

    private var _saleTransactions: Buffer.Buffer<Types.SaleTransaction> = Utils.bufferFromArray<Types.SaleTransaction>(state._saleTransactionsState);
    private var _salesSettlements : HashMap.HashMap<Types.AccountIdentifier, Types.Sale> = HashMap.fromIter(state._salesSettlementsState.vals(), 0, AID.equal, AID.hash);
    private var _salesPrincipals : HashMap.HashMap<Types.AccountIdentifier, Text> = HashMap.fromIter(state._salesPrincipalsState.vals(), 0, AID.equal, AID.hash);
    private var _failedSales : Buffer.Buffer<(Types.AccountIdentifier, Types.SubAccount)> = Utils.bufferFromArray<(Types.AccountIdentifier, Types.SubAccount)>(state._failedSalesState);
    private var _tokensForSale: Buffer.Buffer<Types.TokenIndex> = Utils.bufferFromArray<Types.TokenIndex>(state._tokensForSaleState);
    private var _whitelist : Buffer.Buffer<Types.AccountIdentifier> = Utils.bufferFromArray<Types.AccountIdentifier>(state._whitelistState);
    private var _soldIcp : Nat64 = state._soldIcpState;
    private var _sold : Nat = state._soldState;
    private var _totalToSell : Nat = state._totalToSellState;
    private var _hasBeenInitiated : Bool = state._hasBeenInitiatedState;

    public func toStable() : {
      saleTransactionsState : [Types.SaleTransaction];
      salesSettlementsState : [(Types.AccountIdentifier, Types.Sale)];
      salesPrincipalsState : [(Types.AccountIdentifier, Text)]; 
      failedSalesState : [(Types.AccountIdentifier, Types.SubAccount)];
      tokensForSaleState : [Types.TokenIndex];
      whitelistState : [Types.AccountIdentifier];
      soldIcpState : Nat64;
      soldState : Nat;
      totalToSellState : Nat;
      hasBeenInitiatedState : Bool;
    } {
      return {
        saleTransactionsState = _saleTransactions.toArray();
        salesSettlementsState = Iter.toArray(_salesSettlements.entries());
        salesPrincipalsState = Iter.toArray(_salesPrincipals.entries());
        failedSalesState = _failedSales.toArray();
        tokensForSaleState = _tokensForSale.toArray();
        whitelistState = _whitelist.toArray();
        soldIcpState = _soldIcp;
        soldState = _sold;
        totalToSellState = _totalToSell;
        hasBeenInitiatedState = _hasBeenInitiated;
      }
    };


/*************
* CONSTANTS *
*************/

    let teamRoyaltyAddress : Types.AccountIdentifier = consts.TEAM_ADDRESS;
    let collectionSize : Nat32 = 7777;
    // prices
    // let ethFlowerWhitelistPrice : Nat64 =   350000000;
    // let modclubWhitelistPrice : Nat64 =     500000000;
    let whitelistPrice : Nat64 =            500000000;
    let salePrice : Nat64 =                 700000000;

    let publicSaleStart : Time.Time = 1659276000000000000; //Start of first purchase (WL or other)
    let whitelistTime : Time.Time = 1659362400000000000; //Period for WL only discount. Set to publicSaleStart for no exclusive period
    var marketDelay : Time.Time = 2 * 24 * 60 * 60 * 1_000_000_000; //How long to delay market opening
    var whitelistOneTimeOnly : Bool = true; //Whitelist addresses are removed after purchase
    var whitelistDiscountLimited : Bool = true; //If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored
    //Whitelist
     let whitelistAdresses : [Types.AccountIdentifier]= ["7ada07a0a64bff17b8e057b0d51a21e376c76607a16da88cd3f75656bc6b5b0b"];
    var whitelistLimit : Nat = 1; // how many NFTs per whitelist spot

    //Airdrop (only addresses, no token index anymore)
      var airdrop : [Types.AccountIdentifier] = [];

/********************
* PUBLIC INTERFACE *
********************/

    // updates
    public func initMint(caller : Principal) : async () {
      assert(caller == deps._Tokens.getMinter() and deps._Tokens.getNextTokenId() == 0);
      //Mint
      mintCollection(collectionSize);
      // turn whitelist into buffer for better performance
      setWhitelist(whitelistAdresses);
      // get initial token indices
      _tokensForSale := 
        switch(deps._Tokens.getTokensFromOwner("0000")){ 
          case(?t) t; 
          case(_) Buffer.Buffer<Types.TokenIndex>(0)
        }; 
      // shuffle indices
      let seed: Blob = await Random.blob();
      _tokensForSale := deps._Shuffle.shuffleTokens(_tokensForSale, seed);
      // airdrop tokens
      for(a in airdrop.vals()){
        // nextTokens() updates _tokensForSale, removing consumed tokens
        deps._Tokens.transferTokenToUser(nextTokens(1)[0], a);
      };
      _totalToSell := _tokensForSale.size();
      _hasBeenInitiated := true;
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

    public func salesSettings(address : Types.AccountIdentifier) : Types.SaleSettings {
      return {
        price = getAddressPrice(address);
        salePrice = salePrice;
        remaining = availableTokens();
        sold = _sold;
        startTime = publicSaleStart;
        whitelistTime = whitelistTime;
        whitelist = isWhitelisted(address);
        totalToSell = _totalToSell;
        bulkPricing = getAddressBulkPrice(address);
      } : Types.SaleSettings;
    };

/*******************
* INTERNAL METHODS *
*******************/

    func tempNextTokens(qty : Nat64) : Buffer.Buffer<Types.TokenIndex> {
      //Custom: not pre-mint
      var ret : Buffer.Buffer<Types.TokenIndex> = Buffer.Buffer(Nat64.toNat(qty));
      while(ret.size() < Nat64.toNat(qty)) {        
        ret.add(0 );
      };
      ret;
    };

    func getAddressPrice(address : Types.AccountIdentifier) : Nat64 {
      getAddressBulkPrice(address)[0].1;
    };

    func availableTokens() : Nat {
      _tokensForSale.size();
    };

    //Set different price types here
    func getAddressBulkPrice(address : Types.AccountIdentifier) : [(Nat64, Nat64)] {
      if (isWhitelisted(address)){
        return [(1, whitelistPrice)]
      };
      return [(1, salePrice)]
    };

    public func setWhitelist(whitelistAddresses: [Types.AccountIdentifier]) {
      _whitelist := Utils.bufferFromArray<Types.AccountIdentifier>(whitelistAddresses);
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
    if (whitelistDiscountLimited == true and Time.now() >= whitelistTime) {
      return false;
    };
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

    func mintCollection(collectionSize : Nat32) {
      while(deps._Tokens.getNextTokenId() < collectionSize) {
        deps._Tokens.putTokenMetadata(deps._Tokens.getNextTokenId(), #nonfungible({
          // we start with asset 1, as index 0
          // contains the seed animation and is not being shuffled
          metadata = ?Utils.nat32ToBlob(deps._Tokens.getNextTokenId()+1);
        }));
        deps._Tokens.transferTokenToUser(deps._Tokens.getNextTokenId(), "0000");
        deps._Tokens.incrementSupply();
        deps._Tokens.incrementNextTokenId();
      };
    }
  }
}