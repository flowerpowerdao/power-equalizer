import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Nat16 "mo:base/Nat16";
import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";

import AID "../toniq-labs/util/AccountIdentifier";
import ExtCore "../toniq-labs/ext/Core";
import MarketplaceTypes "../Marketplace/types";
import Types "types";
import Utils "../utils";
import RootTypes "../types";

module {
  public class Factory(config : RootTypes.Config, deps : Types.Dependencies) {
    type CollectionMetadata = Types.CollectionMetadata;
    type Metadata = Types.Metadata;
    type Account = Types.Account;
    type TransferArgs = Types.TransferArgs;
    type TransferError = Types.TransferError;
    type ApprovalArgs = Types.ApprovalArgs;
    type ApprovalError = Types.ApprovalError;

    // TODO
    func _accountIdToAccount(accountId : AID.AccountIdentifier) : Account {
      {
        owner = Principal.fromText("");
        subaccount = null;
      };
    };

    public func icrc7_collection_metadata() : CollectionMetadata {
      {
        icrc7_name = icrc7_name();
        icrc7_symbol = icrc7_symbol();
        icrc7_royalties = icrc7_royalties();
        icrc7_royalty_recipient = icrc7_royalty_recipient();
        icrc7_description = icrc7_description();
        icrc7_image = icrc7_image();
        icrc7_total_supply = icrc7_total_supply();
        icrc7_supply_cap = icrc7_supply_cap();
      };
    };

    public func icrc7_name() : Text {
      config.name;
    };

    public func icrc7_symbol() : Text {
      config.symbol;
    };

    public func icrc7_royalties() : ?Nat16 {
      let royalties = Array.map<(AID.AccountIdentifier, Nat64), Nat64>(config.royalties, func(royalty) {
        royalty.1;
      });
      let sum = Array.foldLeft<Nat64, Nat64>(royalties, 0, Nat64.add);
      ?Nat16.fromNat(Nat64.toNat(sum));
    };

    public func icrc7_royalty_recipient() : ?Account {
      if (config.royalties.size() == 1) {
        return ?_accountIdToAccount(config.royalties[0].0);
      };
      // if there are 0 or >1 recipients, return null
      null;
    };

    public func icrc7_description() : ?Text {
      config.description;
    };

    public func icrc7_image() : ?Text {
      config.image;
    };

    public func icrc7_total_supply() : Nat {
      let notSold = switch (deps._Tokens.getTokensFromOwner("0000")) {
        case (?tokens) tokens.size();
        case (_) 0;
      };
      deps._Tokens.getSupply() - notSold;
    };

    public func icrc7_supply_cap() : ?Nat {
      switch (config.sale) {
        case (#supply(supply)) ?supply;
        case (#duration(_)) null;
      };
    };

    // ??
    public func icrc7_metadata(tokenIndex : Nat) : [(Text, Metadata)] {
      // let assetId = deps._Tokens.getMetadataFromTokenMetadata(Nat32.fromNat(tokenIndex)).assetId;
      switch (deps._Assets.get(tokenIndex).metadata) {
        case (?metadata) {
          let assetId = deps._Assets.get(tokenIndex).name;
          [("json", #Blob(metadata.data[0]))];
        };
        case (null) {
          [];
        };
      };
    };

    public func icrc7_owner_of(tokenIndex : Nat) : Account {
      switch (deps._Tokens.getOwnerFromRegistry(Nat32.fromNat(tokenIndex))) {
        case (?accountId) {
          _accountIdToAccount(accountId);
        };
        case (null) {
          Debug.trap("token not found");
        };
      };
    };

    public func icrc7_balance_of(account : Account) : Nat {
      let accountId = AID.fromPrincipal(account.owner, account.subaccount);

      switch (deps._Tokens.getTokensFromOwner(accountId)) {
        case (?tokens) tokens.size();
        case (null) 0;
      };
    };

    public func icrc7_tokens_of(account : Account) : [Nat] {
      let accountId = AID.fromPrincipal(account.owner, account.subaccount);

      switch (deps._Tokens.getTokensFromOwner(accountId)) {
        case (?tokens) Array.map(Buffer.toArray(tokens), Nat32.toNat);
        case (null) [];
      };
    };

    public func icrc7_transfer(args : TransferArgs) : { #Ok: Nat; #Err: TransferError; } {
      #Ok(0);
    };

    public func icrc7_approve(args : ApprovalArgs) : { #Ok: Nat; #Err: ApprovalError; } {
      #Ok(0);
    };

    public func icrc7_supported_standards() : [{ name : Text; url : Text }] {
      [
        { name = "ICRC-7"; url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-7" }
      ]
    };
  };
};
