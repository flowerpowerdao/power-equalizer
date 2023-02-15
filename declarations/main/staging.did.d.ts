import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
export type AccountIdentifier__3 = string;
export type AccountIdentifier__4 = string;
export type AccountIdentifier__5 = string;
export type AccountIdentifier__6 = string;
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
  'allSettlements' : ActorMethod<[], Array<[TokenIndex__1, Settlement]>>,
  'availableCycles' : ActorMethod<[], bigint>,
  'balance' : ActorMethod<[BalanceRequest], BalanceResponse>,
  'bearer' : ActorMethod<[TokenIdentifier__3], Result_9>,
  'cronDisbursements' : ActorMethod<[], undefined>,
  'cronFailedSales' : ActorMethod<[], undefined>,
  'cronSalesSettlements' : ActorMethod<[], undefined>,
  'cronSettlements' : ActorMethod<[], undefined>,
  'deleteFrontend' : ActorMethod<[string], undefined>,
  'details' : ActorMethod<[TokenIdentifier__1], Result_8>,
  'enableSale' : ActorMethod<[], bigint>,
  'extensions' : ActorMethod<[], Array<Extension>>,
  'failedSales' : ActorMethod<[], Array<[AccountIdentifier__4, SubAccount__1]>>,
  'frontends' : ActorMethod<[], Array<[string, Frontend]>>,
  'getCanistergeekInformation' : ActorMethod<
    [GetInformationRequest],
    GetInformationResponse
  >,
  'getDisbursements' : ActorMethod<[], Array<Disbursement>>,
  'getMinter' : ActorMethod<[], Principal>,
  'getRegistry' : ActorMethod<[], Array<[TokenIndex, AccountIdentifier__2]>>,
  'getTokenToAssetMapping' : ActorMethod<[], Array<[TokenIndex, string]>>,
  'getTokens' : ActorMethod<[], Array<[TokenIndex, Metadata]>>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'http_request_streaming_callback' : ActorMethod<
    [HttpStreamingCallbackToken],
    HttpStreamingCallbackResponse
  >,
  'initCap' : ActorMethod<[], Result_4>,
  'initMint' : ActorMethod<[], Result_4>,
  'list' : ActorMethod<[ListRequest], Result_3>,
  'listings' : ActorMethod<[], Array<[TokenIndex__1, Listing, Metadata__1]>>,
  'lock' : ActorMethod<
    [
      TokenIdentifier__1,
      bigint,
      AccountIdentifier__1,
      SubAccount__2,
      [] | [string],
    ],
    Result_7
  >,
  'metadata' : ActorMethod<[TokenIdentifier__2], Result_6>,
  'pendingCronJobs' : ActorMethod<
    [],
    { 'failedSettlements' : bigint, 'disbursements' : bigint }
  >,
  'putFrontend' : ActorMethod<[string, Frontend], undefined>,
  'reserve' : ActorMethod<
    [bigint, bigint, AccountIdentifier__4, SubAccount__1],
    Result_5
  >,
  'retrieve' : ActorMethod<[AccountIdentifier__4], Result_4>,
  'saleTransactions' : ActorMethod<[], Array<SaleTransaction>>,
  'salesSettings' : ActorMethod<[AccountIdentifier__3], SaleSettings>,
  'salesSettlements' : ActorMethod<[], Array<[AccountIdentifier__4, Sale]>>,
  'settle' : ActorMethod<[TokenIdentifier__1], Result_3>,
  'settlements' : ActorMethod<
    [],
    Array<[TokenIndex__1, AccountIdentifier__1, bigint]>
  >,
  'shuffleAssets' : ActorMethod<[], undefined>,
  'shuffleTokensForSale' : ActorMethod<[], undefined>,
  'stats' : ActorMethod<
    [],
    [bigint, bigint, bigint, bigint, bigint, bigint, bigint]
  >,
  'streamAsset' : ActorMethod<[bigint, boolean, Uint8Array], undefined>,
  'supply' : ActorMethod<[], Result_2>,
  'toAccountIdentifier' : ActorMethod<[string, bigint], AccountIdentifier__3>,
  'tokens' : ActorMethod<[AccountIdentifier__2], Result_1>,
  'tokens_ext' : ActorMethod<[AccountIdentifier__2], Result>,
  'transactions' : ActorMethod<[], Array<Transaction>>,
  'transfer' : ActorMethod<[TransferRequest], TransferResponse>,
  'updateCanistergeekInformation' : ActorMethod<
    [UpdateInformationRequest],
    undefined
  >,
  'updateThumb' : ActorMethod<[string, File], [] | [bigint]>,
}
export type CanisterCyclesAggregatedData = BigUint64Array;
export type CanisterHeapMemoryAggregatedData = BigUint64Array;
export type CanisterLogFeature = { 'filterMessageByContains' : null } |
  { 'filterMessageByRegex' : null };
export interface CanisterLogMessages {
  'data' : Array<LogMessagesData>,
  'lastAnalyzedMessageTimeNanos' : [] | [Nanos],
}
export interface CanisterLogMessagesInfo {
  'features' : Array<[] | [CanisterLogFeature]>,
  'lastTimeNanos' : [] | [Nanos],
  'count' : number,
  'firstTimeNanos' : [] | [Nanos],
}
export type CanisterLogRequest = { 'getMessagesInfo' : null } |
  { 'getMessages' : GetLogMessagesParameters } |
  { 'getLatestMessages' : GetLatestLogMessagesParameters };
export type CanisterLogResponse = { 'messagesInfo' : CanisterLogMessagesInfo } |
  { 'messages' : CanisterLogMessages };
export type CanisterMemoryAggregatedData = BigUint64Array;
export interface CanisterMetrics { 'data' : CanisterMetricsData }
export type CanisterMetricsData = { 'hourly' : Array<HourlyMetricsData> } |
  { 'daily' : Array<DailyMetricsData> };
export type CollectMetricsRequestType = { 'force' : null } |
  { 'normal' : null };
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
export interface Disbursement {
  'to' : AccountIdentifier__5,
  'tokenIndex' : TokenIndex__3,
  'fromSubaccount' : SubAccount__3,
  'amount' : bigint,
}
export type Extension = string;
export interface File { 'data' : Array<Uint8Array>, 'ctype' : string }
export interface Frontend {
  'fee' : bigint,
  'accountIdentifier' : AccountIdentifier__1,
}
export interface GetInformationRequest {
  'status' : [] | [StatusRequest],
  'metrics' : [] | [MetricsRequest],
  'logs' : [] | [CanisterLogRequest],
  'version' : boolean,
}
export interface GetInformationResponse {
  'status' : [] | [StatusResponse],
  'metrics' : [] | [MetricsResponse],
  'logs' : [] | [CanisterLogResponse],
  'version' : [] | [bigint],
}
export interface GetLatestLogMessagesParameters {
  'upToTimeNanos' : [] | [Nanos],
  'count' : number,
  'filter' : [] | [GetLogMessagesFilter],
}
export interface GetLogMessagesFilter {
  'analyzeCount' : number,
  'messageRegex' : [] | [string],
  'messageContains' : [] | [string],
}
export interface GetLogMessagesParameters {
  'count' : number,
  'filter' : [] | [GetLogMessagesFilter],
  'fromTimeNanos' : [] | [Nanos],
}
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
  'frontendIdentifier' : [] | [string],
  'from_subaccount' : [] | [SubAccount__2],
  'price' : [] | [bigint],
}
export interface Listing {
  'sellerFrontend' : [] | [string],
  'locked' : [] | [Time],
  'seller' : Principal,
  'buyerFrontend' : [] | [string],
  'price' : bigint,
}
export interface LogMessagesData { 'timeNanos' : Nanos, 'message' : string }
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
export interface MetricsRequest { 'parameters' : GetMetricsParameters }
export interface MetricsResponse { 'metrics' : [] | [CanisterMetrics] }
export type Nanos = bigint;
export interface NumericEntity {
  'avg' : bigint,
  'max' : bigint,
  'min' : bigint,
  'first' : bigint,
  'last' : bigint,
}
export type Result = {
    'ok' : Array<[TokenIndex, [] | [Listing], [] | [Uint8Array]]>
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
export type Result_7 = { 'ok' : AccountIdentifier__1 } |
  { 'err' : CommonError__1 };
export type Result_8 = { 'ok' : [AccountIdentifier__1, [] | [Listing]] } |
  { 'err' : CommonError__1 };
export type Result_9 = { 'ok' : AccountIdentifier__6 } |
  { 'err' : CommonError__2 };
export interface Sale {
  'expires' : Time__1,
  'subaccount' : SubAccount__1,
  'tokens' : Uint32Array,
  'buyer' : AccountIdentifier__4,
  'price' : bigint,
  'whitelisted' : boolean,
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
  'sellerFrontend' : [] | [string],
  'subaccount' : SubAccount__2,
  'seller' : Principal,
  'buyerFrontend' : [] | [string],
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
export interface StatusRequest {
  'memory_size' : boolean,
  'cycles' : boolean,
  'heap_memory_size' : boolean,
}
export interface StatusResponse {
  'memory_size' : [] | [bigint],
  'cycles' : [] | [bigint],
  'heap_memory_size' : [] | [bigint],
}
export type SubAccount = Uint8Array;
export type SubAccount__1 = Uint8Array;
export type SubAccount__2 = Uint8Array;
export type SubAccount__3 = Uint8Array;
export type Time = bigint;
export type Time__1 = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIdentifier__3 = string;
export type TokenIndex = number;
export type TokenIndex__1 = number;
export type TokenIndex__2 = number;
export type TokenIndex__3 = number;
export interface Transaction {
  'token' : TokenIdentifier__1,
  'time' : Time,
  'seller' : Principal,
  'buyer' : AccountIdentifier__1,
  'price' : bigint,
}
export interface TransferRequest {
  'to' : User,
  'token' : TokenIdentifier,
  'notify' : boolean,
  'from' : User,
  'memo' : Memo,
  'subaccount' : [] | [SubAccount],
  'amount' : Balance,
}
export type TransferResponse = { 'ok' : Balance } |
  {
    'err' : { 'CannotNotify' : AccountIdentifier } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier } |
      { 'Other' : string }
  };
export type UpdateCallsAggregatedData = BigUint64Array;
export interface UpdateInformationRequest {
  'metrics' : [] | [CollectMetricsRequestType],
}
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier };
export interface _SERVICE extends Canister {}
