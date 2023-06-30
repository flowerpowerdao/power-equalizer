import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  publicSaleStart: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n,
  whitelistSlot1_start: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n,
  whitelistSlot1_end: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n * 2n,
  whitelistSlot2_start: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n,
  whitelistSlot2_end: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n * 2n,
};