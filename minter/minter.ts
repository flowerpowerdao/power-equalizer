import {ExecSyncOptions, execSync} from 'node:child_process';
import chalk from 'chalk';

import {decode} from '../backup/pem';
import config from './config';
import {getActor} from './utils';

// create canister
// deploy canister
// upload placeholder (if needed)
// upload assets
// upload metadata
// call initCap, initMint, shuffleTokensForSale, airdropTokens, airdropTokens, enableSale

let execOptions = {stdio: ['inherit', 'pipe', 'inherit']} as ExecSyncOptions;

let identityName = execSync('dfx identity whoami').toString();
let pemData = execSync(`dfx identity export ${identityName}`, execOptions).toString();
let identity = decode(pemData);
let actor = getActor(config.network, identity);

console.log(identity.getPrincipal().toText());

let run = () => {
  // createCanisters();
  deployCanisters();
}

// let createCanisters = () => {
//   console.log(chalk.green('Creating canisters...'));
//   execSync(`dfx canister create --all --network ${config.network}`, execOptions).toString();
// }

let deployCanisters = () => {
  console.log(chalk.green('Deploying assets canister...'));
  execSync(`dfx deploy assets --network ${config.network}`, execOptions);

  console.log(chalk.green('Deploying main canister...'));
  execSync(`dfx deploy ${config.network == 'production' ? 'production' : 'staging'} --argument "$(cat initArgs.did)" --network ${config.network}`, execOptions);
}

let uploadCollectionAssets = async () => {
  console.log(chalk.green('Uploading assets to main canister...'));

  // placeholder
  console.log(chalk.green('Uploading placeholder...'));
  await actor.addAsset({
    name: 'placeholder',
    payload: {
      ctype: '',
      data: [],
    },
    thumbnail: null,
    metadata: null,
    payloadUrl: [config.assetsCanisterUrl + config.placeholder],
    thumbnailUrl: null,
  });

  // assets
  console.log(chalk.green('Uploading assets metadata...'));
  let assets = []; // TODO: get assets from metadata.json
  // let assets = JSON.parse(fs.readFileSync(path.resolve(__dirname, 'assets/metadata.json')).toString());

  for (let asset of assets) {
    await actor.addAsset({
      name: asset.name,
      payload: {
        ctype: '',
        data: [],
      },
      thumbnail: null,
      metadata: [{
        ctype: 'application/json',
        data: [new TextEncoder().encode(JSON.stringify(asset.metadata))],
      }],
      payloadUrl: [config.assetsCanisterUrl + asset.payloadFile],
      thumbnailUrl: [config.assetsCanisterUrl + asset.thumbnailFile],
    });
  }
}

run();