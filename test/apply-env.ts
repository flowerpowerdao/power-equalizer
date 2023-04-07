import { resolve } from 'path';
import { existsSync, copyFileSync, readFileSync, writeFileSync } from 'fs';

let envName = process.argv[2];

let templateDid = resolve(`${__dirname}/initArgs.template.did`);
let tsFile = resolve(`${__dirname}/${envName}/.env.${envName}.ts`);
let initArgsFile = resolve(`${__dirname}/initArgs.did`);

// check if *.ts env file exists
if (existsSync(tsFile)) {
  console.log(`Applying .env.${envName}.ts`);
  let didData = readFileSync(templateDid).toString();

  let env = require(tsFile);

  for (let [key, val] of Object.entries(env.default)) {
    if (typeof val == 'bigint') {
      val = String(val);
    }
    else if (val instanceof Array) {
      val = `vec { ${val.map(v => JSON.stringify(v)).join('; ')} }`;
    }
    else if (String(val).startsWith('#')) {
      val = `variant { ${String(val).slice(1)} }`;
    }
    else {
      val = JSON.stringify(val);
    }
    didData = didData.replaceAll('$' + key, val as string);
  }

  writeFileSync(initArgsFile, didData);
}
else {
  console.log(`ERR: Env '${envName}' not found`);
}