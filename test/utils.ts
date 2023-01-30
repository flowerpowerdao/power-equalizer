import { Principal } from "@dfinity/principal";
import { expect } from "vitest";
import { User } from "./user";

export async function buyFromSale(user: User) {
  let settings = await user.mainActor.salesSettings(user.accountId);
  let res = await user.mainActor.reserve(settings.price, 1n, user.accountId, new Uint8Array);

  expect(res).not.toHaveProperty('err');

  if ('ok' in res) {
    let paymentAddress = res.ok[0];
    let paymentAmount = res.ok[1];
    expect(paymentAddress.length).toBe(64);
    expect(paymentAmount).toBe(settings.price);

    await user.sendICP(paymentAddress, paymentAmount);
    let retrieveRes = await user.mainActor.retrieve(paymentAddress);
    expect(retrieveRes).not.toHaveProperty('err');
  }
}

export async function checkTokenCount(user: User, count: number) {
  let tokensRes = await user.mainActor.tokens(user.accountId);
  expect(tokensRes).not.toHaveProperty('err');
  if ('ok' in tokensRes) {
    expect(tokensRes.ok.length).toBe(count);
    let tokenIndex = tokensRes.ok.at(-1);
    expect(tokenIndex).toBeGreaterThan(0);
  }
}

// https://github.com/Toniq-Labs/ext-cli/blob/main/src/utils.js#L62-L66
export let to32bits = (num) => {
  let b = new ArrayBuffer(4);
  new DataView(b).setUint32(0, num);
  return Array.from(new Uint8Array(b));
}

// https://github.com/Toniq-Labs/ext-cli/blob/main/src/extjs.js#L20-L45
export let tokenIdentifier = (principal, index) => {
  let padding = Buffer.from("\x0Atid");
  let array = new Uint8Array([
      ...padding,
      ...Principal.fromText(principal).toUint8Array(),
      ...to32bits(index),
  ]);
  return Principal.fromUint8Array(array).toText();
};