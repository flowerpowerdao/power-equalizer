import { AccountIdentifier } from '@dfinity/nns';
import { describe, test, expect, it } from 'vitest';
import { User } from '../user';
import { buyFromSale, checkTokenCount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.marketplace';

describe('buy on marketplace', async () => {
  let price = 1_000_000n;

  let seller = new User;
  seller.mintICP(1000_000_000n);

  let buyer = new User;
  buyer.mintICP(1000_000_000n);

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
      price: [price],
      token: tokenIdentifier(tokens[0]),
    });
    expect(res).toHaveProperty('ok');
  });

  let paytoAddress: string;
  it('lock', async () => {
    let lockRes = await buyer.mainActor.lock(tokenIdentifier(tokens[0]), price, buyer.accountId, new Uint8Array);
    expect(lockRes).toHaveProperty('ok');
    if ('ok' in lockRes) {
      paytoAddress = lockRes.ok;
    }
  });

  it('transfer ICP', async () => {
    await buyer.sendICP(paytoAddress, price);
  });

  it('settle by another user', async () => {
    let user = new User;
    let res = await user.mainActor.settle(tokenIdentifier(tokens[0]));
    expect(res).toHaveProperty('ok');
  });

  it('check seller token count', async () => {
    await checkTokenCount(seller, 0)
  });

  it('check buyer token count', async () => {
    await checkTokenCount(buyer, 1)
  });

  // todo: check seller ICP balance
});