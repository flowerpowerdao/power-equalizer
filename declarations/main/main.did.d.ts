import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AccountIdentifier = string;
export type AccountIdentifier__1 = string;
export type AccountIdentifier__2 = string;
export type AccountIdentifier__3 = string;
export type AccountIdentifier__4 = string;
export type AccountIdentifier__5 = string;
export type AccountIdentifier__6 = string;
export type AccountIdentifier__7 = string;
export interface Asset {
  'thumbnail' : [] | [File],
  'metadata' : [] | [File],
  'name' : string,
  'payload' : File,
}
export interface AssetV2 {
  'thumbnail' : [] | [File],
  'payloadUrl' : [] | [string],
  'thumbnailUrl' : [] | [string],
  'metadata' : [] | [File],
  'name' : string,
  'payload' : File,
}
export type Balance = bigint;
export interface BalanceRequest { 'token' : TokenIdentifier, 'user' : User }
export type BalanceResponse = { 'ok' : Balance } |
  { 'err' : CommonError__3 };
export type Balance__1 = bigint;
export type Balance__2 = bigint;
export interface Canister {
  'acceptCycles' : ActorMethod<[], undefined>,
  'addAsset' : ActorMethod<[AssetV2], bigint>,
  'addAssets' : ActorMethod<[Array<AssetV2>], bigint>,
  'addPlaceholder' : ActorMethod<[AssetV2], undefined>,
  'airdropTokens' : ActorMethod<[], undefined>,
  'allSettlements' : ActorMethod<[], Array<[TokenIndex__1, Settlement]>>,
  'availableCycles' : ActorMethod<[], bigint>,
  'backupChunk' : ActorMethod<[bigint, bigint], StableChunk>,
  'balance' : ActorMethod<[BalanceRequest], BalanceResponse>,
  'bearer' : ActorMethod<[TokenIdentifier__3], Result_9>,
  'cronDisbursements' : ActorMethod<[], undefined>,
  'cronFailedSales' : ActorMethod<[], undefined>,
  'cronSalesSettlements' : ActorMethod<[], undefined>,
  'cronSettlements' : ActorMethod<[], undefined>,
  'details' : ActorMethod<[TokenIdentifier__1], Result_8>,
  'enableSale' : ActorMethod<[], bigint>,
  'extensions' : ActorMethod<[], Array<Extension>>,
  'failedSales' : ActorMethod<[], Array<[AccountIdentifier__5, SubAccount__1]>>,
  'frontends' : ActorMethod<[], Array<[string, Frontend]>>,
  'getCanistergeekInformation' : ActorMethod<
    [GetInformationRequest],
    GetInformationResponse
  >,
  'getChunkCount' : ActorMethod<[bigint], bigint>,
  'getDisbursements' : ActorMethod<[], Array<Disbursement>>,
  'getMinter' : ActorMethod<[], Principal>,
  'getRegistry' : ActorMethod<[], Array<[TokenIndex, AccountIdentifier__3]>>,
  'getTokenToAssetMapping' : ActorMethod<[], Array<[TokenIndex, string]>>,
  'getTokens' : ActorMethod<[], Array<[TokenIndex, Metadata__1]>>,
  'grow' : ActorMethod<[bigint], bigint>,
  'http_request' : ActorMethod<[HttpRequest], HttpResponse>,
  'http_request_streaming_callback' : ActorMethod<
    [HttpStreamingCallbackToken],
    HttpStreamingCallbackResponse
  >,
  'initCap' : ActorMethod<[], Result_4>,
  'initMint' : ActorMethod<[], Result_4>,
  'list' : ActorMethod<[ListRequest], Result_3>,
  'listings' : ActorMethod<[], Array<[TokenIndex__1, Listing, Metadata__2]>>,
  'lock' : ActorMethod<
    [
      TokenIdentifier__1,
      bigint,
      AccountIdentifier__2,
      SubAccount__3,
      [] | [string],
    ],
    Result_7
  >,
  'metadata' : ActorMethod<[TokenIdentifier__2], Result_6>,
  'pendingCronJobs' : ActorMethod<
    [],
    { 'failedSettlements' : bigint, 'disbursements' : bigint }
  >,
  'reserve' : ActorMethod<
    [bigint, bigint, AccountIdentifier__5, SubAccount__1],
    Result_5
  >,
  'restoreChunk' : ActorMethod<[StableChunk], undefined>,
  'retrieve' : ActorMethod<[AccountIdentifier__5], Result_4>,
  'saleTransactions' : ActorMethod<[], Array<SaleTransaction>>,
  'salesSettings' : ActorMethod<[AccountIdentifier__4], SaleSettings>,
  'salesSettlements' : ActorMethod<[], Array<[AccountIdentifier__5, Sale]>>,
  'settle' : ActorMethod<[TokenIdentifier__1], Result_3>,
  'settlements' : ActorMethod<
    [],
    Array<[TokenIndex__1, AccountIdentifier__2, bigint]>
  >,
  'shuffleTokensForSale' : ActorMethod<[], undefined>,
  'stats' : ActorMethod<
    [],
    [bigint, bigint, bigint, bigint, bigint, bigint, bigint]
  >,
  'streamAsset' : ActorMethod<
    [bigint, boolean, Uint8Array | number[]],
    undefined
  >,
  'supply' : ActorMethod<[], Result_2>,
  'toAccountIdentifier' : ActorMethod<[string, bigint], AccountIdentifier__4>,
  'tokens' : ActorMethod<[AccountIdentifier__3], Result_1>,
  'tokens_ext' : ActorMethod<[AccountIdentifier__3], Result>,
  'transactions' : ActorMethod<[], Array<Transaction>>,
  'transfer' : ActorMethod<[TransferRequest], TransferResponse>,
  'updateCanistergeekInformation' : ActorMethod<
    [UpdateInformationRequest],
    undefined
  >,
  'updateThumb' : ActorMethod<[string, File], [] | [bigint]>,
}
export type CanisterCyclesAggregatedData = BigUint64Array | bigint[];
export type CanisterHeapMemoryAggregatedData = BigUint64Array | bigint[];
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
export type CanisterMemoryAggregatedData = BigUint64Array | bigint[];
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
  'to' : AccountIdentifier__6,
  'tokenIndex' : TokenIndex__3,
  'fromSubaccount' : SubAccount__2,
  'amount' : bigint,
}
export type Duration = { 'nanoseconds' : bigint } |
  { 'hours' : bigint } |
  { 'days' : bigint } |
  { 'none' : null } |
  { 'minutes' : bigint } |
  { 'seconds' : bigint };
export interface DutchAuction {
  'reservePrice' : bigint,
  'interval' : Time,
  'intervalPriceDrop' : bigint,
  'target' : { 'everyone' : null } |
    { 'whitelist' : null } |
    { 'publicSale' : null },
  'startPrice' : bigint,
}
export type Extension = string;
export interface File {
  'data' : Array<Uint8Array | number[]>,
  'ctype' : string,
}
export interface Frontend {
  'fee' : bigint,
  'accountIdentifier' : AccountIdentifier__2,
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
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Uint8Array | number[],
  'headers' : Array<HeaderField>,
  'streaming_strategy' : [] | [HttpStreamingStrategy],
  'status_code' : number,
}
export interface HttpStreamingCallbackResponse {
  'token' : [] | [HttpStreamingCallbackToken],
  'body' : Uint8Array | number[],
}
export interface HttpStreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Uint8Array | number[]],
  'index' : bigint,
  'content_encoding' : string,
}
export type HttpStreamingStrategy = {
    'Callback' : {
      'token' : HttpStreamingCallbackToken,
      'callback' : [Principal, string],
    }
  };
export interface InitArgs {
  'timersInterval' : [] | [Duration],
  'dutchAuction' : [] | [DutchAuction],
  'legacyPlaceholder' : [] | [boolean],
  'whitelists' : Array<Whitelist>,
  'marketplaces' : Array<[string, AccountIdentifier, bigint]>,
  'name' : string,
  'escrowDelay' : [] | [Duration],
  'sale' : { 'duration' : Duration } |
    { 'supply' : bigint },
  'test' : [] | [boolean],
  'restoreEnabled' : [] | [boolean],
  'revealDelay' : Duration,
  'airdrop' : Array<AccountIdentifier>,
  'royalties' : Array<[AccountIdentifier, bigint]>,
  'salePrice' : bigint,
  'marketDelay' : [] | [Duration],
  'singleAssetCollection' : [] | [boolean],
  'publicSaleStart' : Time,
  'salesDistribution' : Array<[AccountIdentifier, bigint]>,
}
export interface ListRequest {
  'token' : TokenIdentifier__1,
  'frontendIdentifier' : [] | [string],
  'from_subaccount' : [] | [SubAccount__3],
  'price' : [] | [bigint],
}
export interface Listing {
  'sellerFrontend' : [] | [string],
  'locked' : [] | [Time__1],
  'seller' : Principal,
  'buyerFrontend' : [] | [string],
  'price' : bigint,
}
export interface LogMessagesData { 'timeNanos' : Nanos, 'message' : string }
export type Memo = Uint8Array | number[];
export type Metadata = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Uint8Array | number[]],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Uint8Array | number[]] } };
export type Metadata__1 = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Uint8Array | number[]],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Uint8Array | number[]] } };
export type Metadata__2 = {
    'fungible' : {
      'decimals' : number,
      'metadata' : [] | [Uint8Array | number[]],
      'name' : string,
      'symbol' : string,
    }
  } |
  { 'nonfungible' : { 'metadata' : [] | [Uint8Array | number[]] } };
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
export type RemainingSpots = bigint;
export type Result = {
    'ok' : Array<[TokenIndex, [] | [Listing], [] | [Uint8Array | number[]]]>
  } |
  { 'err' : CommonError };
export type Result_1 = { 'ok' : Uint32Array | number[] } |
  { 'err' : CommonError };
export type Result_2 = { 'ok' : Balance__1 } |
  { 'err' : CommonError };
export type Result_3 = { 'ok' : null } |
  { 'err' : CommonError__1 };
export type Result_4 = { 'ok' : null } |
  { 'err' : string };
export type Result_5 = { 'ok' : [AccountIdentifier__5, bigint] } |
  { 'err' : string };
export type Result_6 = { 'ok' : Metadata__1 } |
  { 'err' : CommonError };
export type Result_7 = { 'ok' : AccountIdentifier__2 } |
  { 'err' : CommonError__1 };
export type Result_8 = { 'ok' : [AccountIdentifier__2, [] | [Listing]] } |
  { 'err' : CommonError__1 };
export type Result_9 = { 'ok' : AccountIdentifier__7 } |
  { 'err' : CommonError__2 };
export interface Sale {
  'expires' : Time__2,
  'subaccount' : SubAccount__1,
  'whitelistName' : [] | [string],
  'tokens' : Uint32Array | number[],
  'buyer' : AccountIdentifier__5,
  'price' : bigint,
}
export interface SaleSettings {
  'startTime' : Time__2,
  'whitelist' : boolean,
  'endTime' : Time__2,
  'totalToSell' : bigint,
  'sold' : bigint,
  'bulkPricing' : Array<[bigint, bigint]>,
  'whitelistTime' : Time__2,
  'salePrice' : bigint,
  'remaining' : bigint,
  'openEdition' : boolean,
  'price' : bigint,
}
export interface SaleTransaction {
  'time' : Time__2,
  'seller' : Principal,
  'tokens' : Uint32Array | number[],
  'buyer' : AccountIdentifier__5,
  'price' : bigint,
}
export interface SaleV1 {
  'expires' : Time__2,
  'slot' : [] | [WhitelistSlot],
  'subaccount' : SubAccount__1,
  'tokens' : Uint32Array | number[],
  'buyer' : AccountIdentifier__5,
  'price' : bigint,
}
export interface Settlement {
  'sellerFrontend' : [] | [string],
  'subaccount' : SubAccount__3,
  'seller' : Principal,
  'buyerFrontend' : [] | [string],
  'buyer' : AccountIdentifier__2,
  'price' : bigint,
}
export type StableChunk = {
    'v1' : {
      'marketplace' : StableChunk__3,
      'assets' : StableChunk__1,
      'sale' : StableChunk__4,
      'disburser' : StableChunk__2,
      'tokens' : StableChunk__6,
      'shuffle' : StableChunk__5,
    }
  };
export type StableChunk__1 = [] | [
  { 'v1' : { 'assetsChunk' : Array<Asset>, 'assetsCount' : bigint } } |
    {
      'v2' : {
        'assetsChunk' : Array<AssetV2>,
        'assetsCount' : bigint,
        'placeholder' : AssetV2,
      }
    } |
    { 'v1_chunk' : { 'assetsChunk' : Array<Asset> } } |
    { 'v2_chunk' : { 'assetsChunk' : Array<AssetV2> } }
];
export type StableChunk__2 = [] | [
  { 'v1' : { 'disbursements' : Array<Disbursement> } }
];
export type StableChunk__3 = [] | [
  {
      'v1' : {
        'tokenSettlement' : Array<[TokenIndex__1, Settlement]>,
        'frontends' : Array<[string, Frontend]>,
        'tokenListing' : Array<[TokenIndex__1, Listing]>,
        'transactionChunk' : Array<Transaction>,
        'transactionCount' : bigint,
      }
    } |
    { 'v1_chunk' : { 'transactionChunk' : Array<Transaction> } }
];
export type StableChunk__4 = [] | [
  {
      'v1' : {
        'whitelist' : Array<[bigint, AccountIdentifier__5, WhitelistSlot]>,
        'salesSettlements' : Array<[AccountIdentifier__5, SaleV1]>,
        'totalToSell' : bigint,
        'failedSales' : Array<[AccountIdentifier__5, SubAccount__1]>,
        'sold' : bigint,
        'saleTransactionChunk' : Array<SaleTransaction>,
        'saleTransactionCount' : bigint,
        'nextSubAccount' : bigint,
        'soldIcp' : bigint,
        'tokensForSale' : Uint32Array | number[],
      }
    } |
    {
      'v2' : {
        'salesSettlements' : Array<[AccountIdentifier__5, Sale]>,
        'totalToSell' : bigint,
        'failedSales' : Array<[AccountIdentifier__5, SubAccount__1]>,
        'sold' : bigint,
        'saleTransactionChunk' : Array<SaleTransaction>,
        'saleTransactionCount' : bigint,
        'nextSubAccount' : bigint,
        'soldIcp' : bigint,
        'whitelistSpots' : Array<[WhitelistSpotId, RemainingSpots]>,
        'tokensForSale' : Uint32Array | number[],
      }
    } |
    { 'v1_chunk' : { 'saleTransactionChunk' : Array<SaleTransaction> } } |
    { 'v2_chunk' : { 'saleTransactionChunk' : Array<SaleTransaction> } }
];
export type StableChunk__5 = [] | [{ 'v1' : { 'isShuffled' : boolean } }];
export type StableChunk__6 = [] | [
  {
      'v1' : {
        'owners' : Array<[AccountIdentifier__7, Uint32Array | number[]]>,
        'tokenMetadata' : Array<[TokenIndex__4, Metadata]>,
        'supply' : Balance__2,
        'registry' : Array<[TokenIndex__4, AccountIdentifier__7]>,
        'nextTokenId' : TokenIndex__4,
      }
    }
];
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
export type SubAccount = Uint8Array | number[];
export type SubAccount__1 = Uint8Array | number[];
export type SubAccount__2 = Uint8Array | number[];
export type SubAccount__3 = Uint8Array | number[];
export type Time = bigint;
export type Time__1 = bigint;
export type Time__2 = bigint;
export type TokenIdentifier = string;
export type TokenIdentifier__1 = string;
export type TokenIdentifier__2 = string;
export type TokenIdentifier__3 = string;
export type TokenIndex = number;
export type TokenIndex__1 = number;
export type TokenIndex__2 = number;
export type TokenIndex__3 = number;
export type TokenIndex__4 = number;
export interface Transaction {
  'token' : TokenIdentifier__1,
  'time' : Time__1,
  'seller' : Principal,
  'buyer' : AccountIdentifier__2,
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
    'err' : { 'CannotNotify' : AccountIdentifier__1 } |
      { 'InsufficientBalance' : null } |
      { 'InvalidToken' : TokenIdentifier } |
      { 'Rejected' : null } |
      { 'Unauthorized' : AccountIdentifier__1 } |
      { 'Other' : string }
  };
export type UpdateCallsAggregatedData = BigUint64Array | bigint[];
export interface UpdateInformationRequest {
  'metrics' : [] | [CollectMetricsRequestType],
}
export type User = { 'principal' : Principal } |
  { 'address' : AccountIdentifier__1 };
export interface Whitelist {
  'startTime' : Time,
  'endTime' : [] | [Time],
  'name' : string,
  'oneTimeOnly' : boolean,
  'addresses' : Array<AccountIdentifier>,
  'price' : bigint,
}
export interface WhitelistSlot { 'end' : Time, 'start' : Time }
export type WhitelistSpotId = string;
export interface _SERVICE extends Canister {}
