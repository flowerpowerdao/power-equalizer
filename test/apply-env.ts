import { resolve } from 'path';
import { existsSync, copyFileSync, readFileSync, writeFileSync } from 'fs';

let envName = process.argv[2];

let templateFile = resolve(`${__dirname}/../src/Env/_template.mo`);
let tsFile = resolve(`${__dirname}/${envName}/.env.${envName}.ts`);
let moFile = resolve(`${__dirname}/../src/Env/.env.${envName}.mo`);
let libFile = resolve(`${__dirname}/../src/Env/lib.mo`);

// check if *.mo env file exists
if (existsSync(moFile)) {
  console.log(`Applying .env.${envName}.mo`);
  copyFileSync(moFile, libFile);
}
// check if *.ts env file exists
else if (existsSync(tsFile)) {
  console.log(`Applying .env.${envName}.ts`);
  let data = readFileSync(templateFile).toString();

  let env = require(tsFile);
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

  writeFileSync(libFile, data);
}
else {
  console.log(`ERR: Env '${envName}' not found`);
}