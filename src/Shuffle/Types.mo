import Assets "../CanisterAssets";
import Tokens "../Tokens";

module {
    public type State = {
        _isShuffledState : Bool;
    };

    public type Dependencies = {
        _Assets : Assets.Factory;
        _Tokens : Tokens.Factory;
    };
}