import fs from "fs";
import path from "path";
import { Principal } from "@dfinity/principal";
import { StableChunk } from "../declarations/main/staging.did";
import { marketplace } from "./icpflowerMarketplace";
import { sale } from "./icpflowerSale";
import { tokens } from "./icpflowerTokens";
import { assets } from "./icpflowerAssets";

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
      v2: {
        marketplace: await marketplace(),
        assets: await assets(),
        sale: await sale(),
        disburser: [
          {
            v1: {
              disbursements: [],
            },
          },
        ],
        tokens: await tokens(),
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

  console.log(`Backup successfully saved to backup/data/${file}`);
};

backup({ file });
