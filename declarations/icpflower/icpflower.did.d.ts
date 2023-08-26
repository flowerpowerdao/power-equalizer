import type { Principal } from '@dfinity/principal';
export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
export type AccountIdentifier__3 = string;
export type AccountIdentifier__4 = string;
export type AccountIdentifier__5 = string;
export interface Asset {
  'thumbnail' : [] | [File],
  'metadata' : [] | [File],
  'name' : string,
  'payload' : File,
}
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError__3 };
export type Balance__1 = bigint;
export type CanisterCyclesAggregatedData = Array<bigint>;
export type CanisterHeapMemoryAggregatedData = Array<bigint>;
export type CanisterMemoryAggregatedData = Array<bigint>;
export interface CanisterMetrics { 'data' : CanisterMetricsData }
export type CanisterMetricsData = { 'hourly' : Array<HourlyMetricsData> } |
  { 'daily' : Array<DailyMetricsData> };
export type CommonError = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
export type CommonError__1 = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
export type CommonError__2 = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
export type CommonError__3 = { 'InvalidToken' : TokenIdentifier } |
  { 'Other' : string };
export interface DailyMetricsData {
  'updateCalls' : bigint,
  'canisterHeapMemorySize' : NumericEntity,
  'canisterCycles' : NumericEntity,
  'canisterMemorySize' : NumericEntity,
  'timeMillis' : bigint,
}
export type Extension = string;
export interface File { 'data' : Array<Array<number>>, 'ctype' : string }
export interface GetMetricsParameters {
  'dateToMillis' : bigint,
  'granularity' : MetricsGranularity,
  'dateFromMillis' : bigint,
}
export type HeaderField = [string, string];
export interface HourlyMetricsData {
  'updateCalls' : UpdateCallsAggregatedData,
  'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
  'canisterCycles' : CanisterCyclesAggregatedData,
  'canisterMemorySize' : CanisterMemoryAggregatedData,
  'timeMillis' : bigint,
}
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [HttpStreamingStrategy],
  'status_code' : number,
}
export interface HttpStreamingCallbackResponse {
  'token' : [] | [HttpStreamingCallbackToken],
  'body' : Array<number>,
}
export interface HttpStreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Array<number>],
  'index' : bigint,
  'content_encoding' : string,
}
export type HttpStreamingStrategy = {
    'Callback' : {
      'token' : HttpStreamingCallbackToken,
      'callback' : [Principal, string],
    }
  };
export interface ListRequest {
  'token' : TokenIdentifier__1,
  'from_subaccount' : [] | [SubAccount],
  'price' : [] | [bigint],
}
export interface Listing {
  'locked' : [] | [Time],
  'seller' : Principal,
  'price' : bigint,
}
export type Memo = Array<number>;
export type Metadata = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Array<number>],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Array<number>] } };
export type Metadata__1 = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Array<number>],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Array<number>] } };
export type MetricsGranularity = { 'hourly' : null } |
  { 'daily' : null };
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export type Result = {
    'ok' : Array<[TokenIndex__1, [] | [Listing], [] | [Array<number>]]>
  } |
  { 'err' : CommonError };
export type Result_1 = { 'ok' : Array<TokenIndex__1> } |
  { 'err' : CommonError };
export type Result_2 = { 'ok' : Balance__1 } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : null } |
  { 'err' : CommonError__1 };
export type Result_4 = { 'ok' : null } |
  { 'err' : string };
export type Result_5 = { 'ok' : [AccountIdentifier__4, bigint] } |
  { 'err' : string };
export type Result_6 = { 'ok' : Metadata } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : AccountIdentifier } |
  { 'err' : CommonError__1 };
export type Result_8 = { 'ok' : [AccountIdentifier, [] | [Listing]] } |
  { 'err' : CommonError__1 };
export type Result_9 = { 'ok' : AccountIdentifier__5 } |
  { 'err' : CommonError__2 };
export interface Sale {
  'expires' : Time__1,
  'subaccount' : SubAccount__2,
  'tokens' : Array<TokenIndex__2>,
  'buyer' : AccountIdentifier__4,
  'price' : bigint,
}
export interface SaleSettings {
  'startTime' : Time__1,
  'whitelist' : boolean,
  'totalToSell' : bigint,
  'sold' : bigint,
  'bulkPricing' : Array<[bigint, bigint]>,
  'whitelistTime' : Time__1,
  'salePrice' : bigint,
  'remaining' : bigint,
  'price' : bigint,
}
export interface SaleTransaction {
  'time' : Time__1,
  'seller' : Principal,
  'tokens' : Array<TokenIndex__2>,
  'buyer' : AccountIdentifier__4,
  'price' : bigint,
}
export interface Settlement {
  'subaccount' : SubAccount,
  'seller' : Principal,
  'buyer' : AccountIdentifier,
  'price' : bigint,
}
export type SubAccount = Array<number>;
export type SubAccount__1 = Array<number>;
export type SubAccount__2 = Array<number>;
export type Time = bigint;
export type Time__1 = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIdentifier__3 = string;
export type TokenIndex = number;
export type TokenIndex__1 = number;
export type TokenIndex__2 = number;
export interface Transaction {
  'token' : TokenIdentifier__1,
  'time' : Time,
  'seller' : Principal,
  'buyer' : AccountIdentifier,
  'price' : bigint,
}
export interface TransferRequest {
  'to' : User,
  'token' : TokenIdentifier,
  'notify' : boolean,
  'from' : User,
  'memo' : Memo,
  'subaccount' : [] | [SubAccount__1],
  'amount' : Balance,
}
export type TransferResponse = { 'ok' : Balance } |
  {
    'err' : { 'CannotNotify' : AccountIdentifier__1 } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier__1 } |
      { 'Other' : string }
  };
export type UpdateCallsAggregatedData = Array<bigint>;
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier__1 };
export interface _SERVICE {
  'acceptCycles' : () => Promise<undefined>,
  'addAsset' : (arg_0: Asset) => Promise<bigint>,
  'airdropTokens' : (arg_0: bigint) => Promise<undefined>,
  'allSettlements' : () => Promise<Array<[TokenIndex, Settlement]>>,
  'availableCycles' : () => Promise<bigint>,
  'balance' : (arg_0: BalanceRequest) => Promise<BalanceResponse>,
  'bearer' : (arg_0: TokenIdentifier__3) => Promise<Result_9>,
  'collectCanisterMetrics' : () => Promise<undefined>,
  'cronDisbursements' : () => Promise<undefined>,
  'cronFailedSales' : () => Promise<undefined>,
  'cronSalesSettlements' : () => Promise<undefined>,
  'cronSettlements' : () => Promise<undefined>,
  'details' : (arg_0: TokenIdentifier__1) => Promise<Result_8>,
  'extensions' : () => Promise<Array<Extension>>,
  'failedSales' : () => Promise<Array<[AccountIdentifier__4, SubAccount__2]>>,
  'getCanisterMetrics' : (arg_0: GetMetricsParameters) => Promise<
      [] | [CanisterMetrics]
    >,
  'getMinter' : () => Promise<Principal>,
  'getRegistry' : () => Promise<Array<[TokenIndex__1, AccountIdentifier__2]>>,
  'getTokenToAssetMapping' : () => Promise<Array<[TokenIndex__1, string]>>,
  'getTokens' : () => Promise<Array<[TokenIndex__1, Metadata]>>,
  'http_request' : (arg_0: HttpRequest) => Promise<HttpResponse>,
  'http_request_streaming_callback' : (
      arg_0: HttpStreamingCallbackToken,
    ) => Promise<HttpStreamingCallbackResponse>,
  'initCap' : () => Promise<Result_4>,
  'initMint' : () => Promise<undefined>,
  'list' : (arg_0: ListRequest) => Promise<Result_3>,
  'listings' : () => Promise<Array<[TokenIndex, Listing, Metadata__1]>>,
  'lock' : (
      arg_0: TokenIdentifier__1,
      arg_1: bigint,
      arg_2: AccountIdentifier,
      arg_3: SubAccount,
    ) => Promise<Result_7>,
  'metadata' : (arg_0: TokenIdentifier__2) => Promise<Result_6>,
  'pendingCronJobs' : () => Promise<Array<bigint>>,
  'reserve' : (
      arg_0: bigint,
      arg_1: bigint,
      arg_2: AccountIdentifier__4,
      arg_3: SubAccount__2,
    ) => Promise<Result_5>,
  'retreive' : (arg_0: AccountIdentifier__4) => Promise<Result_4>,
  'saleTransactions' : () => Promise<Array<SaleTransaction>>,
  'salesSettings' : (arg_0: AccountIdentifier__3) => Promise<SaleSettings>,
  'salesSettlements' : () => Promise<Array<[AccountIdentifier__4, Sale]>>,
  'setTotalToSell' : () => Promise<bigint>,
  'settle' : (arg_0: TokenIdentifier__1) => Promise<Result_3>,
  'settlements' : () => Promise<Array<[TokenIndex, AccountIdentifier, bigint]>>,
  'shuffleAssets' : () => Promise<undefined>,
  'shuffleTokensForSale' : () => Promise<undefined>,
  'stats' : () => Promise<
      [bigint, bigint, bigint, bigint, bigint, bigint, bigint]
    >,
  'streamAsset' : (
      arg_0: bigint,
      arg_1: boolean,
      arg_2: Array<number>,
    ) => Promise<undefined>,
  'supply' : () => Promise<Result_2>,
  'toAddress' : (arg_0: string, arg_1: bigint) => Promise<AccountIdentifier__3>,
  'tokens' : (arg_0: AccountIdentifier__2) => Promise<Result_1>,
  'tokens_ext' : (arg_0: AccountIdentifier__2) => Promise<Result>,
  'transactions' : () => Promise<Array<Transaction>>,
  'transfer' : (arg_0: TransferRequest) => Promise<TransferResponse>,
  'updateThumb' : (arg_0: string, arg_1: File) => Promise<[] | [bigint]>,
  'viewDisbursements' : () => Promise<
      Array<[TokenIndex, AccountIdentifier, SubAccount, bigint]>
    >,
}