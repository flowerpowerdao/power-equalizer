import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";
import Cap "mo:cap/Cap";

import Assets "CanisterAssets";
import AssetsTypes "CanisterAssets/types";
import Buffer "./Buffer";
import EXT "Ext";
import EXTTypes "Ext/types";
import ExtAllowance "./toniq-labs/ext/Allowance";
import ExtCommon "./toniq-labs/ext/Common";
import ExtCore "./toniq-labs/ext/Core";
import ExtNonFungible "./toniq-labs/ext/NonFungible";
import Http "Http";
import HttpTypes "Http/types";
import Marketplace "Marketplace";
import MarketplaceTypes "Marketplace/types";
import Sale "Sale";
import SaleTypes "Sale/types";
import Shuffle "Shuffle";
import TokenTypes "Tokens/types";
import Tokens "Tokens";
import Utils "./Utils";

shared ({ caller = init_minter}) actor class Canister(cid: Principal) = myCanister {

/*********
* TYPES *
*********/
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type SubAccount = ExtCore.SubAccount;
  type AccountBalanceArgs = { account : AccountIdentifier };
  type ICPTs = { e8s : Nat64 };
  type SendArgs = {
    memo: Nat64;
    amount: ICPTs;
    fee: ICPTs;
    from_subaccount: ?SubAccount;
    to: AccountIdentifier;
    created_at_time: ?Time.Time;
  };
  
  
/****************
* STABLE STATE *
****************/

 // Tokens
	private stable var _tokenMetadataState : [(TokenTypes.TokenIndex, TokenTypes.Metadata)] = [];
  private stable var _ownersState : [(AccountIdentifier, [TokenTypes.TokenIndex])] = [];
  private stable var _registryState : [(TokenTypes.TokenIndex, AccountIdentifier)] = [];
  private stable var _nextTokenIdState : TokenTypes.TokenIndex  = 0;
  private stable var _minterState : Principal  = init_minter;
  private stable var _supplyState : TokenTypes.Balance  = 0;

 // Sale
	private stable var _saleTransactionsState : [SaleTypes.SaleTransaction] = [];
  private stable var _salesSettlementsState : [(AccountIdentifier, SaleTypes.Sale)] = [];
  private stable var _failedSalesState : [(AccountIdentifier, TokenTypes.SubAccount)] = [];
  private stable var _tokensForSaleState : [TokenTypes.TokenIndex] = [];
  private stable var _ethFlowerWhitelistState : [AccountIdentifier] = [];
  private stable var _modclubWhitelistState : [AccountIdentifier] = [];
  private stable var _soldIcpState : Nat64 = 0;

 // Marketplace
	private stable var _transactionsState : [MarketplaceTypes.Transaction] = [];
	private stable var _tokenSettlementState : [(TokenTypes.TokenIndex, MarketplaceTypes.Settlement)] = [];
	private stable var _paymentsState : [(Principal, [TokenTypes.SubAccount])] = [];
	private stable var _tokenListingState : [(TokenTypes.TokenIndex, MarketplaceTypes.Listing)] = [];
  private stable var _disbursementsState : [(TokenTypes.TokenIndex, AccountIdentifier, SubAccount, Nat64)] = [];
  private stable var _nextSubAccountState : Nat = 0;
  private stable var _soldState : Nat = 0;
  private stable var _totalToSellState : Nat = 0;

 // Assets
	private stable var _assetsState : [AssetsTypes.Asset] = [];

 // Shuffle
  private stable var _isShuffledState : Bool = false;

 // Cap
  private stable var rootBucketId : ?Text = null;

 // Canistergeek
  stable var _canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;

 //State functions
  system func preupgrade() {
   // Tokens  
    let {
      tokenMetadataState;
      ownersState;
      registryState;
      nextTokenIdState;
      minterState;
      supplyState;
    } = _Tokens.toStable();

    _tokenMetadataState := tokenMetadataState;
    _ownersState := ownersState;
    _registryState := registryState;
    _nextTokenIdState := nextTokenIdState;
    _minterState := minterState;
    _supplyState := supplyState;

   // Sale
    let { 
      saleTransactionsState; 
      salesSettlementsState;
      failedSalesState; 
      tokensForSaleState; 
      ethFlowerWhitelistState;
      modclubWhitelistState;
      soldIcpState;
    } = _Sale.toStable();

    _saleTransactionsState := saleTransactionsState;
    _salesSettlementsState := salesSettlementsState;
    _failedSalesState := failedSalesState;
    _tokensForSaleState := tokensForSaleState;
    _ethFlowerWhitelistState := ethFlowerWhitelistState;
    _modclubWhitelistState := modclubWhitelistState;
    _soldIcpState := soldIcpState;
  
   // Marketplace
    let { 
      transactionsState; 
      tokenSettlementState; 
      paymentsState; 
      tokenListingState; 
      disbursementsState;
      nextSubAccountState;
      soldState;
      totalToSellState;
    } = _Marketplace.toStable();

    _transactionsState := transactionsState;
    _tokenSettlementState := tokenSettlementState;
    _paymentsState := paymentsState;
    _tokenListingState := tokenListingState;
    _disbursementsState := disbursementsState;
    _nextSubAccountState := nextSubAccountState;
    _soldState := soldState;
    _totalToSellState := totalToSellState;

   // Assets
    let {
      assetsState;
    } = _Assets.toStable();

    _assetsState := assetsState;

   // Canistergeek
    _canistergeekMonitorUD := ? canistergeekMonitor.preupgrade();
  };

  system func postupgrade() {
   // Tokens
    _tokenMetadataState := [];
    _ownersState := [];
    _registryState := [];
    _nextTokenIdState := 0;
    _minterState := init_minter;
    _supplyState := 0;

   // Sale
    _saleTransactionsState := [];
    _salesSettlementsState := [];
    _failedSalesState := [];
    _tokensForSaleState := [];
    _ethFlowerWhitelistState := [];
    _modclubWhitelistState := [];
    _soldIcpState := 0;

   // Marketplace
    _transactionsState := [];
    _tokenSettlementState := [];
    _paymentsState := [];
    _tokenListingState := [];
    _disbursementsState := [];
    _nextSubAccountState := 0;
    _soldState := 0;
    _totalToSellState := 0;

   // Assets
    _assetsState := [];
   
   // Canistergeek
    canistergeekMonitor.postupgrade(_canistergeekMonitorUD);
    _canistergeekMonitorUD := null;
  };

/*************
* CONSTANTS *
*************/

  let LEDGER_CANISTER = actor "ryjl3-tyaaa-aaaaa-aaaba-cai" : actor { 
    account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs;
    send_dfx : shared SendArgs -> async Nat64; 
  };
  let WHITELIST_CANISTER = actor "s7o6c-giaaa-aaaae-qac4a-cai" : actor { 
    getWhitelist: shared () -> async [Principal];
  };
  let CREATION_CYCLES: Nat = 1_000_000_000_000;

/***********
* CLASSES *
***********/

 // Canistergeek
  private let canistergeekMonitor = Canistergeek.Monitor();
  
  /**
  * Returns collected data based on passed parameters.
  * Called from browser.
  */
  public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
      validateCaller(caller);
      canistergeekMonitor.getMetrics(parameters);
  };

  /**
  * Force collecting the data at current time.
  * Called from browser or any canister "update" method.
  */
  public shared ({caller}) func collectCanisterMetrics(): async () {
      validateCaller(caller);
      canistergeekMonitor.collectMetrics();
  };

  private func validateCaller(principal: Principal) : () {
    assert( principal == Principal.fromText("ikywv-z7xvl-xavcg-ve6kg-dbbtx-wy3gy-qbtwp-7ylai-yl4lc-lwetg-kqe"))
  };


 // Cap
  let _Cap = Cap.Cap(null, rootBucketId);

  public shared(msg) func initCap() : async Result.Result<(), Text> {
    canistergeekMonitor.collectMetrics();
    assert(msg.caller == _minterState);
    let pid = Principal.fromActor(myCanister);
    let tokenContractId = Principal.toText(pid);

    try {
        rootBucketId := await _Cap.handshake(
            tokenContractId,
            CREATION_CYCLES,
        );

        return #ok();
    } catch e {
        throw e;
    };
  };
  
 // Tokens
  let _Tokens = Tokens.Factory(
    cid,
    {
      _minterState;
      _nextTokenIdState;
      _registryState;
      _tokenMetadataState;
      _supplyState;
      _ownersState;
    }
  );

  // updates
  public shared (msg) func setMinter(minter: Principal) {
    canistergeekMonitor.collectMetrics();
    _Tokens.setMinter(msg.caller, minter);
  };
    
  // queries
  public query func balance(request : TokenTypes.BalanceRequest) : async TokenTypes.BalanceResponse {
    _Tokens.balance(request);
  };

  public query func bearer(token : TokenTypes.TokenIdentifier) : async Result.Result<TokenTypes.AccountIdentifier, TokenTypes.CommonError> {
    _Tokens.bearer(token);
  };


 // Marketplace
  let _Marketplace = Marketplace.Factory(
    cid,
    {
      _paymentsState;
      _tokenListingState;
      _tokenSettlementState;
      _transactionsState;
      _disbursementsState;
      _nextSubAccountState;
      _soldState;
      _totalToSellState;
    },
    {
      _Tokens;
      _Cap;
    },
    {
      LEDGER_CANISTER;
    }
  );

  // updates
  public shared(msg) func lock(tokenid : MarketplaceTypes.TokenIdentifier, price : Nat64, address : MarketplaceTypes.AccountIdentifier, subaccount : MarketplaceTypes.SubAccount) : async Result.Result<MarketplaceTypes.AccountIdentifier, MarketplaceTypes.CommonError> {
    canistergeekMonitor.collectMetrics();
    await _Marketplace.lock(msg.caller, tokenid, price, address, subaccount);
  };
    
  public shared(msg) func settle(tokenid : MarketplaceTypes.TokenIdentifier) : async Result.Result<(), MarketplaceTypes.CommonError> {
    canistergeekMonitor.collectMetrics();
   await _Marketplace.settle(msg.caller, tokenid);
  };
    
  public shared(msg) func list(request: MarketplaceTypes.ListRequest) : async Result.Result<(), MarketplaceTypes.CommonError> {
    canistergeekMonitor.collectMetrics();
    await _Marketplace.list(msg.caller, request);
  };
    
  public shared(msg) func clearPayments(seller : Principal, payments : [MarketplaceTypes.SubAccount]) : async () {
    canistergeekMonitor.collectMetrics();
    await _Marketplace.clearPayments(seller, payments);
  };

  public shared(msg) func cronDisbursements() : async () {
    canistergeekMonitor.collectMetrics();
    await _Marketplace.cronDisbursements();
  };

  public shared(msg) func cronSettlements() : async () {
    canistergeekMonitor.collectMetrics();
    await _Marketplace.cronSettlements(msg.caller);
  };

  // queries
  public query func details(token : MarketplaceTypes.TokenIdentifier) : async Result.Result<(MarketplaceTypes.AccountIdentifier, ?MarketplaceTypes.Listing), MarketplaceTypes.CommonError> {
    _Marketplace.details(token);
  };
    
  public query func transactions() : async [MarketplaceTypes.Transaction] {
    _Marketplace.transactions();
  };
    
  public query func settlements() : async [(MarketplaceTypes.TokenIndex, MarketplaceTypes.AccountIdentifier, Nat64)] {
    _Marketplace.settlements();
  };
    
  public query(msg) func payments() : async ?[MarketplaceTypes.SubAccount] {
    _Marketplace.payments(msg.caller);
  };

  public query func listings() : async [(MarketplaceTypes.TokenIndex, MarketplaceTypes.Listing, MarketplaceTypes.Metadata)] {
    _Marketplace.listings();
  };
    
  public query(msg) func allSettlements() : async [(MarketplaceTypes.TokenIndex, MarketplaceTypes.Settlement)] {
    _Marketplace.allSettlements();
  };
    
  public query(msg) func allPayments() : async [(Principal, [MarketplaceTypes.SubAccount])] {
    _Marketplace.allPayments();
  };
    
  public query func stats() : async (Nat64, Nat64, Nat64, Nat64, Nat, Nat, Nat) {
    _Marketplace.stats();
  };

  public query func viewDisbursements() : async [(MarketplaceTypes.TokenIndex, MarketplaceTypes.AccountIdentifier, MarketplaceTypes.SubAccount, Nat64)] {
    _Marketplace.viewDisbursements();
  };

  public query func pendingCronJobs() : async [Nat] {
    _Marketplace.pendingCronJobs();
  };

  public query func toAddress(p : Text, sa : Nat) : async AccountIdentifier {
    _Marketplace.toAddress(p, sa);
  };
    

 // Assets
  let _Assets = Assets.Factory(
    {
      _assetsState;
      _isShuffledState;
    },
    {
      _Tokens
    }
  );

  public shared(msg) func streamAsset(id : Nat, isThumb : Bool, payload : Blob) : async () {
    canistergeekMonitor.collectMetrics();
    _Assets.streamAsset(msg.caller, id, isThumb, payload);
  };
    
  public shared(msg) func updateThumb(name : Text, file : AssetsTypes.File) : async ?Nat {
    canistergeekMonitor.collectMetrics();
    _Assets.updateThumb(msg.caller, name, file);
  };

  public shared(msg) func addAsset(asset : AssetsTypes.Asset) : async Nat {
    canistergeekMonitor.collectMetrics();
    _Assets.addAsset(msg.caller, asset);
  };


 // Shuffle
  let _Shuffle = Shuffle.Factory(
    {
      _isShuffledState;
    },
    {
      _Assets;
      _Tokens;
    }
  );

  public shared(msg) func shuffleAssets() : async () {
    canistergeekMonitor.collectMetrics();
    await _Shuffle.shuffleAssets(msg.caller);
  };


 //Sale 
  let _Sale = Sale.Factory(
    cid,
    {
      _saleTransactionsState;
      _salesSettlementsState;
      _minterState;
      _failedSalesState;
      _tokensForSaleState;
      _ethFlowerWhitelistState;
      _modclubWhitelistState;
      _soldIcpState;
    },
    {
      _Cap;
      _Marketplace;
      _Shuffle;
      _Tokens;
    },
    {
      LEDGER_CANISTER;
      WHITELIST_CANISTER;
    }
  );

  // updates
  public shared(msg) func initMint() : async () {
    canistergeekMonitor.collectMetrics();
    await _Sale.initMint(msg.caller)
  };

  public shared(msg) func shuffleTokensForSale() : async () {
    canistergeekMonitor.collectMetrics();
    await _Sale.shuffleTokensForSale(msg.caller)
  };

  public shared(msg) func airdropTokens(startIndex : Nat) : async () {
    canistergeekMonitor.collectMetrics();
    _Sale.airdropTokens(msg.caller, startIndex)
  };

  public shared(msg) func setTotalToSell() : async Nat {
    canistergeekMonitor.collectMetrics();
    _Sale.setTotalToSell(msg.caller);
  };

  public shared(msg) func reserve(amount : Nat64, quantity : Nat64, address : SaleTypes.AccountIdentifier, _subaccountNOTUSED : SaleTypes.SubAccount) : async Result.Result<(SaleTypes.AccountIdentifier, Nat64), Text> {
    canistergeekMonitor.collectMetrics();
    _Sale.reserve(amount, quantity, address, _subaccountNOTUSED)
  };
    
  public shared(msg) func retreive(paymentaddress : SaleTypes.AccountIdentifier) : async Result.Result<(), Text> {
    canistergeekMonitor.collectMetrics();
    await _Sale.retreive(msg.caller, paymentaddress)
  };

  public shared(msg) func cronSalesSettlements() : async () {
    canistergeekMonitor.collectMetrics();
    await _Sale.cronSalesSettlements(msg.caller);
  };

  // queries
  public query func salesSettlements() : async [(SaleTypes.AccountIdentifier, SaleTypes.Sale)] {
    _Sale.salesSettlements();
  };
    
  public query func failedSales() : async [(SaleTypes.AccountIdentifier, SaleTypes.SubAccount)] {
    _Sale.failedSales();
  };

  public query(msg) func saleTransactions() : async [SaleTypes.SaleTransaction] {
    _Sale.saleTransactions();
  };

  public query(msg) func salesSettings(address : AccountIdentifier) : async SaleTypes.SaleSettings {
    _Sale.salesSettings(address);
  };

 // EXT
  let _EXT = EXT.Factory(
    cid,
    {
      _Tokens;
      _Assets;
      _Marketplace;
      _Cap;
    }
  );
  // updates
  public shared(msg) func transfer(request: EXTTypes.TransferRequest) : async EXTTypes.TransferResponse {
    canistergeekMonitor.collectMetrics();
    await _EXT.transfer(msg.caller, request);
  };

  // queries
  public query func getMinter() : async Principal {
    _EXT.getMinter();
  };

  public query func extensions() : async [EXTTypes.Extension] {
    _EXT.extensions();
  };
    
  public query func supply() : async Result.Result<EXTTypes.Balance, EXTTypes.CommonError> {
    _EXT.supply();
  };
    
  public query func getRegistry() : async [(EXTTypes.TokenIndex, EXTTypes.AccountIdentifier)] {
    _EXT.getRegistry();
  };

  public query func getTokens() : async [(EXTTypes.TokenIndex, EXTTypes.Metadata)] {
    _EXT.getTokens();
  };

  public query func getTokenToAssetMapping() : async [(EXTTypes.TokenIndex, Text)] {
    _EXT.getTokenToAssetMapping();
  };

  public query func tokens(aid : EXTTypes.AccountIdentifier) : async Result.Result<[EXTTypes.TokenIndex], EXTTypes.CommonError> {
    _EXT.tokens(aid);
  };
    
  public query func tokens_ext(aid : EXTTypes.AccountIdentifier) : async Result.Result<[(EXTTypes.TokenIndex, ?MarketplaceTypes.Listing, ?Blob)], EXTTypes.CommonError> {
    _EXT.tokens_ext(aid);
  };

  public query func metadata(token : EXTTypes.TokenIdentifier) : async Result.Result<EXTTypes.Metadata, EXTTypes.CommonError> {
    _EXT.metadata(token);
  };
  


 // Http
  let _HttpHandler = Http.HttpHandler(
    cid,
    {
      _Assets; 
      _Marketplace; 
      _Shuffle; 
      _Tokens;
      _Sale;
    }
  );
  
  // queries
  public query func http_request(request : HttpTypes.HttpRequest) : async HttpTypes.HttpResponse {
    _HttpHandler.http_request(request);
  };

  public query func http_request_streaming_callback(token : HttpTypes.HttpStreamingCallbackToken) : async HttpTypes.HttpStreamingCallbackResponse {
    _HttpHandler.http_request_streaming_callback(token);
  };

 // cycles
  public func acceptCycles() : async () {
    canistergeekMonitor.collectMetrics();
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };

  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };
  
}