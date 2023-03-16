import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import { User } from '../user';


describe('backup', async () => {
  let growSize = 2001n;
  let growCount = 2;
  let chunkSize = 1500n;
  let user = new User('');

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
    execSync(`npm run backup -- --file a.json --chunk-size ${chunkSize}`, { stdio: 'inherit' });
  });
});