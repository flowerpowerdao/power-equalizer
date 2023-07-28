import { describe, test, expect } from 'vitest';
import { User } from '../user';
import { whitelistTier0, whitelistTier1 } from '../well-known-users';
import env from './env';

describe('pending sale', () => {
  test('check salesSettings', async () => {
    let user = new User;
    let res = await user.mainActor.salesSettings(user.accountId);
    expect(res.salePrice).toBe(env.salePrice);
    expect(res.price).toBe(env.salePrice);
    expect(res.remaining).toBe(7777n);
    expect(res.sold).toBe(0n);
    expect(res.totalToSell).toBe(7777n);
    expect(res.startTime).toBe(env.whitelistSlot1_start);
    expect(res.whitelistTime).toBe(env.publicSaleStart);
    expect(res.whitelist).toBe(false);
  });

  test('check salesSettings price for whitelistTier0 address', async () => {
    let user = whitelistTier0[0];
    let res = await user.mainActor.salesSettings(user.accountId);
    expect(res.salePrice).toBe(env.salePrice);
    expect(res.price).toBe(env.whitelistTier0Price);
  });

  test('try to call initMint', async () => {
    let user = new User;
    await expect(user.mainActor.initMint()).rejects.toThrow();
  });

  test('check salesSettings price for whitelistTier1 address', async () => {
    let user = whitelistTier1[0];
    let res = await user.mainActor.salesSettings(user.accountId);
    expect(res.salePrice).toBe(env.salePrice);
    expect(res.price).toBe(env.whitelistTier1Price);
  });

  test('check supply', async () => {
    let user = new User;
    let res = await user.mainActor.supply();
    expect(res['ok']).toBe(7777n);
  });

  test('check getTokens', async () => {
    let user = new User;
    let res = await user.mainActor.getTokens();
    expect(res['ok']).toBe(undefined); // ??
  });

  test('check tokens', async () => {
    let user = new User;
    let res = await user.mainActor.getTokens();
    expect(res['ok']).toBe(undefined); // ??
  });

  test('try to reserve token', async () => {
    let user = new User;
    let res = await user.mainActor.reserve(user.accountId);
    expect(res['err']).toContain('sale has not started');
  });
});