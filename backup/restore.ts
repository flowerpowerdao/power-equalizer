import fs from 'fs';
import path from 'path';
import minimist from 'minimist';
import { Principal } from '@dfinity/principal';

import { getActor } from './actor.js';
import { type StableChunk } from '../declarations/main/staging.did';


let argv = minimist(process.argv.slice(2));
let network = argv.network || 'local';
let file = argv.file;

if (!file) {
  throw new Error('Missing --file argument')
}

let filePath = path.resolve(__dirname, 'data', file);
if (!fs.existsSync(filePath)) {
  throw new Error(`File ${filePath} not found`);
}

let mainActor = getActor(network);

export let restore = async ({network, file}) => {
  console.log(`Network: ${network}`);
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

  await mainActor.finishRestore();

  console.log(`Restore successful`);
}

restore({network, file});