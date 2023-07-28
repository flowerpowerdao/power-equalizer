import { getActor } from "./ethflowerActor";
let mainActor = getActor("ic");

export async function getOrder() {
  const tokens = await mainActor.getTokens();
  const orderedTokens = tokens.sort((a, b) => a[0] - b[0]);
  return orderedTokens.map((token) => {
    const [tokenId, metadata] = token;
    return Number(metadata);
  });
}
