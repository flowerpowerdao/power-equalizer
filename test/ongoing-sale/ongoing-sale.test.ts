import { AccountIdentifier } from '@dfinity/nns';
import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.ongoing-sale';

async function buy(user: User) {
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
  }
}

async function checkTokenCount(user: User, count: number) {
  let tokensRes = await user.mainActor.tokens(user.accountId);
  expect(tokensRes).not.toHaveProperty('err');
  if ('ok' in tokensRes) {
    expect(tokensRes.ok.length).toBe(count);
    let tokenIndex = tokensRes.ok.at(-1);
    expect(tokenIndex).toBeGreaterThan(0);
  }
}

describe('pending sale', () => {
  test('try to list nft before marketplace opens', async () => {
    let user = new User;
    let res = await user.mainActor.list({
      price: [BigInt(1000)],
      token: AccountIdentifier.fromPrincipal({ principal: new User().principal }).toHex(),
      from_subaccount: [],
    });
    expect(res['err'].Other).toContain('can not list yet');
  });

  test('buy nft from sale', async () => {
    let user = new User;
    user.mintICP(1000_000_000n);

    await buy(user);

    await checkTokenCount(user, 1);
  });

  test('buy sequentially 2 nft from sale', async () => {
    let user = new User;
    user.mintICP(100_000_000_000n);
    let settings = await user.mainActor.salesSettings(user.accountId);

    await buy(user);
    await buy(user);

    await checkTokenCount(user, 2);
  });

  test('buy in parallel 4 nft from sale', async () => {
    let user = new User;
    user.mintICP(100_000_000_000n);
    let settings = await user.mainActor.salesSettings(user.accountId);

    await Promise.all([
      await buy(user),
      await buy(user),
      await buy(user),
      await buy(user),
    ]);

    await checkTokenCount(user, 4);
  });
});