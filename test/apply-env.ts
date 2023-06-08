import { resolve } from 'path';
import { existsSync, copyFileSync, readFileSync, writeFileSync } from 'fs';

let initArgsFile = resolve(`${__dirname}/initArgs.did`);
let templateDid = resolve(`${__dirname}/initArgs.template.did`);
let templateDidData = readFileSync(templateDid).toString();

export async function applyEnv(envName: string) {
  let tsFile = resolve(`${__dirname}/${envName}/env.ts`);

  // check if *.ts env file exists
  if (existsSync(tsFile)) {
    let didData = templateDidData;

    // @ts-ignore
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
      else if (String(val).startsWith('variant {')) {
        val = val;
      }
      else {
        val = JSON.stringify(val);
      }
      didData = didData.replaceAll(new RegExp(`\\$${key}\\b`, 'g'), val as string);
    }

    writeFileSync(initArgsFile, didData);
  }
  else {
    console.log(`ERR: Env '${envName}' not found`);
    process.exit(1);
  }
}

if (process.argv[2]) {
  applyEnv(process.argv[2]);
}