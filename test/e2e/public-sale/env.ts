import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  publicSaleStart: BigInt(Date.now()) * 1_000_000n,
};