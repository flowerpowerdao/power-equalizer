import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  timersInterval: 5, // seconds
  sale: 'variant { supply = 100_000 }',
  publicSaleStart: BigInt(Date.now()) * 1_000_000n,
};