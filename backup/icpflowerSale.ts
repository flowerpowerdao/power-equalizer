// import { SaleTransaction } from "../declarations/btcflower/btcflower.did";
import { StableChunk__4 } from "../declarations/main/staging.did";
import { getActor } from "./icpflowerActor";
let mainActor = getActor("ic");

export async function sale() {
  // const saleTransactions = await getSaleTransactions();

  const sale: StableChunk__4 = [
    {
      v2: {
        salesSettlements: [],
        totalToSell: 0n,
        failedSales: [],
        sold: 0n,
        saleTransactionChunk: [],
        saleTransactionCount: 0n,
        nextSubAccount: 0n,
        soldIcp: 0n,
        whitelistSpots: [],
        tokensForSale: [],
      },
    },
  ];
  return sale;
}

// async function getSaleTransactions() {
//   const saleTransactions = await mainActor.saleTransactions();
//   return saleTransactions;
// }

// function getSoldIcp(saleTransactions: SaleTransaction[]) {
//   let soldIcp = BigInt(0);
//   saleTransactions.forEach((saleTransaction) => {
//     soldIcp += saleTransaction.price;
//   });
//   return soldIcp;
// }

// function getSold(saleTransactions: SaleTransaction[]) {
//   let sold = BigInt(0);
//   saleTransactions.forEach((saleTransaction) => {
//     sold += BigInt(saleTransaction.tokens.length);
//   });
//   return sold;
// }

// function getSaleTransactionCount(saleTransactions: SaleTransaction[]) {
//   return BigInt(saleTransactions.length);
// }

sale();
