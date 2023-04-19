import defaultEnv from '../.env.default';

export default {
  ...defaultEnv(),
  sale: 'variant { supply = 5 }',
  publicSaleStart: BigInt(Date.now()) * 1_000_000n,
};