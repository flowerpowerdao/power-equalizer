// import { describe, it, expect } from 'vitest';
// import { readFileSync } from 'fs';
// import { execSync } from 'child_process';
// import { User } from '../user';

// import canisterIds from '../../.dfx/local/canister_ids.json';

// let canisterId = canisterIds.test.local;

// describe('restore', async () => {
//   let chunkSize = 1500n;

//   it('try to restore by non-minter user', async () => {
//     await expect(new User().mainActor.restoreChunk({v1: {
//       marketplace: [],
//       assets: [],
//       sale: [],
//       disburser: [],
//       tokens: [],
//       shuffle: [],
//     }})).rejects.toThrow(/assertion failed/);
//   });

//   it('restore from a.json', async () => {
//     execSync(`npm run restore -- --canister-id ${canisterId} --file a.json`, { stdio: 'inherit' });
//   });

//   it('backup to b.json', async () => {
//     execSync(`npm run backup -- --canister-id ${canisterId} --file b.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });
//   });

//   it('compare a.json and b.json', async () => {
//     if (readFileSync(__dirname + '/../../backup/data/a.json').toString() !== readFileSync(__dirname + '/../../backup/data/b.json').toString()) {
//       throw 'a.json and b.json backups are different!';
//     }
//   });
// });