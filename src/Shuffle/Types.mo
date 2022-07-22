import Assets "../CanisterAssets";
import ExtCore "../toniq-labs/ext/Core";
import Tokens "../Tokens";

module {
    public type State = {
        _isShuffledState : Bool;
    };

    public type Dependencies = {
        _Assets : Assets.Factory;
        _Tokens : Tokens.Factory;
    };
    public type TokenIndex  = ExtCore.TokenIndex ;
}