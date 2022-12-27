import { User } from "../user";
import { airdrop, ethFlowerWhitelist, modclubWhitelist } from "../well-known-users";

export default {
  teamAddress: new User('team').accountId,
  ecscrowDelay: 120_000_000_000n, // 120 seconds
  collectionSize: 7777n,
  entrepotAddress: new User('entrepot').accountId,
  ethFlowerWhitelistPrice: 350000000n,
  modclubWhitelistPrice: 500000000n,
  salePrice: 700000000n,
  publicSaleStart: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n, // Start of first purchase (WL or other)
  whitelistTime: BigInt(new Date(2100, 1, 1).getTime()) * 1_000_000n, // Period for WL only discount. Set to publicSaleStart for no exclusive period
  marketDelay: 172_800_000_000_000n, // How long to delay market opening (2 days after whitelist sale started or when sold out)
  whitelistOneTimeOnly: true, // Whitelist addresses are removed after purchase
  whitelistDiscountLimited: true, // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored
  ethFlowerWhitelist: ethFlowerWhitelist.map(user => user.accountId),
  modclubWhitelist: modclubWhitelist.map(user => user.accountId),
  airdrop: airdrop.map(user => user.accountId),
};