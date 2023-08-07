import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import path from 'path';
import { readFileSync } from 'fs';
import { User } from '../user';
import { applyEnv } from '../apply-env';

import canisterIds from '../../../.dfx/local/canister_ids.json';

let canisterId = canisterIds.test.local;

describe('backup', () => {
  let assetSize = 20_001; // bytes
  let assetCount = 7;
  let chunkSize = 1500n;
  let user = new User('');

  it(`grow transactions to 2_000`, async () => {
    await user.mainActor.grow(2_000n);
  });

  it(`grow assets`, async () => {
    for (let i = 0; i < assetCount; i++) {
      console.log(`Growing assets to ${i + 1}...`);
      execSync(`dfx canister call test addAsset '(record {name = \"asset-${i}\";payload = record {ctype = \"text/html\"; data = vec {blob \"${i}-${'a'.repeat(assetSize / (i + 1) | 0)}\"} } })'`);
    }
  });

  it('mint', async () => {
    execSync(`dfx canister call test initMint && dfx canister call test shuffleTokensForSale && dfx canister call test enableSale`);
  });

  it('backup to a.json', async () => {
    execSync(`npm run backup -- --canister-id ${canisterId} --file a.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });
  });

  it('check a.json', async () => {
    let data = JSON.parse(readFileSync(__dirname + '/../../../backup/data/a.json').toString());
    expect(data[0]['v2']['assets'][0]['v3']['assetsChunk']).toHaveLength(7);
    expect(data[0]['v2']['assets'][0]['v3']['assetsCount']).toBe('###bigint:7');
  });
});

it('deploy', async () => {
  await applyEnv('restore');

  execSync(`npm run deploy-test`, {
    cwd: path.resolve(__dirname, '..'),
    stdio: ['ignore', 'ignore', 'pipe'],
  });
});

describe('restore', () => {
  let chunkSize = 1500n;

  it('try to restore by non-minter user', async () => {
    await expect(new User().mainActor.restoreChunk({v1: {
      marketplace: [],
      assets: [],
      sale: [],
      disburser: [],
      tokens: [],
      shuffle: [],
    }})).rejects.toThrow(/assertion failed/);
  });

  it('restore from a.json', async () => {
    execSync(`npm run restore -- --canister-id ${canisterId} --file a.json`, { stdio: 'inherit' });
  });

  it('backup to b.json', async () => {
    execSync(`npm run backup -- --canister-id ${canisterId} --file b.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });
  });

  it('compare a.json and b.json', async () => {
    if (readFileSync(__dirname + '/../../../backup/data/a.json').toString() !== readFileSync(__dirname + '/../../../backup/data/b.json').toString()) {
      throw 'a.json and b.json backups are different!';
    }
  });
});