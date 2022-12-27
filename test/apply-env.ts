import { resolve } from 'path';
import { copyFileSync, readFileSync, writeFileSync } from 'fs';

let envName = process.argv[2];

console.log(`Applying env '${envName}'...`);

if (envName === 'production') {
  copyFileSync(resolve(__dirname + '/../src/Env/production-env.mo'), resolve(__dirname + '/../src/Env/lib.mo'));
}
else {
  let data = readFileSync(__dirname + '/../src/Env/template.mo').toString();

  let env = require(`./${envName}/.env.ts`)
  for (let [key, val] of Object.entries(env.default)) {
    if (typeof val == 'bigint') {
      val = String(val);
    }
    else {
      val = JSON.stringify(val);
    }
    data = data.replaceAll('$' + key, val as string);
  }

  writeFileSync(__dirname + '/../src/Env/lib.mo', data);
}