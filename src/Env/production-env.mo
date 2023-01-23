import Time "mo:base/Time";
import ExtCore "../toniq-labs/ext/Core";

module {
  public let collectionName = "Pineapple Punks";
  public let placeholderContentLength = "1053832";
  public let teamAddress : ExtCore.AccountIdentifier = "979307078c971f6d82a302825ac07dc63a4f68ece99f24014d69d8ccec7b5d6f";
  public let ecscrowDelay : Time.Time = 120_000_000_000; // 120 seconds
  public let collectionSize : Nat32 = 7777;

  public let salePrice : Nat64 = 700000000;
  public let salesFees : [(ExtCore.AccountIdentifier, Nat64)] = [
    (teamAddress, 7500), // Royalty Fee
    ("c7e461041c0c5800a56b64bb7cefc247abc0bbbb99bd46ff71c64e92d9f5c2f9", 1000), // Entrepot Fee
  ];

  public let publicSaleStart : Time.Time = 1659276000000000000; // Start of first purchase (WL or other)
  public let whitelistTime : Time.Time = 1659362400000000000; // Period for WL only discount. Set to publicSaleStart for no exclusive period
  public let marketDelay : Time.Time = 172_800_000_000_000; // How long to delay market opening (2 days after whitelist sale started or when sold out)

  // true - assets will be revealed after manually calling 'shuffleAssets'
  // false - assets will be revealed immediately and assets shuffling will be disabled
  public let delayedReveal = true;

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
  public let airdropEnabled = true;
  public let airdrop : [ExtCore.AccountIdentifier] = ["d989e0edbaaace9e9f5d7b6f1eeaeb3243a0944cd2446bbf2c64434eb7a215b7", "a555c4f1e300d5b8b8275c29ff9a8e06f746ed736edef52ecf2debf65f065e36", "3ae5f4f296874c82a626cc0ee6cae31d608489e4ac25622a37117a629a81cfad", "64db223bb7b5a173ca443f815ee7d9f682d9e29f133440a36d39115b1146851e", "904826bd329d037d3fcf38e7eb54295cca9f5c68b174c3c750ea5205254ff6bf", "81537cf105cf802521bca09a93eb555a685f8f1802f1d794a427983e3e4203a3", "6c663986f4d3b396d0b3d96749748736e67a18f05c05ee5105e50472e71680e0", "aeffae3744a37e03236d26b2eff3f1a0aeeff778937fbc1745062d05b09e863a", "7ea7d5c4c9b3dec57817678e8472a94a20dc56db0b6ca7162a9cf4a5f381f07e", "94e02368944dedb539dbde90baaacbb50c0dc19e95ed00e6705f8e9781086c85", "b0b2f221e2e017b2969e97a34f72fd752ab03cfb897f31352b9c16aa17bed05c", "d1795d19da19987b3ec2dc081e548823e4d6cd3bcb66a8d04674a08685cc6d6d", "4dc51d0373d9c60c3a708ae7cc904c2de4061f6fc09fd4b84649a222acfe63ac", "48527a2aa76342bab25315c141a93952004e8d2814a788ac072f2101ebaf9336", "a2457c6056d20ceb73e118ebe68ac98da3a179f13c68dfaf73676211c11565c6", "7ea7d5c4c9b3dec57817678e8472a94a20dc56db0b6ca7162a9cf4a5f381f07e", "48527a2aa76342bab25315c141a93952004e8d2814a788ac072f2101ebaf9336"];

  // whitelist tiers
  public type WhitelistTier = {
    name : Text;
    price : Nat64;
    whitelist : [ExtCore.AccountIdentifier];
  };

  // order from lower price to higher price
  public let whitelistTiers : [WhitelistTier] = [
    {
      name = "ethflower";
      price = 350000000;
      whitelist = ["502062492ecee5b58908839ba094bbd67fa46d3447d4c82b376f09c296ff7e84", "2099bccfe4a6060a6df56e5b1e66f8e546f9004a1d3decef619b393c94017342", "a18523f5f15564c05e15f0807204857cc692bcf2cc2b3b9d3eb1cca4242394cf", "a18523f5f15564c05e15f0807204857cc692bcf2cc2b3b9d3eb1cca4242394cf", "a18523f5f15564c05e15f0807204857cc692bcf2cc2b3b9d3eb1cca4242394cf", "a18523f5f15564c05e15f0807204857cc692bcf2cc2b3b9d3eb1cca4242394cf", "496ae69ebe9b5cb721c7a85ea509611336e92002dc61521c87acbd6dcc43c554", "92d18dc83b424db46675fae75704fd16885e3ddfadb827f88505a84fb061fc8f", "c20ada1028b91606129d1147e35bd5f6e6a44f301f2c0af1fce5c6d7e2ea470b", "8d61a4e3d1725b143688e393020710b08b3e0547ee9d7949a0a9f813c997efb3", "670852640878fe777c5ef024bbfe4c022faf58893a3aeb1e84fcb1df5026a1df", "2cb6c992eb0884fbdbb3ff7a6b14d496db0f746049f40ee4387ae038e6608287", "2cb6c992eb0884fbdbb3ff7a6b14d496db0f746049f40ee4387ae038e6608287"];
    },
    {
      name = "modclub";
      price = 500000000;
      whitelist = ["e14e87dd4cf40cf4301bf05a7a1feb3e0a81dfc2f4133865a8b949dc034c3a85", "f6d43b31ced8892daa482725f8fd1ae672353de1282c5b033baae2713fadb24a", "05a032726947d1f108621408fcb7bd4c9c626d2fae52e79eda8a19fca7e4037b", "21874b081e728ae67fd02772ea6de0126adc3dc2d7d51a4e0398b5945c998765", "c9af6c93ab751d50699a21e898f79bda7fd5595cdd8d883f53bbf40cdbaf3568", "374db951f724c1ff9f5d6417a716630afefbe3236a1117d1f47675f9983dc8f6", "c15bfcc5100060143de313def76e748cf02e0c7f42cce614bae672cc11122bb0", "d5461e901fc1ff30fc5ab3ad6372c66c1d409328d421735fc48b867d7981dac4", "cb9a77478c93a47b9ee1e7a41de0a3bfc397811f17be71907b70ab7f917fff1b", "68aeeb01e398bdaffe37aa48ca6d34174079426a1f5524d3e3aefcd11191b057", "80395a57ae178dd6e1b5956a517f34b178cc21fe457d37b7268524e9d655e761", "cf3d7219fa87933f17ebc0239d7c9d26418e9e06e167b42dfeaccfdd5885204b"];
    },
  ];
};
