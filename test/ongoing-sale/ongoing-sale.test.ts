import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env';

describe('pending sale', () => {
  test('try to list nft before marketplace opens', async () => {
    let user = new User;
    let res = await user.mainActor.list({
      price: [BigInt(1000)],
      token: '',
      from_subaccount: [],
    });
    expect(res['err'].Other).toContain('can not list yet');
  });

  test('buy nft from sale', async () => {
    let user = new User;
    user.mintICP(1000_000_000n);
    let settings = await user.mainActor.salesSettings(user.accountId);

    let res = await user.mainActor.reserve(settings.price, 1n, user.accountId, new Uint8Array);

    expect(res).not.toHaveProperty('err');
    if ('ok' in res) {
      let paymentAddress = res.ok[0];
      let paymentAmount = res.ok[1];
      expect(paymentAddress.length).toBe(64);
      expect(paymentAmount).toBe(settings.price);

      await user.sendICP(paymentAddress, paymentAmount);
      let retrieveRes = await user.mainActor.retrieve(paymentAddress);
      expect(retrieveRes).not.toHaveProperty('err');

      let tokensRes = await user.mainActor.tokens(user.accountId);
      expect(tokensRes).not.toHaveProperty('err');
      if ('ok' in tokensRes) {
      console.log(tokensRes.ok.length)
        expect(tokensRes.ok.length).toBe(1);
        let tokenIndex = tokensRes.ok.at(-1);
        expect(tokenIndex).toBeGreaterThan(0);
      }
    }
  });
});