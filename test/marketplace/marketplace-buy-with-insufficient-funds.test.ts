import { AccountIdentifier } from '@dfinity/nns';
import { describe, test, expect, it } from 'vitest';
import { ICP_FEE } from '../consts';
import { User } from '../user';
import { applyFees, buyFromSale, checkTokenCount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './env';

describe('try to buy on marketplace with insufficient funds', () => {
  let seller = new User;
  let buyer = new User;

  let price = 1_000_000n;
  let initialBalance = 1_000_000_000n;

  it('mint ICP', async () => {
    await seller.mintICP(initialBalance);
    await buyer.mintICP(initialBalance);
  });

  it('buy from sale', async () => {
    await buyFromSale(seller)
  });

  it('check seller ICP balance', async () => {
    let expectedBalance = initialBalance - env.salePrice - ICP_FEE;
    expect(await seller.icpActor.account_balance({ account: seller.account })).toEqual({ e8s: expectedBalance });
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
      frontendIdentifier: [],
    });
    expect(res).toHaveProperty('ok');
  });

  let paytoAddress: string;
  it('lock', async () => {
    let lockRes = await buyer.mainActor.lock(tokenIdentifier(tokens[0]), price, buyer.accountId, new Uint8Array, []);
    expect(lockRes).toHaveProperty('ok');
    if ('ok' in lockRes) {
      paytoAddress = lockRes.ok;
    }
  });

  it('transfer ICP', async () => {
    await buyer.sendICP(paytoAddress, price - 1n);
  });

  it('try to settle', async () => {
    let res = await buyer.mainActor.settle(tokenIdentifier(tokens[0]));
    expect(res).toHaveProperty('err');
  });

  it('check seller token count', async () => {
    await checkTokenCount(seller, 1);
  });

  it('check buyer token count', async () => {
    let tokensRes = await buyer.mainActor.tokens(buyer.accountId);
    expect(tokensRes).toHaveProperty('err');
    expect(tokensRes['err']['Other']).toBe('No tokens');
  });
});