import Time "mo:base/Time";

import ExtCommon "../toniq-labs/ext/Common";
import ExtCore "../toniq-labs/ext/Core";

module {
  public type StableChunk = ?{
    #v1: {
      tokenMetadata : [(TokenIndex, Metadata)];
      owners : [(AccountIdentifier, [TokenIndex])];
      registry : [(TokenIndex, AccountIdentifier)];
      nextTokenId : TokenIndex;
      supply : Balance;
    };
  };

  public type TokenIdentifier = ExtCore.TokenIdentifier;
  public type TokenIndex = ExtCore.TokenIndex;
  public type Metadata = ExtCommon.Metadata;
  public type AccountIdentifier = ExtCore.AccountIdentifier;
  public type Balance = ExtCore.Balance;
  public type BalanceRequest = ExtCore.BalanceRequest;
  public type BalanceResponse = ExtCore.BalanceResponse;
  public type Time = Time.Time;
  public type SubAccount = ExtCore.SubAccount;
  public type CommonError = ExtCore.CommonError;

  public type Listing = {
    seller : Principal;
    price : Nat64;
    locked : ?Time;
  };

  public type Constants = {
    minter : Principal;
  }
};
