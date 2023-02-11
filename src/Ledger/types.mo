module {
  public type LedgerAccountIdentifier = [Nat8];
  public type BlockIndex = Nat64;
  public type Memo = Nat64;
  public type LedgerSubAccount = [Nat8];
  public type TimeStamp = {
    timestamp_nanos : Nat64;
  };
  public type Tokens = {
    e8s : Nat64;
  };
  public type AccountBalanceArgs = { account : LedgerAccountIdentifier };
  public type TransferArgs = {
    to : LedgerAccountIdentifier;
    fee : Tokens;
    memo : Memo;
    from_subaccount : ?LedgerSubAccount;
    created_at_time : ?TimeStamp;
    amount : Tokens;
  };
  public type TransferError = {
    #TxTooOld : { allowed_window_nanos : Nat64 };
    #BadFee : { expected_fee : Tokens };
    #TxDuplicate : { duplicate_of : BlockIndex };
    #TxCreatedInFuture;
    #InsufficientFunds : { balance : Tokens };
  };
  public type TransferResult = {
    #Ok : BlockIndex;
    #Err : TransferError;
  };
  public type LEDGER_CANISTER = actor {
    account_balance : shared query AccountBalanceArgs -> async Tokens;
    transfer : shared TransferArgs -> async TransferResult;
  };
};
