import { expect, should, test } from 'vitest';
import { Actor, CanisterStatus, HttpAgent } from '@dfinity/agent';
import { Principal } from '@dfinity/principal';
import { actor } from './actor.js';

test('should check minter principal', async () => {
  const result1 = await actor.getMinter();
  expect(result1.toText()).toBe('km6gf-52jvx-bi3y6-iau4o-edjss-mf5nw-qj7la-bpdhh-hsqm7-sd2ar-nae');
});

test('should throw on collectCanisterMetrics', async () => {
  await expect(async () => {
    await actor.collectCanisterMetrics();
  }).rejects.toThrow(/assertion failed/);
});

test('should throw on shuffleAssets', async () => {
  await expect(async () => {
    await actor.shuffleAssets();
  }).rejects.toThrow(/assertion failed/);
});

test('should throw on initMint', async () => {
  await expect(async () => {
    await actor.initMint();
  }).rejects.toThrow(/assertion failed/);
});

test('should throw on shuffleTokensForSale', async () => {
  await expect(async () => {
    await actor.shuffleTokensForSale();
  }).rejects.toThrow(/assertion failed/);
});