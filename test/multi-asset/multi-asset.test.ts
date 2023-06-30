import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { tokenIdentifier } from '../utils';
import env from './env';

describe('multi asset collection', () => {
  let user = new User;

  test('check getTokenToAssetMapping', async () => {
    let tokenToAsset = await user.mainActor.getTokenToAssetMapping();

    tokenToAsset.forEach(([index, asset], i) => {
      expect(index).toBe(i);
      expect(asset).toBe(`privat${i}`);
    });
  });

  test('check metadata of each token', async () => {
    let settings = await user.mainActor.salesSettings(user.accountId);
    for (let i = 0; i < settings.totalToSell; i++) {
      expect(await user.mainActor.metadata(tokenIdentifier(i))).toEqual({
        ok: {
          nonfungible: {
            metadata: [new Uint8Array([0, 0, 0, i])],
          },
        },
      });
    }
  });
});