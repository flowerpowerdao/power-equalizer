import {ExecSyncOptions, execSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import chalk from 'chalk';
import minimist from 'minimist';

import {decode} from '../backup/pem';
import {getActor, getAssetsCanisterId} from './utils';
import {parallel} from './parallel';


let execOptions = {stdio: ['inherit', 'pipe', 'inherit']} as ExecSyncOptions;

let argv = minimist(process.argv.slice(2));

let network = argv._[0] || 'local';
let dfxNetwork = network === 'local' || network === 'test' ? 'local' : 'ic';

let mode = argv.mode || '';
let modeArg = mode === 'reinstall' ? `--mode=${mode}` : '';

// skip prompt for local reinstall
if (dfxNetwork === 'local' && mode === 'reinstall') {
  modeArg += ' --yes';
}

let withCyclesArg = argv['with-cycles'] ? `--with-cycles=${argv['with-cycles']}` : '';

let nftCanisterName = network == 'production' ? 'production' : 'staging';
let assetsDir = path.resolve(__dirname, '../assets');
let identityName = execSync('dfx identity whoami').toString();
let pemData = execSync(`dfx identity export ${identityName}`, execOptions).toString();
let identity = decode(pemData);
let actor = getActor(network, identity);

console.log(identity.getPrincipal().toText());

let run = () => {
  deployCanisters();
  uploadAssetsMetadata();
  launch();
}

let getAssetUrl = (file) => {
  let assetsCanisterId = getAssetsCanisterId(network);
  if (network === 'local' || network === 'test') {
    return `http://localhost:4943/${file}?canisterId=${assetsCanisterId}`;
  }
  else {
    return `https://${assetsCanisterId}.raw.icp0.io/${file}`;
  }
}

let deployCanisters = () => {
  if (mode === 'reinstall') {
    console.log(chalk.yellow('REINSTALL MODE'));
  }

  console.log(chalk.green('Deploying nft canister...'));
  execSync(`dfx deploy ${nftCanisterName} --argument "$(cat initArgs.did)" --network ${dfxNetwork} ${modeArg} ${withCyclesArg}`, execOptions);

  console.log(chalk.green('Deploying assets canister...'));
  execSync(`dfx deploy assets --network ${dfxNetwork} ${modeArg} ${withCyclesArg}`, execOptions);
}

let uploadAssetsMetadata = async () => {
  let assets = JSON.parse(fs.readFileSync(path.resolve(assetsDir, 'metadata.json')).toString());

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
  console.log(chalk.green(`Found ${assets.length} assets metadata...`));

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

let launch = () => {
  console.log(chalk.green('Launching...'));
  if (dfxNetwork === 'ic') {
    console.log('initiating CAP ...');
    execSync(`dfx canister --network ${dfxNetwork} call ${nftCanisterName} initCap`, execOptions);
  }
  else {
    console.log(chalk.yellow('skip CAP init for local network'));
  }

  console.log('initiating mint ...');
  execSync(`dfx canister --network ${dfxNetwork} call ${nftCanisterName} initMint`, execOptions);

  console.log('shuffle Tokens For Sale ...');
  execSync(`dfx canister --network ${dfxNetwork} call ${nftCanisterName} shuffleTokensForSale`, execOptions);

  console.log('airdrop tokens ...');
  execSync(`dfx canister --network ${dfxNetwork} call ${nftCanisterName} airdropTokens 0`, execOptions);

  console.log('airdrop tokens ...');
  execSync(`dfx canister --network ${dfxNetwork} call ${nftCanisterName} airdropTokens 1500`, execOptions);

  console.log('enable sale ...');
  execSync(`dfx canister --network ${dfxNetwork} call ${nftCanisterName} enableSale`, execOptions);
}

run();