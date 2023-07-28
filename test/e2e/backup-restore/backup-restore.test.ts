import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import path from 'path';
import { readFileSync } from 'fs';
import { User } from '../user';
import { applyEnv } from '../apply-env';

import canisterIds from '../../../.dfx/local/canister_ids.json';

let canisterId = canisterIds.test.local;

describe('backup', () => {
  let growSize = 2001n;
  let growCount = 2;
  let chunkSize = 1500n;
  let user = new User('');

  it('apply env', async () => {
    await applyEnv('restore');
  });

  it('try to restore with restoreEnabled = false', async () => {
    await expect(user.mainActor.restoreChunk({v1: {
      marketplace: [],
      assets: [],
      sale: [],
      disburser: [],
      tokens: [],
      shuffle: [],
    }})).rejects.toThrow(/Restore disabled/);
  });

  it(`grow up to ${growSize * BigInt(growCount)}`, async () => {
    let curSize = 0n;
    for (let i = 0; i < growCount; i++) {
      console.log(`growing up to ${curSize + growSize}`);
      await user.mainActor.grow(growSize);
      curSize += growSize;
    }
  });

  it('backup to a.json', async () => {
    execSync(`npm run backup -- --canister-id ${canisterId} --file a.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });
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