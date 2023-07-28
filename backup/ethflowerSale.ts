import { StableChunk__4 } from "../declarations/main/staging.did";

export async function sale() {
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

sale();
