import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

import AssetTypes "../CanisterAssets/Types";
import Buffer "../Buffer";
import ExtCore "../toniq-labs/ext/Core";
import MarketplaceTypes "../Marketplace/Types";
import Types "Types";
import Utils "../Utils";

module {

  public class HttpHandler(this: Principal, state: Types.State) {
    

/*************
* CONSTANTS *
*************/

    let NOT_FOUND : Types.HttpResponse = {status_code = 404; headers = []; body = Blob.fromArray([]); streaming_strategy = null};
    let BAD_REQUEST : Types.HttpResponse = {status_code = 400; headers = []; body = Blob.fromArray([]); streaming_strategy = null};
    
/********************
* PUBLIC INTERFACE *
********************/

    public func http_request_streaming_callback(token : Types.HttpStreamingCallbackToken) : Types.HttpStreamingCallbackResponse {
      switch(Utils.natFromText(token.key)) {
        case null return {body = Blob.fromArray([]); token = null};
        case (?assetid) {
          let asset : AssetTypes.Asset = state._Assets.get(assetid);
          let res = _streamContent(token.key, token.index, asset.payload.data);
          return {
            body = res.0;
            token = res.1;
          };
        };
      };
    };

    public func http_request(request : Types.HttpRequest) : Types.HttpResponse {
      let path = Iter.toArray(Text.tokens(request.url, #text("/")));
      switch(_getParam(request.url, "tokenid")) {
        case (?tokenid) {
          // start custom
          // we assume the seed animation video is stored in index 0
          // and thus uploaded first
          if (not state._Shuffle.isShuffled()){
            return _processFile(Nat.toText(0), state._Assets.get(0).payload);
          };
          // end custom
          switch(state._Tokens.getTokenData(tokenid)) {
            case(?metadata)  {
              let assetid : Nat = Nat32.toNat(Utils.blobToNat32(metadata));
              let asset : AssetTypes.Asset = state._Assets.get(assetid);
              switch(_getParam(request.url, "type")) {
                case(?t) {
                  // start custom
                  switch(t) {
                    case("thumbnail") {
                      switch(asset.thumbnail) {
                        case(?thumb) {
                          return {
                            status_code = 200;
                            headers = [("content-type", thumb.ctype)];
                            body = thumb.data[0];
                            streaming_strategy = null;
                          };
                        };
                        case (_){};
                      };
                    };
                    case("metadata") {
                      switch(asset.metadata) {
                        case(?metadata) {
                          return {
                            status_code = 200;
                            headers = [("content-type", metadata.ctype)];
                            body = metadata.data[0];
                            streaming_strategy = null;
                          };
                        };
                        case (_){};
                      };
                    };
                    case(_){};
                  };
                  // end custom
                };
                case(_) {
                };
              };
              return _processFile(Nat.toText(assetid), asset.payload);
            };
            case (_){};
          };
        };
        case (_){};
      };
      switch(_getParam(request.url, "asset")) {
        case (?atext) {
          switch(Utils.natFromText(atext)){
            case(?assetid){
              let asset : AssetTypes.Asset = state._Assets.get(assetid);
              switch(_getParam(request.url, "type")) {
                case(?t) {
                  // start custom
                  switch(t) {
                    case("thumbnail") {
                      switch(asset.thumbnail) {
                        case(?thumb) {
                          return {
                            status_code = 200;
                            headers = [("content-type", thumb.ctype)];
                            body = thumb.data[0];
                          streaming_strategy = null;
                          };
                        };
                        case (_){};
                      };
                    };
                    case("metadata") {
                      switch(asset.metadata) {
                        case(?metadata) {
                          return {
                            status_code = 200;
                            headers = [("content-type", metadata.ctype)];
                            body = metadata.data[0];
                            streaming_strategy = null;
                          };
                        };
                        case (_){};
                      };
                    };
                    case(_){};
                  };
                  // end custom
                };
                case(_) {
                };
              };
              return _processFile(Nat.toText(assetid), asset.payload);
            };
            case (_){};
          };
        };
        case (_){};
      };

      /**********************
      * TOKEN INDEX LOOKUP *
      **********************/
      // check if theres a path
      switch (path.size()) {
        // check if there's only on "argument" to it
        case 1 {
          // try and convert it to a Nat from Text
          switch(Utils.natFromText(path[0])) {
            // if that works, use that
            case (?tokenIndex) {
              switch (state._Tokens.getTokenDataFromIndex(Nat32.fromNat(tokenIndex))) {
                case (?assetIdBlob) {
                  let assetid : Nat = Nat32.toNat(Utils.blobToNat32(assetIdBlob));
                  let asset : AssetTypes.Asset = state._Assets.get(assetid);
                  return _processFile(Nat.toText(assetid), asset.payload);
                };
                case (_) {};
              };
            };
            case (_) {};
          };
        };
        case (_) {};
      };
      
      //Just show index
      var soldValue : Nat = Nat64.toNat(Array.foldLeft<MarketplaceTypes.Transaction, Nat64>(state._Marketplace.getTransactions().toArray(), 0, func (b : Nat64, a : MarketplaceTypes.Transaction) : Nat64 { b + a.price }));
      var avg : Nat = if (state._Marketplace.transactionsSize() > 0) {
        soldValue/state._Marketplace.transactionsSize();
      } else {
        0;
      };
      return {
        status_code = 200;
        headers = [("content-type", "text/plain")];
        body = Text.encodeUtf8 (
          "BTC Flower \n" #
          "---\n" #
          "Cycle Balance:                            ~" # debug_show (Cycles.balance()/1000000000000) # "T\n" #
          "Minted NFTs:                              " # debug_show (state._Tokens.getNextTokenId()) # "\n" #
          "Marketplace Listings:                     " # debug_show (state._Marketplace.tokenListingSize()) # "\n" #
          "Sold via Marketplace:                     " # debug_show (state._Marketplace.transactionsSize()) # "\n" #
          "Sold via Marketplace in ICP:              " # _displayICP(soldValue) # "\n" #
          "Average Price ICP Via Marketplace:        " # _displayICP(avg) # "\n" #
          "Admin:                                    " # debug_show (state._Tokens.getMinter()) # "\n"
        );
        streaming_strategy = null;
      };
    };

/********************
* INTERNAL METHODS *
********************/

    private func _processFile(tokenid : ExtCore.TokenIdentifier, file : AssetTypes.File) : Types.HttpResponse {
      // start custom
      let self: Principal = this;
      let canisterId: Text = Principal.toText(self);
      let canister = actor (canisterId) : actor { http_request_streaming_callback : shared () -> async () };
      // end custom

      if (file.data.size() > 1 ) {
        let (payload, token) = _streamContent(tokenid, 0, file.data);
        return {
          // start custom
          status_code = 200;
          headers = [
            ("Content-Type", file.ctype), 
            ("Cache-Control", "public, max-age=15552000"),
            ("Access-Control-Expose-Headers","Content-Length, Content-Range"),
            ("Access-Control-Allow-Methods", "GET, POST, HEAD, OPTIONS"),
            ("Access-Control-Allow-Origin", "*"),
            ("Content-Length","3576448"),
            ("Accept-Ranges","bytes"),
          ];
          // end custom
          body = payload;
          streaming_strategy = ?#Callback({
            token = Option.unwrap(token);
            callback = canister.http_request_streaming_callback;
          });
        };
      } else {
        return {
          status_code = 200;
          headers = [("content-type", file.ctype), ("cache-control", "public, max-age=15552000")];
          body = file.data[0];
          streaming_strategy = null;
        };
      };
    };

    private func _streamContent(id : Text, idx : Nat, data : [Blob]) : (Blob, ?Types.HttpStreamingCallbackToken) {
      let payload = data[idx];
      let size = data.size();

      if (idx + 1 == size) {
        return (payload, null);
      };

      return (payload, ?{
        content_encoding = "gzip";
        index = idx + 1;
        sha256 = null;
        key = id;
      });
    };

    private func _displayICP(amt : Nat) : Text {
      debug_show(amt/100000000) # "." # debug_show ((amt%100000000)/1000000) # " ICP";
    };

    private func _getParam(url : Text, param : Text) : ?Text {
      var _s : Text = url;
      Iter.iterate<Text>(Text.split(_s, #text("/")), func(x, _i) {
        _s := x;
      });
      Iter.iterate<Text>(Text.split(_s, #text("?")), func(x, _i) {
        if (_i == 1) _s := x;
      });
      var t : ?Text = null;
      var found : Bool = false;
      Iter.iterate<Text>(Text.split(_s, #text("&")), func(x, _i) {
        if (found == false) {
          Iter.iterate<Text>(Text.split(x, #text("=")), func(y, _ii) {
            if (_ii == 0) {
              if (Text.equal(y, param)) found := true;
            } else if (found == true) t := ?y;
          });
        };
      });
      return t;
    };




  }
}