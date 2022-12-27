import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { ethFlowerWhitelist, modclubWhitelist } from '../well-known-users';
import env from './.env';

describe('pending sale', () => {
  test('should check salesSettings', async () => {
    let user = new User;
    let res = await user.mainActor.salesSettings(user.accountId);
    expect(res.salePrice).toBe(env.salePrice);
    expect(res.price).toBe(env.salePrice);
    expect(res.remaining).toBe(env.collectionSize);
    expect(res.sold).toBe(0n);
    expect(res.totalToSell).toBe(0n); // not collectionSize??
    expect(res.startTime).toBe(env.publicSaleStart);
    expect(res.whitelist).toBe(false);
    expect(res.whitelistTime).toBe(env.whitelistTime);
    expect(res.bulkPricing).toEqual([[1n, env.salePrice]]);
  });

  test('should check salesSettings price for ethFlowerWhitelist address', async () => {
    let user = ethFlowerWhitelist[0];
    let res = await user.mainActor.salesSettings(user.accountId);
    expect(res.salePrice).toBe(env.salePrice);
    expect(res.price).toBe(env.ethFlowerWhitelistPrice);
  });

  test('should try to call initMint', async () => {
    let user = new User;
    await expect(user.mainActor.initMint()).rejects.toThrow();
  });

  test('should check salesSettings price for modclubWhitelist address', async () => {
    let user = modclubWhitelist[0];
    let res = await user.mainActor.salesSettings(user.accountId);
    expect(res.salePrice).toBe(env.salePrice);
    expect(res.price).toBe(env.modclubWhitelistPrice);
  });

  test('should check supply', async () => {
    let user = new User;
    let res = await user.mainActor.supply();
    expect(res['ok']).toBe(env.collectionSize);
  });

  test('should check getTokens', async () => {
    let user = new User;
    let res = await user.mainActor.getTokens();
    expect(res['ok']).toBe(undefined); // ??
  });

  test('should check tokens', async () => {
    let user = new User;
    let res = await user.mainActor.getTokens();
    expect(res['ok']).toBe(undefined); // ??
  });

  test('should try to reserve token', async () => {
    let user = new User;
    let res = await user.mainActor.reserve(1_000_000n, 1n, user.accountId, new Uint8Array);
    expect(res['err']).toContain('sale has not started');
  });
});