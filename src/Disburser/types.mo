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
    type SendArgs = {
        memo : Nat64;
        amount : ICPTs;
        fee : ICPTs;
        from_subaccount : ?SubAccount;
        to : AccountIdentifier;
        created_at_time : ?Time.Time;
    };
    public type TransferArgs = {
        to : AccountIdentifier;
        fee : ICPTs;
        memo : Nat64;
        from_subaccount : ?SubAccount;
        created_at_time : ?Time.Time;
        amount : ICPTs;
    };
    public type TransferError = {
        #TxTooOld : { allowed_window_nanos : Nat64 };
        #BadFee : { expected_fee : ICPTs };
        #TxDuplicate : { duplicate_of : Nat64 };
        #TxCreatedInFuture;
        #InsufficientFunds : { balance : ICPTs };
    };
	public type TransferResult = { #Ok : Nat64; #Err : TransferError };

    public type Constants = {
        LEDGER_CANISTER : actor {
            account_balance_dfx : shared query AccountBalanceArgs -> async ICPTs;
            send_dfx : shared SendArgs -> async Nat64;
            transfer : shared TransferArgs -> async TransferResult;
        };
    };
};
