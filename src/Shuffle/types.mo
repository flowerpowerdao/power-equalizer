import Assets "../CanisterAssets";
import ExtCore "../toniq-labs/ext/Core";
import Tokens "../Tokens";

module {
  // TODO: remove after upgrade
  public func newStableState() : StableState {
    return {
      _isShuffledState : Bool = false;
    };
  };

  public type StableChunk = ?{
    #legacy: StableState; // TODO: remove after upgrade
    #v1: {
      isShuffled : Bool;
    };
  };

  // TODO: remove after upgrade
  public type StableState = {
    _isShuffledState : Bool;
  };

  public type Dependencies = {
    _Assets : Assets.Factory;
    _Tokens : Tokens.Factory;
  };
  public type TokenIndex = ExtCore.TokenIndex;

  public type Constants = {
    minter : Principal;
  };
};
