import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
  type AccountIdentifier = Text;

  public type WhitelistSlot = {
    start : Time.Time;
    end : Time.Time;
  };

  public type WhitelistTier = {
    name : Text;
    price : Nat64;
    whitelist : [AccountIdentifier];
    slot : WhitelistSlot;
  };

  public type DutchAuction = {
    target : {
      #everyone; // dutch auction for everyone
      #whitelist; // dutch auction for whitelist(tier price is ignored), then salePrice for public sale
      #publicSale; // tier price for whitelist, then dutch auction for public sale
    };
    startPrice : Nat64; // start price for dutch auction
    intervalPriceDrop : Nat64; // drop price every interval
    reservePrice : Nat64; // reserve price
    interval : Time.Time; // nanoseconds
  };

  public type InitArgs = {
    collectionName : Text;
    collectionSize : Nat;
    salePrice : Nat64; // e8s
    publicSaleStart : Time.Time; // Start of first purchase (WL or other)
    whitelistTime : Time.Time; // Period for WL only discount. Set to publicSaleStart for no exclusive period
    marketDelay : Time.Time; // How long to delay market opening (2 days after whitelist sale started or when sold out)
    escrowDelay : Time.Time;
    placeholderContentLength : Text; // ??
    salesDistribution : [(AccountIdentifier, Nat64)];
    royalties : [(AccountIdentifier, Nat64)];
    defaultMarketplaceFee : (AccountIdentifier, Nat64);
    // open edition
    // true - no definite collection size and can be minted in an ongoing effort until 'saleEnd' (need to set collectionSize = 0)
    // false - fixed collection size
    openEdition : Bool;
    // when the sale ends (set to '0' if openEdition = false)
    saleEnd : Time.Time;
    // true - assets will be revealed after 'revealDelay'
    // false - assets will be revealed immediately and assets shuffling will be disabled
    delayedReveal : Bool;
    // How long to delay assets shuffling and reveal (starting after 'publicSaleStart')
    revealDelay : Time.Time; // 86400000000000 == 24 hours
    // true - the entire collection will consists of only one asset, meaning all NFTs look the same
    // false - there are at least two different assets in the collection
    singleAssetCollection : Bool;
    // dutch auction
    dutchAuction: ?DutchAuction;
    // airdrop
    airdrop : [AccountIdentifier];
    // whitelist
    whitelistOneTimeOnly : Bool; // Whitelist addresses are removed after purchase
    whitelistDiscountLimited : Bool; // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored
    // whitelist tiers
    // order from lower price to higher price
    whitelistTiers : [WhitelistTier];
    test : Bool; // must be 'false'
    restoreEnabled : Bool; // must be 'false' (see backup/README.md for details)
    timersInterval : {
      #seconds : Nat;
      #nanoseconds : Nat;
    };
  };

  type InitArgsNew = {
    collectionName : Text;
    salePrice : Nat; // e8s
    saleType : {
      #limitedEdition: Nat; // fixed collection size
      #openEdition: Time.Time; // no definite collection size and can be minted in an ongoing effort until a specified time
    };
    publicSaleStart : Time.Time; // public sale start time
    placeholderContentLength : Text; // ??
    salesDistribution : [(AccountIdentifier, Nat64)];
    royalties : [(AccountIdentifier, Nat64)];
    marketplaces : [(Text, AccountIdentifier, Nat64)];
    // How long to delay assets shuffling and reveal (starting after 'publicSaleStart')
    // 0 - assets will be revealed immediately and assets shuffling will be disabled
    revealDelay : Time.Time; // 86400000000000 == 24 hours
    // true - the entire collection will consists of only one asset, meaning all NFTs look the same
    // false - there are at least two different assets in the collection
    singleAssetCollection : ?Bool;
    airdrop : ?[AccountIdentifier];
    whitelistTiers: ?[{
      name : Text;
      price : Nat64;
      addresses : [AccountIdentifier];
      oneTimeOnly : Bool; // Whitelist addresses are removed after purchase
      startTime : Time.Time;
      endTime : Time.Time; // set to 0 if no end time
    }];
    // dutch auction
    dutchAuction: ?{
      target : {
        #everyone; // dutch auction for everyone
        #whitelist; // dutch auction for whitelist(tier price is ignored), then salePrice for public sale
        #publicSale; // tier price for whitelist, then dutch auction for public sale
      };
      startPrice : Nat64; // start price for dutch auction
      intervalPriceDrop : Nat64; // drop price every interval
      reservePrice : Nat64; // reserve price
      interval : Time.Time; // nanoseconds
    };
    marketDelay : ?Time.Time; // How long to delay market opening (after whitelist sale started or when sold out) (default 172800000000000 - 2 days)
    escrowDelay : ?Time.Time; // default 120000000000 - 120 seconds
    timersInterval : ?Nat; // seconds (defailt 10) nanoseconds?
    testMode : ?Bool; // enables 'grow' methods, only for tests
    restoreEnabled : ?Bool; // must be null (see backup/README.md for details)
  };

  public type Config = InitArgs and {
    canister: Principal;
    minter: Principal;
  };
};