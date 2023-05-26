import { getActor } from "./clownActor";
let mainActor = getActor("ic");

export async function order() {
  const tokens = await mainActor.getTokenToAssetMapping();
  const orderedTokens = tokens.sort((a, b) => a[0] - b[0]);
  const NFTs = orderedTokens.map((token) => {
    const [tokenId, metadata] = token;
    return Number(metadata);
  });
  const NFTsString = JSON.stringify(NFTs);
  const NFTsBashList = NFTsString.replace("[", "(")
    .replace("]", ")")
    .replaceAll(",", " ");
  return NFTsBashList;
}

order();
