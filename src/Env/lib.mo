import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
    public let collectionName = "Punks";
    public let placeholderContentLength = "1053832";
    public let teamAddress = "979307078c971f6d82a302825ac07dc63a4f68ece99f24014d69d8ccec7b5d6f";
    public let ecscrowDelay: Time.Time = 120_000_000_000; // 120 seconds
    public let teamRoyaltyAddress : ExtCore.AccountIdentifier = teamAddress;
    public let collectionSize : Nat32 = 7777;
    public let salesFees : [(ExtCore.AccountIdentifier, Nat64)] = [
      (teamAddress, 7500), //Royalty Fee 
      ("9dd5c70ada66e593cc5739c3177dc7a40530974f270607d142fc72fce91b1d25", 1000), //Entrepot Fee 
    ];

    // prices
    // let ethFlowerWhitelistPrice : Nat64 =   350000000;
    // let modclubWhitelistPrice : Nat64 =     500000000;
    public let whitelistPrice : Nat64 =            500000000;
    public let salePrice : Nat64 =                 700000000;

    public let publicSaleStart : Time.Time = 1659276000000000000; //Start of first purchase (WL or other)
    public let whitelistTime : Time.Time = 1659362400000000000; //Period for WL only discount. Set to publicSaleStart for no exclusive period
    public let marketDelay : Time.Time = 172_800_000_000_000; //How long to delay market opening
    public let whitelistOneTimeOnly : Bool = true; //Whitelist addresses are removed after purchase
    public let whitelistDiscountLimited : Bool = true; //If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored
    //Whitelist
     public let whitelistAdresses : [ExtCore.AccountIdentifier]= ["7ada07a0a64bff17b8e057b0d51a21e376c76607a16da88cd3f75656bc6b5b0b"];
    public let whitelistLimit = 1; // how many NFTs per whitelist spot
     //Airdrop (only addresses, no token index anymore)
      public let airdrop : [ExtCore.AccountIdentifier] = [];
}