import { describe, test, expect, it } from 'vitest';
import { User } from '../user';
import { buyFromSale, checkTokenCount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './env';

describe('list and delist nft', () => {
  let user = new User;

  it('mint ICP', async () => {
    await user.mintICP(1000_000_000n);
  });

  it('buy from sale', async () => {
    await buyFromSale(user)
  });

  it('check token count', async () => {
    await checkTokenCount(user, 1)
  });

  let tokens;
  it('get tokens', async () => {
    let res = await user.mainActor.tokens(user.accountId);
    expect(res).toHaveProperty('ok');
    if ('err' in res) {
      throw res.err;
    }
    tokens = res.ok;
    expect(tokens).toHaveLength(1);
  });

  it('try to list at price < 0.01 ICP', async () => {
    let res = await user.mainActor.list({
      from_subaccount: [],
      price: [BigInt(0.005e8)],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });
    expect(res).toHaveProperty('err');
  });

  it('list at price 0.01 ICP', async () => {
    let res = await user.mainActor.list({
      from_subaccount: [],
      price: [BigInt(0.01e8)],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });
    expect(res).toHaveProperty('ok');
  });

  it('delist', async () => {
    let res = await user.mainActor.list({
      from_subaccount: [],
      price: [],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });
    expect(res).toHaveProperty('ok');
  });

  it('check token count', async () => {
    await checkTokenCount(user, 1)
  });
});