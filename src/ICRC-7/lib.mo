import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";


import AID "../toniq-labs/util/AccountIdentifier";
import ExtCore "../toniq-labs/ext/Core";
import MarketplaceTypes "../Marketplace/types";
import Types "types";
import Utils "../utils";
import RootTypes "../types";
import Nat64 "mo:base/Nat64";

module {
  public class Factory(config : RootTypes.Config, deps : Types.Dependencies) {
    type CollectionMetadata = Types.CollectionMetadata;
    type Metadata = Types.Metadata;
    type Account = Types.Account;
    type TransferArgs = Types.TransferArgs;
    type TransferError = Types.TransferError;
    type ApprovalArgs = Types.ApprovalArgs;
    type ApprovalError = Types.ApprovalError;

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
      let sum = Array.foldLeft<Nat, Nat>(config.royalties, 0, Nat64.add);
      ?Nat16.fromNat(Nat64.toNat(sum));
    };

    public func icrc7_royalty_recipient() : ?Account {
      null; // there are multiple recipients, so we return null
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
        case (#duration) null;
      };
    };

    public func icrc7_metadata(tokenIndex : Nat) : [(Text, Metadata)] {
      let assetId =
      for (e in deps._Tokens.getTokenMetadata().entries()) {
        let assetid = deps._Assets.get(if (config.singleAssetCollection == ?true) startIndex else Nat32.toNat(e.0) + startIndex).name;
        resp.add((e.0, assetid));
      };
    };

    public func icrc7_owner_of(tokenIndex : Nat) : Account {
    };

    public func icrc7_balance_of(account : Account) : Nat {
    };

    public func icrc7_tokens_of(account : Account) : [Nat] {
    };

    public func icrc7_transfer(args : TransferArgs) : { #Ok: Nat; #Err: TransferError; } {
    };

    public func icrc7_approve(args : ApprovalArgs) : { #Ok: Nat; #Err: ApprovalError; } {
    };

    public func icrc7_supported_standards() : [{ name : Text; url : Text }] {
      [
        { name = "ICRC-7"; url = "https://github.com/dfinity/ICRC/ICRCs/ICRC-7" }
      ]
    };
  };
};
