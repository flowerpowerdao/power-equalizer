import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
  public let timersInterval = #seconds($timersInterval);

  let beneficiary0 : ExtCore.AccountIdentifier = $beneficiary0;
  let beneficiary1 : ExtCore.AccountIdentifier = $beneficiary1;

  public let collectionName = "Pineapple Punks";
  public let placeholderContentLength = "1053832";
  public let escrowDelay : Time.Time = $escrowDelay; // 120 seconds
  public let collectionSize : Nat32 = $collectionSize;

  public let salePrice : Nat64 = 700000000;

  public let salesDistribution : [(ExtCore.AccountIdentifier, Nat64)] = [
    (beneficiary0, $salesDistribution0),
    (beneficiary1, $salesDistribution1),
  ];

  public let royalties : [(ExtCore.AccountIdentifier, Nat64)] = [
    (beneficiary0, $royalty0), // Royalty Fee
    (beneficiary1, $royalty1), // Royalty Fee
  ];

  public let defaultMarketplaceFee = ($defaultMarketplaceAddr, $defaultMarketplaceFee : Nat64); // Entrepot Fee

  public let publicSaleStart : Time.Time = $publicSaleStart; // Start of first purchase (WL or other)
  public let whitelistTime : Time.Time = $whitelistTime; // Period for WL only discount. Set to publicSaleStart for no exclusive period
  public let marketDelay : Time.Time = $marketDelay; // How long to delay market opening (2 days after whitelist sale started or when sold out)

  public type WhitelistSlot = {
    start : Time.Time;
    end : Time.Time;
  };

  // this allows you to create slots for whitelists. one slots can contain multiple whitelist.
  // the start of the first slot has to be the publicSaleStart, the end of the last slot the whitelistTime
  let whitelistSlot1 = {
    start = $whitelistSlot1_start;
    end = $whitelistSlot1_end;
  };
  let whitelistSlot2 = {
    start = $whitelistSlot2_start;
    end = $whitelistSlot2_end;
  };

  // true - assets will be revealed after manually calling 'shuffleAssets'
  // false - assets will be revealed immediately and assets shuffling will be disabled
  public let delayedReveal = $delayedReveal;

  // true - the entire collection will consists of only one asset, meaning all NFTs look the same
  // false - there are at least two different assets in the collection
  public let singleAssetCollection = $singleAssetCollection;

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
    slot : WhitelistSlot;
  };

  // order from lower price to higher price
  public let whitelistTiers : [WhitelistTier] = [
    {
      name = $whitelistTier0Name;
      price = $whitelistTier0Price;
      whitelist = $whitelistTier0Whitelist;
      slot = whitelistSlot1;
    },
    {
      name = $whitelistTier1Name;
      price = $whitelistTier1Price;
      whitelist = $whitelistTier1Whitelist;
      slot = whitelistSlot2;
    },
  ];
};
