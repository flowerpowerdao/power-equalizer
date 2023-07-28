import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Hash "mo:base/Hash";
import Int8 "mo:base/Int8";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Hex "mo:encoding/Hex";
import Buffer "mo:base/Buffer";
import BinaryEncoding "mo:encoding/Binary";

import ExtCore "./toniq-labs/ext/Core";
import Types "./types";

module {
  /// Clone from any iterator of key-value pairs
  public func bufferTrieMapFromIter<K, V1>(
    iter : Iter.Iter<(K, [V1])>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
  ) : TrieMap.TrieMap<K, Buffer.Buffer<V1>> {
    let h = TrieMap.TrieMap<K, Buffer.Buffer<V1>>(keyEq, keyHash);
    for ((k, v) in iter) {
      h.put(k, Buffer.fromArray<V1>(v));
    };
    h;
  };

  /// Attempt to parse char to digit.
  private func digitFromChar(c : Char) : ?Nat {
    switch (c) {
      case '0' ?0;
      case '1' ?1;
      case '2' ?2;
      case '3' ?3;
      case '4' ?4;
      case '5' ?5;
      case '6' ?6;
      case '7' ?7;
      case '8' ?8;
      case '9' ?9;
      case _ null;
    };
  };

  /// Attempts to parse a nat from a path string.
  public func natFromText(
    text : Text,
  ) : ?Nat {
    var exponent : Nat = text.size();
    var number : Nat = 0;
    for (char in text.chars()) {
      switch (digitFromChar(char)) {
        case (?digit) {
          exponent -= 1;
          number += digit * (10 ** exponent);
        };
        case (_) {
          return null;
        };
      };
    };
    ?number;
  };

  /// Convert Nat32 to Blob
  public func nat32ToBlob(n : Nat32) : Blob {
    if (n < 256) {
      return Blob.fromArray([0, 0, 0, Nat8.fromNat(Nat32.toNat(n))]);
    } else if (n < 65536) {
      return Blob.fromArray([
        0,
        0,
        Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)),
        Nat8.fromNat(Nat32.toNat((n) & 0xFF)),
      ]);
    } else if (n < 16777216) {
      return Blob.fromArray([
        0,
        Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)),
        Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)),
        Nat8.fromNat(Nat32.toNat((n) & 0xFF)),
      ]);
    } else {
      return Blob.fromArray([
        Nat8.fromNat(Nat32.toNat((n >> 24) & 0xFF)),
        Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)),
        Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)),
        Nat8.fromNat(Nat32.toNat((n) & 0xFF)),
      ]);
    };
  };

  /// Convert Blob to Nat32
  public func blobToNat32(b : Blob) : Nat32 {
    var index : Nat32 = 0;
    Array.foldRight<Nat8, Nat32>(
      Blob.toArray(b),
      0,
      func(u8, accum) {
        index += 1;
        accum + Nat32.fromNat(Nat8.toNat(u8)) << ((index -1) * 8);
      },
    );
  };

  /// creates a pseudo random number generator that returns Nat between 0 and (2^64)-1
  public func prngStrong(seed : Blob) : { next() : Nat } {
    assert (seed.size() == 32);

    let initial : Nat = Nat64.toNat(BinaryEncoding.LittleEndian.toNat64(Blob.toArray(seed)));
    var current = initial * 1103515245 + 12345;

    return {
      next = func() {
        current := (current * 1103515245 + 12345) % ((2 ** 64) -1);
        return current;
      };
    };
  };

  /// convert Nat8 to Int
  public func fromNat8ToInt(n : Nat8) : Int {
    Int8.toInt(Int8.fromNat8(n));
  };

  /// convert Int to Nat8
  private func _fromIntToNat8(n : Int) : Nat8 {
    Int8.toNat8(Int8.fromIntWrap(n));
  };

  /// derive TokenIdentifier from Index
  public func indexToIdentifier(index : Nat32, actorPrincipal : Principal) : Text {
    let identifier = ExtCore.TokenIdentifier.fromPrincipal(actorPrincipal, index);
    assert (index == ExtCore.TokenIdentifier.getIndex(identifier));
    return identifier;
  };

  public func toLowerString(t : Text) : Text {
    var lowerCaseString = "";
    for (char in t.chars()) {
      lowerCaseString #= Text.fromChar(Prim.charToLower(char));
    };

    return lowerCaseString;
  };

  public func natToSubAccount(n : Nat) : ExtCore.SubAccount {
    let n_byte = func(i : Nat) : Nat8 {
      assert (i < 32);
      let shift : Nat = 8 * (32 - 1 - i);
      Nat8.fromIntWrap(n / 2 ** shift);
    };
    Array.tabulate<Nat8>(32, n_byte);
  };

  public func toNanos(duration : Types.Duration) : Nat {
    switch (duration) {
      case (#none) 0;
      case (#nanoseconds(ns)) ns;
      case (#seconds(s)) s * 1_000_000_000;
      case (#minutes(m)) m * 1_000_000_000 * 60;
      case (#hours(h)) h * 1000_000_000 * 60 * 60;
      case (#days(d)) d * 1000_000_000 * 60 * 60 * 24;
    };
  };

  func _getPageItems<T>(items : [T], pageIndex : Nat, limit : Nat) : [T] {
    let start = pageIndex * limit;
    let end = Nat.min(start + limit, items.size());
    let size = end - start;

    if (size == 0) {
      return [];
    };

    let buf = Buffer.Buffer<T>(size);
    for (i in Iter.range(start, end - 1)) {
      buf.add(items[i]);
    };

    Buffer.toArray(buf);
  };

  public func getPage<T>(items : [T], pageIndex : Nat, limit : Nat) : ([T], Nat) {
    (
      _getPageItems(items, pageIndex, limit),
      items.size() / limit + (if (items.size() % limit == 0) 0 else 1),
    );
  };

  // shuffle buffer in place
  public func shuffleBuffer<T>(buffer : Buffer.Buffer<T>, seed : Blob) {
    // use that seed to create random number generator
    let randGen = prngStrong(seed);
    // get the number of available tokens
    var currentIndex : Nat = buffer.size();

    while (currentIndex > 0) {
      // use a random number to calculate a random index between 0 and currentIndex
      var randomIndex = randGen.next() % currentIndex;
      assert (randomIndex < currentIndex);
      currentIndex -= 1;
      let temporaryValue = buffer.get(currentIndex);
      buffer.put(currentIndex, buffer.get(randomIndex));
      buffer.put(randomIndex, temporaryValue);
    };
  };
};
