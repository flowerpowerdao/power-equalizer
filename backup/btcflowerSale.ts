import { SaleTransaction } from "../declarations/btcflower/btcflower.did";
import { StableChunk__4 } from "../declarations/main/staging.did";
import { getActor } from "./btcflowerActor";
let mainActor = getActor("ic");

export async function sale() {
  const saleTransactions = await getSaleTransactions();

  const sale: StableChunk__4 = [
    {
      v2: {
        salesSettlements: [],
        totalToSell: getSold(saleTransactions),
        failedSales: [],
        sold: getSold(saleTransactions),
        saleTransactionChunk: saleTransactions,
        saleTransactionCount: getSaleTransactionCount(saleTransactions),
        nextSubAccount: 0n,
        soldIcp: getSoldIcp(saleTransactions),
        whitelistSpots: [],
        tokensForSale: [],
      },
    },
  ];
  return sale;
}

async function getSaleTransactions() {
  const saleTransactions = await mainActor.saleTransactions();
  return saleTransactions;
}

function getSoldIcp(saleTransactions: SaleTransaction[]) {
  let soldIcp = BigInt(0);
  saleTransactions.forEach((saleTransaction) => {
    soldIcp += saleTransaction.price;
  });
  return soldIcp;
}

function getSold(saleTransactions: SaleTransaction[]) {
  let sold = BigInt(0);
  saleTransactions.forEach((saleTransaction) => {
    sold += BigInt(saleTransaction.tokens.length);
  });
  return sold;
}

function getSaleTransactionCount(saleTransactions: SaleTransaction[]) {
  return BigInt(saleTransactions.length);
}

sale();
