import Principal "mo:base/Principal";

module {
  public type InitArgs = {
    collectionSize: Nat;
  };

  public type Config = InitArgs and {
    canister: Principal;
    minter: Principal;
  };
};