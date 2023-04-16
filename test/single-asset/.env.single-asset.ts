import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  sale: 'variant { supply = 5 }',
  revealDelay: 0n,
  singleAssetCollection: true,
};