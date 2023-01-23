let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall sha256:b46f30e811fe5085741be01e126629c2a55d4c3d6ebf49408fb3b4a98e37589b
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }

let additions = [
  { name = "array"
  , repo = "https://github.com/aviate-labs/array.mo"
  , version = "v0.2.0"
  , dependencies = [ "base" ]
  },
  { name = "encoding"
  , repo = "https://github.com/aviate-labs/encoding.mo"
  , version = "v0.3.2"
  , dependencies = [ "array", "base" ]
  },
  { name = "crypto"
  , repo = "https://github.com/aviate-labs/crypto.mo"
  , version = "v0.1.1"
  , dependencies = [ "base", "encoding" ]
  },
  { name = "hash"
  , repo = "https://github.com/aviate-labs/hash.mo"
  , version = "v0.1.0"
  , dependencies = [ "array", "base" ]
  },
  { name = "asset-storage"
  , repo = "https://github.com/aviate-labs/asset-storage.mo"
  , version = "asset-storage-0.7.0"
  , dependencies = [ "base" ]
  },
  { name = "accountid"
  , repo = "https://github.com/aviate-labs/principal.mo"
  , version = "v0.2.6"
  , dependencies = [ "array", "crypto", "base-0.7.3", "encoding", "hash" ]
  },
  { name = "base-0.7.3"
  , repo = "https://github.com/dfinity/motoko-base"
  , version = "aafcdee0c8328087aeed506e64aa2ff4ed329b47"
  , dependencies = [] : List Text
  },
  { name = "sha"
  , repo = "https://github.com/aviate-labs/sha.mo"
  , version = "v0.1.1"
  , dependencies = [ "base", "encoding" ]
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
  },
  { name = "base"
  , repo = "https://github.com/dfinity/motoko-base.git"
  , version = "moc-0.7.4"
  , dependencies = [] : List Text
  }
] : List Package

let overrides = [] : List Package


in  upstream # additions # overrides
