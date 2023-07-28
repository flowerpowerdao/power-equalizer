import defaultEnv from '../default-env';

export default {
  ...defaultEnv(),
  sale: `variant { duration = variant { seconds = 30 } }`,
  revealDelay: 0n,
  singleAssetCollection: true,
};