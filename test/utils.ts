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