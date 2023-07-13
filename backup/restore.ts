import fs from 'fs';
import path from 'path';
import minimist from 'minimist';
import { Principal } from '@dfinity/principal';
import { ExecSyncOptions, execSync } from 'child_process';

import { getActor } from './actor';
import { type StableChunk } from '../declarations/main/staging.did';
import { decode } from './pem';

let argv = minimist(process.argv.slice(2));
let network = argv.network || 'local';
let file = argv.file;
let pemData = argv.pem || '';
let canisterId = argv['canister-id'];

if (!file) {
  throw new Error('Missing --file argument')
}
if (!canisterId) {
  throw new Error('Missing --canister-id argument');
}

let filePath = path.resolve(__dirname, 'data', file);
if (!fs.existsSync(filePath)) {
  throw new Error(`File ${filePath} not found`);
}

if (!pemData && network == 'local') {
  let execOptions = {stdio: ['inherit', 'pipe', 'inherit']} as ExecSyncOptions;
  let identityName = execSync('dfx identity whoami').toString().trim();
  if (identityName !== 'anonymous') {
    pemData = execSync(`dfx identity export ${identityName}`, execOptions).toString();
  }
}

let identity = pemData && decode(pemData);
let mainActor = getActor(network, canisterId, identity);

export let restore = async ({network, file}) => {
  console.log(`Network: ${network}`);
  console.log(`Backup file: ${file}`);
  if (identity) {
    console.log(`Identity: ${identity.getPrincipal().toText()}`);
  }

  let text = fs.readFileSync(filePath).toString();

  let chunks: StableChunk[] = JSON.parse(text, (key, val) => {
    if (typeof val === 'string') {
      if (val.startsWith('###bigint:')) {
        return BigInt(val.slice('###bigint:'.length));
      } else if (val.startsWith('###principal:')) {
        return Principal.fromText(val.slice('###principal:'.length));
      }
    }
    return val;
  });

  for (let i = 0; i < chunks.length; i++) {
    console.log(`Uploading chunk ${i + 1}`);
    await mainActor.restoreChunk(chunks[i]);
  }

  console.log(`Restore successful`);
}

restore({network, file});