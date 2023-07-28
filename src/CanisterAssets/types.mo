import Tokens "../Tokens";

module {
  public type StableChunk = ?{
    #v2: {
      placeholder : AssetV2;
      assetsCount : Nat;
      assetsChunk : [AssetV2];
    };
    #v2_chunk: {
      assetsChunk : [AssetV2];
    };
    #v3: {
      placeholder : AssetV2;
      assetsCount : Nat;
      assetsChunk : [AssetV2];
      isShuffled : Bool;
    };
    #v3_chunk: {
      assetsChunk : [AssetV2];
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

  public type AssetV2 = {
    name : Text;
    payload : File;
    thumbnail : ?File;
    metadata : ?File;
    payloadUrl : ?Text;
    thumbnailUrl : ?Text;
  };
};
