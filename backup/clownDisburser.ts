import { StableChunk__2 } from "../declarations/main/staging.did";
import { getActor } from "./clownActor";
let mainActor = getActor("ic");

export async function disburser() {
  const disburser: StableChunk__2 = [
    {
      v1: {
        disbursements: await getDisbursements(),
      },
    },
  ];
  return disburser;
}

async function getDisbursements() {
  const disbursements = await mainActor.getDisbursements();
  return disbursements;
}
