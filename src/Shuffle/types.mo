import Assets "../CanisterAssets";
import ExtCore "../toniq-labs/ext/Core";
import Tokens "../Tokens";

module {
  public type StableChunk = ?{
    #v1: {
      isShuffled : Bool;
    };
  };

  public type Dependencies = {
    _Assets : Assets.Factory;
    _Tokens : Tokens.Factory;
  };
  public type TokenIndex = ExtCore.TokenIndex;
};
