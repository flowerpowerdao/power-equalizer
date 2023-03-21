import { AccountIdentifier } from '@dfinity/nns';
import { describe, test, expect, it } from 'vitest';
import { ICP_FEE } from '../consts';
import { User } from '../user';
import { applyFees, buyFromMarketplace, buyFromSale, checkTokenCount, feeOf, toAccount, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.fees';

describe('list and buy on different marketplace frontends', async () => {
  let price = 1_000_000n;
  let initialBalance = 1_000_000_000_000n;
  let transferFees = ICP_FEE * 5n; // 1 seller transfer, 2 marketplace transfers(seller + buyer), 2 royalty transfers

  let yumi = new User;
  let yumiFee = 456n;

  let jelly = new User;
  let jellyFee = 300n;

  let seller = new User;
  await seller.mintICP(initialBalance);

  let buyer = new User;
  await buyer.mintICP(initialBalance);

  it('try to add marketplace with fee < 0', async () => {
    await expect(new User('').mainActor.putFrontend('yumi', {
      accountIdentifier: yumi.accountId,
      fee: -1n,
    })).rejects.toThrow();
  });

  it('try to add marketplace with fee > 500', async () => {
    await expect(new User('').mainActor.putFrontend('yumi', {
      accountIdentifier: yumi.accountId,
      fee: 501n,
    })).rejects.toThrow();
  });

  it('add Yumi marketplace frontend', async () => {
    await new User('').mainActor.putFrontend('yumi', {
      accountIdentifier: yumi.accountId,
      fee: yumiFee,
    });
  });

  it('add Jelly marketplace frontend', async () => {
    await new User('').mainActor.putFrontend('jelly', {
      accountIdentifier: jelly.accountId,
      fee: jellyFee,
    });
  });

  it('buy from sale', async () => {
    await buyFromSale(seller);
    await buyFromSale(seller);
    await buyFromSale(seller);
    await buyFromSale(seller);
  });

  let tokens;
  it('get tokens', async () => {
    let res = await seller.mainActor.tokens(seller.accountId);
    expect(res).toHaveProperty('ok');
    if ('err' in res) {
      throw res.err;
    }
    tokens = res.ok;
    expect(tokens).toHaveLength(4);
  });

  it('try to list with unknown frontend', async () => {
    let res = await seller.mainActor.list({
      from_subaccount: [],
      price: [price],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: ['unknown'],
    });
    expect(res).toHaveProperty('err');
    expect(res['err']['Other']).toBe('Unknown frontend identifier');
  });

  it('list token #0 on Yumi', async () => {
    let res = await seller.mainActor.list({
      from_subaccount: [],
      price: [price],
      token: tokenIdentifier(tokens[0]),
      frontendIdentifier: ['yumi'],
    });
    expect(res).toHaveProperty('ok');
  });

  it('list token #1 on Yumi', async () => {
    let res = await seller.mainActor.list({
      from_subaccount: [],
      price: [price],
      token: tokenIdentifier(tokens[1]),
      frontendIdentifier: ['yumi'],
    });
    expect(res).toHaveProperty('ok');
  });

  it('list token #2 on Jelly', async () => {
    let res = await seller.mainActor.list({
      from_subaccount: [],
      price: [price],
      token: tokenIdentifier(tokens[2]),
      frontendIdentifier: ['jelly'],
    });
    expect(res).toHaveProperty('ok');
  });

  it('list token #3 on Jelly', async () => {
    let res = await seller.mainActor.list({
      from_subaccount: [],
      price: [price],
      token: tokenIdentifier(tokens[3]),
      frontendIdentifier: ['jelly'],
    });
    expect(res).toHaveProperty('ok');
  });

  // buy on different marketplaces
  let yumiBalance = 0n;
  let jellyBalance = 0n;

  it('buy token #0 listed on Yumi', async () => {
    await buyFromMarketplace(buyer, tokenIdentifier(tokens[0]), price, []);
    yumiBalance += yumiFee;
  });

  it('check marketplaces royalty fee disbursement', async () => {
    expect(await seller.icpActor.account_balance({ account: yumi.account })).toEqual({ e8s: feeOf(price - transferFees, yumiBalance) });
    expect(await seller.icpActor.account_balance({ account: jelly.account })).toEqual({ e8s: feeOf(price - transferFees, jellyBalance) });
  });

  it('buy on Yumi token #1 listed on Yumi', async () => {
    await buyFromMarketplace(buyer, tokenIdentifier(tokens[1]), price, ['yumi']);
    yumiBalance += yumiFee * 2n;
  });

  it('check marketplaces royalty fee disbursement', async () => {
    expect(await seller.icpActor.account_balance({ account: yumi.account })).toEqual({ e8s: feeOf(price - transferFees, yumiBalance) });
    expect(await seller.icpActor.account_balance({ account: jelly.account })).toEqual({ e8s: feeOf(price - transferFees, jellyBalance) });
  });

  it('buy on Yumi token #2 listed on Jelly', async () => {
    await buyFromMarketplace(buyer, tokenIdentifier(tokens[2]), price, ['yumi']);
    yumiBalance += yumiFee;
    jellyBalance += jellyFee;
  });

  it('check marketplaces royalty fee disbursement', async () => {
    expect(await seller.icpActor.account_balance({ account: yumi.account })).toEqual({ e8s: feeOf(price - transferFees, yumiBalance) });
    expect(await seller.icpActor.account_balance({ account: jelly.account })).toEqual({ e8s: feeOf(price - transferFees, jellyBalance) });
  });

  it('buy on Jelly token #3 listed on Jelly', async () => {
    await buyFromMarketplace(buyer, tokenIdentifier(tokens[3]), price, ['jelly']);
    jellyBalance += jellyFee * 2n;
  });

  it('check marketplaces royalty fee disbursement', async () => {
    expect(await seller.icpActor.account_balance({ account: yumi.account })).toEqual({ e8s: feeOf(price - transferFees, yumiBalance) });
    expect(await seller.icpActor.account_balance({ account: jelly.account })).toEqual({ e8s: feeOf(price - transferFees, jellyBalance) });
  });
});