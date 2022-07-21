import Time "mo:base/Time";

import Cap "mo:cap/Cap";

import ExtCore "../toniq-labs/Ext/Core";
import TokenTypes "../Tokens/Types";
import Tokens "../Tokens";

module {
  public type AccountIdentifier = ExtCore.AccountIdentifier;

  public type Time = Time.Time;

  public type TokenIdentifier = TokenTypes.TokenIdentifier;

  public type Metadata = TokenTypes.Metadata;

  public type SubAccount = ExtCore.SubAccount;

  public type CommonError = ExtCore.CommonError;

  public type TokenIndex  = ExtCore.TokenIndex ;
  
  public type ICPTs = { e8s : Nat64 };

  public type Transaction = {
    token : TokenIdentifier;
    seller : Principal;
    price : Nat64;
    buyer : AccountIdentifier;
    time : Time;
  };

  public type Settlement = {
    seller : Principal;
    price : Nat64;
    subaccount : SubAccount;
    buyer : AccountIdentifier;
  };

  public type Listing = {
    seller : Principal;
    price : Nat64;
    locked : ?Time;
  };

  public type ListRequest = {
    token : TokenIdentifier;
    from_subaccount : ?SubAccount;
    price : ?Nat64;
  }; 

  type SendArgs = {
    memo: Nat64;
    amount: ICPTs;
    fee: ICPTs;
    from_subaccount: ?SubAccount;
    to: AccountIdentifier;
    created_at_time: ?Time.Time;
  };

  public type AccountBalanceArgs = { account : AccountIdentifier };

  public type State = {
    _transactionsState : [Transaction];
    _tokenSettlementState : [(TokenIndex, Settlement)];
    _usedPaymentAddressessState : [(AccountIdentifier, Principal, SubAccount)];
    _paymentsState : [(Principal, [SubAccount])];
    _tokenListingState : [(TokenIndex, Listing)];
    _disbursementsState : [(TokenIndex, AccountIdentifier, SubAccount, Nat64)];
    _nextSubAccountState : Nat
  };

  public type Dependencies = {
    _Cap : Cap.Cap;
    _Tokens : Tokens.Factory;
  };

  public type Constants = {
    ESCROWDELAY: Time.Time;
    LEDGER_CANISTER : actor { 
    account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs;
    send_dfx : shared SendArgs -> async Nat64; 
    };
  };

}