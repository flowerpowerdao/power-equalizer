import { describe, test, expect } from 'vitest';
import { ICP_FEE } from '../consts';
import { User } from '../user';
import { buyFromSale, checkTokenCount, feeOf, toAccount } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './env';

let count = 10;
describe('open edition', () => {
  test(`buy in parallel ${count} nft from sale`, async () => {
    let user = new User;
    await user.mintICP(1_000_000_000_000n);
    await Promise.all(Array(count).fill('').map(() => buyFromSale(user)));
    await checkTokenCount(user, count);
  });

  test(`buy in parallel ${count} nft from sale`, async () => {
    let user = new User;
    await user.mintICP(1_000_000_000_000n);
    await Promise.all(Array(count).fill('').map(() => buyFromSale(user)));
    await checkTokenCount(user, count);
  });

  test('wait for the sale to end', async () => {
    await new Promise((resolve) => {
      setTimeout(resolve, 1000 * 20);
    });
  });

  test('try to buy when sale ended', async () => {
    let user = new User;
    let settings = await user.mainActor.salesSettings(user.accountId);
    let res = await user.mainActor.reserve(user.accountId);
    expect(res).toHaveProperty('err');
    expect(res['err']).toContain('sale has ended');
  });
});