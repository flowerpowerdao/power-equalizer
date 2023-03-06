import Float "mo:base/Float";
import Int "mo:base/Int";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";

import Types "types";
import Utils "../utils";
import Env "../Env";

module {
  public class Factory(deps : Types.Dependencies, consts : Types.Constants) {

    /*********
    * STATE *
    *********/

    var _isShuffled = false;

    public func toStable() : Types.StableState {
      return {
        _isShuffledState = _isShuffled;
      };
    };

    public func toStableChunk(chunkSize : Nat, chunkIndex : Nat) : Types.StableChunk {
      ?#v1({
        isShuffled = _isShuffled;
      });
    };

    public func loadStableChunk(chunk : Types.StableChunk) {
      switch (chunk) {
        // TODO: remove after upgrade vvv
        case (?#legacy(state)) {
          _isShuffled := state._isShuffledState;
        };
        // TODO: remove after upgrade ^^^
        case (?#v1(data)) {
          _isShuffled := data.isShuffled;
        };
        case (null) {};
      };
    };

    public func isShuffled() : Bool {
      _isShuffled;
    };

    //*** ** ** ** ** ** ** ** ** * * PUBLIC INTERFACE * ** ** ** ** ** ** ** ** ** ** /

    public func shuffleAssets(caller : Principal) : async () {
      assert (caller == consts.minter and Env.delayedReveal and not _isShuffled);
      // get a random seed from the IC
      let seed : Blob = await Random.blob();
      // use that seed to create random number generator
      let randGen = Utils.prngStrong(seed);
      // get the number of available assets
      var currentIndex : Nat = deps._Assets.size();

      // shuffle the assets array using the random beacon
      while (currentIndex != 1) {
        // use a random number to calculate a random index between 0 and currentIndex
        var randomIndex = randGen.next() % currentIndex;
        assert (randomIndex < currentIndex);
        currentIndex -= 1;
        // for delayed reveal we never want to touch the 0 index
        // as it contains the placeholder
        if (Env.delayedReveal and randomIndex == 0) {
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
      // use that seed to create random number generator
      let randGen = Utils.prngStrong(seed);
      // get the number of available tokens
      var currentIndex : Nat = tokens.size();

      while (currentIndex != 1) {
        // use a random number to calculate a random index between 0 and currentIndex
        var randomIndex = randGen.next() % currentIndex;
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
