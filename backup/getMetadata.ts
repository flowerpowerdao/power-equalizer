import ext from "ext";
import fs from "fs";
export default async function getMetadata() {
  let metadata = [];

  // iterate through all 2021 token ids
  for (let i = 0; i < 2021; i++) {
    let tokenId = ext.encodeTokenId("4ggk4-mqaaa-aaaae-qad6q-cai", i);
    // query api for metadata
    let response = await fetch(
      `https://4ggk4-mqaaa-aaaae-qad6q-cai.raw.icp0.io/?tokenid=${tokenId}&type=metadata`
    );
    let json = await response.json();
    // add metadata to array
    metadata.push(json);
  }
  // write metadata to file
  fs.writeFileSync("metadata.json", JSON.stringify(metadata));
}

getMetadata();
