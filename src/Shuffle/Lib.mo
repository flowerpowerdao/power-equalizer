import Float "mo:base/Float";
import Int "mo:base/Int";
import Random "mo:base/Random";

import Types "Types";
import Utils "../Utils";

module {
  public class Shuffle (state : Types.State, deps : Types.Dependencies) {

/*********
* STATE *
*********/

    private var _isShuffled: Bool = state._isShuffledState;

    public func toStable () : {
      _isShuffledState : Bool;
    } {
      return {
        _isShuffledState = _isShuffled;
      }
    };

    public func isShuffled() : Bool {
        _isShuffled
    };

/********************
* PUBLIC INTERFACE *
********************/

    public func shuffleAssets(caller : Principal) : async () {
      assert(caller == deps._Tokens.getMinter() and _isShuffled == false);
      // get a random seed from the IC
      let seed: Blob = await Random.blob();
      // use that seed to generate a truly random number
      var randomNumber : Nat8 = Random.byteFrom(seed);
      // get the number of available assets
      var currentIndex : Nat = deps._Assets.size();

      // shuffle the assets array using the random beacon
      while (currentIndex != 1){
        // create a pseudo random number between 0-99
        randomNumber := Utils.prng(randomNumber);
        // use that number to calculate a random index between 0 and currentIndex
        var randomIndex : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(Utils.fromNat8ToInt(randomNumber)* currentIndex/100))));
        assert(randomIndex < currentIndex);
        currentIndex -= 1;
        // we never want to touch the 0 index
        // as it contains the seed video
        if (randomIndex == 0) {
          randomIndex += 1;
        };
        assert((randomIndex != 0) and (currentIndex != 0));
        let temporaryValue = deps._Assets.get(currentIndex);
        deps._Assets.put(currentIndex, deps._Assets.get(randomIndex));
        deps._Assets.put(randomIndex,temporaryValue);
      };
      _isShuffled := true;
    };

  };
}