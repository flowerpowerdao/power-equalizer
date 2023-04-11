import { resolve } from 'path';
import { existsSync, copyFileSync, readFileSync, writeFileSync } from 'fs';

let initArgsFile = resolve(`${__dirname}/initArgs.did`);
let templateDid = resolve(`${__dirname}/initArgs.template.did`);
let templateDidData = readFileSync(templateDid).toString();

export async function applyEnv(envName: string) {
  let tsFile = resolve(`${__dirname}/${envName}/.env.${envName}.ts`);

  // check if *.ts env file exists
  if (existsSync(tsFile)) {
    console.log(`Applying .env.${envName}.ts`);
    let didData = templateDidData;

    let env = await import(tsFile);

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
}

if (process.argv[2]) {
  applyEnv(process.argv[2]);
}