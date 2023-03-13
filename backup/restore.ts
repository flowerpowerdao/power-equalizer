import fs from 'fs';
import path from 'path';
import minimist from 'minimist';
import { Principal } from '@dfinity/principal';

import { getActor } from './actor';
import { type StableChunk } from '../declarations/main/staging.did';
import {decode} from './pem';

let argv = minimist(process.argv.slice(2));
let network = argv.network || 'local';
let file = argv.file;
let pemData = argv.pem;

if (!file) {
  throw new Error('Missing --file argument')
}

if (!pemData) {
  throw new Error('Missing --pem argument')
}

let filePath = path.resolve(__dirname, 'data', file);
if (!fs.existsSync(filePath)) {
  throw new Error(`File ${filePath} not found`);
}

let identity = decode(pemData);
let mainActor = getActor(network, identity);

export let restore = async ({network, file}) => {
  console.log(`Network: ${network}`);
  console.log(`Identity: ${identity.getPrincipal().toText()}`);
  console.log(`Backup file: ${file}`);

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
    console.log(`Uploading chunk ${i + 1}...`);
    await mainActor.restoreChunk(chunks[i]);
  }

  console.log(`Restore successful`);
}

restore({network, file});