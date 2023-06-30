import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  timersInterval: 1, // seconds
  publicSaleStart: BigInt(Date.now()) * 1_000_000n,
  marketDelay: 0n, // How long to delay market opening (2 days after whitelist sale started or when sold out)
};