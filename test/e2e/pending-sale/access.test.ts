import { describe, test, expect } from 'vitest';
import { User } from '../user';
import env from './env';

describe('method calls restricted to admin/minter', () => {
  test('should try to call initMint', async () => {
    let user = new User;
    await expect(user.mainActor.initMint()).rejects.toThrow(/assertion failed/);
  });

  test('should try to call addAssets', async () => {
    let user = new User;
    await expect(user.mainActor.addAssets([{
      thumbnail: [],
      metadata: [],
      name: 'test',
      payload: { data: [new Uint8Array], ctype: '' },
      payloadUrl: [],
      thumbnailUrl: [],
    }])).rejects.toThrow(/assertion failed/);
  });
});