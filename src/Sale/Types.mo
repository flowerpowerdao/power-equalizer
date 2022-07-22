
import Time "mo:base/Time";

import Cap "mo:cap/Cap";

import Assets "../CanisterAssets";
import ExtCore "../toniq-labs/ext/Core";
import Marketplace "../Marketplace";
import Shuffle "../Shuffle";
import Tokens "../Tokens";

module {

  public type State = {
    _saleTransactionsState : [SaleTransaction];
    _salesSettlementsState : [(AccountIdentifier, Sale)];
    _salesPrincipalsState : [(AccountIdentifier, Text)];
    _failedSalesState : [(AccountIdentifier, SubAccount)];
    _tokensForSaleState : [TokenIndex];
    _whitelistState : [AccountIdentifier];
    _soldIcpState : Nat64;
    _soldState : Nat;
    _totalToSellState : Nat;
    _hasBeenInitiatedState : Bool;
  };

  public type Dependencies = {
    _Cap : Cap.Cap;
    _Tokens : Tokens.Factory;
    _Marketplace: Marketplace.Factory;
    _Shuffle : Shuffle.Factory;
  };

  public type Constants = {
    ESCROWDELAY: Time.Time;
    LEDGER_CANISTER : actor { account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs };
    TEAM_ADDRESS: AccountIdentifier;
  };

  public type AccountIdentifier = ExtCore.AccountIdentifier;

  public type Time = Time.Time;

  public type TokenIdentifier = ExtCore.TokenIdentifier;

  public type SubAccount = ExtCore.SubAccount;

  public type CommonError = ExtCore.CommonError;

  public type TokenIndex  = ExtCore.TokenIndex ;
  
  public type ICPTs = { e8s : Nat64 };
  
  public type AccountBalanceArgs = { account : AccountIdentifier };
  
  public type Sale = {
    tokens : [TokenIndex];
    price : Nat64;
    subaccount : SubAccount;
    buyer : AccountIdentifier;
    expires : Time;
  };
  
  public type SaleTransaction = {
    tokens : [TokenIndex];
    seller : Principal;
    price : Nat64;
    buyer : AccountIdentifier;
    time : Time;
  };
}