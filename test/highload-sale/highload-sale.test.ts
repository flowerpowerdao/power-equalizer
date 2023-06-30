import { describe, test, expect } from 'vitest';
import { ICP_FEE } from '../consts';
import { User } from '../user';
import { buyFromSale, checkTokenCount, feeOf, toAccount } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './env';

let buyTransferFees = ICP_FEE * 2n; // 2 sale fee transfers
let saleFee0 = feeOf(env.salePrice - buyTransferFees, env.salesDistribution0);
let saleFee1 = feeOf(env.salePrice - buyTransferFees, env.salesDistribution1);

let count1 = 100;
describe('highload sale ' + count1, () => {
  let user = new User;

  test(`buy in parallel ${count1} nft from sale`, async () => {
    await user.mintICP(1000_000_000_000n);

    console.time('buy ' + count1);
    await Promise.all(Array(count1).fill('').map(() => buyFromSale(user)));
    console.timeEnd('buy ' + count1);

    await checkTokenCount(user, count1);
  });

  test('wait for timers', async () => {
    await new Promise((resolve) => {
      setTimeout(resolve, env.timersInterval * 1000 * 2);
    });
  });

  test('check fee disbursements', async () => {
    expect(await user.icpActor.account_balance(toAccount(env.beneficiary0))).toEqual({ e8s: saleFee0 * BigInt(count1) });
    expect(await user.icpActor.account_balance(toAccount(env.beneficiary1))).toEqual({ e8s: saleFee1 * BigInt(count1) });
  });
});

let count2 = 100;
describe('highload sale ' + count2, () => {
  let user = new User;

  test(`buy in parallel ${count2} nft from sale`, async () => {
    await user.mintICP(1000_000_000_000n);

    console.time('buy ' + count2);
    await Promise.all(Array(count2).fill('').map(() => buyFromSale(user)));
    console.timeEnd('buy ' + count2);

  });

  test('wait for timers', async () => {
    await new Promise((resolve) => {
      setTimeout(resolve, env.timersInterval * 1000 * 2);
    });
  });

  test('check fee disbursements', async () => {
    expect(await user.icpActor.account_balance(toAccount(env.beneficiary0))).toEqual({ e8s: saleFee0 * BigInt(count1) + saleFee0 * BigInt(count2) });
    expect(await user.icpActor.account_balance(toAccount(env.beneficiary1))).toEqual({ e8s: saleFee1 * BigInt(count1) + saleFee1 * BigInt(count2) });
  });
});

let count3 = 70;
let times = 4;
describe(`highload sale ${count3*times}`, () => {
  let user = new User;

  for (let i = 0; i < times; i++) {
    test(`${i + 1}. buy in parallel ${count3} nft from sale`, async () => {
      await user.mintICP(1000_000_000_000n);
      await Promise.all(Array(count3).fill('').map(() => buyFromSale(user)));
    });
  }

  test('wait for timers', async () => {
    await new Promise((resolve) => {
      setTimeout(resolve, env.timersInterval * 1000 * 4);
    });
  });

  test('check fee disbursements', async () => {
    let balance0 = (await user.icpActor.account_balance(toAccount(env.beneficiary0))).e8s;
    let balance1 = (await user.icpActor.account_balance(toAccount(env.beneficiary1))).e8s;
    let fee0 = saleFee0 * BigInt(count1) + saleFee0 * BigInt(count2) + saleFee0 * BigInt(count3 * times);
    let fee1 = saleFee1 * BigInt(count1) + saleFee1 * BigInt(count2) + saleFee1 * BigInt(count3 * times);
    expect(balance0).toBe(fee0);
    expect(balance1).toBe(fee1);
  });
});