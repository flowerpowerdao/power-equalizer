import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

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
export interface Canister {
  'acceptCycles' : ActorMethod<[], undefined>,
  'addAsset' : ActorMethod<[Asset], bigint>,
  'airdropTokens' : ActorMethod<[bigint], undefined>,
  'allSettlements' : ActorMethod<[], Array<[TokenIndex, Settlement]>>,
  'availableCycles' : ActorMethod<[], bigint>,
  'balance' : ActorMethod<[BalanceRequest], BalanceResponse>,
  'bearer' : ActorMethod<[TokenIdentifier__3], Result_9>,
  'collectCanisterMetrics' : ActorMethod<[], undefined>,
  'cronDisbursements' : ActorMethod<[], undefined>,
  'cronFailedSales' : ActorMethod<[], undefined>,
  'cronSalesSettlements' : ActorMethod<[], undefined>,
  'cronSettlements' : ActorMethod<[], undefined>,
  'details' : ActorMethod<[TokenIdentifier__1], Result_8>,
  'extensions' : ActorMethod<[], Array<Extension>>,
  'failedSales' : ActorMethod<[], Array<[AccountIdentifier__4, SubAccount__2]>>,
  'getCanisterMetrics' : ActorMethod<
    [GetMetricsParameters],
    [] | [CanisterMetrics]
  >,
  'getMinter' : ActorMethod<[], Principal>,
  'getRegistry' : ActorMethod<[], Array<[TokenIndex__1, AccountIdentifier__2]>>,
  'getTokenToAssetMapping' : ActorMethod<[], Array<[TokenIndex__1, string]>>,
  'getTokens' : ActorMethod<[], Array<[TokenIndex__1, Metadata]>>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'http_request_streaming_callback' : ActorMethod<
    [HttpStreamingCallbackToken],
    HttpStreamingCallbackResponse
  >,
  'initCap' : ActorMethod<[], Result_4>,
  'initMint' : ActorMethod<[], Result_4>,
  'list' : ActorMethod<[ListRequest], Result_3>,
  'listings' : ActorMethod<[], Array<[TokenIndex, Listing, Metadata__1]>>,
  'lock' : ActorMethod<
    [TokenIdentifier__1, bigint, AccountIdentifier, SubAccount],
    Result_7
  >,
  'metadata' : ActorMethod<[TokenIdentifier__2], Result_6>,
  'pendingCronJobs' : ActorMethod<[], Array<bigint>>,
  'reserve' : ActorMethod<
    [bigint, bigint, AccountIdentifier__4, SubAccount__2],
    Result_5
  >,
  'retrieve' : ActorMethod<[AccountIdentifier__4], Result_4>,
  'saleTransactions' : ActorMethod<[], Array<SaleTransaction>>,
  'salesSettings' : ActorMethod<[AccountIdentifier__3], SaleSettings>,
  'salesSettlements' : ActorMethod<[], Array<[AccountIdentifier__4, Sale]>>,
  'setTotalToSell' : ActorMethod<[], bigint>,
  'settle' : ActorMethod<[TokenIdentifier__1], Result_3>,
  'settlements' : ActorMethod<
    [],
    Array<[TokenIndex, AccountIdentifier, bigint]>
  >,
  'shuffleAssets' : ActorMethod<[], undefined>,
  'shuffleTokensForSale' : ActorMethod<[], undefined>,
  'stats' : ActorMethod<
    [],
    [bigint, bigint, bigint, bigint, bigint, bigint, bigint]
  >,
  'streamAsset' : ActorMethod<[bigint, boolean, Uint8Array], undefined>,
  'supply' : ActorMethod<[], Result_2>,
  'toAddress' : ActorMethod<[string, bigint], AccountIdentifier__3>,
  'tokens' : ActorMethod<[AccountIdentifier__2], Result_1>,
  'tokens_ext' : ActorMethod<[AccountIdentifier__2], Result>,
  'transactions' : ActorMethod<[], Array<Transaction>>,
  'transfer' : ActorMethod<[TransferRequest], TransferResponse>,
  'updateThumb' : ActorMethod<[string, File], [] | [bigint]>,
  'viewDisbursements' : ActorMethod<
    [],
    Array<[TokenIndex, AccountIdentifier, SubAccount, bigint]>
  >,
}
export type CanisterCyclesAggregatedData = BigUint64Array;
export type CanisterHeapMemoryAggregatedData = BigUint64Array;
export type CanisterMemoryAggregatedData = BigUint64Array;
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
export interface File { 'data' : Array<Uint8Array>, 'ctype' : string }
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
  'body' : Uint8Array,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Uint8Array,
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [HttpStreamingStrategy],
  'status_code' : number,
}
export interface HttpStreamingCallbackResponse {
  'token' : [] | [HttpStreamingCallbackToken],
  'body' : Uint8Array,
}
export interface HttpStreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Uint8Array],
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
export type Memo = Uint8Array;
export type Metadata = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Uint8Array],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Uint8Array] } };
export type Metadata__1 = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Uint8Array],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Uint8Array] } };
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
    'ok' : Array<[TokenIndex__1, [] | [Listing], [] | [Uint8Array]]>
  } |
  { 'err' : CommonError };
export type Result_1 = { 'ok' : Uint32Array } |
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
  'tokens' : Uint32Array,
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
  'tokens' : Uint32Array,
  'buyer' : AccountIdentifier__4,
  'price' : bigint,
}
export interface Settlement {
  'subaccount' : SubAccount,
  'seller' : Principal,
  'buyer' : AccountIdentifier,
  'price' : bigint,
}
export type SubAccount = Uint8Array;
export type SubAccount__1 = Uint8Array;
export type SubAccount__2 = Uint8Array;
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
export type UpdateCallsAggregatedData = BigUint64Array;
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier__1 };
export interface _SERVICE extends Canister {}
