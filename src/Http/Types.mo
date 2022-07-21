import Assets "../CanisterAssets";
import Tokens "../Tokens";
import Shuffle "../Shuffle";
import Marketplace "../Marketplace";

module {
  public type HeaderField = (Text, Text);
  public type HttpResponse = {
    status_code: Nat16;
    headers: [HeaderField];
    body: Blob;
    streaming_strategy: ?HttpStreamingStrategy;
  };
  public type HttpRequest = {
    method : Text;
    url : Text;
    headers : [HeaderField];
    body : Blob;
  };
  public type HttpStreamingCallbackToken =  {
    content_encoding: Text;
    index: Nat;
    key: Text;
    sha256: ?Blob;
  };

  public type HttpStreamingStrategy = {
    #Callback: {
        // start custom
        callback: shared () -> async ();
        // end custom
        token: HttpStreamingCallbackToken;
    };
  };

  public type HttpStreamingCallbackResponse = {
    body: Blob;
    token: ?HttpStreamingCallbackToken;
  };

  public type State = {
    _Assets : Assets.Factory;
    _Shuffle : Shuffle.Shuffle;
    _Tokens : Tokens.Factory;
    _Marketplace : Marketplace.Factory;
  }
}