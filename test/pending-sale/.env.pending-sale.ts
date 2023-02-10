import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  publicSaleStart: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
};