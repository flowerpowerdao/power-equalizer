import fs from "fs";
import path from "path";
import { AssetV2, StableChunk__1 } from "../declarations/main/staging.did";
import { getOrder } from "./icpflowerNFTOrder";

let metadataPath = path.resolve(__dirname, "data", "metadata.json");
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
  let collectionMetadata: {
    background: string | null;
    flower: string | null;
    grave: string | null;
    coin: string | null;
    logo: string | null;
    unique: string | null;
  }[] = JSON.parse(fs.readFileSync(metadataPath).toString());
  let order = await getOrder();

  let assetsChunk: AssetV2[] = order.map((nftIndex, index) => {
    return {
      thumbnail: [],
      payloadUrl: [
        `https://4bhmi-biaaa-aaaae-qad6a-cai.raw.ic0.app/${nftIndex}.svg`,
      ],
      thumbnailUrl: [
        `https://4bhmi-biaaa-aaaae-qad6a-cai.raw.ic0.app/${nftIndex}_thumbnail.svg`,
      ],
      metadata: [
        {
          data: [new TextEncoder().encode(JSON.stringify(collectionMetadata[index]))],
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
