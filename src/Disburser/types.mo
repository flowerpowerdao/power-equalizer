import Time "mo:base/Time";

import Assets "../CanisterAssets";
import ExtCore "../toniq-labs/ext/Core";
import Tokens "../Tokens";
import TokenTypes "../Tokens/types";

module {
  public type AccountIdentifier = ExtCore.AccountIdentifier;

  public type SubAccount = ExtCore.SubAccount;

  public func newStableState() : StableState {
    return {
      _disbursementsState = [];
    };
  };

  public type Disbursement = {
    to : AccountIdentifier;
    fromSubaccount : SubAccount;
    amount : Nat64;
    tokenIndex : TokenIndex;
  };

  public type StableState = {
    _disbursementsState : [Disbursement];
  };

  public type AccountBalanceArgs = { account : AccountIdentifier };
  public type TokenIndex = ExtCore.TokenIndex;
  public type ICPTs = { e8s : Nat64 };
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
  };
};
