import { readFileSync, write, writeFileSync } from "fs";

import { StableChunk } from "../declarations/main/staging.did";

let test = async () => {
  console.log("Compare backups");
  let a: StableChunk[] = JSON.parse(
    readFileSync(__dirname + "/data/2023-05-26_20-05-07.json", "utf-8")
  );
  let b: StableChunk[] = JSON.parse(
    readFileSync(__dirname + "/data/2023-05-26_19-45-34.json", "utf-8")
  );

  a[0].v1.tokens[0].v1.owners.sort();
  a[0].v1.tokens[0].v1.tokenMetadata.sort();

  b[0].v1.tokens[0].v1.owners.sort();
  b[0].v1.tokens[0].v1.tokenMetadata.sort();

  let aUpdated = JSON.stringify(a, null, 2);
  let bUpdated = JSON.stringify(b, null, 2);

  writeFileSync(__dirname + "/data/a.json", aUpdated);
  writeFileSync(__dirname + "/data/b.json", bUpdated);

  if (aUpdated !== bUpdated) {
    throw "a.json and b.json backups are different!";
  }

  console.log("Success!");
};

test();
