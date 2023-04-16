import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
  type AccountIdentifier = Text;

  public type Duration = {
    #nanoseconds : Nat;
    #seconds : Nat;
    #minutes : Nat;
    #hours : Nat;
    #days : Nat;
    #none;
  };

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
    name : Text;
    sale : {
      #supply: Nat; // fixed collection size
      #duration: Duration; // no definite collection size and can be minted within a given time (starting after 'publicSaleStart')
    };
    salePrice : Nat64; // e8s
    publicSaleStart : Time.Time; // Start of first purchase (WL or other)
    whitelistTime : Time.Time; // Period for WL only discount. Set to publicSaleStart for no exclusive period
    salesDistribution : [(AccountIdentifier, Nat64)];
    royalties : [(AccountIdentifier, Nat64)];
    marketplaces : [(Text, AccountIdentifier, Nat64)]; // first marketplace is default
    // How long to delay assets shuffling and reveal (starting after 'publicSaleStart')
    // 0 - assets will be revealed immediately and assets shuffling will be disabled
    revealDelay : Duration; // 86400000000000 == 24 hours
    // true - the entire collection will consists of only one asset, meaning all NFTs look the same
    // false - there are at least two different assets in the collection
    singleAssetCollection : Bool;
    dutchAuction: ?DutchAuction;
    airdrop : [AccountIdentifier];
    // whitelist
    whitelistOneTimeOnly : Bool; // Whitelist addresses are removed after purchase
    whitelistDiscountLimited : Bool; // If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored
    // whitelist tiers
    // order from lower price to higher price
    whitelistTiers : [WhitelistTier];
    escrowDelay : ?Duration; // default 2 minutes
    marketDelay : ?Duration; // How long to delay market opening (2 days after whitelist sale started or when sold out) (default 2 days)
    test : ?Bool; // must be null
    restoreEnabled : ?Bool; // must be null (see backup/README.md for details)
    timersInterval : ?Duration; // default 60 seconds
  };

  public type Config = InitArgs and {
    canister: Principal;
    minter: Principal;
  };

  type InitArgsNew = {
    name : Text;
    salePrice : Nat; // e8s
    saleType : {
      #supplyCap: Nat; // fixed collection size
      #duration: Time.Time; // no definite collection size and can be minted in an ongoing effort until a specified time
    };
    publicSaleStart : Time.Time; // public sale start time
    // salesDistribution : [(AccountIdentifier, Nat64)];
    // royalties : [(AccountIdentifier, Nat64)];
    // marketplaces : [(Text, AccountIdentifier, Nat64)];
    // How long to delay assets shuffling and reveal (starting after 'publicSaleStart')
    // 0 - assets will be revealed immediately and assets shuffling will be disabled
    // revealDelay : Time.Time; // 86400000000000 == 24 hours
    // true - the entire collection will consists of only one asset, meaning all NFTs look the same
    // false - there are at least two different assets in the collection
    singleAssetCollection : ?Bool;
    airdrop : ?[AccountIdentifier];
    whitelists: ?[{
      name : Text;
      price : Nat64;
      addresses : [AccountIdentifier];
      oneTimeOnly : Bool; // Whitelist addresses are removed after purchase
      startTime : Time.Time;
      endTime : Time.Time; // set to 0 if no end time
    }];
    // dutch auction
    // dutchAuction: ?{
    //   target : {
    //     #everyone; // dutch auction for everyone
    //     #whitelist; // dutch auction for whitelist(tier price is ignored), then salePrice for public sale
    //     #publicSale; // tier price for whitelist, then dutch auction for public sale
    //   };
    //   startPrice : Nat64; // start price for dutch auction
    //   intervalPriceDrop : Nat64; // drop price every interval
    //   reservePrice : Nat64; // reserve price
    //   interval : Time.Time; // nanoseconds
    // };
    // marketDelay : ?Time.Time; // How long to delay market opening (after whitelist sale started or when sold out) (default 172800000000000 - 2 days)
    // escrowDelay : ?Time.Time; // default 120000000000 - 120 seconds
    // timersInterval : ?Nat; // seconds (defailt 10) nanoseconds?
    // testMode : ?Bool; // enables 'grow' methods, only for tests
    // restoreEnabled : ?Bool; // must be null (see backup/README.md for details)
  };
};