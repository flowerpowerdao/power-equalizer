import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { buyFromSale } from '../utils';
import { whitelistTier0, whitelistTier1, lucky, doubleSpot } from '../well-known-users';
import env from './env';

describe('whitelist sale (public sale not open yet)', () => {
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

    // tier 0 price
    let settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier0Price);

    await buyFromSale(user);

    // tier 1 price
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier1Price);

    await buyFromSale(user);

    // sale price
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.salePrice);
  });
});

describe('multiple whitelist spot', async () => {
  let user = doubleSpot[0];
  let settings;

  await test('tier 0 price', async () => {
    await user.mintICP(100_000_000_000n);

    // first spot in whitelist tier 0
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier0Price);

    await buyFromSale(user);

    // second spot in whitelist tier 0
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier0Price);

    await buyFromSale(user);
  });

  await test('tier 1 price', async () => {
    // first spot in whitelist tier 1
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier1Price);

    await buyFromSale(user);

    // second spot in whitelist tier 1
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.whitelistTier1Price);

    await buyFromSale(user);
  });

  await test('sale price', async () => {
    settings = await user.mainActor.salesSettings(user.accountId);
    expect(settings.price).toBe(env.salePrice);
  });
});