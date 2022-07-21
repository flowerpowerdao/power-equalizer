let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall sha256:b46f30e811fe5085741be01e126629c2a55d4c3d6ebf49408fb3b4a98e37589b
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }

let additions = [
   { name = "asset-storage"
   , repo = "https://github.com/aviate-labs/asset-storage.mo"
   , version = "asset-storage-0.7.0"
   , dependencies = [ "base" ]
   },
   { name = "sha"
   , repo = "https://github.com/aviate-labs/sha.mo"
   , version = "v0.1.1"
   , dependencies = [ "base", "encoding" ]
   },
   { name = "encoding"
  , repo = "https://github.com/aviate-labs/encoding.mo"
  , version = "v0.2.1"
  , dependencies = ["base"]
  },
  { name = "cap"
  , repo = "https://github.com/Psychedelic/cap-motoko-library"
  , version = "v1.0.4"
  , dependencies = ["base"] : List Text
  },
  { name = "canistergeek"
  , repo = "https://github.com/usergeek/canistergeek-ic-motoko"
  , version = "v0.0.4"
  , dependencies = ["base"] : List Text
  }
] : List Package

let overrides = [] : List Package


in  upstream # additions # overrides
