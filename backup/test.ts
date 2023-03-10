import {readFileSync} from 'fs';
import {backup} from './backup';
import {restore} from './restore';

let test = async () => {
  let network = 'local';
  let chunkSize = 10_000n;

  await backup({network, file: 'a.json', chunkSize});
  await restore({network, file: 'a.json'});
  await backup({network, file: 'b.json', chunkSize});

  if (readFileSync('a.json').toString() !== readFileSync('b.json').toString()) {
    throw 'a.json and b.json backups are different!';
  };
}

test();