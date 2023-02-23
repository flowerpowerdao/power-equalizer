import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  timersInterval: 1, // seconds
  publicSaleStart: BigInt(Date.now()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(Date.now()) * 1_000_000n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
  marketDelay: 0n, // How long to delay market opening (2 days after whitelist sale started or when sold out)
};