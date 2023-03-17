import { readFileSync } from 'fs';
import { execSync } from 'child_process';

import { getActor } from './actor';

let network = 'local';
let mainActor = getActor(network);

let test = async () => {
  let growSize = 2_001n;
  let growCount = 6;
  let chunkSize = 10_020n;

  console.log('Reinstall');
  execSync('npm run deploy:staging -- -qqqq');

  for (let i = 0; i < growCount; i++) {
    let count = await mainActor.grow(growSize);
    console.log(`Grown to ${count}`);
  }

  console.log('Backup to a.json');
  execSync(`npm run backup -- --file a.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });

  console.log('Reinstall');
  execSync('npm run deploy:staging -- -qqqq');

  console.log('Restore');
  execSync('npm run restore -- --file a.json', { stdio: 'inherit' });

  console.log('Backup to b.json');
  execSync(`npm run backup -- --file b.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });

  console.log('Compare backups');
  if (readFileSync(__dirname + '/data/a.json').toString() !== readFileSync(__dirname + '/data/b.json').toString()) {
    throw 'a.json and b.json backups are different!';
  }

  console.log('Success!');
}

test();