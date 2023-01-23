import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
  public let collectionName = "Pineapple Punks";
  public let placeholderContentLength = "1053832";
  public let teamAddress : ExtCore.AccountIdentifier = $teamAddress;
  public let ecscrowDelay : Time.Time = $collectionSize; // 120 seconds
  public let collectionSize : Nat32 = 7777;

  public let salePrice : Nat64 = 700000000;
  public let salesFees : [(ExtCore.AccountIdentifier, Nat64)] = [
    (teamAddress, 7500), // Royalty Fee
    ("c7e461041c0c5800a56b64bb7cefc247abc0bbbb99bd46ff71c64e92d9f5c2f9", 1000), // Entrepot Fee
  ];

  public let publicSaleStart : Time.Time = $publicSaleStart; // Start of first purchase (WL or other)
  public let whitelistTime : Time.Time = $whitelistTime; // Period for WL only discount. Set to publicSaleStart for no exclusive period
  public let marketDelay : Time.Time = $marketDelay; // How long to delay market opening (2 days after whitelist sale started or when sold out)

  // true - assets will be revealed after manually calling 'shuffleAssets'
  // false - assets will be revealed immediately and assets shuffling will be disabled
  public let delayedReveal = $delayedReveal;

  public let whitelistOneTimeOnly : Bool = $whitelistOneTimeOnly; // Whitelist addresses are removed after purchase
  public let whitelistDiscountLimited : Bool = $whitelistDiscountLimited; // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored

  // dutch auction
  public type DutchAuctionFor = {
    #everyone; // dutch auction for everyone
    #whitelist; // dutch auction for whitelist(tier price is ignored), then salePrice for public sale
    #publicSale; // tier price for whitelist, then dutch auction for public sale
  };
  public let dutchAuctionEnabled = $dutchAuctionEnabled;
  public let dutchAuctionFor : DutchAuctionFor = $dutchAuctionFor;
  public let dutchAuctionStartPrice : Nat64 = $dutchAuctionStartPrice; // start with 350 icp for dutch auction
  public let dutchAuctionIntervalPriceDrop : Nat64 = $dutchAuctionIntervalPriceDrop; // drop 5 icp every interval
  public let dutchAuctionReservePrice : Nat64 = $dutchAuctionReservePrice; // reserve price is 5 icp
  public let dutchAuctionInterval : Time.Time = $dutchAuctionInterval; // 1 minute

  // Airdrop (only addresses, no token index anymore)
  public let airdropEnabled = $airdropEnabled;
  public let airdrop : [ExtCore.AccountIdentifier] = $airdrop;

  // whitelist tiers
  public type WhitelistTier = {
    name : Text;
    price : Nat64;
    whitelist : [ExtCore.AccountIdentifier];
  };

  // order from lower price to higher price
  public let whitelistTiers : [WhitelistTier] = [
    {
      name = $whitelistTier0Name;
      price = $whitelistTier0Price;
      whitelist = $whitelistTier0Whitelist;
    },
    {
      name = $whitelistTier1Name;
      price = $whitelistTier1Price;
      whitelist = $whitelistTier1Whitelist;
    },
  ];
};
