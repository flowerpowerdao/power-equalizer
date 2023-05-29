import { readFileSync } from 'fs';
import { execSync } from 'child_process';

import { getActor } from './actor';
import canister_ids_local from '../.dfx/local/canister_ids.json';

let network = 'local';
let canisterId = canister_ids_local.test.local;
let mainActor = getActor(network, canisterId);

let test = async () => {
  let assetSize = 20_001; // bytes
  let assetCount = 7;
  let chunkSize = 10_020;

  console.log('Reinstall');
  execSync('npm run reinstall:staging -- -qqqq');

  // grow marketplace and sale
  await mainActor.grow(2_000n);

  // grow assets
  for (let i = 0; i < assetCount; i++) {
    console.log(`Growing assets to ${i + 1}...`);
    execSync(`dfx canister call staging addAsset '(record {name = \"asset-${i}\";payload = record {ctype = \"text/html\"; data = vec {blob \"${i}-${'a'.repeat(assetSize / (i + 1) |0)}\"} } })'`)
  }

  console.log('Backup to a.json');
  execSync(`npm run backup -- --canister-id ${canisterId} --file a.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });

  console.log('Reinstall');
  execSync('npm run deploy:staging -- -qqqq');

  console.log('Restore');
  execSync(`npm run restore -- --canister-id ${canisterId} --file a.json`, { stdio: 'inherit' });

  console.log('Backup to b.json');
  execSync(`npm run backup -- --canister-id ${canisterId} --file b.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });

  console.log('Compare backups');
  if (readFileSync(__dirname + '/data/a.json').toString() !== readFileSync(__dirname + '/data/b.json').toString()) {
    throw 'a.json and b.json backups are different!';
  }

  console.log('Success!');
}

test();