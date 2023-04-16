import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  sale: `variant { duration = variant { seconds = 60 } }`,
  revealDelay: 0n,
  singleAssetCollection: true,
};