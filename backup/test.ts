import { readFileSync } from 'fs';
import { execSync } from 'child_process';

import { getActor } from './actor';

let network = 'local';
let mainActor = getActor(network);

let test = async () => {
  let growSize = 20_000n;
  let chunkSize = 30_000n;

  console.log('Reinstall');
  execSync('npm run deploy:staging');

  let curSize = 0n;
  for (let i = 0; i < 50; i++) {
    console.log(`Grow up to ${curSize + growSize}`);
    await mainActor.grow(growSize);
    curSize += growSize;
  }

  console.log('Backup before');
  execSync(`npm run backup -- --file a.json --chunk-size ${chunkSize}`);

  console.log('Reinstall');
  execSync('npm run deploy:staging');

  console.log('Backup before');
  execSync('npm run restore -- --file a.json --pem');

  console.log('Backup after');
  execSync(`npm run backup -- --file b.json --chunk-size ${chunkSize}`);

  console.log('Compare backups');
  if (readFileSync('a.json').toString() !== readFileSync('b.json').toString()) {
    throw 'a.json and b.json backups are different!';
  }

  console.log('Success!');
}

test();