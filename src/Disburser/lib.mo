import Ledger "canister:ledger";

import Float "mo:base/Float";
import Int "mo:base/Int";
import Random "mo:base/Random";
import Blob "mo:base/Blob";
import List "mo:base/List";
import Principal "mo:base/Principal";

import Encoding "mo:encoding/Binary";
import AviateAccountIdentifier "mo:accountid/AccountIdentifier";

import ExtCore "../toniq-labs/ext/Core";
import Types "types";
import RootTypes "../types";
import Utils "../utils";

module {
  public class Factory(config : RootTypes.Config) {

    /*********
    * STATE *
    *********/

    var _disbursements = List.nil<Types.Disbursement>();
    var curNonce : Nat64 = 0;

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      if (chunkIndex != 0) {
        return null;
      };
      ?#v1({
        disbursements = List.toArray(_disbursements);
      });
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        case (?#v1(data)) {
          _disbursements := List.fromArray(data.disbursements);
        };
        case (null) {};
      };
    };

    //*** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    public func addDisbursement(disbursement : Types.Disbursement) : () {
      _disbursements := List.push(disbursement, _disbursements);
    };

    public func getDisbursements() : [Types.Disbursement] {
      List.toArray(_disbursements);
    };

    public func cronDisbursements() : async* () {
      label payloop while (true) {
        let (last, newDisbursements) = List.pop(_disbursements);
        switch (last) {
          case (?disbursement) {
            _disbursements := newDisbursements;

            try {
              curNonce := (curNonce + 1) % 1000;
              var res = await Ledger.transfer({
                to = switch (AviateAccountIdentifier.fromText(disbursement.to)) {
                  case (#ok(accountId)) {
                    Blob.fromArray(AviateAccountIdentifier.addHash(accountId));
                  };
                  case (#err(_)) {
                    // this should never happen because account ids are always created from within the
                    // canister which should guarantee that they are valid and we are able to decode them
                    // to [Nat8]
                    continue payloop;
                  };
                };
                from_subaccount = ?Blob.fromArray(disbursement.fromSubaccount);
                amount = { e8s = disbursement.amount };
                fee = { e8s = 10000 };
                created_at_time = null;
                memo = curNonce + Encoding.BigEndian.toNat64(Blob.toArray(Principal.toBlob(Principal.fromText(ExtCore.TokenIdentifier.fromPrincipal(config.canister, disbursement.tokenIndex)))));
              });
            } catch (e) {
              _disbursements := List.push(disbursement, _disbursements);
              break payloop;
            };
          };
          case (null) {
            break payloop;
          };
        };
      };
    };

    public func pendingCronJobs() : Nat {
      List.size(_disbursements);
    };
  };
};
