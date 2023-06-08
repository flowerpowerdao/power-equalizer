import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  publicSaleStart: BigInt(Date.now()) * 1_000_000n * 2n,
  whitelistSlot1_start: BigInt(Date.now()) * 1_000_000n, // starts now
  whitelistSlot1_end: BigInt(Date.now()) * 1_000_000n + 1_000_000n * 1000n * 60n, // 60s
  whitelistSlot2_start: BigInt(Date.now()) * 1_000_000n + 1_000_000n * 1000n * 60n,
  whitelistSlot2_end: BigInt(Date.now()) * 1_000_000n * 2n,
};