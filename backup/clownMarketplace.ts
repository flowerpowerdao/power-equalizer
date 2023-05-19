import {
  Listing,
  Settlement,
  StableChunk__3,
} from "../declarations/main/staging.did";
import { getActor } from "./clownActor";
let mainActor = getActor("ic");

export async function marketplace() {
  const transactions = await getTransactions();
  const marketplace: StableChunk__3 = [
    {
      v1: {
        frontends: [],
        tokenListing: await getTokenListing(),
        transactionCount: BigInt(transactions.length),
        transactionChunk: transactions,
        tokenSettlement: await getSettlements(),
      },
    },
  ];
  return marketplace;
}

async function getTokenListing(): Promise<[number, Listing][]> {
  const tokenListing = await mainActor.listings();
  return tokenListing.map((listing) => {
    let newListing: [number, Listing] = [
      listing[0],
      { ...listing[1], sellerFrontend: [], buyerFrontend: [] },
    ];
    return newListing;
  });
}

async function getTransactions() {
  const transactions = await mainActor.transactions();
  return transactions;
}

async function getSettlements(): Promise<[number, Settlement][]> {
  const settlements = await mainActor.allSettlements();
  return settlements.map((settlement) => {
    let newSettlement: [number, Settlement] = [
      settlement[0],
      { ...settlement[1], sellerFrontend: [], buyerFrontend: [] },
    ];
    return newSettlement;
  });
}
