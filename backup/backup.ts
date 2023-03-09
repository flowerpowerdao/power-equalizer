import fs from 'fs';
import path from 'path';
import minimist from 'minimist';
import { Actor, HttpAgent } from '@dfinity/agent';

// @ts-ignore
import { idlFactory as idlFactoryMain } from '../declarations/main/staging.did.js';
import { _SERVICE as _SERVICE_MAIN } from '../declarations/main/staging.did';

let argv = minimist(process.argv.slice(2));
let network = argv.network || 'local';
let host = network == 'ic' ? 'https://ic0.app' : 'http://127.0.0.1:4943';
let out = argv.out || new Date().toISOString().replaceAll(':', '-').replace('T', '_').replace('Z', '').slice(0, -4);
let chunkSize = argv['chunk-size'] ? BigInt(argv['chunk-size']) : 10_000n;

let canisterId = '';
if (network == 'ic') {
  canisterId = JSON.parse(fs.readFileSync('canister_ids.json').toString()).production.ic;
}
else {
  canisterId = JSON.parse(fs.readFileSync('.dfx/local/canister_ids.json').toString()).staging.local;
}

let agent = new HttpAgent({ host });
if (network == 'local') {
  agent.fetchRootKey();
}

let mainActor = Actor.createActor(idlFactoryMain, {
  agent: agent,
  canisterId,
});

let backup = async () => {
  console.log(`Network: ${network}`);
  console.log(`Chunk size: ${chunkSize}`);
  console.log(`Backup name: ${out}`);

  let chunkCount = await mainActor.getChunkCount(chunkSize);

  console.log(`Total chunks: ${chunkCount}`);

  let chunks = [];
  for (let i = 0; i < chunkCount; i++) {
    console.log(`Loading chunk ${i + 1}`);
    let chunk = await mainActor.backupChunk(chunkSize, i);
    chunks.push(chunk);
  }

  fs.mkdirSync(path.resolve('backup/data/'), {recursive: true});
  fs.writeFileSync(`backup/data/${out}.json`, JSON.stringify(chunks, (_, val) => {
    if (typeof val === 'bigint') {
      return { _isBigInt: true, _str: String(val) };
    }
    else if (val instanceof Uint8Array) {
      return Array.from(val)
    }
    else if (val instanceof Uint32Array) {
      return Array.from(val)
    }
    else {
      return val;
    }
  }, '  '));

  console.log(`Backup successfully saved to backup/data/${out}.json`);
}

backup();