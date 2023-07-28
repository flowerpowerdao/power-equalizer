import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  sale: 'variant { supply = 5 }',
  revealDelay: 0n,
  singleAssetCollection: true,
};