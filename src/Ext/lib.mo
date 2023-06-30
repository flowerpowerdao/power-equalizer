import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";

import Root "mo:cap/Root";

import AID "../toniq-labs/util/AccountIdentifier";
import ExtCore "../toniq-labs/ext/Core";
import MarketplaceTypes "../Marketplace/types";
import Types "types";
import Utils "../utils";
import RootTypes "../types";

module {
  public class Factory(config : RootTypes.Config, deps : Types.Dependencies) {

    /*************
    * CONSTANTS *
    *************/

    private let EXTENSIONS : [Types.Extension] = ["@ext/common", "@ext/nonfungible"];

    /********************
    * PUBLIC INTERFACE *
    ********************/

    public func getMinter() : Principal {
      config.minter;
    };

    public func extensions() : [Types.Extension] {
      EXTENSIONS;
    };

    public func supply() : Result.Result<Types.Balance, Types.CommonError> {
      #ok(deps._Tokens.getSupply());
    };

    public func getRegistry() : [(Types.TokenIndex, Types.AccountIdentifier)] {
      Iter.toArray(deps._Tokens.getRegistry().entries());

    };

    public func getTokens() : [(Types.TokenIndex, Types.Metadata)] {
      var resp : Buffer.Buffer<(Types.TokenIndex, Types.Metadata)> = Buffer.Buffer(0);
      for (e in deps._Tokens.getTokenMetadata().entries()) {
        resp.add((e.0, #nonfungible({ metadata = null })));
      };
      Buffer.toArray(resp);
    };

    public func getTokenToAssetMapping() : [(Types.TokenIndex, Text)] {
      var resp : Buffer.Buffer<(Types.TokenIndex, Text)> = Buffer.Buffer(0);
      // legacy placeholder is stored in asset 0
      let startIndex = if (config.legacyPlaceholder == ?true and Utils.toNanos(config.revealDelay) > 0) { 1 } else { 0 };
      for (e in deps._Tokens.getTokenMetadata().entries()) {
        let assetid = deps._Assets.get(if (config.singleAssetCollection == ?true) startIndex else Nat32.toNat(e.0) + startIndex).name;
        resp.add((e.0, assetid));
      };
      Buffer.toArray(resp);
    };

    public func tokens(aid : Types.AccountIdentifier) : Result.Result<[Types.TokenIndex], Types.CommonError> {
      switch (deps._Tokens.getTokensFromOwner(aid)) {
        case (?tokens) return #ok(Buffer.toArray(tokens));
        case (_) return #err(#Other("No tokens"));
      };
    };

    public func tokens_ext(aid : Types.AccountIdentifier) : Result.Result<[(Types.TokenIndex, ?MarketplaceTypes.Listing, ?Blob)], Types.CommonError> {
      switch (deps._Tokens.getTokensFromOwner(aid)) {
        case (?tokens) {
          var resp : Buffer.Buffer<(Types.TokenIndex, ?MarketplaceTypes.Listing, ?Blob)> = Buffer.Buffer(0);
          for (a in tokens.vals()) {
            resp.add((a, deps._Marketplace.getListingFromTokenListing(a), null));
          };
          return #ok(Buffer.toArray(resp));
        };
        case (_) return #err(#Other("No tokens"));
      };
    };

    public func metadata(token : Types.TokenIdentifier) : Result.Result<Types.Metadata, Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(token, config.canister) == false) {
        return #err(#InvalidToken(token));
      };
      let tokenind = ExtCore.TokenIdentifier.getIndex(token);
      switch (deps._Tokens.getMetadataFromTokenMetadata(tokenind)) {
        case (?token_metadata) {
          return #ok(token_metadata);
        };
        case (_) {
          return #err(#InvalidToken(token));
        };
      };
    };

    public func transfer(caller : Principal, request : Types.TransferRequest) : async* Types.TransferResponse {
      if (request.amount != 1) {
        return #err(#Other("Must use amount of 1"));
      };
      if (ExtCore.TokenIdentifier.isPrincipal(request.token, config.canister) == false) {
        return #err(#InvalidToken(request.token));
      };
      let token = ExtCore.TokenIdentifier.getIndex(request.token);
      if (Option.isSome(deps._Marketplace.getListingFromTokenListing(token))) {
        return #err(#Other("This token is currently listed for sale!"));
      };
      let owner = ExtCore.User.toAID(request.from);
      let spender = AID.fromPrincipal(caller, request.subaccount);
      let receiver = ExtCore.User.toAID(request.to);
      if (AID.equal(owner, spender) == false) {
        return #err(#Unauthorized(spender));
      };

      switch (deps._Tokens.getOwnerFromRegistry(token)) {
        case (?token_owner) {
          if (AID.equal(owner, token_owner) == false) {
            return #err(#Unauthorized(owner));
          };

          // start custom
          let event : Root.IndefiniteEvent = {
            operation = "transfer";
            details = [
              ("to", #Text receiver),
              ("from", #Text owner),
              ("token_id", #Text(request.token)),
            ];
            caller = caller;
          };
          ignore deps._Cap.insert(event);
          // end custom

          deps._Tokens.transferTokenToUser(token, receiver); // actual transfer

          return #ok(request.amount);
        };
        case (_) {
          return #err(#InvalidToken(request.token));
        };
      };
    };

  };
};
