import { createActor } from './actor'
import { generateIdentity } from './generate-identity'
import canisterIds from '../.dfx/local/canister_ids.json';

// generate actor with identity generated from seed
export let generateActor = (seed?: string) => {
   return createActor(canisterIds.staging.local, {
       agentOptions: {
         host: 'http://127.0.0.1:4943',
         identity: generateIdentity(seed),
       },
   });
};