import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
  public let test = true; // must be 'false'
  public let restoreEnabled = false; // must be 'false' (see backup/README.md for details)
  public let timersInterval = #seconds(10);

  // let beneficiary0 : ExtCore.AccountIdentifier = "58842a4424f706f3465e8d9aa7bb6507a1c2d8810b1a9f43f0c94087b62b86ed";
  // let beneficiary1 : ExtCore.AccountIdentifier = "24fc8fbcf345bc6a2ba14bbd323fc041c8ad400cc48b1e69cb53dd612afd0d81";

  // public let collectionName = "Pineapple Punks";
  // public let placeholderContentLength = "1053832";
  // public let escrowDelay : Time.Time = 120000000000; // 120 seconds
  // public let collectionSize : Nat32 = 7777;

  // public let salePrice : Nat64 = 700000000;

  // public let salesDistribution : [(ExtCore.AccountIdentifier, Nat64)] = [
  //   (beneficiary0, 45000),
  //   (beneficiary1, 10125),
  // ];

  // public let royalties : [(ExtCore.AccountIdentifier, Nat64)] = [
  //   (beneficiary0, 3375), // Royalty Fee
  //   (beneficiary1, 750), // Royalty Fee
  // ];

  // public let defaultMarketplaceFee = ("ccfe146bb249b6c59e8c5ae71a1b59ddf85d9f9034611427b696f8b25d7b826a", 1000 : Nat64); // Entrepot Fee

  // public let publicSaleStart : Time.Time = 1680696181381000000; // Start of first purchase (WL or other)
  // public let whitelistTime : Time.Time = 1680696181381000000; // Period for WL only discount. Set to publicSaleStart for no exclusive period
  // public let marketDelay : Time.Time = 0; // How long to delay market opening (2 days after whitelist sale started or when sold out)

  // open edition
  // true - no definite collection size and can be minted in an ongoing effort until 'saleEnd' (need to set collectionSize = 0)
  // false - fixed collection size
  // public let openEdition = false;
  // // when the sale ends (set to '0' if openEdition = false)
  // public let saleEnd : Time.Time = 0;

  public type WhitelistSlot = {
    start : Time.Time;
    end : Time.Time;
  };

  // this allows you to create slots for whitelists. one slots can contain multiple whitelist.
  // the start of the first slot has to be the publicSaleStart, the end of the last slot the whitelistTime
  let whitelistSlot1 = {
    start = 1680696181381000000;
    end = 1680696181381000000;
  };
  let whitelistSlot2 = {
    start = 1680696181381000000;
    end = 1680696181381000000;
  };

  // // true - assets will be revealed after 'revealDelay'
  // // false - assets will be revealed immediately and assets shuffling will be disabled
  // public let delayedReveal = true;
  // // How long to delay assets shuffling and reveal (starting after 'publicSaleStart')
  // public let revealDelay : Time.Time = 86400000000000; // 86400000000000 == 24 hours

  // true - the entire collection will consists of only one asset, meaning all NFTs look the same
  // false - there are at least two different assets in the collection
  // public let singleAssetCollection = false;

  // public let whitelistOneTimeOnly : Bool = true; // Whitelist addresses are removed after purchase
  // public let whitelistDiscountLimited : Bool = true; // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored

  // // dutch auction
  // public type DutchAuctionFor = {
  //   #everyone; // dutch auction for everyone
  //   #whitelist; // dutch auction for whitelist(tier price is ignored), then salePrice for public sale
  //   #publicSale; // tier price for whitelist, then dutch auction for public sale
  // };
  // public let dutchAuctionEnabled = false;
  // public let dutchAuctionFor : DutchAuctionFor = #everyone;
  // public let dutchAuctionStartPrice : Nat64 = 21500000000; // start with 350 icp for dutch auction
  // public let dutchAuctionIntervalPriceDrop : Nat64 = 500000000; // drop 5 icp every interval
  // public let dutchAuctionReservePrice : Nat64 = 500000000; // reserve price is 5 icp
  // public let dutchAuctionInterval : Time.Time = 60000000000; // 1 minute

  // Airdrop (only addresses, no token index anymore)
  // public let airdropEnabled = false;
  // public let airdrop : [ExtCore.AccountIdentifier] = ["e66c26a7e1258984b84dfc92bbfca3084d4252abb0091ca6c1196df2acb18f9d","ae3dbb489190f52c7a9830bbd89e00da4eef57b1d6ca04ede55be4e6fcb61bf9","943fd89889433e9095cdfee0998e51b76c3e89ec96cb1b19b09c51dd60ef61d2","a0b0636cb7e5962c3f8b579d4eaea4fa5cf5bd2b7bca012f7edb4c8e22704a15","aaa8563d505d86d00721da1fc5e6ec6005306fb815aa480d12d82c066279bfd9","a8811f0497f397fc669783447e53a3ee62f58089b28ddbfe8cf4e91a5e37073e","1edf167a947719829359da03128db5b6d18b1c6e0e342df97a21110740fcd4e2","5c064042aa679a9faf58af1b9c4e696110ddfa0502dcafae6c88c333654f1e5c","1f2fa4e9a5e1ad1ded167e898b13693bfaa5f7e7021da33a6ed9f3f71d6c6efd","8ecad355c3bafd563621d50c54d7718f87c17f27b1da7d2b954ef0c8824ae552","8949adb95619f40749af2335822f3731dc5ed3f03c511f471f087a88d29c90a6","4727f8e0b8c54069fa11d08e8b8e8b44b135379729a19819fb6a5c8432ceca6e","61929645bdc5f4859fc22b2427205c07fbb07c5149f253632a7ed05bab0db8b1","12db85c8a60e716f3ea2aaf80ba0f0e674e673e9dbf70f17124bfd434eb2c2a1","a50e7c492cc7eda25664194fa4c612cb1de137de88d528e87f0d5f4b6875ec65","55445d5b6a4a850fe3896a7193c5da517ed6e97fd183e19452f6ff692a834c00","22cbdf6a68d58e954e396d3dfd5d279cc895095380a7ee8be941d50c922a9739","c90b990316a82945ec505fc81908cc07801deea6234cb2235cca6f533ca3155a","c48d08f41c4e9d583acd49d7f02f5f4ae8725fad969ff7539805f4d146916efc","f12e0e9913b343ab381f0c53e78fceb55f186ad587a9df8ba7090e81ed7834f7"];

  // whitelist tiers
  public type WhitelistTier = {
    name : Text;
    price : Nat64;
    whitelist : [ExtCore.AccountIdentifier];
    slot : WhitelistSlot;
  };

  // order from lower price to higher price
  public let whitelistTiers : [WhitelistTier] = [
    {
      name = "ethflower";
      price = 350000000;
      whitelist = ["da1fae1e25a417ab70953983a0c83ae5d7ee68ea83b1ac7b291246a29c87cc04","d29028c05d4b3a4e54b2c9040dd6d5acf8d79308b28344898729a0de0a52b241","43bf49989a6ac24d7dc97c93cc9e8bfe2ac245cb61a93754c6cd816877a7e59e","67e748b7e98637e151e261306cb2a503a229f6b6fbac37bc7b29f67e5d3984a7","e2f3ea30711a84fc73be573dc190ce6cc1d823e3b66f5f2b801e08c0662287f2","022012e61adc127db33504a4184e06656c0f61a523775495917e5d9800d3755e","f08b37e12779213cb9009e5d002b3e6882bc4b25ff74c5fa495c5b59a8afa114","7768f524837c292350dc65d0dc9e3d74c4ecabdac079280af4ad300e67cc5c02","747b0cd2a9671ac975320eef57ab3a91bda305632a8e5cbb89fe48a494e9c3f7","4d3e6ffca4fa377c11ccedc34a3f1c394287a0a04387b2843eb6769923767d05","8949adb95619f40749af2335822f3731dc5ed3f03c511f471f087a88d29c90a6","4727f8e0b8c54069fa11d08e8b8e8b44b135379729a19819fb6a5c8432ceca6e","61929645bdc5f4859fc22b2427205c07fbb07c5149f253632a7ed05bab0db8b1","12db85c8a60e716f3ea2aaf80ba0f0e674e673e9dbf70f17124bfd434eb2c2a1","a50e7c492cc7eda25664194fa4c612cb1de137de88d528e87f0d5f4b6875ec65","55445d5b6a4a850fe3896a7193c5da517ed6e97fd183e19452f6ff692a834c00","22cbdf6a68d58e954e396d3dfd5d279cc895095380a7ee8be941d50c922a9739","c90b990316a82945ec505fc81908cc07801deea6234cb2235cca6f533ca3155a","c48d08f41c4e9d583acd49d7f02f5f4ae8725fad969ff7539805f4d146916efc","f12e0e9913b343ab381f0c53e78fceb55f186ad587a9df8ba7090e81ed7834f7"];
      slot = whitelistSlot1;
    },
    {
      name = "modclub";
      price = 500000000;
      whitelist = ["b35858170c410ce65ae3dc9d36298766aa36d287854fe43dcb65998f19bc5881","68b9a81e80a707742e8639d92e69e629734c1bd7da330a7bef67247f80ea72dc","e9a5963080ece74caa4f799f7edfb469383f489427c05baa0ce3936d3552bd69","1dcf2932101e2f4ab453eb8c6a4bac692f4698d02509482c982027b157627cd7","856b2784f3b293a0257a8250490f64b5bea7855158e440f433efa9fcb2aa93cc","5f2e86d837b90f6dbd38be922d3cbeee8bc5734e6f283fc7290c7fbd222ffdbc","25baafc61173510143682d577d4fe06a018ffbd304b97c16d72dcf7c76f90d9b","360ddd1c4bf11ecf74f9d4e5970b3074c760417d09b2167c4579d7f752e20de9","e6c13c6004b4e2ee4031b86be2a3a4312dfb367889cd83c0283bc8d29859e427","d00df7eab5e813fa15efc9fbc54fef6c3b22b7765210170fbdebe17dafb83876","8949adb95619f40749af2335822f3731dc5ed3f03c511f471f087a88d29c90a6","4727f8e0b8c54069fa11d08e8b8e8b44b135379729a19819fb6a5c8432ceca6e","61929645bdc5f4859fc22b2427205c07fbb07c5149f253632a7ed05bab0db8b1","12db85c8a60e716f3ea2aaf80ba0f0e674e673e9dbf70f17124bfd434eb2c2a1","a50e7c492cc7eda25664194fa4c612cb1de137de88d528e87f0d5f4b6875ec65","55445d5b6a4a850fe3896a7193c5da517ed6e97fd183e19452f6ff692a834c00","22cbdf6a68d58e954e396d3dfd5d279cc895095380a7ee8be941d50c922a9739","c90b990316a82945ec505fc81908cc07801deea6234cb2235cca6f533ca3155a","c48d08f41c4e9d583acd49d7f02f5f4ae8725fad969ff7539805f4d146916efc","f12e0e9913b343ab381f0c53e78fceb55f186ad587a9df8ba7090e81ed7834f7"];
      slot = whitelistSlot2;
    },
  ];
};
