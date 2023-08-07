let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.8.1-20230203/package-set.dhall
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
  , version = "v0.0.7"
  , dependencies = ["base"] : List Text
  },
  { name = "fuzz"
  , repo = "https://github.com/ZenVoich/fuzz"
  , version = "main"
  , dependencies = ["base"] : List Text
  },
  { name = "http-parser"
  , repo = "https://github.com/NatLabs/http-parser.mo"
  , version = "v0.1.2"
  , dependencies = ["base"] : List Text
  },
  { name = "json"
  , repo = "https://github.com/aviate-labs/json.mo"
  , version = "v0.2.1"
  , dependencies = [ "base", "parser-combinators" ]
  },
  { name = "parser-combinators"
  , repo = "https://github.com/aviate-labs/parser-combinators.mo"
  , version = "v0.1.0"
  , dependencies = [ "base" ]
  },
  { name = "base"
  , repo = "https://github.com/dfinity/motoko-base"
  , version = "moc-0.8.1"
  , dependencies = [] : List Text
  },
] : List Package

let overrides = [] : List Package


in  upstream # additions # overrides
