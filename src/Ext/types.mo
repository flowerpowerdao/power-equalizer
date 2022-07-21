
import Time "mo:base/Time";

import Assets "../CanisterAssets";
import ExtCommon "../toniq-labs/Ext/Common";
import ExtCore "../toniq-labs/ext/Core";
import Tokens "../Tokens";
import Marketplace "../Marketplace";

module {
  public type Extension = ExtCore.Extension;

  public type TokenIdentifier = ExtCore.TokenIdentifier;
  
  public type TokenIndex  = ExtCore.TokenIndex ;
  
  public type Metadata = ExtCommon.Metadata;
  
  public type AccountIdentifier = ExtCore.AccountIdentifier;

  public type Balance = ExtCore.Balance;
  
  public type BalanceRequest = ExtCore.BalanceRequest;
  
  public type BalanceResponse = ExtCore.BalanceResponse;

  public type Listing = {
    seller : Principal;
    price : Nat64;
    locked : ?Time;
  };

  public type Time = Time.Time;

  public type SubAccount = ExtCore.SubAccount;

  public type CommonError = ExtCore.CommonError;
  
  public type ICPTs = { e8s : Nat64 };

  public type Dependencies = {
    _Tokens : Tokens.Factory;
    _Assets : Assets.Factory;
    _Marketplace : Marketplace.Factory;
  };
}