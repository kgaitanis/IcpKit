//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum EXT {
	/// type AccountIdentifier = text;
	typealias AccountIdentifier = String
	
	/// type AccountIdentifier__1 = text;
	typealias AccountIdentifier__1 = String
	
	/// type AccountIdentifier__2 = text;
	typealias AccountIdentifier__2 = String
	
	/// type Airdrop = vec text;
	typealias Airdrop = [String]
	
	/// type Balance = nat;
	typealias Balance = BigUInt
	
	/// type CanisterCyclesAggregatedData = vec nat64;
	typealias CanisterCyclesAggregatedData = [UInt64]
	
	/// type CanisterHeapMemoryAggregatedData = vec nat64;
	typealias CanisterHeapMemoryAggregatedData = [UInt64]
	
	/// type CanisterMemoryAggregatedData = vec nat64;
	typealias CanisterMemoryAggregatedData = [UInt64]
	
	/// type CommonError__1 = 
	///  variant {
	///    InvalidToken: TokenIdentifier__1;
	///    Other: text;
	///  };
	typealias CommonError__1 = CommonError
	
	/// type CommonError__2 = 
	///  variant {
	///    InvalidToken: TokenIdentifier__1;
	///    Other: text;
	///  };
	typealias CommonError__2 = CommonError
	
	typealias Disbursement = CandidTuple4<TokenIndex__1, AccountIdentifier__1, SubAccount__1, UInt64>
	
	/// type Extension = text;
	typealias Extension = String
	
	/// type Floor = nat64;
	typealias Floor = UInt64
	
	typealias HeaderField = CandidTuple2<String, String>
	
	/// type Inventory = vec ItemInventory;
	typealias Inventory = [ItemInventory]
	
	/// type ListingResponse = 
	///  vec record {
	///        TokenIndex__1;
	///        ExtListing;
	///        Metadata__1;
	///      };
	typealias ListingResponse = [CandidTuple3<TokenIndex__1, ExtListing, Metadata__1>]
	
	/// type Memo = blob;
	typealias Memo = Data
	
	/// type Metadata__1 = 
	///  variant {
	///    fungible:
	///     record {
	///       decimals: nat8;
	///       metadata: opt blob;
	///       name: text;
	///       symbol: text;
	///     };
	///    nonfungible: record {metadata: opt blob;};
	///  };
	typealias Metadata__1 = Metadata
	
	/// type Nanos = nat64;
	typealias Nanos = UInt64
	
	/// type Recipe = vec text;
	typealias Recipe = [String]
	
	/// type Result__1 = 
	///  variant {
	///    err: text;
	///    ok;
	///  };
	typealias Result__1 = Result
	
	/// type StreamingCallback = func (StreamingCallbackToken) ->
	///                           (StreamingCallbackResponse) query;
	typealias StreamingCallback = ICPQuery<StreamingCallbackToken, StreamingCallbackResponse>
	
	/// type SubAccount = vec nat8;
	typealias SubAccount = Data
	
	/// type SubAccount__1 = vec nat8;
	typealias SubAccount__1 = Data
	
	/// type SubAccount__2 = vec nat8;
	typealias SubAccount__2 = Data
	
	/// type Supply = nat;
	typealias Supply = BigUInt
	
	/// type Time = int;
	typealias Time = BigInt
	
	/// type TokenIdentifier = text;
	typealias TokenIdentifier = String
	
	/// type TokenIdentifier__1 = text;
	typealias TokenIdentifier__1 = String
	
	/// type TokenIdentifier__2 = text;
	typealias TokenIdentifier__2 = String
	
	/// type TokenIndex = nat32;
	typealias TokenIndex = UInt32
	
	/// type TokenIndex__1 = nat32;
	typealias TokenIndex__1 = UInt32
	
	/// type UpdateCallsAggregatedData = vec nat64;
	typealias UpdateCallsAggregatedData = [UInt64]
	
	
	/// type AccessoryInventory = 
	///  record {
	///    equipped: bool;
	///    name: text;
	///    tokenIdentifier: text;
	///  };
	struct AccessoryInventory: Codable {
		let tokenIdentifier: String
		let name: String
		let equipped: Bool
	}
	
	/// type BalanceRequest = 
	///  record {
	///    token: TokenIdentifier__1;
	///    user: User;
	///  };
	struct BalanceRequest: Codable {
		let token: TokenIdentifier__1
		let user: User
	}
	
	/// type BalanceResponse = 
	///  variant {
	///    err: CommonError__1;
	///    ok: Balance;
	///  };
	enum BalanceResponse: Codable {
		case ok(Balance)
		case err(CommonError__1)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type CanisterLogFeature = 
	///  variant {
	///    filterMessageByContains;
	///    filterMessageByRegex;
	///  };
	enum CanisterLogFeature: Codable {
		case filterMessageByContains
		case filterMessageByRegex
	
		enum CodingKeys: String, CandidCodingKey {
			case filterMessageByContains
			case filterMessageByRegex
		}
	}
	
	/// type CanisterLogMessages = 
	///  record {
	///    data: vec LogMessagesData;
	///    lastAnalyzedMessageTimeNanos: opt Nanos;
	///  };
	struct CanisterLogMessages: Codable {
		let data: [LogMessagesData]
		let lastAnalyzedMessageTimeNanos: Nanos?
	}
	
	/// type CanisterLogMessagesInfo = 
	///  record {
	///    count: nat32;
	///    features: vec opt CanisterLogFeature;
	///    firstTimeNanos: opt Nanos;
	///    lastTimeNanos: opt Nanos;
	///  };
	struct CanisterLogMessagesInfo: Codable {
		let features: [CanisterLogFeature?]
		let lastTimeNanos: Nanos?
		let count: UInt32
		let firstTimeNanos: Nanos?
	}
	
	/// type CanisterLogRequest = 
	///  variant {
	///    getLatestMessages: GetLatestLogMessagesParameters;
	///    getMessages: GetLogMessagesParameters;
	///    getMessagesInfo;
	///  };
	enum CanisterLogRequest: Codable {
		case getMessagesInfo
		case getMessages(GetLogMessagesParameters)
		case getLatestMessages(GetLatestLogMessagesParameters)
	
		enum CodingKeys: String, CandidCodingKey {
			case getMessagesInfo
			case getMessages
			case getLatestMessages
		}
	}
	
	/// type CanisterLogResponse = 
	///  variant {
	///    messages: CanisterLogMessages;
	///    messagesInfo: CanisterLogMessagesInfo;
	///  };
	enum CanisterLogResponse: Codable {
		case messagesInfo(CanisterLogMessagesInfo)
		case messages(CanisterLogMessages)
	
		enum CodingKeys: String, CandidCodingKey {
			case messagesInfo
			case messages
		}
	}
	
	/// type CanisterMetrics = record {data: CanisterMetricsData;};
	struct CanisterMetrics: Codable {
		let data: CanisterMetricsData
	}
	
	/// type CanisterMetricsData = 
	///  variant {
	///    daily: vec DailyMetricsData;
	///    hourly: vec HourlyMetricsData;
	///  };
	enum CanisterMetricsData: Codable {
		case hourly([HourlyMetricsData])
		case daily([DailyMetricsData])
	
		enum CodingKeys: String, CandidCodingKey {
			case hourly
			case daily
		}
	}
	
	/// type CommonError = 
	///  variant {
	///    InvalidToken: TokenIdentifier__1;
	///    Other: text;
	///  };
	enum CommonError: Codable {
		case InvalidToken(TokenIdentifier__1)
		case Other(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case InvalidToken
			case Other
		}
	}
	
	/// type DailyMetricsData = 
	///  record {
	///    canisterCycles: NumericEntity;
	///    canisterHeapMemorySize: NumericEntity;
	///    canisterMemorySize: NumericEntity;
	///    timeMillis: int;
	///    updateCalls: nat64;
	///  };
	struct DailyMetricsData: Codable {
		let updateCalls: UInt64
		let canisterHeapMemorySize: NumericEntity
		let canisterCycles: NumericEntity
		let canisterMemorySize: NumericEntity
		let timeMillis: BigInt
	}
	
	/// type DetailsResponse = 
	///  variant {
	///    err: CommonError__2;
	///    ok: record {
	///          AccountIdentifier__1;
	///          opt Listing__1;
	///        };
	///  };
	enum DetailsResponse: Codable {
		case ok(AccountIdentifier__1, Listing__1?)
		case err(CommonError__2)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type EntrepotTransaction = 
	///  record {
	///    buyer: AccountIdentifier__1;
	///    price: nat64;
	///    seller: principal;
	///    time: Time;
	///    token: TokenIdentifier__2;
	///  };
	struct EntrepotTransaction: Codable {
		let token: TokenIdentifier__2
		let time: Time
		let seller: ICPPrincipal
		let buyer: AccountIdentifier__1
		let price: UInt64
	}
	
	/// type ExtListing = 
	///  record {
	///    locked: opt Time;
	///    price: nat64;
	///    seller: principal;
	///  };
	struct ExtListing: Codable {
		let locked: Time?
		let seller: ICPPrincipal
		let price: UInt64
	}
	
	/// type GetLatestLogMessagesParameters = 
	///  record {
	///    count: nat32;
	///    filter: opt GetLogMessagesFilter;
	///    upToTimeNanos: opt Nanos;
	///  };
	struct GetLatestLogMessagesParameters: Codable {
		let upToTimeNanos: Nanos?
		let count: UInt32
		let filter: GetLogMessagesFilter?
	}
	
	/// type GetLogMessagesFilter = 
	///  record {
	///    analyzeCount: nat32;
	///    messageContains: opt text;
	///    messageRegex: opt text;
	///  };
	struct GetLogMessagesFilter: Codable {
		let analyzeCount: UInt32
		let messageRegex: String?
		let messageContains: String?
	}
	
	/// type GetLogMessagesParameters = 
	///  record {
	///    count: nat32;
	///    filter: opt GetLogMessagesFilter;
	///    fromTimeNanos: opt Nanos;
	///  };
	struct GetLogMessagesParameters: Codable {
		let count: UInt32
		let filter: GetLogMessagesFilter?
		let fromTimeNanos: Nanos?
	}
	
	/// type GetMetricsParameters = 
	///  record {
	///    dateFromMillis: nat;
	///    dateToMillis: nat;
	///    granularity: MetricsGranularity;
	///  };
	struct GetMetricsParameters: Codable {
		let dateToMillis: BigUInt
		let granularity: MetricsGranularity
		let dateFromMillis: BigUInt
	}
	
	/// type HourlyMetricsData = 
	///  record {
	///    canisterCycles: CanisterCyclesAggregatedData;
	///    canisterHeapMemorySize: CanisterHeapMemoryAggregatedData;
	///    canisterMemorySize: CanisterMemoryAggregatedData;
	///    timeMillis: int;
	///    updateCalls: UpdateCallsAggregatedData;
	///  };
	struct HourlyMetricsData: Codable {
		let updateCalls: UpdateCallsAggregatedData
		let canisterHeapMemorySize: CanisterHeapMemoryAggregatedData
		let canisterCycles: CanisterCyclesAggregatedData
		let canisterMemorySize: CanisterMemoryAggregatedData
		let timeMillis: BigInt
	}
	
	/// type ItemInventory = 
	///  variant {
	///    Accessory: AccessoryInventory;
	///    Material: MaterialInventory;
	///  };
	enum ItemInventory: Codable {
		case Accessory(AccessoryInventory)
		case Material(MaterialInventory)
	
		enum CodingKeys: String, CandidCodingKey {
			case Accessory
			case Material
		}
	}
	
	/// type ListRequest = 
	///  record {
	///    from_subaccount: opt SubAccount__1;
	///    price: opt nat64;
	///    token: TokenIdentifier__2;
	///  };
	struct ListRequest: Codable {
		let token: TokenIdentifier__2
		let from_subaccount: SubAccount__1?
		let price: UInt64?
	}
	
	/// type ListResponse = 
	///  variant {
	///    err: CommonError__2;
	///    ok;
	///  };
	enum ListResponse: Codable {
		case ok
		case err(CommonError__2)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Listing = 
	///  record {
	///    locked: opt Time;
	///    price: nat64;
	///    seller: principal;
	///    subaccount: opt SubAccount;
	///  };
	struct Listing: Codable {
		let subaccount: SubAccount?
		let locked: Time?
		let seller: ICPPrincipal
		let price: UInt64
	}
	
	/// type Listing__1 = 
	///  record {
	///    locked: opt Time;
	///    price: nat64;
	///    seller: principal;
	///    subaccount: opt SubAccount__1;
	///  };
	struct Listing__1: Codable {
		let subaccount: SubAccount__1?
		let locked: Time?
		let seller: ICPPrincipal
		let price: UInt64
	}
	
	/// type LockResponse = 
	///  variant {
	///    err: CommonError__2;
	///    ok: AccountIdentifier__1;
	///  };
	enum LockResponse: Codable {
		case ok(AccountIdentifier__1)
		case err(CommonError__2)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type LogMessagesData = 
	///  record {
	///    message: text;
	///    timeNanos: Nanos;
	///  };
	struct LogMessagesData: Codable {
		let timeNanos: Nanos
		let message: String
	}
	
	/// type MaterialInventory = 
	///  record {
	///    name: text;
	///    tokenIdentifier: text;
	///  };
	struct MaterialInventory: Codable {
		let tokenIdentifier: String
		let name: String
	}
	
	/// type Metadata = 
	///  variant {
	///    fungible:
	///     record {
	///       decimals: nat8;
	///       metadata: opt blob;
	///       name: text;
	///       symbol: text;
	///     };
	///    nonfungible: record {metadata: opt blob;};
	///  };
	enum Metadata: Codable {
		case fungible(decimals: UInt8, metadata: Data?, name: String, symbol: String)
		case nonfungible(metadata: Data?)
	
		enum CodingKeys: String, CandidCodingKey {
			case fungible
			case nonfungible
		}
		enum FungibleCodingKeys: String, CandidCodingKey {
			case decimals
			case metadata
			case name
			case symbol
		}
		enum NonfungibleCodingKeys: String, CandidCodingKey {
			case metadata
		}
	}
	
	/// type MetricsGranularity = 
	///  variant {
	///    daily;
	///    hourly;
	///  };
	enum MetricsGranularity: Codable {
		case hourly
		case daily
	
		enum CodingKeys: String, CandidCodingKey {
			case hourly
			case daily
		}
	}
	
	/// type NFT = 
	///  record {
	///    identifier: text;
	///    name: text;
	///  };
	struct NFT: Codable {
		let name: String
		let identifier: String
	}
	
	/// type NumericEntity = 
	///  record {
	///    avg: nat64;
	///    first: nat64;
	///    last: nat64;
	///    max: nat64;
	///    min: nat64;
	///  };
	struct NumericEntity: Codable {
		let avg: UInt64
		let max: UInt64
		let min: UInt64
		let first: UInt64
		let last: UInt64
	}
	
	/// type Request = 
	///  record {
	///    body: blob;
	///    headers: vec HeaderField;
	///    method: text;
	///    url: text;
	///  };
	struct Request: Codable {
		let url: String
		let method: String
		let body: Data
		let headers: [HeaderField]
	}
	
	/// type Response = 
	///  record {
	///    body: blob;
	///    headers: vec HeaderField;
	///    status_code: nat16;
	///    streaming_strategy: opt StreamingStrategy;
	///  };
	struct Response: Codable {
		let body: Data
		let headers: [HeaderField]
		let streaming_strategy: StreamingStrategy?
		let status_code: UInt16
	}
	
	/// type Result = 
	///  variant {
	///    err: text;
	///    ok;
	///  };
	enum Result: Codable {
		case ok
		case err(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_1 = 
	///  variant {
	///    err: CommonError;
	///    ok: vec record {
	///              TokenIndex;
	///              opt Listing;
	///              opt blob;
	///            };
	///  };
	enum Result_1: Codable {
		case ok([CandidTuple3<TokenIndex, Listing?, Data?>])
		case err(CommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_2 = 
	///  variant {
	///    err: CommonError;
	///    ok: vec TokenIndex;
	///  };
	enum Result_2: Codable {
		case ok([TokenIndex])
		case err(CommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_3 = 
	///  variant {
	///    err: CommonError;
	///    ok;
	///  };
	enum Result_3: Codable {
		case ok
		case err(CommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_4 = 
	///  variant {
	///    err: CommonError__1;
	///    ok: Metadata;
	///  };
	enum Result_4: Codable {
		case ok(Metadata)
		case err(CommonError__1)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_5 = 
	///  variant {
	///    err: text;
	///    ok: Inventory;
	///  };
	enum Result_5: Codable {
		case ok(Inventory)
		case err(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_6 = 
	///  variant {
	///    err: CommonError;
	///    ok: AccountIdentifier__2;
	///  };
	enum Result_6: Codable {
		case ok(AccountIdentifier__2)
		case err(CommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result_7 = 
	///  variant {
	///    err: text;
	///    ok: text;
	///  };
	enum Result_7: Codable {
		case ok(String)
		case err(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result__1_1 = 
	///  variant {
	///    err: text;
	///    ok: TokenIdentifier;
	///  };
	enum Result__1_1: Codable {
		case ok(TokenIdentifier)
		case err(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Result__1_2 = 
	///  variant {
	///    err: CommonError__1;
	///    ok;
	///  };
	enum Result__1_2: Codable {
		case ok
		case err(CommonError__1)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type Reward = 
	///  record {
	///    amount: nat;
	///    category: TypeReward;
	///    collection: principal;
	///    date: Time;
	///  };
	struct Reward: Codable {
		let collection: ICPPrincipal
		let date: Time
		let category: TypeReward
		let amount: BigUInt
	}
	
	/// type StreamingCallbackResponse = 
	///  record {
	///    body: blob;
	///    token: opt StreamingCallbackToken;
	///  };
	struct StreamingCallbackResponse: Codable {
		let token: StreamingCallbackToken?
		let body: Data
	}
	
	/// type StreamingCallbackToken = 
	///  record {
	///    content_encoding: text;
	///    index: nat;
	///    key: text;
	///  };
	struct StreamingCallbackToken: Codable {
		let key: String
		let index: BigUInt
		let content_encoding: String
	}
	
	/// type StreamingStrategy = variant {
	///                            Callback:
	///                             record {
	///                               callback: StreamingCallback;
	///                               token: StreamingCallbackToken;
	///                             };};
	enum StreamingStrategy: Codable {
		case Callback(token: StreamingCallbackToken, callback: StreamingCallback)
	
		enum CodingKeys: String, CandidCodingKey {
			case Callback
		}
		enum CallbackCodingKeys: String, CandidCodingKey {
			case token
			case callback
		}
	}
	
	/// type Template = 
	///  variant {
	///    Accessory: record {
	///                 after_wear: text;
	///                 before_wear: text;
	///                 recipe: Recipe;
	///               };
	///    LegendaryAccessory: blob;
	///    Material: blob;
	///  };
	enum Template: Codable {
		case Accessory(after_wear: String, before_wear: String, recipe: Recipe)
		case LegendaryAccessory(Data)
		case Material(Data)
	
		enum CodingKeys: String, CandidCodingKey {
			case Accessory
			case LegendaryAccessory
			case Material
		}
		enum AccessoryCodingKeys: String, CandidCodingKey {
			case after_wear
			case before_wear
			case recipe
		}
	}
	
	/// type Token = 
	///  record {
	///    decimals: nat8;
	///    name: text;
	///  };
	struct Token: Codable {
		let decimals: UInt8
		let name: String
	}
	
	/// type Transaction = 
	///  record {
	///    bytes: vec nat8;
	///    closed: opt Time;
	///    from: AccountIdentifier__1;
	///    id: nat;
	///    initiated: Time;
	///    memo: opt blob;
	///    price: nat64;
	///    seller: principal;
	///    to: AccountIdentifier__1;
	///    token: TokenIdentifier__2;
	///  };
	struct Transaction: Codable {
		let id: BigUInt
		let to: AccountIdentifier__1
		let closed: Time?
		let token: TokenIdentifier__2
		let initiated: Time
		let from: AccountIdentifier__1
		let memo: Data?
		let seller: ICPPrincipal
		let bytes: Data
		let price: UInt64
	}
	
	/// type TransferRequest = 
	///  record {
	///    amount: Balance;
	///    from: User;
	///    memo: Memo;
	///    notify: bool;
	///    subaccount: opt SubAccount;
	///    to: User;
	///    token: TokenIdentifier__1;
	///  };
	struct TransferRequest: Codable {
		let to: User
		let token: TokenIdentifier__1
		let notify: Bool
		let from: User
		let memo: Memo
		let subaccount: SubAccount?
		let amount: Balance
	}
	
	/// type TransferResponse = 
	///  variant {
	///    err:
	///     variant {
	///       CannotNotify: AccountIdentifier;
	///       InsufficientBalance;
	///       InvalidToken: TokenIdentifier__1;
	///       Other: text;
	///       Rejected;
	///       Unauthorized: AccountIdentifier;
	///     };
	///    ok: Balance;
	///  };
	enum TransferResponse: Codable {
		case ok(Balance)
		case err(UnnamedType0)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type TypeReward = 
	///  variant {
	///    Material: NFT;
	///    NFT: NFT;
	///    Other;
	///    Token: Token;
	///  };
	enum TypeReward: Codable {
		case NFT(NFT)
		case Token(Token)
		case Other
		case Material(NFT)
	
		enum CodingKeys: String, CandidCodingKey {
			case NFT
			case Token
			case Other
			case Material
		}
	}
	
	enum UnnamedType0: Codable {
		case CannotNotify(AccountIdentifier)
		case InsufficientBalance
		case InvalidToken(TokenIdentifier__1)
		case Rejected
		case Unauthorized(AccountIdentifier)
		case Other(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case CannotNotify
			case InsufficientBalance
			case InvalidToken
			case Rejected
			case Unauthorized
			case Other
		}
	}
	
	/// type User = 
	///  variant {
	///    address: AccountIdentifier;
	///    "principal": principal;
	///  };
	enum User: Codable {
		case principal(ICPPrincipal)
		case address(AccountIdentifier)
	
		enum CodingKeys: String, CandidCodingKey {
			case principal
			case address
		}
	}
	

	/// service : {
	///   acceptCycles: () -> ();
	///   add_admin: (principal) -> ();
	///   add_template: (text, Template) -> (Result_7);
	///   airdrop_rewards: (vec record {
	///                           AccountIdentifier__2;
	///                           Airdrop;
	///                         }) -> ();
	///   availableCycles: () -> (nat) query;
	///   balance: (BalanceRequest) -> (BalanceResponse) query;
	///   bearer: (TokenIdentifier) -> (Result_6) query;
	///   can_settle: (principal, TokenIdentifier__1) -> (Result__1_2);
	///   collectCanisterMetrics: () -> ();
	///   create_accessory: (text, nat) -> (Result__1_1);
	///   cron_burned: () -> ();
	///   cron_disbursements: () -> ();
	///   cron_events: () -> ();
	///   cron_settlements: () -> ();
	///   cron_verification: () -> ();
	///   details: (TokenIdentifier) -> (DetailsResponse) query;
	///   extensions: () -> (vec Extension) query;
	///   getCanisterLog: (opt CanisterLogRequest) -> (opt CanisterLogResponse) query;
	///   getCanisterMetrics: (GetMetricsParameters) -> (opt CanisterMetrics) query;
	///   getInventory: () -> (Result_5) query;
	///   getRegistry: () -> (vec record {
	///                             TokenIndex;
	///                             AccountIdentifier__2;
	///                           }) query;
	///   getTokens: () -> (vec record {
	///                           TokenIndex;
	///                           Metadata;
	///                         }) query;
	///   get_admins: () -> (vec principal) query;
	///   get_pending_transactions: () ->
	///    (vec record {
	///           TokenIndex;
	///           Transaction;
	///         }) query;
	///   get_recorded_rewards: (principal) -> (opt vec Reward) query;
	///   get_stats_items: () -> (vec record {
	///                                 text;
	///                                 Supply;
	///                                 opt Floor;
	///                               }) query;
	///   http_request: (Request) -> (Response) query;
	///   is_admin: (principal) -> (bool) query;
	///   list: (ListRequest) -> (ListResponse);
	///   listings: () -> (ListingResponse) query;
	///   lock: (TokenIdentifier, nat64, AccountIdentifier__2, vec nat8) ->
	///    (LockResponse);
	///   metadata: (TokenIdentifier) -> (Result_4) query;
	///   payments: () -> (opt vec SubAccount__2) query;
	///   read_disbursements: () -> (vec Disbursement) query;
	///   record_icps: (AccountIdentifier__2, nat) -> () oneway;
	///   record_nft: (AccountIdentifier__2, principal, text, text) -> () oneway;
	///   record_token: (AccountIdentifier__2, nat, text, nat8, principal) ->
	///    () oneway;
	///   remove_accessory: (TokenIdentifier, TokenIdentifier) -> (Result__1);
	///   remove_admin: (principal) -> ();
	///   remove_record_nft: (AccountIdentifier__2, text) -> () oneway;
	///   setMaxMessagesCount: (nat) -> ();
	///   settle: (TokenIdentifier) -> (Result_3);
	///   size: () -> (nat) query;
	///   stats: () -> (nat64, nat64, nat64, nat64, nat, nat, nat) query;
	///   tokenId: (TokenIndex) -> (TokenIdentifier) query;
	///   tokens: (AccountIdentifier__2) -> (Result_2) query;
	///   tokens_ext: (AccountIdentifier__2) -> (Result_1) query;
	///   transactions: () -> (vec EntrepotTransaction) query;
	///   transfer: (TransferRequest) -> (TransferResponse);
	///   update_accessories: () -> ();
	///   wear_accessory: (TokenIdentifier, TokenIdentifier) -> (Result);
	/// }
	class Service: ICPService {
		/// acceptCycles: () -> ();
		func acceptCycles(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "acceptCycles")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// add_admin: (principal) -> ();
		func add_admin(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPPrincipal>(canister, "add_admin")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// add_template: (text, Template) -> (Result_7);
		func add_template(_ arg0: String, _ arg1: Template, sender: ICPSigningPrincipal? = nil) async throws -> Result_7 {
			let caller = ICPCall<ICPFunctionArgs2<String, Template>, Result_7>(canister, "add_template")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// airdrop_rewards: (vec record {
		///                           AccountIdentifier__2;
		///                           Airdrop;
		///                         }) -> ();
		func airdrop_rewards(_ arg0: [CandidTuple2<AccountIdentifier__2, Airdrop>], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[CandidTuple2<AccountIdentifier__2, Airdrop>]>(canister, "airdrop_rewards")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// availableCycles: () -> (nat) query;
		func availableCycles(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "availableCycles")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// balance: (BalanceRequest) -> (BalanceResponse) query;
		func balance(_ arg0: BalanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> BalanceResponse {
			let caller = ICPQuery<BalanceRequest, BalanceResponse>(canister, "balance")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearer: (TokenIdentifier) -> (Result_6) query;
		func bearer(_ arg0: TokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> Result_6 {
			let caller = ICPQuery<TokenIdentifier, Result_6>(canister, "bearer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// can_settle: (principal, TokenIdentifier__1) -> (Result__1_2);
		func can_settle(_ arg0: ICPPrincipal, _ arg1: TokenIdentifier__1, sender: ICPSigningPrincipal? = nil) async throws -> Result__1_2 {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, TokenIdentifier__1>, Result__1_2>(canister, "can_settle")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// collectCanisterMetrics: () -> ();
		func collectCanisterMetrics(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "collectCanisterMetrics")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// create_accessory: (text, nat) -> (Result__1_1);
		func create_accessory(_ arg0: String, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result__1_1 {
			let caller = ICPCall<ICPFunctionArgs2<String, BigUInt>, Result__1_1>(canister, "create_accessory")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// cron_burned: () -> ();
		func cron_burned(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "cron_burned")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// cron_disbursements: () -> ();
		func cron_disbursements(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "cron_disbursements")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// cron_events: () -> ();
		func cron_events(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "cron_events")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// cron_settlements: () -> ();
		func cron_settlements(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "cron_settlements")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// cron_verification: () -> ();
		func cron_verification(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "cron_verification")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// details: (TokenIdentifier) -> (DetailsResponse) query;
		func details(_ arg0: TokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> DetailsResponse {
			let caller = ICPQuery<TokenIdentifier, DetailsResponse>(canister, "details")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// extensions: () -> (vec Extension) query;
		func extensions(sender: ICPSigningPrincipal? = nil) async throws -> [Extension] {
			let caller = ICPQueryNoArgs<[Extension]>(canister, "extensions")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// getCanisterLog: (opt CanisterLogRequest) -> (opt CanisterLogResponse) query;
		func getCanisterLog(_ arg0: CanisterLogRequest?, sender: ICPSigningPrincipal? = nil) async throws -> CanisterLogResponse? {
			let caller = ICPQuery<CanisterLogRequest?, CanisterLogResponse?>(canister, "getCanisterLog")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// getCanisterMetrics: (GetMetricsParameters) -> (opt CanisterMetrics) query;
		func getCanisterMetrics(_ arg0: GetMetricsParameters, sender: ICPSigningPrincipal? = nil) async throws -> CanisterMetrics? {
			let caller = ICPQuery<GetMetricsParameters, CanisterMetrics?>(canister, "getCanisterMetrics")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// getInventory: () -> (Result_5) query;
		func getInventory(sender: ICPSigningPrincipal? = nil) async throws -> Result_5 {
			let caller = ICPQueryNoArgs<Result_5>(canister, "getInventory")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// getRegistry: () -> (vec record {
		///                             TokenIndex;
		///                             AccountIdentifier__2;
		///                           }) query;
		func getRegistry(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<TokenIndex, AccountIdentifier__2>] {
			let caller = ICPQueryNoArgs<[CandidTuple2<TokenIndex, AccountIdentifier__2>]>(canister, "getRegistry")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// getTokens: () -> (vec record {
		///                           TokenIndex;
		///                           Metadata;
		///                         }) query;
		func getTokens(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<TokenIndex, Metadata>] {
			let caller = ICPQueryNoArgs<[CandidTuple2<TokenIndex, Metadata>]>(canister, "getTokens")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_admins: () -> (vec principal) query;
		func get_admins(sender: ICPSigningPrincipal? = nil) async throws -> [ICPPrincipal] {
			let caller = ICPQueryNoArgs<[ICPPrincipal]>(canister, "get_admins")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_pending_transactions: () ->
		///    (vec record {
		///           TokenIndex;
		///           Transaction;
		///         }) query;
		func get_pending_transactions(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<TokenIndex, Transaction>] {
			let caller = ICPQueryNoArgs<[CandidTuple2<TokenIndex, Transaction>]>(canister, "get_pending_transactions")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_recorded_rewards: (principal) -> (opt vec Reward) query;
		func get_recorded_rewards(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> [Reward]? {
			let caller = ICPQuery<ICPPrincipal, [Reward]?>(canister, "get_recorded_rewards")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_stats_items: () -> (vec record {
		///                                 text;
		///                                 Supply;
		///                                 opt Floor;
		///                               }) query;
		func get_stats_items(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple3<String, Supply, Floor?>] {
			let caller = ICPQueryNoArgs<[CandidTuple3<String, Supply, Floor?>]>(canister, "get_stats_items")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// http_request: (Request) -> (Response) query;
		func http_request(_ arg0: Request, sender: ICPSigningPrincipal? = nil) async throws -> Response {
			let caller = ICPQuery<Request, Response>(canister, "http_request")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// is_admin: (principal) -> (bool) query;
		func is_admin(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> Bool {
			let caller = ICPQuery<ICPPrincipal, Bool>(canister, "is_admin")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// list: (ListRequest) -> (ListResponse);
		func list(_ arg0: ListRequest, sender: ICPSigningPrincipal? = nil) async throws -> ListResponse {
			let caller = ICPCall<ListRequest, ListResponse>(canister, "list")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// listings: () -> (ListingResponse) query;
		func listings(sender: ICPSigningPrincipal? = nil) async throws -> ListingResponse {
			let caller = ICPQueryNoArgs<ListingResponse>(canister, "listings")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// lock: (TokenIdentifier, nat64, AccountIdentifier__2, vec nat8) ->
		///    (LockResponse);
		func lock(_ arg0: TokenIdentifier, _ arg1: UInt64, _ arg2: AccountIdentifier__2, _ arg3: Data, sender: ICPSigningPrincipal? = nil) async throws -> LockResponse {
			let caller = ICPCall<ICPFunctionArgs4<TokenIdentifier, UInt64, AccountIdentifier__2, Data>, LockResponse>(canister, "lock")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2, arg3), client, sender: sender)
			return response
		}
	
		/// metadata: (TokenIdentifier) -> (Result_4) query;
		func metadata(_ arg0: TokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> Result_4 {
			let caller = ICPQuery<TokenIdentifier, Result_4>(canister, "metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// payments: () -> (opt vec SubAccount__2) query;
		func payments(sender: ICPSigningPrincipal? = nil) async throws -> [SubAccount__2]? {
			let caller = ICPQueryNoArgs<[SubAccount__2]?>(canister, "payments")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// read_disbursements: () -> (vec Disbursement) query;
		func read_disbursements(sender: ICPSigningPrincipal? = nil) async throws -> [Disbursement] {
			let caller = ICPQueryNoArgs<[Disbursement]>(canister, "read_disbursements")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// record_icps: (AccountIdentifier__2, nat) -> () oneway;
		func record_icps(_ arg0: AccountIdentifier__2, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPFunctionArgs2<AccountIdentifier__2, BigUInt>>(canister, "record_icps")
			let _ = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
		}
	
		/// record_nft: (AccountIdentifier__2, principal, text, text) -> () oneway;
		func record_nft(_ arg0: AccountIdentifier__2, _ arg1: ICPPrincipal, _ arg2: String, _ arg3: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPFunctionArgs4<AccountIdentifier__2, ICPPrincipal, String, String>>(canister, "record_nft")
			let _ = try await caller.callMethod(.init(arg0, arg1, arg2, arg3), client, sender: sender)
		}
	
		/// record_token: (AccountIdentifier__2, nat, text, nat8, principal) ->
		///    () oneway;
		func record_token(_ arg0: AccountIdentifier__2, _ arg1: BigUInt, _ arg2: String, _ arg3: UInt8, _ arg4: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPFunctionArgs5<AccountIdentifier__2, BigUInt, String, UInt8, ICPPrincipal>>(canister, "record_token")
			let _ = try await caller.callMethod(.init(arg0, arg1, arg2, arg3, arg4), client, sender: sender)
		}
	
		/// remove_accessory: (TokenIdentifier, TokenIdentifier) -> (Result__1);
		func remove_accessory(_ arg0: TokenIdentifier, _ arg1: TokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> Result__1 {
			let caller = ICPCall<ICPFunctionArgs2<TokenIdentifier, TokenIdentifier>, Result__1>(canister, "remove_accessory")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// remove_admin: (principal) -> ();
		func remove_admin(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPPrincipal>(canister, "remove_admin")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// remove_record_nft: (AccountIdentifier__2, text) -> () oneway;
		func remove_record_nft(_ arg0: AccountIdentifier__2, _ arg1: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPFunctionArgs2<AccountIdentifier__2, String>>(canister, "remove_record_nft")
			let _ = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
		}
	
		/// setMaxMessagesCount: (nat) -> ();
		func setMaxMessagesCount(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<BigUInt>(canister, "setMaxMessagesCount")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// can_settle: (principal, TokenIdentifier__1) -> (Result__1_2);
		func settle(_ arg0: TokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> Result_3 {
			let caller = ICPCall<TokenIdentifier, Result_3>(canister, "settle")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// size: () -> (nat) query;
		func size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// stats: () -> (nat64, nat64, nat64, nat64, nat, nat, nat) query;
		func stats(sender: ICPSigningPrincipal? = nil) async throws -> (UInt64, UInt64, UInt64, UInt64, BigUInt, BigUInt, BigUInt) {
			let caller = ICPQueryNoArgs<ICPFunctionArgs7<UInt64, UInt64, UInt64, UInt64, BigUInt, BigUInt, BigUInt>>(canister, "stats")
			let response = try await caller.callMethod(client, sender: sender)
			return response.tuple
		}
	
		/// tokenId: (TokenIndex) -> (TokenIdentifier) query;
		func tokenId(_ arg0: TokenIndex, sender: ICPSigningPrincipal? = nil) async throws -> TokenIdentifier {
			let caller = ICPQuery<TokenIndex, TokenIdentifier>(canister, "tokenId")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// tokens: (AccountIdentifier__2) -> (Result_2) query;
		func tokens(_ arg0: AccountIdentifier__2, sender: ICPSigningPrincipal? = nil) async throws -> Result_2 {
			let caller = ICPQuery<AccountIdentifier__2, Result_2>(canister, "tokens")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// tokens_ext: (AccountIdentifier__2) -> (Result_1) query;
		func tokens_ext(_ arg0: AccountIdentifier__2, sender: ICPSigningPrincipal? = nil) async throws -> Result_1 {
			let caller = ICPQuery<AccountIdentifier__2, Result_1>(canister, "tokens_ext")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_pending_transactions: () ->
		///    (vec record {
		///           TokenIndex;
		///           Transaction;
		///         }) query;
		func transactions(sender: ICPSigningPrincipal? = nil) async throws -> [EntrepotTransaction] {
			let caller = ICPQueryNoArgs<[EntrepotTransaction]>(canister, "transactions")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// transfer: (TransferRequest) -> (TransferResponse);
		func transfer(_ arg0: TransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> TransferResponse {
			let caller = ICPCall<TransferRequest, TransferResponse>(canister, "transfer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// update_accessories: () -> ();
		func update_accessories(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "update_accessories")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// wear_accessory: (TokenIdentifier, TokenIdentifier) -> (Result);
		func wear_accessory(_ arg0: TokenIdentifier, _ arg1: TokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<TokenIdentifier, TokenIdentifier>, Result>(canister, "wear_accessory")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
	}

}
