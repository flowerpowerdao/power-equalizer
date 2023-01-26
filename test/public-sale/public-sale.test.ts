import { AccountIdentifier } from '@dfinity/nns';
import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { buyFromSale } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.public-sale';

async function checkTokenCount(user: User, count: number) {
  let tokensRes = await user.mainActor.tokens(user.accountId);
  expect(tokensRes).not.toHaveProperty('err');
  if ('ok' in tokensRes) {
    expect(tokensRes.ok.length).toBe(count);
    let tokenIndex = tokensRes.ok.at(-1);
    expect(tokenIndex).toBeGreaterThan(0);
  }
}

describe('public sale', () => {
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

    await buyFromSale(user);

    await checkTokenCount(user, 1);
  });

  test('buy sequentially 2 nft from sale', async () => {
    let user = new User;
    user.mintICP(100_000_000_000n);
    let settings = await user.mainActor.salesSettings(user.accountId);

    await buyFromSale(user);
    await buyFromSale(user);

    await checkTokenCount(user, 2);
  });

  test('buy in parallel 4 nft from sale', async () => {
    let user = new User;
    user.mintICP(100_000_000_000n);
    let settings = await user.mainActor.salesSettings(user.accountId);

    await Promise.all([
      await buyFromSale(user),
      await buyFromSale(user),
      await buyFromSale(user),
      await buyFromSale(user),
    ]);

    await checkTokenCount(user, 4);
  });
});