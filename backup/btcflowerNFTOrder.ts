import { getActor } from "./btcflowerActor";
let mainActor = getActor("ic");

export async function order() {
  const tokens = await mainActor.getTokens();
  const orderedTokens = tokens.sort((a, b) => a[0] - b[0]);
  const NFTs = orderedTokens.map((token) => {
    const [tokenId, metadata] = token;
    return Number(metadata);
  });
  return JSON.stringify(NFTs);
}
