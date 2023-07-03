import fs from "fs";
import path from "path";
import chalk from "chalk";
import chunk from "chunk";
import minimist from "minimist";
import { Principal } from "@dfinity/principal";

import { getActor } from "./actor";
import { type StableChunk } from "../declarations/main/staging.did";
import { decode } from "./pem";

let argv = minimist(process.argv.slice(2));
let network = argv.network || "local";
let file = argv.file;
let metadata = argv.metadata;
let pemData = argv.pem || "";
let canisterId = argv["canister-id"];

if (!file) {
  throw new Error("Missing --file argument");
}
if (!metadata) {
  throw new Error("Missing --metadata argument");
}
if (!canisterId) {
  throw new Error("Missing --canister-id argument");
}

let filePath = path.resolve(__dirname, "data", file);
if (!fs.existsSync(filePath)) {
  throw new Error(`File ${filePath} not found`);
}

let metadataPath = path.resolve(__dirname, "data", metadata);
if (!fs.existsSync(metadataPath)) {
  throw new Error(`File ${metadataPath} not found`);
}

let orderPath = path.resolve(__dirname, "data", "order.json");
if (!fs.existsSync(orderPath)) {
  throw new Error(`File ${orderPath} not found`);
}

let identity = pemData && decode(pemData);
let mainActor = getActor(network, canisterId, identity);

export let restore = async ({ network, file }) => {
  console.log(`Network: ${network}`);
  console.log(`Backup file: ${file}`);
  if (identity) {
    console.log(`Identity: ${identity.getPrincipal().toText()}`);
  }

  let text = fs.readFileSync(filePath).toString();

  let chunks: StableChunk[] = JSON.parse(text, (key, val) => {
    if (typeof val === "string") {
      if (val.startsWith("###bigint:")) {
        return BigInt(val.slice("###bigint:".length));
      } else if (val.startsWith("###principal:")) {
        return Principal.fromText(val.slice("###principal:".length));
      }
    }
    return val;
  });

  for (let i = 0; i < chunks.length; i++) {
    console.log(`Uploading chunk ${i + 1}`);
    await mainActor.restoreChunk(chunks[i]);
  }

  await uploadAssetsMetadata();

  console.log(`Restore successful`);
};

let uploadAssetsMetadata = async () => {
  let assets = JSON.parse(fs.readFileSync(metadataPath).toString());
  let order = JSON.parse(fs.readFileSync(orderPath).toString());

  // assets
  console.log(chalk.green("Uploading assets metadata..."));
  console.log(chalk.green(`Found ${assets.length} assets metadata...`));

  let all = new Set([...assets.keys()]);
  let uploadedCount = 0;

  let chunks = chunk([...order.entries()], 1000);

  console.log("Chunks:", chunks.length);

  for (let chunk of chunks) {
    let metadataChunk = chunk.map(([arrayIndex, nftIndex]) => {
      return {
        name: String(nftIndex),
        payload: {
          ctype: "",
          data: [],
        },
        thumbnail: [],
        metadata: [
          {
            ctype: "application/json",
            data: [
              new TextEncoder().encode(JSON.stringify(assets[nftIndex - 1])),
            ],
          },
        ],
        payloadUrl: [
          `https://n6au6-3aaaa-aaaae-qaaxq-cai.raw.ic0.app/${nftIndex}.svg`,
        ],
        thumbnailUrl: [
          `https://n6au6-3aaaa-aaaae-qaaxq-cai.raw.ic0.app/${nftIndex}_low.svg`,
        ],
      };
    });

    await mainActor.addAssets(metadataChunk);

    uploadedCount += chunk.length;

    console.log(`Uploaded metadata: ${uploadedCount}`);

    chunk.forEach(([index, _]) => {
      all.delete(index);
    });
  }

  if (all.size > 0) {
    throw new Error(`Failed to upload metadata for ${[...all].join(", ")}`);
  }

  console.log(chalk.green("All assets metadata uploaded"));
};

restore({ network, file });
