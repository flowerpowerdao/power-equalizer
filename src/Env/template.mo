import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
  public let isLocal = true; // change to false on production build
  public let collectionName = "Pineapple Punks";
  public let placeholderContentLength = "1053832";
  public let teamAddress = $teamAddress;
  public let ecscrowDelay: Time.Time = $ecscrowDelay; // 120 seconds
  public let teamRoyaltyAddress : ExtCore.AccountIdentifier = teamAddress;
  public let collectionSize : Nat32 = $collectionSize;
  public let salesFees : [(ExtCore.AccountIdentifier, Nat64)] = [
    (teamAddress, 7500), //Royalty Fee 
    ($entrepotAddress, 1000), //Entrepot Fee 
  ];

  // prices
  public let ethFlowerWhitelistPrice : Nat64 =   $ethFlowerWhitelistPrice;
  public let modclubWhitelistPrice : Nat64 =     $modclubWhitelistPrice;
  public let salePrice : Nat64 =                 $salePrice;

  public let publicSaleStart : Time.Time = $publicSaleStart; //Start of first purchase (WL or other)
  public let whitelistTime : Time.Time = $whitelistTime; //Period for WL only discount. Set to publicSaleStart for no exclusive period
  public let marketDelay : Time.Time = $marketDelay; //How long to delay market opening (2 days after whitelist sale started or when sold out)

  public let whitelistOneTimeOnly : Bool = $whitelistOneTimeOnly; //Whitelist addresses are removed after purchase
  public let whitelistDiscountLimited : Bool = $whitelistDiscountLimited; //If the whitelist discount is limited to the whitelist period only. If no whitelist period this is ignored

  // Ethflower Whitelist
  public let ethFlowerWhitelist: [ExtCore.AccountIdentifier] = $ethFlowerWhitelist;
  // modclub Whitelist
  public let modclubWhitelist: [ExtCore.AccountIdentifier] = $modclubWhitelist;
  //Airdrop (only addresses, no token index anymore)
  public let airdrop : [ExtCore.AccountIdentifier] = $airdrop;
}