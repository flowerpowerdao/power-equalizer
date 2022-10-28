import Float "mo:base/Float";
import Int "mo:base/Int";
import Random "mo:base/Random";

import Buffer "../buffer";
import Types "types";
import Utils "../utils";

module {
  public class Factory(state : Types.StableState, deps : Types.Dependencies, consts : Types.Constants) {

    /*********
* STATE *
*********/

    private var _isShuffled : Bool = state._isShuffledState;

    public func toStable() : Types.StableState {
      return {
        _isShuffledState = _isShuffled;
      };
    };

    public func isShuffled() : Bool {
      _isShuffled;
    };

    //*** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    public func shuffleAssets(caller : Principal) : async () {
      assert (caller == consts.minter and _isShuffled == false);
      // get a random seed from the IC
      let seed : Blob = await Random.blob();
      // use that seed to generate a truly random number
      var randomNumber : Nat8 = Random.byteFrom(seed);
      // get the number of available assets
      var currentIndex : Nat = deps._Assets.size();

      // shuffle the assets array using the random beacon
      while (currentIndex != 1) {
        // create a pseudo random number between 0-99
        randomNumber := Utils.prng(randomNumber);
        // use that number to calculate a random index between 0 and currentIndex
        var randomIndex : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(Utils.fromNat8ToInt(randomNumber) * currentIndex / 100))));
        assert (randomIndex < currentIndex);
        currentIndex -= 1;
        // we never want to touch the 0 index
        // as it contains the seed video
        if (randomIndex == 0) {
          randomIndex += 1;
        };
        assert ((randomIndex != 0) and (currentIndex != 0));
        let temporaryValue = deps._Assets.get(currentIndex);
        deps._Assets.put(currentIndex, deps._Assets.get(randomIndex));
        deps._Assets.put(randomIndex, temporaryValue);
      };
      _isShuffled := true;
    };

    // *** ** ** ** ** ** ** ** ** * * INTERNAL METHODS * ** ** ** ** ** ** ** ** ** ** /

    public func shuffleTokens(tokens : Buffer.Buffer<Types.TokenIndex>, seed : Blob) : Buffer.Buffer<Types.TokenIndex> {
      // use seed to generate a truly random number
      var randomNumber : Nat8 = Random.byteFrom(seed);
      var currentIndex : Nat = tokens.size();

      while (currentIndex != 1) {
        // create a pseudo random number between 0-99
        randomNumber := Utils.prng(randomNumber);
        // use that number to calculate a random index between 0 and currentIndex
        var randomIndex : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(Utils.fromNat8ToInt(randomNumber) * currentIndex / 100))));
        assert (randomIndex < currentIndex);
        currentIndex -= 1;
        let temporaryValue = tokens.get(currentIndex);
        tokens.put(currentIndex, tokens.get(randomIndex));
        tokens.put(randomIndex, temporaryValue);
      };
      return tokens;
    };
  };
};
