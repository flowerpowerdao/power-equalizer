import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  publicSaleStart: BigInt(Date.now()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(Date.now()) * 1_000_000n * 2n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
  whitelistSlot1_start: BigInt(Date.now()) * 1_000_000n,
  whitelistSlot1_end: BigInt(Date.now()) * 1_000_000n * 2n,
  whitelistSlot2_start: BigInt(Date.now()) * 1_000_000n,
  whitelistSlot2_end: BigInt(Date.now()) * 1_000_000n * 2n,
};