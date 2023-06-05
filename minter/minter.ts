import {ExecSyncOptions, execSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import chalk from 'chalk';

import {decode} from '../backup/pem';
import {getActor, getAssetsCanisterId} from './utils';
import {parallel} from './parallel';

// create canister
// deploy canister
// upload placeholder (if needed)
// upload assets
// upload metadata
// call initCap, initMint, shuffleTokensForSale, airdropTokens, airdropTokens, enableSale

let execOptions = {stdio: ['inherit', 'pipe', 'inherit']} as ExecSyncOptions;

let network = 'local';
let mainCanisterName = network == 'production' ? 'production' : 'staging';
let assetsDir = path.resolve(__dirname, '../assets');
let identityName = execSync('dfx identity whoami').toString();
let pemData = execSync(`dfx identity export ${identityName}`, execOptions).toString();
let identity = decode(pemData);
let actor = getActor(network, identity);

console.log(identity.getPrincipal().toText());

let run = () => {
  // createCanisters();
  deployCanisters();
  uploadAssetsMetadata();
  mint();
}

let getAssetUrl = (file) => {
  let assetsCanisterId = getAssetsCanisterId(network);

  let assetsCanisterUrl = '';
  if (network === 'local' || network === 'test') {
    assetsCanisterUrl = `http://localhost:3000/`;
  }
  else {
    assetsCanisterUrl = `https://${assetsCanisterId}.raw.icp0.io/`;
  }

  return assetsCanisterUrl + file;
}

let deployCanisters = () => {
  console.log(chalk.green('Deploying assets canister...'));
  execSync(`dfx deploy assets --network ${network}`, execOptions);

  console.log(chalk.green('Deploying main canister...'));
  execSync(`dfx deploy ${mainCanisterName} --argument "$(cat initArgs.did)" --network ${network}`, execOptions);
}

let uploadAssetsMetadata = async () => {
  let assets = JSON.parse(fs.readFileSync(path.resolve(assetsDir, 'metadata.json')).toString());
  console.log(chalk.green(`Found ${assets.length} assets`));

  let dirContent = fs.readdirSync(assetsDir);
  let files = dirContent.filter((item) => {
    return fs.lstatSync(path.resolve(assetsDir, item)).isFile();
  });

  let filesByName = new Map(files.map((file) => {
    return [path.parse(file).name, file];
  }));

  // placeholder
  if (filesByName.has('placeholder')) {
    console.log(chalk.green('Uploading placeholder...'));
    await actor.addPlaceholder({
      name: 'placeholder',
      payload: {
        ctype: '',
        data: [],
      },
      thumbnail: [],
      metadata: [],
      payloadUrl: [getAssetUrl(filesByName.get('placeholder'))],
      thumbnailUrl: [],
    });
  }
  else {
    console.log(chalk.yellow('No placeholder.'));
  }

  // assets
  console.log(chalk.green('Uploading assets metadata...'));

  await parallel(100, [...assets.entries()], async ([index, metadata]) => {
    console.log(`Uploading asset ${index}`);
    let uploadedIndex = await actor.addAsset({
      name: String(index),
      payload: {
        ctype: '',
        data: [],
      },
      thumbnail: [],
      metadata: [{
        ctype: 'application/json',
        data: [new TextEncoder().encode(JSON.stringify(metadata))],
      }],
      payloadUrl: [getAssetUrl(filesByName.get(String(index)))],
      thumbnailUrl: [getAssetUrl(filesByName.get(String(index) + '_thumbnail'))],
    });
    console.log(uploadedIndex, index);
  });
};

let mint = () => {
  console.log(chalk.green('Minting...'));
  console.log('initiating cap ...');
  execSync(`dfx canister --network ${network} call ${mainCanisterName} initCap`, execOptions);

  console.log('initiating mint ...');
  execSync(`dfx canister --network ${network} call ${mainCanisterName} initMint`, execOptions);

  console.log('shuffle Tokens For Sale ...');
  execSync(`dfx canister --network ${network} call ${mainCanisterName} shuffleTokensForSale`, execOptions);

  console.log('airdrop tokens ...');
  execSync(`dfx canister --network ${network} call ${mainCanisterName} airdropTokens 0`, execOptions);

  console.log('airdrop tokens ...');
  execSync(`dfx canister --network ${network} call ${mainCanisterName} airdropTokens 1500`, execOptions);

  console.log('enable sale ...');
  execSync(`dfx canister --network ${network} call ${mainCanisterName} enableSale`, execOptions);
}

run();