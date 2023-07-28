import fs from "fs";
import path from "path";
import { AssetV2, StableChunk__1 } from "../declarations/main/staging.did";
import { getOrder } from "./ethflowerNFTOrder";

let metadataPath = path.resolve(__dirname, "data", "ethflower.json");
if (!fs.existsSync(metadataPath)) {
  throw new Error(`File ${metadataPath} not found`);
}

export async function assets() {
  let assetsChunk = await getAssets();
  const assets: StableChunk__1 = [
    {
      v3: {
        assetsChunk: assetsChunk,
        assetsCount: BigInt(assetsChunk.length),
        placeholder: {
          thumbnail: [],
          payloadUrl: [],
          thumbnailUrl: [],
          metadata: [],
          name: "placeholder",
          payload: { data: [], ctype: "" },
        },
        isShuffled: true,
      },
    },
  ];
  return assets;
}

async function getAssets() {
  let metadata: {
    mint_number: number;
    background: string;
    flower: string;
    coin: string;
    grave: string;
  }[] = JSON.parse(fs.readFileSync(metadataPath).toString());
  let order = await getOrder();

  let assetsChunk: AssetV2[] = order.map((nftIndex) => {
    let { mint_number, ...metadataWithoutMintnumber } = metadata[nftIndex - 1];
    return {
      thumbnail: [],
      payloadUrl: [
        `https://cdfps-iyaaa-aaaae-qabta-cai.raw.ic0.app/${nftIndex}.svg`,
      ],
      thumbnailUrl: [
        `https://cdfps-iyaaa-aaaae-qabta-cai.raw.ic0.app/${nftIndex}_low.svg`,
      ],
      metadata: [
        {
          data: [
            new TextEncoder().encode(JSON.stringify(metadataWithoutMintnumber)),
          ],
          ctype: "application/json",
        },
      ],
      name: String(nftIndex),
      payload: {
        data: [],
        ctype: "",
      },
    };
  });

  return assetsChunk;
}
