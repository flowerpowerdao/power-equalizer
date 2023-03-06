import Time "mo:base/Time";

import Assets "../CanisterAssets";
import ExtCore "../toniq-labs/ext/Core";
import Tokens "../Tokens";
import TokenTypes "../Tokens/types";
import LedgerTypes "../Ledger/types";

module {
  public type AccountIdentifier = ExtCore.AccountIdentifier;
  public type SubAccount = ExtCore.SubAccount;
  public type TokenIndex = ExtCore.TokenIndex;

  public type Disbursement = {
    to : AccountIdentifier;
    fromSubaccount : SubAccount;
    amount : Nat64;
    tokenIndex : TokenIndex;
  };

  public type StableChunk = ?{
    #legacy: StableState; // TODO: remove after upgrade
    #v1: {
      disbursements : [Disbursement];
    };
  };

  // TODO: remove after upgrade
  public func newStableState() : StableState {
    return {
      _disbursementsState = [];
    };
  };

  // TODO: remove after upgrade
  public type StableState = {
    _disbursementsState : [Disbursement];
  };

  public type Constants = {
    LEDGER_CANISTER : LedgerTypes.LEDGER_CANISTER;
  };
};
