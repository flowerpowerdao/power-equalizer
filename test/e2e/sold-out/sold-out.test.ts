import { describe, test, it, expect } from 'vitest';
import { User } from '../user';
import { buyFromSale, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1, lucky } from '../well-known-users';
import env from './env';

describe('sold out', () => {
  let user = new User;

  it('mint ICP', async () => {
    await user.mintICP(1_000_000_000_000n);
  });

  it('try to list token before sold out', async () => {
    await buyFromSale(user);

    let res = await user.mainActor.tokens(user.accountId);
    expect(res).toHaveProperty('ok');
    if ('err' in res) {
      throw res.err;
    }
    let tokens = res.ok;

    let listRes = await user.mainActor.list({
      from_subaccount: [],
      price: [1000_000n],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });

    expect(listRes).toHaveProperty('err');
  });

  it('buy entire collection on sale', async () => {
    let settings = await user.mainActor.salesSettings(user.accountId);
    for (let i = 0; i < settings.totalToSell - 1n; i++) {
      await buyFromSale(user);
    }
  });

  it('list token after sold out', async () => {
    let res = await user.mainActor.tokens(user.accountId);
    expect(res).toHaveProperty('ok');
    if ('err' in res) {
      throw res.err;
    }
    let tokens = res.ok;

    let listRes = await user.mainActor.list({
      from_subaccount: [],
      price: [1000_000n],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });

    expect(listRes).toHaveProperty('ok');
  });
});