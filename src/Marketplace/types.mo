import Time "mo:base/Time";

import Cap "mo:cap/Cap";

import ExtCore "../toniq-labs/ext/Core";
import TokenTypes "../Tokens/types";
import Tokens "../Tokens";
import Sale "../Sale";
import Disburser "../Disburser";

module {
  public type StableChunk = ?{
    // v1
    #v1: {
      transactionCount : Nat;
      transactionChunk : [Transaction];
      tokenSettlement : [(TokenIndex, Settlement)];
      tokenListing : [(TokenIndex, Listing)];
      frontends : [(Text, Frontend)]; // ignored
    };
    #v1_chunk: {
      transactionChunk : [Transaction];
    };
    // v2
    #v2: {
      transactionCount : Nat;
      transactionChunk : [TransactionV2];
      tokenSettlement : [(TokenIndex, Settlement)];
      tokenListing : [(TokenIndex, Listing)];
    };
    #v2_chunk: {
      transactionChunk : [TransactionV2];
    };
  };

  public type Frontend = {
    fee : Nat64;
    accountIdentifier : AccountIdentifier;
  };

  public type AccountIdentifier = ExtCore.AccountIdentifier;
  public type Time = Time.Time;
  public type TokenIdentifier = TokenTypes.TokenIdentifier;
  public type Metadata = TokenTypes.Metadata;
  public type SubAccount = ExtCore.SubAccount;
  public type CommonError = ExtCore.CommonError;
  public type TokenIndex = ExtCore.TokenIndex;

  public type Transaction = {
    token : TokenIdentifier;
    seller : Principal;
    price : Nat64;
    buyer : AccountIdentifier;
    time : Time;
    sellerFrontend : ?Text;
    buyerFrontend : ?Text;
  };

  public type TransactionV2 = {
    token : TokenIdentifier;
    seller : Principal;
    price : Nat64;
    buyer : AccountIdentifier;
    time : Time;
    sellerFrontend : ?Text;
    buyerFrontend : ?Text;
  };

  public type Settlement = {
    seller : Principal;
    price : Nat64;
    subaccount : SubAccount;
    buyer : AccountIdentifier;
    sellerFrontend : ?Text;
    buyerFrontend : ?Text;
  };

  public type Listing = {
    seller : Principal;
    price : Nat64;
    locked : ?Time;
    sellerFrontend : ?Text;
    buyerFrontend : ?Text;
  };

  public type ListRequest = {
    token : TokenIdentifier;
    from_subaccount : ?SubAccount;
    price : ?Nat64;
    frontendIdentifier : ?Text;
  };

  public type Dependencies = {
    _Cap : Cap.Cap;
    _Tokens : Tokens.Factory;
    _Sale : Sale.Factory;
    _Disburser : Disburser.Factory;
  };
};
