import { expect, should, test } from 'vitest';
import { Principal } from '@dfinity/principal';
import { AccountIdentifier } from '@dfinity/nns';
import { generateIdentity } from './generate-identity.js';
import { User } from './user';
// import { generateActor } from './generate-actor.js';

// let actor = generateActor();
// console.log(AccountIdentifier.fromPrincipal({principal: Principal.fromText('exnaa-55bwr-ekmuc-o2cuk-l6hom-ubazh-uqcjs-m5dwv-gplzr-j44cm-kae')}).toHex())
// console.log(generateIdentity('minter').getPrincipal().toText())

test('should check minter principal', async () => {
  let alice = new User('Alice');
  const result1 = await alice.actor.getMinter();
  expect(result1.toText()).toBe('km6gf-52jvx-bi3y6-iau4o-edjss-mf5nw-qj7la-bpdhh-hsqm7-sd2ar-nae');
});

// test('should throw on collectCanisterMetrics', async () => {
//   await expect(async () => {
//     await actor.collectCanisterMetrics();
//   }).rejects.toThrow(/assertion failed/);
// });

// test('should throw on shuffleAssets', async () => {
//   await expect(async () => {
//     await actor.shuffleAssets();
//   }).rejects.toThrow(/assertion failed/);
// });

// test('should throw on initMint', async () => {
//   await expect(async () => {
//     await actor.initMint();
//   }).rejects.toThrow(/assertion failed/);
// });

// test('should throw on shuffleTokensForSale', async () => {
//   await expect(async () => {
//     await actor.shuffleTokensForSale();
//   }).rejects.toThrow(/assertion failed/);
// });