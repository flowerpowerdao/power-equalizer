import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  collectionSize: 5n,
  revealDelay: 86400000000000n, // 86400000000000 == 24 hours
  singleAssetCollection: true,
};