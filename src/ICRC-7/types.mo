import Time "mo:base/Time";

import Cap "mo:cap/Cap";

import Assets "../CanisterAssets";
import ExtCommon "../toniq-labs/ext/Common";
import ExtCore "../toniq-labs/ext/Core";
import Marketplace "../Marketplace";
import Tokens "../Tokens";

module {
  public type Account = {
    owner : Principal;
    subaccount : ?[Nat8];
  };

  public type Metadata = { #Nat : nat; #Int : int; #Text : text; #Blob : blob };

  public type CollectionMetadata = {
    icrc7_name : Text;
    icrc7_symbol : Text;
    icrc7_royalties : ?Nat16;
    icrc7_royalty_recipient : ?Account;
    icrc7_description : ?Text;
    icrc7_image : ?Text;  // The URL of the token logo. The value can contain the actual image if it's a Data URL.
    icrc7_total_supply : Nat;
    icrc7_supply_cap : ?Nat;
  };

  public type TransferArgs = {
    from : ?Account; // if supplied and is not caller then is permit transfer, if not supplied defaults to subaccount 0 of the caller principal
    to : Account;
    token_ids : [Nat];
    // type: leave open for now
    memo : ?Blob;
    created_at_time : ?Nat64;
    is_atomic : ?Bool;
  };

  public type TransferError = {
    #Unauthorized: { token_ids : [Nat] };
    #TooOld;
    #CreatedInFuture : { ledger_time: Nat64 };
    #Duplicate : { duplicate_of : Nat };
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
  };

  public type ApprovalArgs = {
    from_subaccount : ?Blob;
    to : principal;
    tokenIds : ?[Nat]; // if no tokenIds given then approve entire collection
    expires_at : ?Nat64;
    memo : ?Blob;
    created_at : ?Nat64;
  };

  public type ApprovalError = {
    #Unauthorized : [Nat];
    #TooOld;
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
  };

  public type Dependencies = {
    _Tokens : Tokens.Factory;
    _Assets : Assets.Factory;
    _Marketplace : Marketplace.Factory;
    _Cap : Cap.Cap;
  };
};
