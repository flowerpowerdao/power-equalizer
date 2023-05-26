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
        tokenSettlement: await getSettlements(),
        frontends: await getFrontends(),
        tokenListing: await getTokenListing(),
        transactionChunk: transactions,
        transactionCount: BigInt(transactions.length),
      },
    },
  ];
  return marketplace;
}

async function getFrontends() {
  const frontends = await mainActor.frontends();
  return frontends;
}

async function getTokenListing(): Promise<[number, Listing][]> {
  const tokenListing = await mainActor.listings();
  return tokenListing.map((listing) => {
    let newListing: [number, Listing] = [listing[0], listing[1]];
    return newListing;
  });
}

async function getTransactions() {
  const transactions = await mainActor.transactions();
  return transactions;
}

async function getSettlements(): Promise<[number, Settlement][]> {
  const settlements = await mainActor.allSettlements();
  return settlements;
}
