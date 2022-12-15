import { Secp256k1KeyIdentity } from "@dfinity/identity-secp256k1/src";
import { AccountIdentifier } from "@dfinity/nns";
import { Principal } from "@dfinity/principal";
import { generateActor } from "./generate-actor";
import { generateIdentity } from "./generate-identity";
import { _SERVICE } from './declarations/staging.did';
import { ActorSubclass } from "@dfinity/agent";

export class User {
   actor: ActorSubclass<_SERVICE>;
   identity: Secp256k1KeyIdentity;
   principal: Principal;
   accountId: string;
   
   constructor(seed?: string) {
      this.actor = generateActor(seed);
      this.identity = generateIdentity(seed);
      this.principal = this.identity.getPrincipal();
      this.accountId = AccountIdentifier.fromPrincipal({principal: this.principal}).toHex();
   }
}