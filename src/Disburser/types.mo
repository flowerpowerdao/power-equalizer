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
    #v1: {
      disbursements : [Disbursement];
    };
  };

  public type Constants = {
    LEDGER_CANISTER : LedgerTypes.LEDGER_CANISTER;
  };
};
