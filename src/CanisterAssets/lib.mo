import Array "mo:base/Array";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";

import Types "types";
import Utils "../utils";
import Env "../Env";

module {

  public class Factory(state : Types.StableState, consts : Types.Constants) {

    /*********
    * STATE *
    *********/

    private var _assets : Buffer.Buffer<Types.Asset> = Buffer.fromArray(state._assetsState);

    public func toStable() : Types.StableState {
      return {
        _assetsState = Buffer.toArray(_assets);
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
