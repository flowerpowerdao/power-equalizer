import fs from "fs";
import path from "path";
import { Principal } from "@dfinity/principal";
import { StableChunk } from "../declarations/main/staging.did";
import { marketplace } from "./clownMarketplace";
import { sale } from "./clownSale";
import { tokens } from "./clownTokens";
import { order } from "./clownNFTOrder";

let file =
  new Date()
    .toISOString()
    .replaceAll(":", "-")
    .replace("T", "_")
    .replace("Z", "")
    .slice(0, -4) + ".json";

export let backup = async ({ file }) => {
  console.log(`Backup file: ${file}`);

  let backup: StableChunk[] = [
    {
      v1: {
        marketplace: await marketplace(),
        assets: [],
        sale: await sale(),
        disburser: [],
        tokens: await tokens(),
        shuffle: [{ v1: { isShuffled: true } }],
      },
    },
  ];

  fs.mkdirSync(path.resolve("backup/data/"), { recursive: true });
  fs.writeFileSync(
    `backup/data/${file}`,
    JSON.stringify(
      backup,
      (_, val) => {
        if (val instanceof Uint8Array) {
          return Array.from(val);
        } else if (val instanceof Uint32Array) {
          return Array.from(val);
        } else if (typeof val === "bigint") {
          return `###bigint:${String(val)}`;
        } else if (val instanceof Principal) {
          return `###principal:${val.toText()}`;
        } else {
          return val;
        }
      },
      "  "
    )
  );

  fs.writeFileSync(`backup/data/nft.txt`, await order());

  console.log(`Backup successfully saved to backup/data/${file}`);
};

backup({ file });
