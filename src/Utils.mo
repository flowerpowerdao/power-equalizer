import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int8 "mo:base/Int8";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";

import Buffer "./Buffer";
import ExtCore "./toniq-labs/ext/Core";

module {
  
  /// Create a Buffer from an Array
  public func bufferFromArray<T>(array : [T]) : Buffer.Buffer<T> {
    let buffer = Buffer.Buffer<T>(array.size());
    for (element in Array.vals(array)) {
      buffer.add(element);
    };
    return buffer;
  };

  /// Clone from any iterator of key-value pairs
  public func BufferHashMapFromIter<K, V1>(
    iter : Iter.Iter<(K, [V1])>,
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap.HashMap<K, Buffer.Buffer<V1>> {
    let h = HashMap.HashMap<K, Buffer.Buffer<V1>>(initCapacity, keyEq, keyHash);
    for ((k, v) in iter) {
      h.put(k, bufferFromArray<V1>(v));
    };
    h
  };

  /// Attempt to parse char to digit.
  private func digitFromChar(c: Char): ?Nat {
      switch(c) {
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
      }
  };

  /// Attempts to parse a nat from a path string.
  public func natFromText(
      text : Text
  ) : ?Nat {
      var exponent : Nat = text.size();
      var number : Nat = 0;
      for (char in text.chars()){
          switch (digitFromChar(char)) {
              case (?digit) {
                  exponent -= 1;
                  number += digit * (10**exponent);
              };
              case (_) {
                  return null
              }
          }
      };
      ?number
  };

  /// Convert Nat32 to Blob
  public func nat32ToBlob(n : Nat32) : Blob {
    if (n < 256) {
      return Blob.fromArray([0,0,0, Nat8.fromNat(Nat32.toNat(n))]);
    } else if (n < 65536) {
      return Blob.fromArray([
        0,0,
        Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
        Nat8.fromNat(Nat32.toNat((n) & 0xFF))
      ]);
    } else if (n < 16777216) {
      return Blob.fromArray([
        0,
        Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)), 
        Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
        Nat8.fromNat(Nat32.toNat((n) & 0xFF))
      ]);
    } else {
      return Blob.fromArray([
        Nat8.fromNat(Nat32.toNat((n >> 24) & 0xFF)), 
        Nat8.fromNat(Nat32.toNat((n >> 16) & 0xFF)), 
        Nat8.fromNat(Nat32.toNat((n >> 8) & 0xFF)), 
        Nat8.fromNat(Nat32.toNat((n) & 0xFF))
      ]);
    };
  };

  /// Convert Blob to Nat32
  public func blobToNat32(b : Blob) : Nat32 {
    var index : Nat32 = 0;
    Array.foldRight<Nat8, Nat32>(Blob.toArray(b), 0, func (u8, accum) {
      index += 1;
      accum + Nat32.fromNat(Nat8.toNat(u8)) << ((index-1) * 8);
    });
  };

  /// a pseudo random number generator that returns Nat8 between 0 and 99
  public func prng(current: Nat8) : Nat8 {
    let next : Int =  fromNat8ToInt(current) * 1103515245 + 12345;
    return _fromIntToNat8(next) % 100;
  };

  /// convert Nat8 to Int
  public func fromNat8ToInt(n : Nat8) : Int {
    Int8.toInt(Int8.fromNat8(n))
  };

  /// convert Int to Nat8
  private func _fromIntToNat8(n: Int) : Nat8 {
    Int8.toNat8(Int8.fromIntWrap(n))
  };

  /// derive TokenIdentifier from Index
  public func indexToIdentifier(index: Nat32, actorPrincipal : Principal) : Text {
    let identifier = ExtCore.TokenIdentifier.fromPrincipal(actorPrincipal, index);
    assert(index == ExtCore.TokenIdentifier.getIndex(identifier));
    return identifier;
  };
}