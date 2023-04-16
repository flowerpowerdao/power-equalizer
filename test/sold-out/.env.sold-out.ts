import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  sale: 'variant { supply = 5 }',
  publicSaleStart: BigInt(Date.now()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(Date.now()) * 1_000_000n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
};