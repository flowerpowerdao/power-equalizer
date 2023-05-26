import { SaleTransaction } from "../declarations/clowns/production.did";
import { StableChunk__4 } from "../declarations/main/staging.did";
import { getActor } from "./clownActor";
let mainActor = getActor("ic");

export async function sale() {
  const saleTransactions = await getSaleTransactions();

  const sale: StableChunk__4 = [
    {
      v1: {
        saleTransactionCount: getSaleTransactionCount(saleTransactions),
        saleTransactionChunk: saleTransactions,
        salesSettlements: await getSalesSettlements(),
        failedSales: await getFailedSailes(),
        tokensForSale: [], // sale already ended
        whitelist: [], // sale ended
        soldIcp: getSoldIcp(saleTransactions),
        sold: getSold(saleTransactions), // how many token were sold
        totalToSell: getSold(saleTransactions), // how many token were for sale
        nextSubAccount: 3000n, // 2000 mint transactions + 656 marketplace transactions
      },
    },
  ];
  return sale;
}

async function getSalesSettlements() {
  const salesSettlements = await mainActor.salesSettlements();
  return salesSettlements;
}

async function getFailedSailes() {
  const failedSales = await mainActor.failedSales();
  return failedSales;
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
