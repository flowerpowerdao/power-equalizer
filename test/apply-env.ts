import { resolve } from 'path';
import { copyFileSync, readFileSync, writeFileSync } from 'fs';

let envName = process.argv[2];

console.log(`Applying env '${envName}'...`);

if (envName === 'btcflower') {
  copyFileSync(resolve(__dirname + '/../src/Env/.env.btcflower.mo'), resolve(__dirname + '/../src/Env/lib.mo'));
}
else {
  let data = readFileSync(__dirname + '/../src/Env/_template.mo').toString();

  let env = require(`./${envName}/.env.${envName}.ts`);
  for (let [key, val] of Object.entries(env.default)) {
    if (typeof val == 'bigint') {
      val = String(val);
    }
    else if (String(val).startsWith('#')) {
      val = val;
    }
    else {
      val = JSON.stringify(val);
    }
    data = data.replaceAll('$' + key, val as string);
  }

  writeFileSync(__dirname + '/../src/Env/lib.mo', data);
}