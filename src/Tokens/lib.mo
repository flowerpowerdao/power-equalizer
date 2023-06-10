import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat32 "mo:base/Nat32";

import AID "../toniq-labs/util/AccountIdentifier";
import ExtCore "../toniq-labs/ext/Core";
import Types "types";
import RootTypes "../types";
import Utils "../utils";

module {
  public class Factory(config : RootTypes.Config) {

    /*********
    * STATE *
    *********/

    var _tokenMetadata = TrieMap.TrieMap<Types.TokenIndex, Types.Metadata>(ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    var _owners = TrieMap.TrieMap<Types.AccountIdentifier, Buffer.Buffer<Types.TokenIndex>>(AID.equal, AID.hash);
    var _registry = TrieMap.TrieMap<Types.TokenIndex, Types.AccountIdentifier>(ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
    var _nextTokenId = 0 : Types.TokenIndex;
    var _supply = 0 : Types.Balance;

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      ?#v1({
        tokenMetadata = Iter.toArray(_tokenMetadata.entries());
        owners = Iter.toArray(
          Iter.map<(Types.AccountIdentifier, Buffer.Buffer<Types.TokenIndex>), (Types.AccountIdentifier, [Types.TokenIndex])>(
            _owners.entries(),
            func(owner) {
              return (owner.0, Buffer.toArray(owner.1));
            },
          ),
        );
        registry = Iter.toArray(_registry.entries());
        nextTokenId = _nextTokenId;
        supply = _supply;
      });
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        case (?#v1(data)) {
          _tokenMetadata := TrieMap.fromEntries(data.tokenMetadata.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _owners := Utils.bufferTrieMapFromIter(data.owners.vals(), AID.equal, AID.hash);
          _registry := TrieMap.fromEntries(data.registry.vals(), ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
          _nextTokenId := data.nextTokenId;
          _supply := data.supply;
        };
        case (null) {};
      };
    };

    //*** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    public func balance(request : Types.BalanceRequest) : Types.BalanceResponse {
      if (ExtCore.TokenIdentifier.isPrincipal(request.token, config.canister) == false) {
        return #err(#InvalidToken(request.token));
      };
      let token = ExtCore.TokenIdentifier.getIndex(request.token);
      let aid = ExtCore.User.toAID(request.user);
      switch (_registry.get(token)) {
        case (?token_owner) {
          if (AID.equal(aid, token_owner) == true) {
            return #ok(1);
          } else {
            return #ok(0);
          };
        };
        case (_) {
          return #err(#InvalidToken(request.token));
        };
      };
    };

    public func bearer(token : Types.TokenIdentifier) : Result.Result<Types.AccountIdentifier, Types.CommonError> {
      if (ExtCore.TokenIdentifier.isPrincipal(token, config.canister) == false) {
        return #err(#InvalidToken(token));
      };
      let tokenind = ExtCore.TokenIdentifier.getIndex(token);
      switch (getBearer(tokenind)) {
        case (?token_owner) {
          return #ok(token_owner);
        };
        case (_) {
          return #err(#InvalidToken(token));
        };
      };
    };

    /*******************
    * INTERNAL METHODS *
    *******************/

    public func mintCollection() {
      let openEdition = switch (config.sale) {
        case (#supply(supplyCap)) {
          while (getNextTokenId() < Nat32.fromNat(supplyCap)) {
            mintNextToken();
          };
        };
        case (#duration(_)) {
          if (config.singleAssetCollection != ?true) {
            Debug.trap("Open edition must be a single asset collection");
          };
          if (Utils.toNanos(config.revealDelay) > 0) {
            Debug.trap("Open edition must have revealDelay = 0");
          };
        };
      };
    };

    public func mintNextToken() {
      putTokenMetadata(getNextTokenId(), #nonfungible({ metadata = ?Utils.nat32ToBlob(if (config.singleAssetCollection == ?true) 0 else getNextTokenId()) }));
      transferTokenToUser(getNextTokenId(), "0000");
      incrementSupply();
      incrementNextTokenId();
    };

    public func getOwnerFromRegistry(tokenIndex : Types.TokenIndex) : ?Types.AccountIdentifier {
      return _registry.get(tokenIndex);
    };

    public func getTokensFromOwner(aid : Types.AccountIdentifier) : ?Buffer.Buffer<Types.TokenIndex> {
      _owners.get(aid);
    };

    public func registrySize() : Nat {
      return _registry.size();
    };

    public func getNextTokenId() : Types.TokenIndex {
      return _nextTokenId;
    };

    func incrementNextTokenId() {
      _nextTokenId := _nextTokenId + 1;
    };

    func incrementSupply() {
      _supply := _supply + 1;
    };

    public func getSupply() : Types.Balance {
      _supply;
    };

    public func getRegistry() : TrieMap.TrieMap<Types.TokenIndex, Types.AccountIdentifier> {
      _registry;
    };

    public func getTokenMetadata() : TrieMap.TrieMap<Types.TokenIndex, Types.Metadata> {
      _tokenMetadata;
    };

    public func getMetadataFromTokenMetadata(tokenIndex : Types.TokenIndex) : ?Types.Metadata {
      _tokenMetadata.get(tokenIndex);
    };

    func putTokenMetadata(index : Types.TokenIndex, metadata : Types.Metadata) {
      _tokenMetadata.put(index, metadata);
    };

    public func getTokenDataFromIndex(tokenind : Nat32) : ?Blob {
      switch (_tokenMetadata.get(tokenind)) {
        case (?token_metadata) {
          switch (token_metadata) {
            case (#fungible data) return null;
            case (#nonfungible data) return data.metadata;
          };
        };
        case (_) {
          return null;
        };
      };
      return null;
    };

    public func getTokenData(token : Text) : ?Blob {
      if (ExtCore.TokenIdentifier.isPrincipal(token, config.canister) == false) {
        return null;
      };
      let tokenind = ExtCore.TokenIdentifier.getIndex(token);
      switch (_tokenMetadata.get(tokenind)) {
        case (?token_metadata) {
          switch (token_metadata) {
            case (#fungible data) return null;
            case (#nonfungible data) return data.metadata;
          };
        };
        case (_) {
          return null;
        };
      };
      return null;
    };

    public func getBearer(tindex : Types.TokenIndex) : ?Types.AccountIdentifier {
      _registry.get(tindex);
    };

    public func transferTokenToUser(tindex : Types.TokenIndex, receiver : Types.AccountIdentifier) : () {
      let owner : ?Types.AccountIdentifier = getBearer(tindex); // who owns the token (no one if mint)

      // transfer the token to the new owner
      _registry.put(tindex, receiver);

      // remove from old owner tokens
      switch (owner) {
        case (?o) _removeFromUserTokens(tindex, o);
        case (_) {};
      };

      // add to new owner tokens
      _addToUserTokens(tindex, receiver);
    };

    public func removeTokenFromUser(tindex : Types.TokenIndex) : () {
      let owner : ?Types.AccountIdentifier = getBearer(tindex);

      _registry.delete(tindex);

      switch (owner) {
        case (?o) _removeFromUserTokens(tindex, o);
        case (_) {};
      };
    };

    func _removeFromUserTokens(tindex : Types.TokenIndex, owner : Types.AccountIdentifier) : () {
      switch (_owners.get(owner)) {
        case (?ownersTokens) ownersTokens.filterEntries(func(_, a : Types.TokenIndex) : Bool { (a != tindex) });
        case (_)();
      };
    };

    func _addToUserTokens(tindex : Types.TokenIndex, receiver : Types.AccountIdentifier) : () {
      let ownersTokensNew : Buffer.Buffer<Types.TokenIndex> = switch (_owners.get(receiver)) {
        case (?ownersTokens) { ownersTokens.add(tindex); ownersTokens };
        case (_) Buffer.fromArray([tindex]);
      };
      _owners.put(receiver, ownersTokensNew);
    };
  };
};
