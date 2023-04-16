import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  sale: 'variant { supply = 2 }',
  revealDelay: 0n,
  singleAssetCollection: false,
};