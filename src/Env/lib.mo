import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
  public let timersInterval = #seconds(5);

  let beneficiary0 : ExtCore.AccountIdentifier = "58842a4424f706f3465e8d9aa7bb6507a1c2d8810b1a9f43f0c94087b62b86ed";
  let beneficiary1 : ExtCore.AccountIdentifier = "24fc8fbcf345bc6a2ba14bbd323fc041c8ad400cc48b1e69cb53dd612afd0d81";

  public let collectionName = "Pineapple Punks";
  public let placeholderContentLength = "1053832";
  public let escrowDelay : Time.Time = 120000000000; // 120 seconds
  public let collectionSize : Nat32 = 100000;

  public let salePrice : Nat64 = 700000000;

  public let salesDistribution : [(ExtCore.AccountIdentifier, Nat64)] = [
    (beneficiary0, 45000),
    (beneficiary1, 10125),
  ];

  public let royalties : [(ExtCore.AccountIdentifier, Nat64)] = [
    (beneficiary0, 3375), // Royalty Fee
    (beneficiary1, 750), // Royalty Fee
  ];

  public let defaultMarketplaceFee = ("ccfe146bb249b6c59e8c5ae71a1b59ddf85d9f9034611427b696f8b25d7b826a", 1000 : Nat64); // Entrepot Fee

  public let publicSaleStart : Time.Time = 1677345064258000000; // Start of first purchase (WL or other)
  public let whitelistTime : Time.Time = 1677345075058000000; // Period for WL only discount. Set to publicSaleStart for no exclusive period
  public let marketDelay : Time.Time = 172800000000000; // How long to delay market opening (2 days after whitelist sale started or when sold out)

  public type WhitelistSlot = {
    start : Time.Time;
    end : Time.Time;
  };

  // this allows you to create slots for whitelists. one slots can contain multiple whitelist.
  // the start of the first slot has to be the publicSaleStart, the end of the last slot the whitelistTime
  let firstHour = {
    start = publicSaleStart;
    end = 1677345067858000000;
  };
  let secondHour = {
    start = 1677345067858000000;
    end = whitelistTime;
  };

  // true - assets will be revealed after 'revealDelay'
  // false - assets will be revealed immediately and assets shuffling will be disabled
  public let delayedReveal = true;
  // How long to delay assets shuffling and reveal (starting after 'publicSaleStart')
  public let revealDelay : Time.Time = 86400000000000; // 86400000000000 == 24 hours

  // true - the entire collection will consists of only one asset, meaning all NFTs look the same
  // false - there are at least two different assets in the collection
  public let singleAssetCollection = true;

  public let whitelistOneTimeOnly : Bool = true; // Whitelist addresses are removed after purchase
  public let whitelistDiscountLimited : Bool = true; // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored

  // dutch auction
  public type DutchAuctionFor = {
    #everyone; // dutch auction for everyone
    #whitelist; // dutch auction for whitelist(tier price is ignored), then salePrice for public sale
    #publicSale; // tier price for whitelist, then dutch auction for public sale
  };
  public let dutchAuctionEnabled = false;
  public let dutchAuctionFor : DutchAuctionFor = #everyone;
  public let dutchAuctionStartPrice : Nat64 = 21500000000; // start with 350 icp for dutch auction
  public let dutchAuctionIntervalPriceDrop : Nat64 = 500000000; // drop 5 icp every interval
  public let dutchAuctionReservePrice : Nat64 = 500000000; // reserve price is 5 icp
  public let dutchAuctionInterval : Time.Time = 60000000000; // 1 minute

  // Airdrop (only addresses, no token index anymore)
  public let airdropEnabled = false;
  public let airdrop : [ExtCore.AccountIdentifier] = ["e66c26a7e1258984b84dfc92bbfca3084d4252abb0091ca6c1196df2acb18f9d"];

  // whitelist tiers
  public type WhitelistTier = {
    name : Text;
    price : Nat64;
    whitelist : [ExtCore.AccountIdentifier];
    slot : WhitelistSlot;
  };

  // order from slots and within slots by price
  public let whitelistTiers : [WhitelistTier] = [
    {
      name = "ethflower";
      price = 350000000;
      whitelist = ["da1fae1e25a417ab70953983a0c83ae5d7ee68ea83b1ac7b291246a29c87cc04"];
      slot = firstHour;
    },
    {
      name = "modclub";
      price = 500000000;
      whitelist = ["b35858170c410ce65ae3dc9d36298766aa36d287854fe43dcb65998f19bc5881"];
      slot = secondHour;
    },
  ];
};
