import fs from 'fs';
import path from 'path';
import minimist from 'minimist';
import { Principal } from '@dfinity/principal';

import { getActor } from './actor.js';

let argv = minimist(process.argv.slice(2));
let network = argv.network || 'local';
let file = argv.file || new Date().toISOString().replaceAll(':', '-').replace('T', '_').replace('Z', '').slice(0, -4) + '.json';
let chunkSize = argv['chunk-size'] ? BigInt(argv['chunk-size']) : 10_000n;

let mainActor = getActor(network);

export let backup = async ({network, file, chunkSize}) => {
  console.log(`Network: ${network}`);
  console.log(`Chunk size: ${chunkSize}`);
  console.log(`Backup file: ${file}`);

  let chunkCount = await mainActor.getChunkCount(chunkSize);

  console.log(`Total chunks: ${chunkCount}`);

  let chunks = [];
  for (let i = 0; i < chunkCount; i++) {
    console.log(`Loading chunk ${i + 1}`);
    let chunk = await mainActor.backupChunk(chunkSize, BigInt(i));
    chunks.push(chunk);
  }

  fs.mkdirSync(path.resolve('backup/data/'), {recursive: true});
  fs.writeFileSync(`backup/data/${file}`, JSON.stringify(chunks, (_, val) => {
    if (val instanceof Uint8Array) {
      return Array.from(val)
    } else if (val instanceof Uint32Array) {
      return Array.from(val)
    } else if (typeof val === 'bigint') {
      return `###bigint:${String(val)}`;
    } else if (val instanceof Principal) {
      return `###principal:${val.toText()}`;
    } else {
      return val;
    }
  }, '  '));

  console.log(`Backup successfully saved to backup/data/${file}`);
}

backup({network, file, chunkSize});