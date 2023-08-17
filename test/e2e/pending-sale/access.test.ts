import { describe, test, expect } from 'vitest';
import { User } from '../user';
import env from './env';

describe('method calls restricted to admin/minter', () => {
  test('should try to call initMint', async () => {
    let user = new User;
    await expect(user.mainActor.initMint()).rejects.toThrow(/assertion failed/);
  });

  test('should try to call streamAsset', async () => {
    let user = new User;
    await expect(user.mainActor.streamAsset(0n, false, new Uint8Array)).rejects.toThrow(/assertion failed/);
  });

  test('should try to call updateThumb', async () => {
    let user = new User;
    await expect(user.mainActor.updateThumb('test', { data: [new Uint8Array], ctype: '' })).rejects.toThrow(/assertion failed/);
  });

  test('should try to call addAsset', async () => {
    let user = new User;
    await expect(user.mainActor.addAsset({
      thumbnail: [],
      metadata: [],
      name: 'test',
      payload: { data: [new Uint8Array], ctype: '' },
      payloadUrl: [],
      thumbnailUrl: [],
    })).rejects.toThrow(/assertion failed/);
  });
});