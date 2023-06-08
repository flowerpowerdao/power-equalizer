import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  sale: 'variant { supply = 2 }',
  revealDelay: 0n,
  singleAssetCollection: false,
};