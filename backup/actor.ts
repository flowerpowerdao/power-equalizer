import fs from 'fs';
import { Actor, HttpAgent } from '@dfinity/agent';

// @ts-ignore
import { idlFactory } from '../declarations/main/staging.did.js';
import { _SERVICE } from '../declarations/main/staging.did';

export let getActor = (network: string) => {
  let host = network == 'ic' ? 'https://ic0.app' : 'http://127.0.0.1:4943';

  let canisterId = '';
  if (network == 'ic') {
    canisterId = JSON.parse(fs.readFileSync('canister_ids.json').toString()).production.ic;
  }
  else {
    canisterId = JSON.parse(fs.readFileSync('.dfx/local/canister_ids.json').toString()).staging.local;
  }

  let agent = new HttpAgent({host});
  if (network == 'local') {
    agent.fetchRootKey();
  }

  return Actor.createActor<_SERVICE>(idlFactory, {
    agent: agent,
    canisterId,
  });
}