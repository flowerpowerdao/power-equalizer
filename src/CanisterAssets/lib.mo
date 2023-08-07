import Array "mo:base/Array";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";

import Types "types";
import RootTypes "../types";
import Utils "../utils";
import Debug "mo:base/Debug";

module {

  public class Factory(config : RootTypes.Config) {

    /*********
    * STATE *
    *********/

    var _assets = Buffer.Buffer<Types.AssetV2>(0);

    // placeholder returned instead of asset when there is reveal delay and not yet revealed
    var _placeholder : Types.AssetV2 = {
      name = "placeholder";
      payload = {
        ctype = "";
        data = [];
      };
      thumbnail = null;
      metadata = null;
      payloadUrl = null;
      thumbnailUrl = null;
    };

    public func getChunkCount(chunkSize : Nat) : Nat {
      var count = _assets.size() / chunkSize;
      if (_assets.size() % chunkSize != 0) {
        count += 1;
      };
      Nat.max(1, count);
    };

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      let start = Nat.min(_assets.size(), chunkSize * chunkIndex);
      let count = Nat.min(chunkSize, _assets.size() - start);
      let assetsChunk = if (_assets.size() == 0 or count == 0) {
        []
      } else {
        Buffer.toArray(Buffer.subBuffer(_assets, start, count));
      };

      if (chunkIndex == 0) {
        return ?#v2({
          placeholder = _placeholder;
          assetsCount = _assets.size();
          assetsChunk;
        });
      } else if (chunkIndex < getChunkCount(chunkSize)) {
        return ?#v2_chunk({ assetsChunk });
      } else {
        null;
      };
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      let toV2 = func(assets : [Types.Asset]) : [Types.AssetV2] {
        Array.map<Types.Asset, Types.AssetV2>(assets, func(asset) {
          {
            asset with
            payloadUrl = null;
            thumbnailUrl = null;
          };
        });
      };

      switch (chunk) {
        // v1 -> v2
        case (?#v1(data)) {
          _assets := Buffer.Buffer<Types.AssetV2>(data.assetsCount);
          _assets.append(Buffer.fromArray(toV2(data.assetsChunk)));
        };
        case (?#v1_chunk(data)) {
          _assets.append(Buffer.fromArray(toV2(data.assetsChunk)));
        };
        // v2
        case (?#v2(data)) {
          _placeholder := data.placeholder;
          _assets := Buffer.Buffer<Types.AssetV2>(data.assetsCount);
          _assets.append(Buffer.fromArray(data.assetsChunk));
        };
        case (?#v2_chunk(data)) {
          _assets.append(Buffer.fromArray(data.assetsChunk));
        };
        case (null) {};
      };
    };

    public func _checkLegacyAsset(asset : Types.AssetV2) {
      if (asset.thumbnail != null or asset.metadata != null or asset.payload.data.size() != 0) {
        Debug.trap("Legacy asset detected. Please use separate asset canister and add only redirect URLs to the collection");
      };
    };

    //*** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    public func addAssets(caller : Principal, assets : [Types.AssetV2]) : Nat {
      assert (caller == config.minter);
      if (config.singleAssetCollection == ?true) {
        if (Utils.toNanos(config.revealDelay) > 0) {
          assert (_assets.size() < 2);
        } else {
          assert (_assets.size() == 0);
        };
      };
      for (asset in assets.vals()) {
        _checkLegacyAsset(asset);
      };
      _assets.append(Buffer.fromArray(assets));
      _assets.size() - 1;
    };

    public func addPlaceholder(caller : Principal, asset : Types.AssetV2) {
      assert (caller == config.minter);
      _checkLegacyAsset(asset);
      _placeholder := asset;
    };

    /*******************
    * INTERNAL METHODS *
    *******************/

    public func getPlaceholder() : Types.AssetV2 {
      _placeholder;
    };

    public func get(id : Nat) : Types.AssetV2 {
      return _assets.get(id);
    };

    public func put(id : Nat, element : Types.AssetV2) {
      _assets.put(id, element);
    };

    public func add(element : Types.AssetV2) {
      _assets.add(element);
    };

    public func size() : Nat {
      _assets.size();
    };

    public func vals() : Iter.Iter<Types.AssetV2> {
      _assets.vals();
    };
  };
};
