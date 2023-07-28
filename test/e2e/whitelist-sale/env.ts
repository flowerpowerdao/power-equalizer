import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  publicSaleStart: BigInt(Date.now()) * 1_000_000n * 2n,
  whitelistSlot1_start: BigInt(Date.now()) * 1_000_000n,
  whitelistSlot1_end: BigInt(Date.now()) * 1_000_000n * 2n,
  whitelistSlot2_start: BigInt(Date.now()) * 1_000_000n,
  whitelistSlot2_end: BigInt(Date.now()) * 1_000_000n * 2n,
};