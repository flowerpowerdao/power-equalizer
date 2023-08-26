import {
  Listing,
  Settlement,
  StableChunk__3,
  TransactionV2,
} from "../declarations/main/staging.did";
import { getActor } from "./icpflowerActor";
let mainActor = getActor("ic");

export async function marketplace() {
  const transactions = await getTransactions();
  const marketplace: StableChunk__3 = [
    {
      v2: {
        tokenSettlement: await getSettlements(),
        tokenListing: await getTokenListing(),
        transactionChunk: transactions,
        transactionCount: BigInt(transactions.length),
      },
    },
  ];
  return marketplace;
}

async function getTokenListing(): Promise<[number, Listing][]> {
  const tokenListing = await mainActor.listings();
  return tokenListing
    .map((listing) => {
      let newListing: [number, Listing] = [
        listing[0],
        {
          sellerFrontend: [],
          locked: listing[1].locked,
          seller: listing[1].seller,
          buyerFrontend: [],
          price: listing[1].price,
        },
      ];
      return newListing;
    })
    .sort((a, b) => a[0] - b[0]);
}

async function getTransactions() {
  const transactions = await mainActor.transactions();
  const transactionsV2: TransactionV2[] = transactions.map((transaction) => {
    let newTransaction: TransactionV2 = {
      sellerFrontend: [],
      token: transaction.token,
      time: transaction.time,
      seller: transaction.seller,
      buyerFrontend: [],
      buyer: transaction.buyer,
      price: transaction.price,
    };
    return newTransaction;
  });
  return transactionsV2;
}

async function getSettlements(): Promise<[number, Settlement][]> {
  const settlements = await mainActor.allSettlements();
  return settlements.map((settlement) => {
    let newSettlement: [number, Settlement] = [
      settlement[0],
      {
        sellerFrontend: [],
        subaccount: settlement[1].subaccount,
        seller: settlement[1].seller,
        buyerFrontend: [],
        buyer: settlement[1].buyer,
        price: settlement[1].price,
      },
    ];
    return newSettlement;
  });
}
