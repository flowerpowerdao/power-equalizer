import fs from 'fs';
import path from 'path';
import { Actor, HttpAgent } from '@dfinity/agent';

// @ts-ignore
import { idlFactory } from '../declarations/main/staging.did.js';
import { _SERVICE } from '../declarations/main/staging.did.js';
import { Ed25519KeyIdentity } from '@dfinity/identity';
import { Secp256k1KeyIdentity } from '@dfinity/identity-secp256k1';

export let getMainCanisterId = (network: string): string => {
  if (network === 'local') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, '.dfx/local/canister_ids.json')).toString());
    return ids.staging.local;
  }
  else if (network === 'test') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, '.dfx/local/canister_ids.json')).toString());
    return ids.test.local;
  }
  else if (network === 'staging') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, 'canister_ids.json')).toString());
    return ids.staging.ic;
  }
  else if (network === 'production') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, 'canister_ids.json')).toString());
    return ids.production.ic;
  }
};

export let getAssetsCanisterId = (network: string): string => {
  if (network === 'local') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, '.dfx/local/canister_ids.json')).toString());
    return ids.assets.local;
  }
  else if (network === 'test') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, '.dfx/local/canister_ids.json')).toString());
    return ids.assets.local;
  }
  else if (network === 'staging') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, 'canister_ids.json')).toString());
    // return ids.assets.ic; ??
  }
  else if (network === 'production') {
    let ids = JSON.parse(fs.readFileSync(path.resolve(__dirname, 'canister_ids.json')).toString());
    return ids.assets.ic;
  }
};

export let getActor = (network: string, identity?: Ed25519KeyIdentity | Secp256k1KeyIdentity) => {
  let host = network == 'ic' ? 'https://icp0.io' : 'http://127.0.0.1:4943';
  let canisterId = getMainCanisterId(network);

  if (network === 'local' || network === 'test') {
    host = 'http://127.0.0.1:4943';
  }
  else {
    host = 'https://icp0.io';
  }

  let agent = new HttpAgent({host, identity});
  if (network == 'local') {
    agent.fetchRootKey();
  }

  return Actor.createActor<_SERVICE>(idlFactory, {
    agent: agent,
    canisterId,
  });
}