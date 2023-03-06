import Tokens "../Tokens";

module {
  // TODO: remove after upgrade
  public func newStableState() : StableState {
    return {
      _assetsState : [Asset] = [];
    };
  };

  public type StableChunk = ?{
    #legacy: StableState; // TODO: remove after upgrade
    #v1: {
      assets : [Asset];
    };
  };

  public type File = {
    ctype : Text; // "image/jpeg"
    data : [Blob];
  };

  public type Asset = {
    name : Text;
    thumbnail : ?File;
    metadata : ?File;
    payload : File;
  };

  // TODO: remove after upgrade
  public type StableState = {
    _assetsState : [Asset];
  };

  public type Constants = {
    minter : Principal;
  }

};
