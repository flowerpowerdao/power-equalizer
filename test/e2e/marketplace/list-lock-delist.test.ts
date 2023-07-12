import { describe, test, expect, it } from 'vitest';
import { User } from '../user';
import { buyFromSale, checkTokenCount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './env';

describe('list, lock and try to delist nft', () => {
  let seller = new User;
  let buyer = new User;

  it('mint ICP', async () => {
    await seller.mintICP(1000_000_000n);
    await buyer.mintICP(1000_000_000n);
  });

  it('buy from sale', async () => {
    await buyFromSale(seller)
  });

  it('check token count', async () => {
    await checkTokenCount(seller, 1)
  });

  let tokens;
  it('get tokens', async () => {
    let res = await seller.mainActor.tokens(seller.accountId);
    expect(res).toHaveProperty('ok');
    if ('err' in res) {
      throw res.err;
    }
    tokens = res.ok;
    expect(tokens).toHaveLength(1);
  });

  it('list', async () => {
    let res = await seller.mainActor.list({
      from_subaccount: [],
      price: [1000_000n],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });
    expect(res).toHaveProperty('ok');
  });

  it('lock', async () => {
    let lockRes = await buyer.mainActor.lock(tokenIdentifier(tokens[0]), 1000_000n, buyer.accountId, new Uint8Array, []);
    expect(lockRes).toHaveProperty('ok');
  });

  it('try to lock twice', async () => {
    let user = new User;
    let lockRes = await user.mainActor.lock(tokenIdentifier(tokens[0]), 1000_000n, user.accountId, new Uint8Array, []);
    expect(lockRes).toHaveProperty('err');
    expect(lockRes['err'].Other).toBe('Listing is locked');
  });

  it('try to delist', async () => {
    let delistRes = await seller.mainActor.list({
      from_subaccount: [],
      price: [],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: [],
    });
    expect(delistRes).toHaveProperty('err');
    expect(delistRes['err'].Other).toBe('Listing is locked');

  });

  it('check token count', async () => {
    await checkTokenCount(seller, 1)
  });
});