import defaultEnv from '../.env.default';

export default {
  ...defaultEnv,
  publicSaleStart: BigInt(Date.now()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(Date.now()) * 1_000_000n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
  collectionSize: 0n,
  openEdition: true,
  saleEnd: BigInt(Date.now()) * 1_000_000n + 1000n * 30n, // now + 30 seconds
  singleAssetCollection: true,
};