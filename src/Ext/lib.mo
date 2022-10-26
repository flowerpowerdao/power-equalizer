import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Root "mo:cap/Root";

import AID "../toniq-labs/util/AccountIdentifier";
import Buffer "../buffer";
import ExtCore "../toniq-labs/ext/Core";
import MarketplaceTypes "../Marketplace/types";
import Types "types";

module {
  public class Factory(this : Principal, deps : Types.Dependencies, consts : Types.Constants) {

    /*************
* CONSTANTS *
*************/

    private let EXTENSIONS : [Types.Extension] = ["@ext/common", "@ext/nonfungible"];

    /********************
* PUBLIC INTERFACE *
********************/

    public func getMinter() : Principal {
      consts.minter
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
      resp.toArray();
    };

    public func getTokenToAssetMapping() : [(Types.TokenIndex, Text)] {
      var resp : Buffer.Buffer<(Types.TokenIndex, Text)> = Buffer.Buffer(0);
      for (e in deps._Tokens.getTokenMetadata().entries()) {
        let assetid = deps._Assets.get(Nat32.toNat(e.0) +1).name;
        resp.add((e.0, assetid));
      };
      resp.toArray();
    };

    public func tokens(aid : Types.AccountIdentifier) : Result.Result<[Types.TokenIndex], Types.CommonError> {
      switch (deps._Tokens.getTokensFromOwner(aid)) {
        case (?tokens) return #ok(tokens.toArray());
        case (_) return #err(#Other("No tokens"));
      };
    };

    public func tokens_ext(aid : Types.AccountIdentifier) : Result.Result<[(Types.TokenIndex, ?MarketplaceTypes.Listing, ?Blob)], Types.CommonError> {
      switch (deps._Tokens.getTokensFromOwner(aid)) {
        case (?tokens) {
          var resp : Buffer.Buffer<(Types.TokenIndex, ?Types.Listing, ?Blob)> = Buffer.Buffer(0);
          for (a in tokens.vals()) {
            resp.add((a, deps._Marketplace.getListingFromTokenListing(a), null));
          };
          return #ok(resp.toArray());
        };
        case (_) return #err(#Other("No tokens"));
      };
    };

    public func metadata(token : Types.TokenIdentifier) : Result.Result<Types.Metadata, Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(token, this) == false) {
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

    public func transfer(caller : Principal, request : Types.TransferRequest) : async Types.TransferResponse {
      if (request.amount != 1) {
        return #err(#Other("Must use amount of 1"));
      };
      if (ExtCore.TokenIdentifier.isPrincipal(request.token, this) == false) {
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
          if (request.notify) {
            switch (ExtCore.User.toPrincipal(request.to)) {
              case (?canisterId) {
                //Do this to avoid atomicity issue
                deps._Tokens.removeTokenFromUser(token);
                let notifier : Types.NotifyService = actor (Principal.toText(canisterId));
                switch (await notifier.tokenTransferNotification(request.token, request.from, request.amount, request.memo)) {
                  case (?balance) {
                    if (balance == 1) {
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
                      deps._Tokens.transferTokenToUser(token, receiver);
                      return #ok(request.amount);
                    } else {
                      //Refund
                      deps._Tokens.transferTokenToUser(token, owner);
                      return #err(#Rejected);
                    };
                  };
                  case (_) {
                    //Refund
                    deps._Tokens.transferTokenToUser(token, owner);
                    return #err(#Rejected);
                  };
                };
              };
              case (_) {
                return #err(#CannotNotify(receiver));
              };
            };
          } else {
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
            deps._Tokens.transferTokenToUser(token, receiver);
            return #ok(request.amount);
          };
        };
        case (_) {
          return #err(#InvalidToken(request.token));
        };
      };
    };

  };
};
