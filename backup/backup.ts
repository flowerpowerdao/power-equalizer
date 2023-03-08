import fs from 'fs';
import minimist from 'minimist';

import {createActor, canisterId as localCanisterId} from '../declarations/main';
import canisterIds from './canister_ids.json';

let argv = minimist(process.argv.slice(2));
let network = argv.network || 'local';
let out = argv.out || new Date().toISOString().replaceAll(':', '-').replace('T', '_').replace('Z', '').slice(0, -4);
let chunkSize = argv['chunk-size'] ? BigInt(argv['chunk-size']) : 10_000n;
let canisterId = network == 'ic' ? canisterIds.production.ic : localCanisterId;

let main = createActor(canisterId, {
	agentOptions: {
		host: network == 'ic' ? 'https://ic0.app' : 'https://127.0.0.1:4943',
	},
});

let backup = async () => {
	console.log(`Network: ${network}`);
	console.log(`Chunk size: ${chunkSize}`);
	console.log(`Backup name: ${out}`);

	let chunkCount = await main.getChunkCount(chunkSize);

	console.log(`Total chunks: ${chunkCount}`);

	let chunks = [];
	for (let i = 0; i < chunkCount; i++) {
		console.log(`Loading chunk ${i + 1}`)
		let chunk = await main.backupChunk(chunkSize, chunkCount);
		chunks.push(chunk);
	}

	fs.writeFileSync(`./data/${out}.json`, JSON.stringify(chunks));

	console.log(`Backup successfully save to ${out}.json`);
}

backup();