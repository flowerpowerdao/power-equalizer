import Array "mo:base/Array";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";

import Types "types";
import Utils "../utils";
import Env "../Env";

module {

  public class Factory(consts : Types.Constants) {

    /*********
    * STATE *
    *********/

    var _assets = Buffer.Buffer<Types.Asset>(0);

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
      let start = chunkSize * chunkIndex;
      let assetsChunk = if (_assets.size() == 0) {
        []
      }
      else {
        Buffer.toArray(Buffer.subBuffer(_assets, start, Nat.min(chunkSize, _assets.size() - start)));
      };

      if (chunkIndex == 0) {
        return ?#v1({
          assetsCount = _assets.size();
          assetsChunk;
        });
      }
      else if (chunkIndex <= getChunkCount()) {
        return ?#v1_chunk({ assetsChunk });
      }
      else {
        null;
      };
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        // TODO: remove after upgrade vvv
        case (?#legacy(state)) {
          _assets := Buffer.fromArray(state._assetsState);
          _updateBiggestAssetSize();
        };
        // TODO: remove after upgrade ^^^
        case (?#v1(data)) {
          _assets := Buffer.Buffer<Types.Asset>(data.assetsCount);
          _assets.append(Buffer.fromArray(data.assetsChunk));
        };
        case (?#v1_chunk(data)) {
          _assets.append(Buffer.fromArray(data.assetsChunk));
        };
        case (null) {};
      };
    };

    func _updateBiggestAssetSize() {
      for (asset in _assets.vals()) {
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

    public func streamAsset(caller : Principal, id : Nat, isThumb : Bool, payload : Blob) : () {
      assert (caller == consts.minter);
      var asset : Types.Asset = _assets.get(id);
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
        };
      };
      _assets.put(id, asset);
    };

    public func updateThumb(caller : Principal, name : Text, file : Types.File) : ?Nat {
      assert (caller == consts.minter);
      var i : Nat = 0;
      for (a in _assets.vals()) {
        if (a.name == name) {
          var asset : Types.Asset = _assets.get(i);
          asset := {
            name = asset.name;
            thumbnail = ?file;
            payload = asset.payload;
            metadata = asset.metadata;
          };
          _assets.put(i, asset);
          return ?i;
        };
        i += 1;
      };
      return null;
    };

    public func addAsset(caller : Principal, asset : Types.Asset) : Nat {
      assert (caller == consts.minter);
      if (Env.singleAssetCollection) {
        if (Env.delayedReveal) {
          assert (_assets.size() < 2);
        } else {
          assert (_assets.size() == 0);
        };
      };
      _assets.add(asset);
      _assets.size() - 1;
    };

    /*******************
    * INTERNAL METHODS *
    *******************/

    public func get(id : Nat) : Types.Asset {
      return _assets.get(id);
    };

    public func put(id : Nat, element : Types.Asset) {
      _assets.put(id, element);
    };

    public func add(element : Types.Asset) {
      _assets.add(element);
    };

    public func size() : Nat {
      _assets.size();
    };

    public func vals() : Iter.Iter<Types.Asset> {
      _assets.vals();
    };

  };
};
