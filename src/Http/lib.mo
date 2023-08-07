import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";

import HttpParser "mo:http-parser";

import AssetTypes "../CanisterAssets/types";
import MarketplaceTypes "../Marketplace/types";
import Types "types";
import RootTypes "../types";
import Utils "../utils";

module {

  public class HttpHandler(config : RootTypes.Config, deps : Types.Dependencies) {

    /********************
    * PUBLIC INTERFACE *
    ********************/

    public func http_request(request : Types.HttpRequest) : Types.HttpResponse {
      // by token id
      // https://.../?tokenid=<tokenId>
      ignore do ? {
        let tokenId = _getParam(request, "tokenid")!;

        // if not revealed yet, return placeholder
        if (Utils.toNanos(config.revealDelay) > 0 and not deps._Shuffle.isShuffled()) {
          let placeholder = deps._Assets.getPlaceholder();
          switch (placeholder.payloadUrl) {
            case (?payloadUrl) return _redirect(payloadUrl);
            case (null) return _collectionInfo();
          };
        };

        let metadata = deps._Tokens.getTokenData(tokenId)!;
        let assetid : Nat = Nat32.toNat(Utils.blobToNat32(metadata));
        let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
        return _processAsset(request, asset);
      };

      // by asset id
      // https://.../?asset=<assetId>
      ignore do ? {
        let atext = _getParam(request, "asset")!;
        let assetid = Utils.natFromText(atext)!;
        let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
        return _processAsset(request, asset);
      };

      /**********************
      * TOKEN INDEX LOOKUP *
      * * * * * * * * * * *
      * https://.../<tokenIndex>
      * https://.../<tokenIndex>?type=metadata
      * https://.../<tokenIndex>?type=thumbnail
      **********************/

      let path = Iter.toArray(Text.tokens(request.url, #text("/")));

      if (path.size() == 1) {
        ignore do ? {
          let parts = Iter.toArray(Text.split(path[0], #text("?")));
          let tokenIndex = Utils.natFromText(parts[0])!;
          let assetIdBlob = deps._Tokens.getTokenDataFromIndex(Nat32.fromNat(tokenIndex))!;
          let assetid : Nat = Nat32.toNat(Utils.blobToNat32(assetIdBlob));
          let asset : AssetTypes.AssetV2 = deps._Assets.get(assetid);
          return _processAsset(request, asset);
        };
      };

      // just show collection info
      _collectionInfo();
    };

    /********************
    * INTERNAL METHODS *
    ********************/

    func _processAsset(request : Types.HttpRequest, asset : AssetTypes.AssetV2) : Types.HttpResponse {
      let t = switch (_getParam(request, "type")) {
        case (?t) { t };
        case (null) { "" };
      };

      // return metadata
      if (t == "metadata") {
        let ?metadata = asset.metadata else return _collectionInfo();
        return {
          status_code = 200;
          headers = [("content-type", metadata.ctype)];
          body = metadata.data[0];
          streaming_strategy = null;
        };
      };

      // redirect thumbnail
      if (t == "thumbnail") {
        ignore do ? {
          let thumbnailUrl = asset.thumbnailUrl!;
          return _redirect(thumbnailUrl);
        };
      };

      // redirect payload or show collection info
      let ?payloadUrl = asset.payloadUrl else return _collectionInfo();
      return _redirect(payloadUrl);
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

    func _collectionInfo() : Types.HttpResponse {
      var soldValue : Nat = Nat64.toNat(
        Array.foldLeft<MarketplaceTypes.Transaction, Nat64>(
          Buffer.toArray(deps._Marketplace.getTransactions()),
          0,
          func(b : Nat64, a : MarketplaceTypes.Transaction) : Nat64 {
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

    func _displayICP(amt : Nat) : Text {
      debug_show (amt / 100000000) # "." # debug_show ((amt % 100000000) / 1000000) # " ICP";
    };

    func _getParam(request : Types.HttpRequest, param : Text) : ?Text {
      let req = HttpParser.parse(request);
      return req.url.queryObj.get(param);
    };
  };
};
