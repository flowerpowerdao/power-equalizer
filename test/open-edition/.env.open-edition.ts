import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  collectionSize: 0n,
  openEdition: true,
  saleEnd: BigInt(Date.now()) * 1_000_000n + 1_000_000n * 1000n * 50n, // now + 50 seconds
  delayedReveal: false,
  singleAssetCollection: true,
};