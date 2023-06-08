import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  sale: 'variant { supply = 5 }',
  revealDelay: 86400000000000n, // 86400000000000 == 24 hours
  singleAssetCollection: true,
};