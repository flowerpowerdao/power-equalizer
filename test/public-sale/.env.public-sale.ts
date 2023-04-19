import defaultEnv from '../.env.default';

export default {
  ...defaultEnv(),
  publicSaleStart: BigInt(Date.now()) * 1_000_000n,
};