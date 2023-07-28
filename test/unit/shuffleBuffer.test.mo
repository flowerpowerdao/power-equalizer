import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Random "mo:base/Random";

import {test; suite} "mo:test/async";
import Fuzz "mo:fuzz";
import Utils "../../src/utils";

let fuzz = Fuzz.Fuzz();

await suite("Utils.shuffleBuffer should shuffle buffer in place", func() : async () {
  await test("0 items", func() : async () {
    let seed = await Random.blob();
    let ar = [];
    let buf = Buffer.fromArray<Nat>(ar);

    assert(Buffer.toArray(buf) == ar);
    Utils.shuffleBuffer<Nat>(buf, seed);
    assert(Buffer.toArray(buf) == ar);
  });

  await test("1 item", func() : async () {
    let seed = await Random.blob();
    let ar = [0];
    let buf = Buffer.fromArray<Nat>(ar);

    assert(Buffer.toArray(buf) == ar);
    Utils.shuffleBuffer<Nat>(buf, seed);
    assert(Buffer.toArray(buf) == ar);
  });

  await test("10 items", func() : async () {
    let seed = await Random.blob();
    let ar = fuzz.array.randomArray<Nat8>(10, fuzz.nat8.random);
    let buf = Buffer.fromArray<Nat8>(ar);

    assert(Buffer.toArray(buf) == ar);
    Debug.print(debug_show(Buffer.toArray(buf)));

    Utils.shuffleBuffer<Nat8>(buf, seed);

    assert(Buffer.toArray(buf) != ar);
    Debug.print(debug_show(Buffer.toArray(buf)));
  });

  await test("10_000 items", func() : async () {
    let seed = await Random.blob();
    let ar = fuzz.array.randomArray<Nat8>(10_000, fuzz.nat8.random);
    let buf = Buffer.fromArray<Nat8>(ar);

    assert(Buffer.toArray(buf) == ar);
    Utils.shuffleBuffer<Nat8>(buf, seed);
    assert(Buffer.toArray(buf) != ar);
  });
});