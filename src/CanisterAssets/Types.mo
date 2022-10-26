import Tokens "../Tokens";

module {

  public func newStableState() : StableState {
    return {
      _assetsState : [Asset] = [];
    };
  };

  public type File = {
    ctype : Text; //"image/jpeg"
    data : [Blob];
  };
  public type Asset = {
    name : Text;
    thumbnail : ?File;
    metadata : ?File;
    payload : File;
  };

  public type StableState = {
    _assetsState : [Asset];
  };

  public type Dependencies = {
    _Tokens : Tokens.Factory;
  };

  public type Constants = {
    minter : Principal;
  }

};
