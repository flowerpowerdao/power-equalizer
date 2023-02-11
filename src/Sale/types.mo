import Time "mo:base/Time";

import Cap "mo:cap/Cap";

import ExtCore "../toniq-labs/ext/Core";
import Shuffle "../Shuffle";
import Tokens "../Tokens";
import Disburser "../Disburser";
import LedgerTypes "../Ledger/types";

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

  public type Constants = {
    LEDGER_CANISTER : LedgerTypes.LEDGER_CANISTER;
    minter : Principal;
  };

  public type AccountIdentifier = ExtCore.AccountIdentifier;

  public type TokenIdentifier = ExtCore.TokenIdentifier;

  public type SubAccount = ExtCore.SubAccount;

  public type CommonError = ExtCore.CommonError;

  public type TokenIndex = ExtCore.TokenIndex;

  public type Time = Time.Time;

  public type Tokens = LedgerTypes.Tokens;

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
