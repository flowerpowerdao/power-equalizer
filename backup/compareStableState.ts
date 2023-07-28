import { getActor as getEthflowerActor } from "./ethflowerActor";
import { getActor } from "./actor";
import { Listing } from "../declarations/ethflower/ethflower.did";

let powerActor = getActor("local", "pk6rk-6aaaa-aaaae-qaazq-cai");
let legacyActor = getEthflowerActor("ic");

function serializeBigInt(key, value) {
  if (typeof value === "bigint") {
    return value.toString(); // Convert BigInt to string
  }
  return value; // Return other values as is
}

// compare registry
async function compareRegistry() {
  const localRegistry = (await powerActor.getRegistry()).sort();
  const mainRegistry = (await legacyActor.getRegistry()).sort();

  // check if the two arrays are equal
  if (JSON.stringify(localRegistry) !== JSON.stringify(mainRegistry)) {
    console.warn("Registry is not equal ");
  }
}

// compare token to asset mapping
async function compareTokenToAsset() {
  const localTokens = (await powerActor.getTokenToAssetMapping()).sort();
  const mainTokens = (await legacyActor.getTokens()).sort();

  // check if the two arrays are equal
  if (JSON.stringify(localTokens) !== JSON.stringify(mainTokens)) {
    console.warn("Token to asset mapping is not equal ");
  }
}

// compare owners
async function compareOwners() {
  const localRegistry = (await powerActor.getRegistry()).sort();
  // bin the registry by owners
  const localOwners = localRegistry.reduce((acc, [token, owner]) => {
    if (!acc[owner]) {
      acc[owner] = [];
    }
    acc[owner].push(token);
    return acc;
  }, {});

  // for each owner, call call both actors `tokens` method and compare the results
  for (const owner in localOwners) {
    const localTokens = await powerActor.tokens(owner);
    const mainTokens = await legacyActor.tokens(owner);

    if ("ok" in localTokens && "ok" in mainTokens) {
      // sort the tokens
      localTokens.ok.sort();
      mainTokens.ok.sort();
    } else {
      console.warn("Error in getting tokens for owner ", owner);
      continue;
    }

    // check if the two arrays are equal
    if (JSON.stringify(localTokens) !== JSON.stringify(mainTokens)) {
      console.warn("Tokens for owner ", owner, " are not equal ");
    }
  }
}

// compare tokenListing
async function compareTokenListing() {
  const localTokenListing: [number, Listing][] = (await powerActor.listings())
    .map((listing) => {
      return [
        listing[0],
        {
          locked: listing[1].locked,
          seller: listing[1].seller,
          price: listing[1].price,
        },
      ] as [number, Listing];
    })
    .sort();
  const mainTokenListing: [number, Listing][] = (await legacyActor.listings())
    .map((listing) => {
      return [listing[0], listing[1]] as [number, Listing];
    })
    .sort();

  // check if the two arrays are equal
  if (
    JSON.stringify(localTokenListing, serializeBigInt) !==
    JSON.stringify(mainTokenListing, serializeBigInt)
  ) {
    console.warn("Token listing is not equal ");
  }
}

// compare transactions
async function compareTransactions() {
  const localTransactions = (await powerActor.transactions()).sort();
  const mainTransactions = (await legacyActor.transactions()).sort();

  // check if the two arrays are equal
  if (
    JSON.stringify(localTransactions, serializeBigInt) !==
    JSON.stringify(mainTransactions, serializeBigInt)
  ) {
    console.warn("Transactions are not equal ");
  }
}

// compare supply
async function compareSupply() {
  const localSupply = await powerActor.supply();
  const mainSupply = await legacyActor.supply();

  // compare the supply
  if (
    JSON.stringify(localSupply, serializeBigInt) !==
    JSON.stringify(mainSupply, serializeBigInt)
  ) {
    console.warn("Supply is not equal ");
  }
}

// compare sale transactions
// async function compareSaleTransactions() {
//   const localSaleTransactions = (await powerActor.saleTransactions()).sort();
//   const mainSaleTransactions = (await legacyActor.saleTransactions()).sort();

//   // check if the two arrays are equal
//   if (
//     JSON.stringify(localSaleTransactions, serializeBigInt) !==
//     JSON.stringify(mainSaleTransactions, serializeBigInt)
//   ) {
//     console.warn("Sale transactions are not equal ");
//   }
// }

compareRegistry();
compareTokenToAsset();
compareOwners();
compareTokenListing();
compareTransactions();
compareSupply();
// compareSaleTransactions();
