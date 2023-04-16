import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  sale: `variant { duration = variant { seconds = 80 } }`,
  revealDelay: 0n,
  singleAssetCollection: true,
};