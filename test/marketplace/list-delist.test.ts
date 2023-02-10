import { describe, test, expect, it } from 'vitest';
import { User } from '../user';
import { buyFromSale, checkTokenCount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.marketplace';

describe('list and delist nft', async () => {
  let user = new User;
  user.mintICP(1000_000_000n);

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

  it('list', async () => {
    let res = await user.mainActor.list({
      from_subaccount: [],
      price: [1000_000n],
      token: tokenIdentifier(tokens[0]),
      marketplacePrincipal: [],
    });
    expect(res).toHaveProperty('ok');
  });

  it('delist', async () => {
    let res = await user.mainActor.list({
      from_subaccount: [],
      price: [],
      token: tokenIdentifier(tokens[0]),
      marketplacePrincipal: [],
    });
    expect(res).toHaveProperty('ok');
  });

  it('check token count', async () => {
    await checkTokenCount(user, 1)
  });
});