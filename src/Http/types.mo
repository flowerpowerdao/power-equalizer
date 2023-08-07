import Assets "../CanisterAssets";
import Marketplace "../Marketplace";
import Sale "../Sale";
import Tokens "../Tokens";

module {
  public type HeaderField = (Text, Text);
  public type HttpResponse = {
    status_code : Nat16;
    headers : [HeaderField];
    body : Blob;
    streaming_strategy : ?HttpStreamingStrategy;
  };
  public type HttpRequest = {
    method : Text;
    url : Text;
    headers : [HeaderField];
    body : Blob;
  };
  public type HttpStreamingCallbackToken = {
    content_encoding : Text;
    index : Nat;
    key : Text;
    sha256 : ?Blob;
  };

  public type HttpStreamingStrategy = {
    #Callback : {
      // start custom
      callback : shared () -> async ();
      // end custom
      token : HttpStreamingCallbackToken;
    };
  };

  public type HttpStreamingCallbackResponse = {
    body : Blob;
    token : ?HttpStreamingCallbackToken;
  };

  public type Dependencies = {
    _Assets : Assets.Factory;
    _Tokens : Tokens.Factory;
    _Marketplace : Marketplace.Factory;
    _Sale : Sale.Factory;
  };
};
