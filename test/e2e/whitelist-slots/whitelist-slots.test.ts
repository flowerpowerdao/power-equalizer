import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { buyFromSale } from '../utils';
import { whitelistTier0, whitelistTier1, lucky } from '../well-known-users';
import env from './env';

// slot 1
describe('whitelist slot 1', () => {
  test('check price for non-whitelisted user', async () => {
    let user = new User;
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.salePrice);
  });

  test('check whitelist price', async () => {
    let user = whitelistTier0[0];
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier0Price);
  });

  test('check whitelist price after nft bought', async () => {
    let user = whitelistTier0[1];
    await user.mintICP(100_000_000_000n);

    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier0Price);

    await buyFromSale(user);

    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.salePrice);
  });

  test('check whitelist price for user from multiple whitelists', async () => {
    let user = lucky[2];
    await user.mintICP(100_000_000_000n);

    let settings = await user.mainActor.salesSettings(user.accountId);
    // must be cheapest price
    expect(settings.price).toBe(env.whitelistTier0Price);
  });

  test('check whitelist price change for user from multiple whitelists after multiple nft bought', async () => {
    let user = lucky[3];
    await user.mintICP(100_000_000_000n);

    // tier 1 price
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier0Price);

    await buyFromSale(user);

    // tier 2 price
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier1Price);
  });

  test('try to buy after spot from slot 1 was used and slot 2 has not started yet', async () => {
    let user = lucky[3];

    let settings = await user.mainActor.salesSettings(user.accountId);
    let res = await user.mainActor.reserve(user.accountId);

    expect(res).toHaveProperty('err');
  });

  test('user from slot 2 try to buy during slot 1', async () => {
    let user = whitelistTier1[0];

    let res = await user.mainActor.reserve(user.accountId);
    expect(res).toHaveProperty('err');
  });
});

// slot 2
describe('whitelist slot 2', () => {
  test('wait for slot 2 to start', async () => {
    await new Promise<void>((resolve) => {
      let interval = setInterval(() => {
        if (Date.now() * 1_000_000 > env.whitelistSlot2_start) {
          resolve();
          clearInterval(interval);
        }
      }, 1000 * 5);
    });
  });

  test('user from slot 1 try to buy during slot 2', async () => {
    let user = whitelistTier0[4];
    await user.mintICP(100_000_000_000n);

    // should be sale price
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.salePrice);

    let res = await user.mainActor.reserve(user.accountId);
    expect(res).toHaveProperty('err');
  });

  test('user from both tiers bought during slot 1 and should be able to buy during slot 2', async () => {
    let user = lucky[3];
    await user.mintICP(100_000_000_000n);

    // should be tier 2 price
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier1Price);

    await buyFromSale(user);
  });

  test('user from both tiers did not buy during slot 1 try to buy at tier 1 price during slot 2', async () => {
    let user = lucky[5];
    await user.mintICP(100_000_000_000n);

    // try to buy at tier 1 price
    let res = await user.mainActor.reserve(user.accountId);
    expect(res).toHaveProperty('ok');

    if ('ok' in res) {
      let paymentAddress = res.ok[0];

      await user.sendICP(paymentAddress, env.whitelistTier0Price);
      let retrieveRes = await user.mainActor.retrieve(paymentAddress);
      expect(retrieveRes).toHaveProperty('err');
      expect(retrieveRes['err']).toMatch(/Insufficient funds/i);
    }
  });

  test('user from both tiers did not buy during slot 1 and should be able to buy during slot 2 at tier 2 price', async () => {
    let user = lucky[6];
    await user.mintICP(100_000_000_000n);

    // should be tier 2 price
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier1Price);

    await buyFromSale(user);
  });
});
