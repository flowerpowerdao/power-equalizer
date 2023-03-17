import Tokens "../Tokens";

module {
  public type StableChunk = ?{
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

  public type Constants = {
    minter : Principal;
  }
};
