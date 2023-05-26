import {
  Metadata,
  StableChunk__6,
} from "../declarations/main/staging.did";
import { getActor } from "./clownActor";
let mainActor = getActor("ic");

export async function tokens() {
  const registry = await getRegistry();

  const tokens: StableChunk__6 = [
    {
      v1: {
        tokenMetadata: getTokenMetadata(),
        owners: getOwners(registry), // owners is not directly exposed, so we have to calculate it
        registry,
        nextTokenId: 2000,
        supply: 2000n, // supply is basically equal to nextTokenId
      },
    },
  ];
  return tokens;
}
function getTokenMetadata(): [number, Metadata][] {
  const tokenMetadata: [number, Metadata][] = [];
  for (let i = 0; i < 2000; i++) {
    let item: [number, Metadata] = [
      i,
      {
        nonfungible: {
          metadata: [intToByteArray(i + 1)], // because collection had a delayedReveal, we don't point to the 0 index
        },
      },
    ];
    tokenMetadata.push(item);
  }
  return tokenMetadata;
}

function getOwners(registry: [number, string][]): [string, number[]][] {
  // bin the registry entries by AccountIdentifier,
  // each AccountIdentifier has a list of TokenIndex
  const owners = registry.reduce((acc, item) => {
    const [tokenIndex, accountIdentifier] = item;
    if (!acc[accountIdentifier]) {
      acc[accountIdentifier] = [];
    }
    acc[accountIdentifier].push(tokenIndex);
    return acc;
  }, {});
  // turn the object into a list of [AccountIdentifier, [TokenIndex]]
  const ownersList = Object.entries<number[]>(owners);
  return ownersList;
}

async function getRegistry() {
  const registry = await mainActor.getRegistry();
  return registry;
}

function intToByteArray(int) {
  // Create a new 4-byte array
  const byteArray = new Uint8Array(4);

  // Convert an integer to a 4-byte array using DataView.setInt32()
  const dataView = new DataView(byteArray.buffer);
  dataView.setUint32(0, int);

  // byteArray now contains the 4 bytes of the integer
  const array = Array.from(byteArray);
  return array;
}
