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

module {

  public class Factory(config : RootTypes.Config) {

    /*********
    * STATE *
    *********/

    var _assets = Buffer.Buffer<Types.AssetV2>(0);
    var _isShuffled = false;

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

    let _bytesPerChunk = 500_000; // 500kb
    var _biggestAssetSize = 10_000; // 10kb

    public func getChunkCount() : Nat {
      var count = _assets.size() * _biggestAssetSize / _bytesPerChunk;
      if (_assets.size() * _biggestAssetSize % _bytesPerChunk != 0) {
        count += 1;
      };
      return Nat.max(1, count);
    };

    public func toStableChunk(chunkSize_ignored : Nat, chunkIndex : Nat) : Types.StableChunk {
      let chunkSize = _bytesPerChunk / _biggestAssetSize;
      let start = Nat.min(_assets.size(), chunkSize * chunkIndex);
      let count = Nat.min(chunkSize, _assets.size() - start);
      let assetsChunk = if (_assets.size() == 0 or count == 0) {
        []
      }
      else {
        Buffer.toArray(Buffer.subBuffer(_assets, start, count));
      };

      if (chunkIndex == 0) {
        return ?#v3({
          placeholder = _placeholder;
          assetsCount = _assets.size();
          assetsChunk;
          isShuffled = _isShuffled;
        });
      }
      else if (chunkIndex < getChunkCount()) {
        return ?#v3_chunk({ assetsChunk });
      }
      else {
        null;
      };
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        // v2 -> v3
        case (?#v2(data)) {
          _assets := Buffer.Buffer<Types.AssetV2>(data.assetsCount);
          _assets.append(Buffer.fromArray(data.assetsChunk));
          _updateBiggestAssetSize(data.assetsChunk);
          _isShuffled := true;
        };
        case (?#v2_chunk(data)) {
          _assets.append(Buffer.fromArray(data.assetsChunk));
          _updateBiggestAssetSize(data.assetsChunk);
        };
        // v3
        case (?#v3(data)) {
          _placeholder := data.placeholder;
          _assets := Buffer.Buffer<Types.AssetV2>(data.assetsCount);
          _assets.append(Buffer.fromArray(data.assetsChunk));
          _updateBiggestAssetSize(data.assetsChunk);
          _isShuffled := data.isShuffled;
        };
        case (?#v3_chunk(data)) {
          _assets.append(Buffer.fromArray(data.assetsChunk));
          _updateBiggestAssetSize(data.assetsChunk);
        };
        case (null) {};
      };
    };

    func _updateBiggestAssetSize(assets : [Types.Asset]) {
      for (asset in assets.vals()) {
        var assetSize = asset.payload.data.size();
        switch (asset.thumbnail) {
          case (?thumbnail) {
            assetSize += thumbnail.data.size();
          };
          case (null) {};
        };
        _biggestAssetSize := Nat.max(_biggestAssetSize, assetSize);
      };
    };

    //*** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    // legacy
    public func streamAsset(caller : Principal, id : Nat, isThumb : Bool, payload : Blob) : () {
      assert (caller == config.minter);
      var asset : Types.AssetV2 = _assets.get(id);
      if (isThumb) {
        switch (asset.thumbnail) {
          case (?t) {
            asset := {
              name = asset.name;
              thumbnail = ?{
                ctype = t.ctype;
                data = Array.append(t.data, [payload]);
              };
              payload = asset.payload;
              metadata = asset.metadata;
              payloadUrl = asset.payloadUrl;
              thumbnailUrl = asset.thumbnailUrl;
            };
          };
          case (_) {};
        };
      } else {
        asset := {
          name = asset.name;
          thumbnail = asset.thumbnail;
          payload = {
            ctype = asset.payload.ctype;
            data = Array.append(asset.payload.data, [payload]);
          };
          metadata = asset.metadata;
          payloadUrl = asset.payloadUrl;
          thumbnailUrl = asset.thumbnailUrl;
        };
      };
      _assets.put(id, asset);
      _updateBiggestAssetSize([asset]);
    };

    // legacy
    public func updateThumb(caller : Principal, name : Text, file : Types.File) : ?Nat {
      assert (caller == config.minter);
      var i : Nat = 0;
      for (a in _assets.vals()) {
        if (a.name == name) {
          var asset : Types.AssetV2 = _assets.get(i);
          asset := {
            name = asset.name;
            thumbnail = ?file;
            payload = asset.payload;
            metadata = asset.metadata;
            payloadUrl = asset.payloadUrl;
            thumbnailUrl = asset.thumbnailUrl;
          };
          _assets.put(i, asset);
          _updateBiggestAssetSize([asset]);
          return ?i;
        };
        i += 1;
      };
      return null;
    };

    // legacy
    public func addAsset(caller : Principal, asset : Types.AssetV2) : Nat {
      assert (caller == config.minter);
      if (config.singleAssetCollection == ?true) {
        if (Utils.toNanos(config.revealDelay) > 0) {
          assert (_assets.size() < 2);
        } else {
          assert (_assets.size() == 0);
        };
      };
      _assets.add(asset);
      _updateBiggestAssetSize([asset]);
      _assets.size() - 1;
    };

    public func addAssets(caller : Principal, assets : [Types.AssetV2]) : Nat {
      assert (caller == config.minter);
      if (config.singleAssetCollection == ?true) {
        if (Utils.toNanos(config.revealDelay) > 0) {
          assert (_assets.size() < 2);
        } else {
          assert (_assets.size() == 0);
        };
      };
      _assets.append(Buffer.fromArray(assets));
      _updateBiggestAssetSize(assets);
      _assets.size() - 1;
    };

    public func addPlaceholder(caller : Principal, asset : Types.AssetV2) {
      assert (caller == config.minter);
      _placeholder := asset;
    };

    public func shuffleAssets() : async () {
      assert (Utils.toNanos(config.revealDelay) > 0 and not _isShuffled);
      let seed : Blob = await Random.blob();
      Utils.shuffleBuffer(_assets, seed);
      _isShuffled := true;
    };

    public func isShuffled() : Bool {
      _isShuffled;
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
