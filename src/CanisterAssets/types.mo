import Tokens "../Tokens";

module {
  public type StableChunk = ?{
    #v1: {
      assetsCount : Nat;
      assetsChunk : [Asset];
    };
    #v1_chunk: {
      assetsChunk : [Asset];
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
