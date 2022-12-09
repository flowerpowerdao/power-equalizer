export const idlFactory = ({ IDL }) => {
  const File = IDL.Record({
    'data' : IDL.Vec(IDL.Vec(IDL.Nat8)),
    'ctype' : IDL.Text,
  });
  const Asset = IDL.Record({
    'thumbnail' : IDL.Opt(File),
    'metadata' : IDL.Opt(File),
    'name' : IDL.Text,
    'payload' : File,
  });
  const TokenIndex = IDL.Nat32;
  const SubAccount = IDL.Vec(IDL.Nat8);
  const AccountIdentifier = IDL.Text;
  const Settlement = IDL.Record({
    'subaccount' : SubAccount,
    'seller' : IDL.Principal,
    'buyer' : AccountIdentifier,
    'price' : IDL.Nat64,
  });
  const TokenIdentifier = IDL.Text;
  const AccountIdentifier__1 = IDL.Text;
  const User = IDL.Variant({
    'principal' : IDL.Principal,
    'address' : AccountIdentifier__1,
  });
  const BalanceRequest = IDL.Record({
    'token' : TokenIdentifier,
    'user' : User,
  });
  const Balance = IDL.Nat;
  const CommonError__3 = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const BalanceResponse = IDL.Variant({
    'ok' : Balance,
    'err' : CommonError__3,
  });
  const TokenIdentifier__3 = IDL.Text;
  const AccountIdentifier__5 = IDL.Text;
  const CommonError__2 = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const Result_9 = IDL.Variant({
    'ok' : AccountIdentifier__5,
    'err' : CommonError__2,
  });
  const TokenIdentifier__1 = IDL.Text;
  const Time = IDL.Int;
  const Listing = IDL.Record({
    'locked' : IDL.Opt(Time),
    'seller' : IDL.Principal,
    'price' : IDL.Nat64,
  });
  const CommonError__1 = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const Result_8 = IDL.Variant({
    'ok' : IDL.Tuple(AccountIdentifier, IDL.Opt(Listing)),
    'err' : CommonError__1,
  });
  const Extension = IDL.Text;
  const AccountIdentifier__4 = IDL.Text;
  const SubAccount__2 = IDL.Vec(IDL.Nat8);
  const MetricsGranularity = IDL.Variant({
    'hourly' : IDL.Null,
    'daily' : IDL.Null,
  });
  const GetMetricsParameters = IDL.Record({
    'dateToMillis' : IDL.Nat,
    'granularity' : MetricsGranularity,
    'dateFromMillis' : IDL.Nat,
  });
  const UpdateCallsAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterHeapMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterCyclesAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const HourlyMetricsData = IDL.Record({
    'updateCalls' : UpdateCallsAggregatedData,
    'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
    'canisterCycles' : CanisterCyclesAggregatedData,
    'canisterMemorySize' : CanisterMemoryAggregatedData,
    'timeMillis' : IDL.Int,
  });
  const NumericEntity = IDL.Record({
    'avg' : IDL.Nat64,
    'max' : IDL.Nat64,
    'min' : IDL.Nat64,
    'first' : IDL.Nat64,
    'last' : IDL.Nat64,
  });
  const DailyMetricsData = IDL.Record({
    'updateCalls' : IDL.Nat64,
    'canisterHeapMemorySize' : NumericEntity,
    'canisterCycles' : NumericEntity,
    'canisterMemorySize' : NumericEntity,
    'timeMillis' : IDL.Int,
  });
  const CanisterMetricsData = IDL.Variant({
    'hourly' : IDL.Vec(HourlyMetricsData),
    'daily' : IDL.Vec(DailyMetricsData),
  });
  const CanisterMetrics = IDL.Record({ 'data' : CanisterMetricsData });
  const TokenIndex__1 = IDL.Nat32;
  const AccountIdentifier__2 = IDL.Text;
  const Metadata = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const HttpStreamingCallbackToken = IDL.Record({
    'key' : IDL.Text,
    'sha256' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'index' : IDL.Nat,
    'content_encoding' : IDL.Text,
  });
  const HttpStreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : HttpStreamingCallbackToken,
      'callback' : IDL.Func([], [], []),
    }),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(HttpStreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const HttpStreamingCallbackResponse = IDL.Record({
    'token' : IDL.Opt(HttpStreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const Result_4 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const ListRequest = IDL.Record({
    'token' : TokenIdentifier__1,
    'from_subaccount' : IDL.Opt(SubAccount),
    'price' : IDL.Opt(IDL.Nat64),
  });
  const Result_3 = IDL.Variant({ 'ok' : IDL.Null, 'err' : CommonError__1 });
  const Metadata__1 = IDL.Variant({
    'fungible' : IDL.Record({
      'decimals' : IDL.Nat8,
      'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'name' : IDL.Text,
      'symbol' : IDL.Text,
    }),
    'nonfungible' : IDL.Record({ 'metadata' : IDL.Opt(IDL.Vec(IDL.Nat8)) }),
  });
  const Result_7 = IDL.Variant({
    'ok' : AccountIdentifier,
    'err' : CommonError__1,
  });
  const TokenIdentifier__2 = IDL.Text;
  const CommonError = IDL.Variant({
    'InvalidToken' : TokenIdentifier,
    'Other' : IDL.Text,
  });
  const Result_6 = IDL.Variant({ 'ok' : Metadata, 'err' : CommonError });
  const Result_5 = IDL.Variant({
    'ok' : IDL.Tuple(AccountIdentifier__4, IDL.Nat64),
    'err' : IDL.Text,
  });
  const Time__1 = IDL.Int;
  const TokenIndex__2 = IDL.Nat32;
  const SaleTransaction = IDL.Record({
    'time' : Time__1,
    'seller' : IDL.Principal,
    'tokens' : IDL.Vec(TokenIndex__2),
    'buyer' : AccountIdentifier__4,
    'price' : IDL.Nat64,
  });
  const AccountIdentifier__3 = IDL.Text;
  const SaleSettings = IDL.Record({
    'startTime' : Time__1,
    'whitelist' : IDL.Bool,
    'totalToSell' : IDL.Nat,
    'sold' : IDL.Nat,
    'bulkPricing' : IDL.Vec(IDL.Tuple(IDL.Nat64, IDL.Nat64)),
    'whitelistTime' : Time__1,
    'salePrice' : IDL.Nat64,
    'remaining' : IDL.Nat,
    'price' : IDL.Nat64,
  });
  const Sale = IDL.Record({
    'expires' : Time__1,
    'subaccount' : SubAccount__2,
    'tokens' : IDL.Vec(TokenIndex__2),
    'buyer' : AccountIdentifier__4,
    'price' : IDL.Nat64,
  });
  const Balance__1 = IDL.Nat;
  const Result_2 = IDL.Variant({ 'ok' : Balance__1, 'err' : CommonError });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Vec(TokenIndex__1),
    'err' : CommonError,
  });
  const Result = IDL.Variant({
    'ok' : IDL.Vec(
      IDL.Tuple(TokenIndex__1, IDL.Opt(Listing), IDL.Opt(IDL.Vec(IDL.Nat8)))
    ),
    'err' : CommonError,
  });
  const Transaction = IDL.Record({
    'token' : TokenIdentifier__1,
    'time' : Time,
    'seller' : IDL.Principal,
    'buyer' : AccountIdentifier,
    'price' : IDL.Nat64,
  });
  const Memo = IDL.Vec(IDL.Nat8);
  const SubAccount__1 = IDL.Vec(IDL.Nat8);
  const TransferRequest = IDL.Record({
    'to' : User,
    'token' : TokenIdentifier,
    'notify' : IDL.Bool,
    'from' : User,
    'memo' : Memo,
    'subaccount' : IDL.Opt(SubAccount__1),
    'amount' : Balance,
  });
  const TransferResponse = IDL.Variant({
    'ok' : Balance,
    'err' : IDL.Variant({
      'CannotNotify' : AccountIdentifier__1,
      'InsufficientBalance' : IDL.Null,
      'InvalidToken' : TokenIdentifier,
      'Rejected' : IDL.Null,
      'Unauthorized' : AccountIdentifier__1,
      'Other' : IDL.Text,
    }),
  });
  const Canister = IDL.Service({
    'acceptCycles' : IDL.Func([], [], []),
    'addAsset' : IDL.Func([Asset], [IDL.Nat], []),
    'airdropTokens' : IDL.Func([IDL.Nat], [], []),
    'allSettlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Settlement))],
        ['query'],
      ),
    'availableCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'balance' : IDL.Func([BalanceRequest], [BalanceResponse], ['query']),
    'bearer' : IDL.Func([TokenIdentifier__3], [Result_9], ['query']),
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'cronDisbursements' : IDL.Func([], [], []),
    'cronFailedSales' : IDL.Func([], [], []),
    'cronSalesSettlements' : IDL.Func([], [], []),
    'cronSettlements' : IDL.Func([], [], []),
    'details' : IDL.Func([TokenIdentifier__1], [Result_8], ['query']),
    'extensions' : IDL.Func([], [IDL.Vec(Extension)], ['query']),
    'failedSales' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(AccountIdentifier__4, SubAccount__2))],
        ['query'],
      ),
    'getCanisterMetrics' : IDL.Func(
        [GetMetricsParameters],
        [IDL.Opt(CanisterMetrics)],
        ['query'],
      ),
    'getMinter' : IDL.Func([], [IDL.Principal], ['query']),
    'getRegistry' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex__1, AccountIdentifier__2))],
        ['query'],
      ),
    'getTokenToAssetMapping' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex__1, IDL.Text))],
        ['query'],
      ),
    'getTokens' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex__1, Metadata))],
        ['query'],
      ),
    'http_request' : IDL.Func([HttpRequest], [HttpResponse], ['query']),
    'http_request_streaming_callback' : IDL.Func(
        [HttpStreamingCallbackToken],
        [HttpStreamingCallbackResponse],
        ['query'],
      ),
    'initCap' : IDL.Func([], [Result_4], []),
    'initMint' : IDL.Func([], [Result_4], []),
    'list' : IDL.Func([ListRequest], [Result_3], []),
    'listings' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, Listing, Metadata__1))],
        ['query'],
      ),
    'lock' : IDL.Func(
        [TokenIdentifier__1, IDL.Nat64, AccountIdentifier, SubAccount],
        [Result_7],
        [],
      ),
    'metadata' : IDL.Func([TokenIdentifier__2], [Result_6], ['query']),
    'pendingCronJobs' : IDL.Func([], [IDL.Vec(IDL.Nat)], ['query']),
    'reserve' : IDL.Func(
        [IDL.Nat64, IDL.Nat64, AccountIdentifier__4, SubAccount__2],
        [Result_5],
        [],
      ),
    'retreive' : IDL.Func([AccountIdentifier__4], [Result_4], []),
    'saleTransactions' : IDL.Func([], [IDL.Vec(SaleTransaction)], ['query']),
    'salesSettings' : IDL.Func(
        [AccountIdentifier__3],
        [SaleSettings],
        ['query'],
      ),
    'salesSettlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(AccountIdentifier__4, Sale))],
        ['query'],
      ),
    'setTotalToSell' : IDL.Func([], [IDL.Nat], []),
    'settle' : IDL.Func([TokenIdentifier__1], [Result_3], []),
    'settlements' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(TokenIndex, AccountIdentifier, IDL.Nat64))],
        ['query'],
      ),
    'shuffleAssets' : IDL.Func([], [], []),
    'shuffleTokensForSale' : IDL.Func([], [], []),
    'stats' : IDL.Func(
        [],
        [IDL.Nat64, IDL.Nat64, IDL.Nat64, IDL.Nat64, IDL.Nat, IDL.Nat, IDL.Nat],
        ['query'],
      ),
    'streamAsset' : IDL.Func([IDL.Nat, IDL.Bool, IDL.Vec(IDL.Nat8)], [], []),
    'supply' : IDL.Func([], [Result_2], ['query']),
    'toAddress' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [AccountIdentifier__3],
        ['query'],
      ),
    'tokens' : IDL.Func([AccountIdentifier__2], [Result_1], ['query']),
    'tokens_ext' : IDL.Func([AccountIdentifier__2], [Result], ['query']),
    'transactions' : IDL.Func([], [IDL.Vec(Transaction)], ['query']),
    'transfer' : IDL.Func([TransferRequest], [TransferResponse], []),
    'updateThumb' : IDL.Func([IDL.Text, File], [IDL.Opt(IDL.Nat)], []),
    'viewDisbursements' : IDL.Func(
        [],
        [
          IDL.Vec(
            IDL.Tuple(TokenIndex, AccountIdentifier, SubAccount, IDL.Nat64)
          ),
        ],
        ['query'],
      ),
  });
  return Canister;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };
