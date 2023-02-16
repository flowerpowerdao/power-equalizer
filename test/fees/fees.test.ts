import { AccountIdentifier } from '@dfinity/nns';
import { describe, test, expect, it } from 'vitest';
import { ICP_FEE } from '../consts';
import { User } from '../user';
import { applyFees, buyFromSale, checkTokenCount, feeOf, tokenIdentifier } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.fees';

let toAccount = (address: string) => {
  return { account: AccountIdentifier.fromHex(address).toNumbers() };
}

describe('sale and royalty fees', async () => {
  let price = 1_000_000n;
  let initialBalance = 1_000_000_000n;

  let seller = new User;
  await seller.mintICP(initialBalance);

  let buyer = new User;
  await buyer.mintICP(initialBalance);

  it('check beneficiary0 balance', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.beneficiary0))).toEqual({ e8s: 0n });
  });

  it('check beneficiary1 balance', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.beneficiary1))).toEqual({ e8s: 0n });
  });

  it('check defaultMarketplace balance', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.defaultMarketplaceAddr))).toEqual({ e8s: 0n });
  });

  it('buy from sale', async () => {
    await buyFromSale(seller)
  });

  it('cron cronDisbursements', async () => {
    await seller.mainActor.cronDisbursements();
  });

  let buyTransferFees = ICP_FEE * 2n; // 2 sale fee transfers
  it('check beneficiary0 sale fee disbursement', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.beneficiary0))).toEqual({ e8s: feeOf(env.salePrice - buyTransferFees, env.salesDistribution0) });
  });

  it('check beneficiary1 sale fee disbursement', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.beneficiary1))).toEqual({ e8s: feeOf(env.salePrice - buyTransferFees, env.salesDistribution1) });
  });

  it('check defaultMarketplace sale fee disbursement', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.defaultMarketplaceAddr))).toEqual({ e8s: 0n });
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
    await buyer.sendICP(paytoAddress, price);
  });

  it('settle by another user', async () => {
    let user = new User;
    let res = await user.mainActor.settle(tokenIdentifier(tokens[0]));
    expect(res).toHaveProperty('ok');
  });

  it('check seller token count', async () => {
    await checkTokenCount(seller, 0);
  });

  it('check buyer token count', async () => {
    await checkTokenCount(buyer, 1);
  });

  it('check buyer ICP balance', async () => {
    let expectedBalance = initialBalance - price - ICP_FEE;
    expect(await buyer.icpActor.account_balance({ account: buyer.account })).toEqual({ e8s: expectedBalance });
  });

  it('cron settlements and cronDisbursements', async () => {
    await seller.mainActor.cronSettlements();
    await seller.mainActor.cronDisbursements();
  });

  let transferFees = ICP_FEE * 5n; // 1 seller transfer, 2 marketplace transfers(seller + buyer), 2 royalty transfers

  it('check seller ICP balance', async () => {
    let balanceAfterBuyOnSale = initialBalance - env.salePrice - ICP_FEE;
    let expectedBalance = balanceAfterBuyOnSale + applyFees(price - transferFees, [env.royalty0, env.royalty1, env.defaultMarketplaceFee * 2n]);
    expect(await seller.icpActor.account_balance({ account: seller.account })).toEqual({ e8s: expectedBalance });
  });

  it('check beneficiary0 royalty fee disbursement', async () => {
    let saleFee = feeOf(env.salePrice - buyTransferFees, env.salesDistribution0);
    let royaltyFee = feeOf(price - transferFees, env.royalty0);
    expect(await seller.icpActor.account_balance(toAccount(env.beneficiary0))).toEqual({ e8s: saleFee + royaltyFee });
  });

  it('check beneficiary1 royalty fee disbursement', async () => {
    let saleFee = feeOf(env.salePrice - buyTransferFees, env.salesDistribution1);
    let royaltyFee = feeOf(price - transferFees, env.royalty1);
    expect(await seller.icpActor.account_balance(toAccount(env.beneficiary1))).toEqual({ e8s: saleFee + royaltyFee });
  });

  it('check defaultMarketplace royalty fee disbursement', async () => {
    expect(await seller.icpActor.account_balance(toAccount(env.defaultMarketplaceAddr))).toEqual({ e8s: feeOf(price - transferFees, env.defaultMarketplaceFee * 2n) });
  });
});