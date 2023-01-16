import Time "mo:base/Time";

import Cap "mo:cap/Cap";

import ExtCore "../toniq-labs/ext/Core";
import Shuffle "../Shuffle";
import Tokens "../Tokens";
import Disburser "../Disburser";

module {

  public func newStableState() : StableState {
    return {
      _saleTransactionsState : [SaleTransaction] = [];
      _salesSettlementsState : [(AccountIdentifier, Sale)] = [];
      _failedSalesState : [(AccountIdentifier, SubAccount)] = [];
      _tokensForSaleState : [TokenIndex] = [];
      _whitelistStable : [(Nat64, AccountIdentifier)] = [];
      _soldIcpState : Nat64 = 0;
      _soldState : Nat = 0;
      _totalToSellState : Nat = 0;
      _nextSubAccountState : Nat = 0;
    };
  };

  public type StableState = {
    _saleTransactionsState : [SaleTransaction];
    _salesSettlementsState : [(AccountIdentifier, Sale)];
    _failedSalesState : [(AccountIdentifier, SubAccount)];
    _tokensForSaleState : [TokenIndex];
    _whitelistStable : [(Nat64, AccountIdentifier)];
    _soldIcpState : Nat64;
    _soldState : Nat;
    _totalToSellState : Nat;
    _nextSubAccountState : Nat;
  };

  public type Dependencies = {
    _Cap : Cap.Cap;
    _Tokens : Tokens.Factory;
    _Shuffle : Shuffle.Factory;
    _Disburser : Disburser.Factory;
  };

  // ledger types
  type LedgerAccountIdentifier = [Nat8];
  type BlockIndex = Nat64;
  type Memo = Nat64;
  type LedgerSubAccount = [Nat8];
  type TimeStamp = {
    timestamp_nanos : Nat64;
  };
  type Tokens = {
    e8s : Nat64;
  };
  type TransferArgs = {
    to : LedgerAccountIdentifier;
    fee : Tokens;
    memo : Memo;
    from_subaccount : ?LedgerSubAccount;
    created_at_time : ?TimeStamp;
    amount : Tokens;
  };
  type TransferError = {
    #TxTooOld : { allowed_window_nanos : Nat64 };
    #BadFee : { expected_fee : Tokens };
    #TxDuplicate : { duplicate_of : BlockIndex };
    #TxCreatedInFuture;
    #InsufficientFunds : { balance : Tokens };
  };
  type TransferResult = {
    #Ok : BlockIndex;
    #Err : TransferError;
  };

  public type Constants = {
    LEDGER_CANISTER : actor {
      account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs;
      transfer : shared TransferArgs -> async TransferResult;
    };
    WHITELIST_CANISTER : actor { getWhitelist : shared () -> async [Principal] };
    minter : Principal;
  };

  public type AccountIdentifier = ExtCore.AccountIdentifier;

  public type Time = Time.Time;

  public type TokenIdentifier = ExtCore.TokenIdentifier;

  public type SubAccount = ExtCore.SubAccount;

  public type CommonError = ExtCore.CommonError;

  public type TokenIndex = ExtCore.TokenIndex;

  public type ICPTs = { e8s : Nat64 };

  public type AccountBalanceArgs = { account : AccountIdentifier };

  public type Sale = {
    tokens : [TokenIndex];
    price : Nat64;
    subaccount : SubAccount;
    buyer : AccountIdentifier;
    whitelisted : Bool;
    expires : Time;
  };

  public type SaleTransaction = {
    tokens : [TokenIndex];
    seller : Principal;
    price : Nat64;
    buyer : AccountIdentifier;
    time : Time;
  };

  public type SaleSettings = {
    price : Nat64;
    salePrice : Nat64;
    sold : Nat;
    remaining : Nat;
    startTime : Time;
    whitelistTime : Time;
    whitelist : Bool;
    totalToSell : Nat;
    bulkPricing : [(Nat64, Nat64)];
  };
};
