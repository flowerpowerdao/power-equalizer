import { describe, test, expect } from 'vitest';
import { ICP_FEE } from '../consts';
import { User } from '../user';
import { buyFromSale, checkTokenCount, feeOf, toAccount } from '../utils';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './.env.open-edition';

let count = 20;
describe('open edition', () => {
  let user = new User;

  test(`buy in parallel ${count} nft from sale`, async () => {
    await user.mintICP(1_000_000_000_000n);
    await Promise.all(Array(count).fill('').map(() => buyFromSale(user)));
    await checkTokenCount(user, count);
  });

  test('wait for the sale to end', async () => {
    await new Promise((resolve) => {
      setTimeout(resolve, 1000 * 30);
    });
  });

  test('try to buy after the sale ends', async () => {
    let settings = await user.mainActor.salesSettings(user.accountId);
    let res = await user.mainActor.reserve(settings.price, 1n, user.accountId, new Uint8Array);
    expect(res).toHaveProperty('err');
  });
});