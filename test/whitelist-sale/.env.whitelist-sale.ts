import { User } from "../user";
import { airdrop, whitelistTier0, whitelistTier1 } from "../well-known-users";

export default {
  teamAddress: new User('team').accountId,
  ecscrowDelay: 120_000_000_000n, // 120 seconds
  collectionSize: 7777n,
  entrepotAddress: new User('entrepot').accountId,
  salePrice: 700000000n,
  publicSaleStart: BigInt(Date.now()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(Date.now()) * 1_000_000n * 2n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
  marketDelay: 172_800_000_000_000n, // How long to delay market opening (2 days after whitelist sale started or when sold out)
  // true - assets will be revealed after manually calling 'shuffleAssets'
  // false - assets will be revealed immediately and assets shuffling will be disabled
  delayedReveal: true,
  whitelistOneTimeOnly: true, // Whitelist addresses are removed after purchase
  whitelistDiscountLimited: true, // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored
  dutchAuctionEnabled: false,
  // #everyone - dutch auction for everyone
  // #whitelist - dutch auction for whitelist(tier price is ignored), then salePrice for public sale
  // #publicSale - tier price for whitelist, then dutch auction for public sale
  dutchAuctionFor: "#everyone",
  dutchAuctionStartPrice: 21500000000n, // start with 350 icp for dutch auction
  dutchAuctionIntervalPriceDrop: 500000000n, // drop 5 icp every interval
  dutchAuctionReservePrice: 500000000n, // reserve price is 5 icp
  dutchAuctionInterval: 60000000000n, // 1 minute
  airdropEnabled: false,
  airdrop: airdrop.map(user => user.accountId),
  // order from lower price to higher price
  whitelistTier0Name: "ethflower",
  whitelistTier0Price: 350000000n,
  whitelistTier0Whitelist: whitelistTier0.map(user => user.accountId),
  whitelistTier1Name: "modclub",
  whitelistTier1Price: 500000000n,
  whitelistTier1Whitelist: whitelistTier1.map(user => user.accountId),
};