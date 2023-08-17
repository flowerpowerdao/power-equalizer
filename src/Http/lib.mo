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
import Buffer "mo:base/Buffer";

import AssetTypes "../CanisterAssets/types";
import ExtCore "../toniq-labs/ext/Core";
import MarketplaceTypes "../Marketplace/types";
import Types "types";
import RootTypes "../types";
import Utils "../utils";

module {

  public class HttpHandler(config : RootTypes.Config, deps : Types.Dependencies) {

    /********************
    * PUBLIC INTERFACE *
    ********************/

    public func http_request_streaming_callback(token : Types.HttpStreamingCallbackToken) : Types.HttpStreamingCallbackResponse {
      switch (Utils.natFromText(token.key)) {
        case null return { body = Blob.fromArray([]); token = null };
        case (?assetid) {
          let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
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
      switch (_getParam(request.url, "tokenid")) {
        case (?tokenid) {
          // start custom
          // if not revealed yet, return placeholder
          if (Utils.toNanos(config.revealDelay) > 0 and not deps._Assets.isShuffled()) {
            let placeholder = deps._Assets.getPlaceholder();
            return _processFile("placeholder", placeholder.payload, placeholder.payloadUrl);
          };
          // end custom
          switch (deps._Tokens.getTokenData(tokenid)) {
            case (?metadata) {
              let assetid : Nat = Nat32.toNat(Utils.blobToNat32(metadata));
              let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
              // start custom
              switch (_processAsset(request, asset)) {
                case (?response) {
                  return response;
                };
                case (null) {};
              };
              // end custom
              return _processFile(Nat.toText(assetid), asset.payload, asset.payloadUrl);
            };
            case (_) {};
          };
        };
        case (_) {};
      };
      switch (_getParam(request.url, "asset")) {
        case (?atext) {
          switch (Utils.natFromText(atext)) {
            case (?assetid) {
              let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
              // start custom
              switch (_processAsset(request, asset)) {
                case (?response) {
                  return response;
                };
                case (null) {};
              };
              // end custom
              return _processFile(Nat.toText(assetid), asset.payload, asset.payloadUrl);
            };
            case (_) {};
          };
        };
        case (_) {};
      };

      /**********************
      * TOKEN INDEX LOOKUP *
      **********************/

      // check if there's only on "argument" to it
      if (path.size() == 1) {
        let parts = Iter.toArray(Text.split(path[0], #text("?")));
        // try and convert it to a Nat from Text
        switch (Utils.natFromText(parts[0])) {
          // if that works, use that
          case (?tokenIndex) {
            switch (deps._Tokens.getTokenDataFromIndex(Nat32.fromNat(tokenIndex))) {
              case (?assetIdBlob) {
                let assetid : Nat = Nat32.toNat(Utils.blobToNat32(assetIdBlob));
                let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
                // start custom
                switch (_processAsset(request, asset)) {
                  case (?response) {
                    return response;
                  };
                  case (null) {};
                };
                // end custom
                return _processFile(Nat.toText(assetid), asset.payload, asset.payloadUrl);
              };
              case (_) {};
            };
          };
          case (_) {};
        };
      };

      // Just show index
      var soldValue : Nat = Nat64.toNat(
        Array.foldLeft<MarketplaceTypes.TransactionV2, Nat64>(
          Buffer.toArray(deps._Marketplace.getTransactions()),
          0,
          func(b : Nat64, a : MarketplaceTypes.TransactionV2) : Nat64 {
            b + a.price;
          },
        ),
      );
      var avg : Nat = if (deps._Marketplace.transactionsSize() > 0) {
        soldValue / deps._Marketplace.transactionsSize();
      } else {
        0;
      };

      var whitelistsText = "";
      for (whitelist in config.whitelists.vals()) {
        whitelistsText #= whitelist.name # " " # _displayICP(Nat64.toNat(whitelist.price)) # "start: " # debug_show (whitelist.startTime) # ", end: " # debug_show (whitelist.endTime) # "; ";
      };

      return {
        status_code = 200;
        headers = [("content-type", "text/plain")];
        body = Text.encodeUtf8(
          config.name # "\n" # "---\n"
          # "Cycle Balance:                            ~" # debug_show (Cycles.balance() / 1000000000000) # "T\n"
          # "Minted NFTs:                              " # debug_show (deps._Tokens.getNextTokenId()) # "\n"
          # "Assets:                                   " # debug_show (deps._Assets.size()) # "\n" # "---\n"
          # "Whitelists:                               " # whitelistsText # "\n"
          # "Total to sell:                            " # debug_show (deps._Sale.getTotalToSell()) # "\n"
          # "Remaining:                                " # debug_show (deps._Sale.availableTokens()) # "\n"
          # "Sold:                                     " # debug_show (deps._Sale.getSold()) # "\n"
          # "Sold (ICP):                               " # _displayICP(Nat64.toNat(deps._Sale.soldIcp())) # "\n" # "---\n"
          # "Marketplace Listings:                     " # debug_show (deps._Marketplace.tokenListingSize()) # "\n"
          # "Sold via Marketplace:                     " # debug_show (deps._Marketplace.transactionsSize()) # "\n"
          # "Sold via Marketplace in ICP:              " # _displayICP(soldValue) # "\n"
          # "Average Price ICP Via Marketplace:        " # _displayICP(avg) # "\n"
          # "Admin:                                    " # debug_show (config.minter) # "\n",
        );
        streaming_strategy = null;
      };
    };

    /********************
    * INTERNAL METHODS *
    ********************/

    func _processAsset(request : Types.HttpRequest, asset : AssetTypes.AssetV2) : ?Types.HttpResponse {
      let t = switch (_getParam(request.url, "type")) {
        case (?t) { t };
        case (null) {
          return null;
        };
      };
      if (t == "thumbnail") {
        // redirect thumbnail
        switch (asset.thumbnailUrl) {
          case (?thumbnailUrl) {
            return ?_redirect(thumbnailUrl);
          };
          case (_) {};
        };

        switch (asset.thumbnail) {
          case (?thumb) {
            return ?{
              status_code = 200;
              headers = [("content-type", thumb.ctype)];
              body = thumb.data[0];
              streaming_strategy = null;
            };
          };
          case (_) {};
        };
      } else if (t == "metadata") {
        switch (asset.metadata) {
          case (?metadata) {
            return ?{
              status_code = 200;
              headers = [("content-type", metadata.ctype)];
              body = metadata.data[0];
              streaming_strategy = null;
            };
          };
          case (_) {};
        };
      };
      return null;
    };

    private func _processFile(tokenid : ExtCore.TokenIdentifier, file : AssetTypes.File, redirectUrlOpt : ?Text) : Types.HttpResponse {
      switch (redirectUrlOpt) {
        case (?redirectUrl) {
          return _redirect(redirectUrl);
        };
        case (null) {};
      };

      // start custom
      let self : Principal = config.canister;
      let canisterId : Text = Principal.toText(self);
      let canister = actor (canisterId) : actor {
        http_request_streaming_callback : shared () -> async ();
      };
      // end custom

      if (file.data.size() > 1) {
        let (payload, token) = _streamContent(tokenid, 0, file.data);
        let contentLength = Array.foldLeft<Blob, Nat>(file.data, 0, func(total, blob) = total + blob.size());
        return {
          // start custom
          status_code = 200;
          headers = [
            ("Content-Type", file.ctype),
            ("Cache-Control", "public, max-age=15552000"),
            ("Access-Control-Expose-Headers", "Content-Length, Content-Range"),
            ("Access-Control-Allow-Methods", "GET, POST, HEAD, OPTIONS"),
            ("Access-Control-Allow-Origin", "*"),
            ("Content-Length", Nat.toText(contentLength)),
            ("Accept-Ranges", "bytes"),
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

      return (
        payload,
        ?{
          content_encoding = "gzip";
          index = idx + 1;
          sha256 = null;
          key = id;
        },
      );
    };

    func _redirect(url : Text) : Types.HttpResponse {
      {
        status_code = 302;
        headers = [
          ("Location", url),
        ];
        body = Blob.fromArray([]);
        streaming_strategy = null;
      }
    };

    private func _displayICP(amt : Nat) : Text {
      debug_show (amt / 100000000) # "." # debug_show ((amt % 100000000) / 1000000) # " ICP";
    };

    private func _getParam(url : Text, param : Text) : ?Text {
      var _s : Text = url;
      Iter.iterate<Text>(
        Text.split(_s, #text("/")),
        func(x, _i) {
          _s := x;
        },
      );
      Iter.iterate<Text>(
        Text.split(_s, #text("?")),
        func(x, _i) {
          if (_i == 1) _s := x;
        },
      );
      var t : ?Text = null;
      var found : Bool = false;
      Iter.iterate<Text>(
        Text.split(_s, #text("&")),
        func(x, _i) {
          if (found == false) {
            Iter.iterate<Text>(
              Text.split(x, #text("=")),
              func(y, _ii) {
                if (_ii == 0) {
                  if (Text.equal(y, param)) found := true;
                } else if (found == true) t := ?y;
              },
            );
          };
        },
      );
      return t;
    };

  };
};
