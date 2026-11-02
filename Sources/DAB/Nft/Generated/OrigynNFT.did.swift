//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum OrigynNFT {
	/// type Account__1 = variant {
	///   account_id : text;
	///   "principal" : principal;
	///   extensible : CandyShared;
	///   account : record { owner : principal; sub_account : opt vec nat8 };
	/// };
	typealias Account__1 = Account
	
	/// type Account__2 = variant {
	///   account_id : text;
	///   "principal" : principal;
	///   extensible : CandyShared;
	///   account : record { owner : principal; sub_account : opt vec nat8 };
	/// };
	typealias Account__2 = Account
	
	/// type ApprovalResult = vec record {
	///   token_id : nat;
	///   approval_result : variant { Ok : nat; Err : ApprovalError };
	/// };
	typealias ApprovalResult = [UnnamedType1]
	
	/// type AskConfigShared = opt AskFeatureArray;
	typealias AskConfigShared = AskFeatureArray?
	
	/// type AskFeatureArray = vec AskFeature;
	typealias AskFeatureArray = [AskFeature]
	
	/// type AskSubscribeResponse = bool;
	typealias AskSubscribeResponse = Bool
	
	/// type BidConfigShared = opt vec BidFeature;
	typealias BidConfigShared = [BidFeature]?
	
	/// type Caller = opt principal;
	typealias Caller = ICPPrincipal?
	
	/// type CandyShared = variant {
	///   Int : int;
	///   Map : vec record { CandyShared; CandyShared };
	///   Nat : nat;
	///   Set : vec CandyShared;
	///   Nat16 : nat16;
	///   Nat32 : nat32;
	///   Nat64 : nat64;
	///   Blob : vec nat8;
	///   Bool : bool;
	///   Int8 : int8;
	///   Ints : vec int;
	///   Nat8 : nat8;
	///   Nats : vec nat;
	///   Text : text;
	///   Bytes : vec nat8;
	///   Int16 : int16;
	///   Int32 : int32;
	///   Int64 : int64;
	///   Option : opt CandyShared;
	///   Floats : vec float64;
	///   Float : float64;
	///   Principal : principal;
	///   Array : vec CandyShared;
	///   Class : vec PropertyShared;
	/// };
	typealias CandyShared = C_Data
	
	/// type CanisterCyclesAggregatedData = vec nat64;
	typealias CanisterCyclesAggregatedData = [UInt64]
	
	/// type CanisterHeapMemoryAggregatedData = vec nat64;
	typealias CanisterHeapMemoryAggregatedData = [UInt64]
	
	/// type CanisterMemoryAggregatedData = vec nat64;
	typealias CanisterMemoryAggregatedData = [UInt64]
	
	/// type CollectionMetadata = vec record { text; Value };
	typealias CollectionMetadata = [CandidTuple2<String, Value>]
	
	/// type DistributeSaleResponse = vec Result;
	typealias DistributeSaleResponse = [Result]
	
	/// type EXTAccountIdentifier = text;
	typealias EXTAccountIdentifier = String
	
	/// type EXTBalance = nat;
	typealias EXTBalance = BigUInt
	
	/// type EXTMemo = vec nat8;
	typealias EXTMemo = Data
	
	/// type EXTSubAccount = vec nat8;
	typealias EXTSubAccount = Data
	
	/// type EXTTokenIdentifier = text;
	typealias EXTTokenIdentifier = String
	
	typealias EXTTokensResponse = CandidTuple3<UInt32, UnnamedType9?, Data?>
	
	/// type EndSaleResponse = record {
	///   token_id : text;
	///   txn_type : variant {
	///     escrow_deposit : record {
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     fee_deposit : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     canister_network_updated : record {
	///       network : principal;
	///       extensible : CandyShared;
	///     };
	///     escrow_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     canister_managers_updated : record {
	///       managers : vec principal;
	///       extensible : CandyShared;
	///     };
	///     auction_bid : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : text;
	///     };
	///     burn : record { from : opt Account__1; extensible : CandyShared };
	///     data : record {
	///       hash : opt vec nat8;
	///       extensible : CandyShared;
	///       data_dapp : opt text;
	///       data_path : opt text;
	///     };
	///     sale_ended : record {
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : opt text;
	///     };
	///     mint : record {
	///       to : Account__1;
	///       from : Account__1;
	///       sale : opt record { token : TokenSpec; amount : nat };
	///       extensible : CandyShared;
	///     };
	///     royalty_paid : record {
	///       tag : text;
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       receiver : Account__1;
	///       sale_id : opt text;
	///     };
	///     extensible : CandyShared;
	///     fee_deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     owner_transfer : record {
	///       to : Account__1;
	///       from : Account__1;
	///       extensible : CandyShared;
	///     };
	///     sale_opened : record {
	///       pricing : PricingConfigShared;
	///       extensible : CandyShared;
	///       sale_id : text;
	///     };
	///     canister_owner_updated : record {
	///       owner : principal;
	///       extensible : CandyShared;
	///     };
	///     sale_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///   };
	///   timestamp : int;
	///   index : nat;
	/// };
	typealias EndSaleResponse = BidResponse
	
	/// type EscrowReceipt__1 = record {
	///   token : TokenSpec;
	///   token_id : text;
	///   seller : Account__1;
	///   buyer : Account__1;
	///   amount : nat;
	/// };
	typealias EscrowReceipt__1 = EscrowReceipt
	
	/// type FeeAccountsParams = vec FeeName;
	typealias FeeAccountsParams = [FeeName]
	
	/// type FeeName = text;
	typealias FeeName = String
	
	/// type GetArchivesResult = vec GetArchivesResultItem;
	typealias GetArchivesResult = [GetArchivesResultItem]
	
	/// type GetTransactionsFn = func (vec TransactionRange__1) -> (
	///     GetTransactionsResult__1,
	///   ) query;
	typealias GetTransactionsFn = ICPQuery<[TransactionRange__1], GetTransactionsResult__1>
	
	/// type GetTransactionsResult__1 = record {
	///   log_length : nat;
	///   blocks : vec record { id : nat; block : Value__1 };
	///   archived_blocks : vec ArchivedTransactionResponse;
	/// };
	typealias GetTransactionsResult__1 = GetTransactionsResult
	
	typealias HeaderField = CandidTuple2<String, String>
	
	/// type ICTokenSpec__1 = record {
	///   id : opt nat;
	///   fee : opt nat;
	///   decimals : nat;
	///   canister : principal;
	///   standard : variant { ICRC1; EXTFungible; DIP20; Other : CandyShared; Ledger };
	///   symbol : text;
	/// };
	typealias ICTokenSpec__1 = ICTokenSpec
	
	/// type InstantConfigShared = opt vec InstantFeature;
	typealias InstantConfigShared = [InstantFeature]?
	
	/// type MarketTransferRequestReponse = record {
	///   token_id : text;
	///   txn_type : variant {
	///     escrow_deposit : record {
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     fee_deposit : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     canister_network_updated : record {
	///       network : principal;
	///       extensible : CandyShared;
	///     };
	///     escrow_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     canister_managers_updated : record {
	///       managers : vec principal;
	///       extensible : CandyShared;
	///     };
	///     auction_bid : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : text;
	///     };
	///     burn : record { from : opt Account__1; extensible : CandyShared };
	///     data : record {
	///       hash : opt vec nat8;
	///       extensible : CandyShared;
	///       data_dapp : opt text;
	///       data_path : opt text;
	///     };
	///     sale_ended : record {
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : opt text;
	///     };
	///     mint : record {
	///       to : Account__1;
	///       from : Account__1;
	///       sale : opt record { token : TokenSpec; amount : nat };
	///       extensible : CandyShared;
	///     };
	///     royalty_paid : record {
	///       tag : text;
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       receiver : Account__1;
	///       sale_id : opt text;
	///     };
	///     extensible : CandyShared;
	///     fee_deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     owner_transfer : record {
	///       to : Account__1;
	///       from : Account__1;
	///       extensible : CandyShared;
	///     };
	///     sale_opened : record {
	///       pricing : PricingConfigShared;
	///       extensible : CandyShared;
	///       sale_id : text;
	///     };
	///     canister_owner_updated : record {
	///       owner : principal;
	///       extensible : CandyShared;
	///     };
	///     sale_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///   };
	///   timestamp : int;
	///   index : nat;
	/// };
	typealias MarketTransferRequestReponse = BidResponse
	
	/// type NFTUpdateResponse = bool;
	typealias NFTUpdateResponse = Bool
	
	/// type Nanos = nat64;
	typealias Nanos = UInt64
	
	/// type PricingConfigShared__1 = variant {
	///   ask : AskConfigShared;
	///   extensible : CandyShared;
	///   instant : InstantConfigShared;
	///   auction : AuctionConfig;
	/// };
	typealias PricingConfigShared__1 = PricingConfigShared
	
	/// type Result = variant { ok : ManageSaleResponse; err : OrigynError };
	typealias Result = ManageSaleResult
	
	/// type StableEscrowBalances = vec record {
	///   Account;
	///   Account;
	///   text;
	///   EscrowRecord__1;
	/// };
	typealias StableEscrowBalances = [CandidTuple4<Account, Account, String, EscrowRecord__1>]
	
	/// type StableNftLedger = vec record { text; TransactionRecord };
	typealias StableNftLedger = [CandidTuple2<String, TransactionRecord>]
	
	/// type StableOffers = vec record { Account; Account; int };
	typealias StableOffers = [CandidTuple3<Account, Account, BigInt>]
	
	/// type StableSalesBalances = vec record {
	///   Account;
	///   Account;
	///   text;
	///   EscrowRecord__1;
	/// };
	typealias StableSalesBalances = [CandidTuple4<Account, Account, String, EscrowRecord__1>]
	
	/// type Subaccount = vec nat8;
	typealias Subaccount = Data
	
	/// type TokenSpec__2 = variant { ic : ICTokenSpec; extensible : CandyShared };
	typealias TokenSpec__2 = TokenSpec
	
	/// type TransactionID__1 = variant {
	///   "nat" : nat;
	///   "text" : text;
	///   extensible : CandyShared;
	/// };
	typealias TransactionID__1 = TransactionID
	
	/// type TransactionRange__1 = record { start : nat; length : nat };
	typealias TransactionRange__1 = TransactionRange
	
	/// type TransactionRecord = record {
	///   token_id : text;
	///   txn_type : variant {
	///     escrow_deposit : record {
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     fee_deposit : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     canister_network_updated : record {
	///       network : principal;
	///       extensible : CandyShared;
	///     };
	///     escrow_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     canister_managers_updated : record {
	///       managers : vec principal;
	///       extensible : CandyShared;
	///     };
	///     auction_bid : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : text;
	///     };
	///     burn : record { from : opt Account__1; extensible : CandyShared };
	///     data : record {
	///       hash : opt vec nat8;
	///       extensible : CandyShared;
	///       data_dapp : opt text;
	///       data_path : opt text;
	///     };
	///     sale_ended : record {
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : opt text;
	///     };
	///     mint : record {
	///       to : Account__1;
	///       from : Account__1;
	///       sale : opt record { token : TokenSpec; amount : nat };
	///       extensible : CandyShared;
	///     };
	///     royalty_paid : record {
	///       tag : text;
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       receiver : Account__1;
	///       sale_id : opt text;
	///     };
	///     extensible : CandyShared;
	///     fee_deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     owner_transfer : record {
	///       to : Account__1;
	///       from : Account__1;
	///       extensible : CandyShared;
	///     };
	///     sale_opened : record {
	///       pricing : PricingConfigShared;
	///       extensible : CandyShared;
	///       sale_id : text;
	///     };
	///     canister_owner_updated : record {
	///       owner : principal;
	///       extensible : CandyShared;
	///     };
	///     sale_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///   };
	///   timestamp : int;
	///   index : nat;
	/// };
	typealias TransactionRecord = BidResponse
	
	/// type TransferResult = vec opt TransferResultItem;
	typealias TransferResult = [TransferResultItem?]
	
	/// type UpdateCallsAggregatedData = vec nat64;
	typealias UpdateCallsAggregatedData = [UInt64]
	
	/// type Vec = vec record {
	///   text;
	///   variant {
	///     Nat64Content : nat64;
	///     Nat32Content : nat32;
	///     BoolContent : bool;
	///     Nat8Content : nat8;
	///     Int64Content : int64;
	///     IntContent : int;
	///     NatContent : nat;
	///     Nat16Content : nat16;
	///     Int32Content : int32;
	///     Int8Content : int8;
	///     FloatContent : float64;
	///     Int16Content : int16;
	///     BlobContent : vec nat8;
	///     NestedContent : Vec;
	///     Principal : principal;
	///     TextContent : text;
	///   };
	/// };
	typealias Vec = [CandidTuple2<String, GenericValue>]
	
	/// type WithdrawResponse = record {
	///   token_id : text;
	///   txn_type : variant {
	///     escrow_deposit : record {
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     fee_deposit : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     canister_network_updated : record {
	///       network : principal;
	///       extensible : CandyShared;
	///     };
	///     escrow_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     canister_managers_updated : record {
	///       managers : vec principal;
	///       extensible : CandyShared;
	///     };
	///     auction_bid : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : text;
	///     };
	///     burn : record { from : opt Account__1; extensible : CandyShared };
	///     data : record {
	///       hash : opt vec nat8;
	///       extensible : CandyShared;
	///       data_dapp : opt text;
	///       data_path : opt text;
	///     };
	///     sale_ended : record {
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : opt text;
	///     };
	///     mint : record {
	///       to : Account__1;
	///       from : Account__1;
	///       sale : opt record { token : TokenSpec; amount : nat };
	///       extensible : CandyShared;
	///     };
	///     royalty_paid : record {
	///       tag : text;
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       receiver : Account__1;
	///       sale_id : opt text;
	///     };
	///     extensible : CandyShared;
	///     fee_deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     owner_transfer : record {
	///       to : Account__1;
	///       from : Account__1;
	///       extensible : CandyShared;
	///     };
	///     sale_opened : record {
	///       pricing : PricingConfigShared;
	///       extensible : CandyShared;
	///       sale_id : text;
	///     };
	///     canister_owner_updated : record {
	///       owner : principal;
	///       extensible : CandyShared;
	///     };
	///     sale_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///   };
	///   timestamp : int;
	///   index : nat;
	/// };
	typealias WithdrawResponse = BidResponse
	
	/// type canister_id = principal;
	typealias canister_id = ICPPrincipal
	
	
	/// type Account = variant {
	///   account_id : text;
	///   "principal" : principal;
	///   extensible : CandyShared;
	///   account : record { owner : principal; sub_account : opt vec nat8 };
	/// };
	enum Account: Codable {
		case account_id(String)
		case principal(ICPPrincipal)
		case extensible(CandyShared)
		case account(owner: ICPPrincipal, sub_account: Data?)
	
		enum CodingKeys: String, CandidCodingKey {
			case account_id
			case principal
			case extensible
			case account
		}
		enum AccountCodingKeys: String, CandidCodingKey {
			case owner
			case sub_account
		}
	}
	
	/// type Account__3 = record { owner : principal; subaccount : opt Subaccount };
	struct Account__3: Codable {
		let owner: ICPPrincipal
		let subaccount: Subaccount?
	}
	
	/// type AllocationRecordStable = record {
	///   allocated_space : nat;
	///   token_id : text;
	///   available_space : nat;
	///   canister : principal;
	///   chunks : vec nat;
	///   library_id : text;
	/// };
	struct AllocationRecordStable: Codable {
		let allocated_space: BigUInt
		let token_id: String
		let available_space: BigUInt
		let canister: ICPPrincipal
		let chunks: [BigUInt]
		let library_id: String
	}
	
	/// type ApprovalArgs = record {
	///   memo : opt vec nat8;
	///   from_subaccount : opt vec nat8;
	///   created_at_time : opt nat64;
	///   expires_at : opt nat64;
	///   spender : Account__3;
	/// };
	struct ApprovalArgs: Codable {
		let memo: Data?
		let from_subaccount: Data?
		let created_at_time: UInt64?
		let expires_at: UInt64?
		let spender: Account__3
	}
	
	/// type ApprovalError = variant {
	///   GenericError : record { message : text; error_code : nat };
	///   CreatexInFuture : record { ledger_time : nat64 };
	///   NonExistingTokenId;
	///   Unauthorized;
	///   TooOld;
	/// };
	enum ApprovalError: Codable {
		case GenericError(message: String, error_code: BigUInt)
		case CreatexInFuture(ledger_time: UInt64)
		case NonExistingTokenId
		case Unauthorized
		case TooOld
	
		enum CodingKeys: String, CandidCodingKey {
			case GenericError
			case CreatexInFuture
			case NonExistingTokenId
			case Unauthorized
			case TooOld
		}
		enum GenericErrorCodingKeys: String, CandidCodingKey {
			case message
			case error_code
		}
		enum CreatexInFutureCodingKeys: String, CandidCodingKey {
			case ledger_time
		}
	}
	
	/// type ArchivedTransactionResponse = record {
	///   args : vec TransactionRange__1;
	///   callback : GetTransactionsFn;
	/// };
	struct ArchivedTransactionResponse: Codable {
		let args: [TransactionRange__1]
		let callback: GetTransactionsFn
	}
	
	/// type AskFeature = variant {
	///   kyc : principal;
	///   start_price : nat;
	///   token : TokenSpec;
	///   fee_schema : text;
	///   notify : vec principal;
	///   wait_for_quiet : WaitForQuietType;
	///   reserve : nat;
	///   start_date : int;
	///   min_increase : MinIncreaseType;
	///   allow_list : vec principal;
	///   buy_now : nat;
	///   fee_accounts : FeeAccountsParams;
	///   nifty_settlement : NiftySettlementType;
	///   atomic;
	///   dutch : DutchParams;
	///   ending : EndingType;
	/// };
	enum AskFeature: Codable {
		case kyc(ICPPrincipal)
		case start_price(BigUInt)
		case token(TokenSpec)
		case fee_schema(String)
		case notify([ICPPrincipal])
		case wait_for_quiet(WaitForQuietType)
		case reserve(BigUInt)
		case start_date(BigInt)
		case min_increase(MinIncreaseType)
		case allow_list([ICPPrincipal])
		case buy_now(BigUInt)
		case fee_accounts(FeeAccountsParams)
		case nifty_settlement(NiftySettlementType)
		case atomic
		case dutch(DutchParams)
		case ending(EndingType)
	
		enum CodingKeys: String, CandidCodingKey {
			case kyc
			case start_price
			case token
			case fee_schema
			case notify
			case wait_for_quiet
			case reserve
			case start_date
			case min_increase
			case allow_list
			case buy_now
			case fee_accounts
			case nifty_settlement
			case atomic
			case dutch
			case ending
		}
	}
	
	/// type AskSubscribeRequest = variant {
	///   subscribe : record {
	///     stake : record { principal; nat };
	///     filter : opt record {
	///       tokens : opt vec TokenSpecFilter;
	///       token_ids : opt vec TokenIDFilter;
	///     };
	///   };
	///   unsubscribe : record { principal; nat };
	/// };
	enum AskSubscribeRequest: Codable {
		case subscribe(stake: CandidTuple2<ICPPrincipal, BigUInt>, filter: UnnamedType2?)
		case unsubscribe(ICPPrincipal, BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case subscribe
			case unsubscribe
		}
		enum SubscribeCodingKeys: String, CandidCodingKey {
			case stake
			case filter
		}
	}
	
	/// type AuctionConfig = record {
	///   start_price : nat;
	///   token : TokenSpec;
	///   reserve : opt nat;
	///   start_date : int;
	///   min_increase : MinIncreaseType;
	///   allow_list : opt vec principal;
	///   buy_now : opt nat;
	///   ending : variant {
	///     date : int;
	///     wait_for_quiet : record {
	///       max : nat;
	///       date : int;
	///       fade : float64;
	///       extension : nat64;
	///     };
	///   };
	/// };
	struct AuctionConfig: Codable {
		let start_price: BigUInt
		let token: TokenSpec
		let reserve: BigUInt?
		let start_date: BigInt
		let min_increase: MinIncreaseType
		let allow_list: [ICPPrincipal]?
		let buy_now: BigUInt?
		let ending: UnnamedType3
	}
	
	/// type AuctionStateShared = record {
	///   status : variant { closed; open; not_started };
	///   participants : vec record { principal; int };
	///   token : TokenSpec__1;
	///   current_bid_amount : nat;
	///   winner : opt Account;
	///   end_date : int;
	///   current_config : BidConfigShared;
	///   start_date : int;
	///   wait_for_quiet_count : opt nat;
	///   current_escrow : opt EscrowReceipt;
	///   allow_list : opt vec record { principal; bool };
	///   min_next_bid : nat;
	///   config : PricingConfigShared__1;
	/// };
	struct AuctionStateShared: Codable {
		let status: UnnamedType4
		let participants: [CandidTuple2<ICPPrincipal, BigInt>]
		let token: TokenSpec__1
		let current_bid_amount: BigUInt
		let winner: Account?
		let end_date: BigInt
		let current_config: BidConfigShared
		let start_date: BigInt
		let wait_for_quiet_count: BigUInt?
		let current_escrow: EscrowReceipt?
		let allow_list: [CandidTuple2<ICPPrincipal, Bool>]?
		let min_next_bid: BigUInt
		let config: PricingConfigShared__1
	}
	
	/// type BalanceResponse = record {
	///   nfts : vec text;
	///   offers : vec EscrowRecord__1;
	///   sales : vec EscrowRecord__1;
	///   stake : vec StakeRecord;
	///   multi_canister : opt vec principal;
	///   escrow : vec EscrowRecord__1;
	/// };
	struct BalanceResponse: Codable {
		let nfts: [String]
		let offers: [EscrowRecord__1]
		let sales: [EscrowRecord__1]
		let stake: [StakeRecord]
		let multi_canister: [ICPPrincipal]?
		let escrow: [EscrowRecord__1]
	}
	
	/// type BalanceResult = variant { ok : BalanceResponse; err : OrigynError };
	enum BalanceResult: Codable {
		case ok(BalanceResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type BearerResult = variant { ok : Account; err : OrigynError };
	enum BearerResult: Codable {
		case ok(Account)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type BidFeature = variant {
	///   fee_schema : text;
	///   broker : Account__1;
	///   fee_accounts : FeeAccountsParams;
	/// };
	enum BidFeature: Codable {
		case fee_schema(String)
		case broker(Account__1)
		case fee_accounts(FeeAccountsParams)
	
		enum CodingKeys: String, CandidCodingKey {
			case fee_schema
			case broker
			case fee_accounts
		}
	}
	
	/// type BidRequest = record {
	///   config : BidConfigShared;
	///   escrow_record : EscrowRecord;
	/// };
	struct BidRequest: Codable {
		let config: BidConfigShared
		let escrow_record: EscrowRecord
	}
	
	/// type BidResponse = record {
	///   token_id : text;
	///   txn_type : variant {
	///     escrow_deposit : record {
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     fee_deposit : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     canister_network_updated : record {
	///       network : principal;
	///       extensible : CandyShared;
	///     };
	///     escrow_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     canister_managers_updated : record {
	///       managers : vec principal;
	///       extensible : CandyShared;
	///     };
	///     auction_bid : record {
	///       token : TokenSpec;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : text;
	///     };
	///     burn : record { from : opt Account__1; extensible : CandyShared };
	///     data : record {
	///       hash : opt vec nat8;
	///       extensible : CandyShared;
	///       data_dapp : opt text;
	///       data_path : opt text;
	///     };
	///     sale_ended : record {
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       sale_id : opt text;
	///     };
	///     mint : record {
	///       to : Account__1;
	///       from : Account__1;
	///       sale : opt record { token : TokenSpec; amount : nat };
	///       extensible : CandyShared;
	///     };
	///     royalty_paid : record {
	///       tag : text;
	///       token : TokenSpec;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///       receiver : Account__1;
	///       sale_id : opt text;
	///     };
	///     extensible : CandyShared;
	///     fee_deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       account : Account__1;
	///       amount : nat;
	///     };
	///     owner_transfer : record {
	///       to : Account__1;
	///       from : Account__1;
	///       extensible : CandyShared;
	///     };
	///     sale_opened : record {
	///       pricing : PricingConfigShared;
	///       extensible : CandyShared;
	///       sale_id : text;
	///     };
	///     canister_owner_updated : record {
	///       owner : principal;
	///       extensible : CandyShared;
	///     };
	///     sale_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       token_id : text;
	///       trx_id : TransactionID;
	///       seller : Account__1;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///     deposit_withdraw : record {
	///       fee : nat;
	///       token : TokenSpec;
	///       trx_id : TransactionID;
	///       extensible : CandyShared;
	///       buyer : Account__1;
	///       amount : nat;
	///     };
	///   };
	///   timestamp : int;
	///   index : nat;
	/// };
	struct BidResponse: Codable {
		let token_id: String
		let txn_type: UnnamedType6
		let timestamp: BigInt
		let index: BigUInt
	}
	
	/// type BlockType = record { url : text; block_type : text };
	struct BlockType: Codable {
		let url: String
		let block_type: String
	}
	
	/// type Data = variant {
	///   Int : int;
	///   Map : vec record { CandyShared; CandyShared };
	///   Nat : nat;
	///   Set : vec CandyShared;
	///   Nat16 : nat16;
	///   Nat32 : nat32;
	///   Nat64 : nat64;
	///   Blob : vec nat8;
	///   Bool : bool;
	///   Int8 : int8;
	///   Ints : vec int;
	///   Nat8 : nat8;
	///   Nats : vec nat;
	///   Text : text;
	///   Bytes : vec nat8;
	///   Int16 : int16;
	///   Int32 : int32;
	///   Int64 : int64;
	///   Option : opt CandyShared;
	///   Floats : vec float64;
	///   Float : float64;
	///   Principal : principal;
	///   Array : vec CandyShared;
	///   Class : vec PropertyShared;
	/// };
	indirect enum C_Data: Codable {
		case Int(BigInt)
		case Map([CandidTuple2<CandyShared, CandyShared>])
		case Nat(BigUInt)
		case Set([CandyShared])
		case Nat16(UInt16)
		case Nat32(UInt32)
		case Nat64(UInt64)
		case Blob(Data)
		case Bool(Bool)
		case Int8(Int8)
		case Ints([BigInt])
		case Nat8(UInt8)
		case Nats([BigUInt])
		case Text(String)
		case Bytes(Data)
		case Int16(Int16)
		case Int32(Int32)
		case Int64(Int64)
		case Option(CandyShared?)
		case Floats([Double])
		case Float(Double)
		case Principal(ICPPrincipal)
		case Array([CandyShared])
		case Class([PropertyShared])
	
		enum CodingKeys: String, CandidCodingKey {
			case Int
			case Map
			case Nat
			case Set
			case Nat16
			case Nat32
			case Nat64
			case Blob
			case Bool
			case Int8
			case Ints
			case Nat8
			case Nats
			case Text
			case Bytes
			case Int16
			case Int32
			case Int64
			case Option
			case Floats
			case Float
			case Principal
			case Array
			case Class
		}
	}
	
	/// type CanisterLogFeature = variant {
	///   filterMessageByContains;
	///   filterMessageByRegex;
	/// };
	enum CanisterLogFeature: Codable {
		case filterMessageByContains
		case filterMessageByRegex
	
		enum CodingKeys: String, CandidCodingKey {
			case filterMessageByContains
			case filterMessageByRegex
		}
	}
	
	/// type CanisterLogMessages = record {
	///   data : vec LogMessagesData;
	///   lastAnalyzedMessageTimeNanos : opt Nanos;
	/// };
	struct CanisterLogMessages: Codable {
		let data: [LogMessagesData]
		let lastAnalyzedMessageTimeNanos: Nanos?
	}
	
	/// type CanisterLogMessagesInfo = record {
	///   features : vec opt CanisterLogFeature;
	///   lastTimeNanos : opt Nanos;
	///   count : nat32;
	///   firstTimeNanos : opt Nanos;
	/// };
	struct CanisterLogMessagesInfo: Codable {
		let features: [CanisterLogFeature?]
		let lastTimeNanos: Nanos?
		let count: UInt32
		let firstTimeNanos: Nanos?
	}
	
	/// type CanisterLogRequest = variant {
	///   getMessagesInfo;
	///   getMessages : GetLogMessagesParameters;
	///   getLatestMessages : GetLatestLogMessagesParameters;
	/// };
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
	
	/// type CanisterLogResponse = variant {
	///   messagesInfo : CanisterLogMessagesInfo;
	///   messages : CanisterLogMessages;
	/// };
	enum CanisterLogResponse: Codable {
		case messagesInfo(CanisterLogMessagesInfo)
		case messages(CanisterLogMessages)
	
		enum CodingKeys: String, CandidCodingKey {
			case messagesInfo
			case messages
		}
	}
	
	/// type CanisterMetrics = record { data : CanisterMetricsData };
	struct CanisterMetrics: Codable {
		let data: CanisterMetricsData
	}
	
	/// type CanisterMetricsData = variant {
	///   hourly : vec HourlyMetricsData;
	///   daily : vec DailyMetricsData;
	/// };
	enum CanisterMetricsData: Codable {
		case hourly([HourlyMetricsData])
		case daily([DailyMetricsData])
	
		enum CodingKeys: String, CandidCodingKey {
			case hourly
			case daily
		}
	}
	
	/// type ChunkContent = variant {
	///   remote : record { args : ChunkRequest; canister : principal };
	///   chunk : record {
	///     total_chunks : nat;
	///     content : vec nat8;
	///     storage_allocation : AllocationRecordStable;
	///     current_chunk : opt nat;
	///   };
	/// };
	enum ChunkContent: Codable {
		case remote(args: ChunkRequest, canister: ICPPrincipal)
		case chunk(total_chunks: BigUInt, content: Data, storage_allocation: AllocationRecordStable, current_chunk: BigUInt?)
	
		enum CodingKeys: String, CandidCodingKey {
			case remote
			case chunk
		}
		enum RemoteCodingKeys: String, CandidCodingKey {
			case args
			case canister
		}
		enum ChunkCodingKeys: String, CandidCodingKey {
			case total_chunks
			case content
			case storage_allocation
			case current_chunk
		}
	}
	
	/// type ChunkRequest = record {
	///   token_id : text;
	///   chunk : opt nat;
	///   library_id : text;
	/// };
	struct ChunkRequest: Codable {
		let token_id: String
		let chunk: BigUInt?
		let library_id: String
	}
	
	/// type ChunkResult = variant { ok : ChunkContent; err : OrigynError };
	enum ChunkResult: Codable {
		case ok(ChunkContent)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type CollectionInfo = record {
	///   multi_canister_count : opt nat;
	///   managers : opt vec principal;
	///   owner : opt principal;
	///   metadata : opt CandyShared;
	///   logo : opt text;
	///   name : opt text;
	///   network : opt principal;
	///   created_at : opt nat64;
	///   fields : opt vec record { text; opt nat; opt nat };
	///   upgraded_at : opt nat64;
	///   token_ids_count : opt nat;
	///   available_space : opt nat;
	///   multi_canister : opt vec principal;
	///   token_ids : opt vec text;
	///   transaction_count : opt nat;
	///   unique_holders : opt nat;
	///   total_supply : opt nat;
	///   symbol : opt text;
	///   allocated_storage : opt nat;
	/// };
	struct CollectionInfo: Codable {
		let multi_canister_count: BigUInt?
		let managers: [ICPPrincipal]?
		let owner: ICPPrincipal?
		let metadata: CandyShared?
		let logo: String?
		let name: String?
		let network: ICPPrincipal?
		let created_at: UInt64?
		let fields: [CandidTuple3<String, BigUInt?, BigUInt?>]?
		let upgraded_at: UInt64?
		let token_ids_count: BigUInt?
		let available_space: BigUInt?
		let multi_canister: [ICPPrincipal]?
		let token_ids: [String]?
		let transaction_count: BigUInt?
		let unique_holders: BigUInt?
		let total_supply: BigUInt?
		let symbol: String?
		let allocated_storage: BigUInt?
	}
	
	/// type CollectionResult = variant { ok : CollectionInfo; err : OrigynError };
	enum CollectionResult: Codable {
		case ok(CollectionInfo)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type DIP721BoolResult = variant { Ok : bool; Err : NftError };
	enum DIP721BoolResult: Codable {
		case Ok(Bool)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type DIP721Metadata = record {
	///   logo : opt text;
	///   name : opt text;
	///   created_at : nat64;
	///   upgraded_at : nat64;
	///   custodians : vec principal;
	///   symbol : opt text;
	/// };
	struct DIP721Metadata: Codable {
		let logo: String?
		let name: String?
		let created_at: UInt64
		let upgraded_at: UInt64
		let custodians: [ICPPrincipal]
		let symbol: String?
	}
	
	/// type DIP721NatResult = variant { Ok : nat; Err : NftError };
	enum DIP721NatResult: Codable {
		case Ok(BigUInt)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type DIP721Stats = record {
	///   cycles : nat;
	///   total_transactions : nat;
	///   total_unique_holders : nat;
	///   total_supply : nat;
	/// };
	struct DIP721Stats: Codable {
		let cycles: BigUInt
		let total_transactions: BigUInt
		let total_unique_holders: BigUInt
		let total_supply: BigUInt
	}
	
	/// type DIP721SupportedInterface = variant {
	///   Burn;
	///   Mint;
	///   Approval;
	///   TransactionHistory;
	/// };
	enum DIP721SupportedInterface: Codable {
		case Burn
		case Mint
		case Approval
		case TransactionHistory
	
		enum CodingKeys: String, CandidCodingKey {
			case Burn
			case Mint
			case Approval
			case TransactionHistory
		}
	}
	
	/// type DIP721TokenMetadata = variant { Ok : TokenMetadata; Err : NftError };
	enum DIP721TokenMetadata: Codable {
		case Ok(TokenMetadata)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type DIP721TokensListMetadata = variant { Ok : vec nat; Err : NftError };
	enum DIP721TokensListMetadata: Codable {
		case Ok([BigUInt])
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type DIP721TokensMetadata = variant { Ok : vec TokenMetadata; Err : NftError };
	enum DIP721TokensMetadata: Codable {
		case Ok([TokenMetadata])
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type DailyMetricsData = record {
	///   updateCalls : nat64;
	///   canisterHeapMemorySize : NumericEntity;
	///   canisterCycles : NumericEntity;
	///   canisterMemorySize : NumericEntity;
	///   timeMillis : int;
	/// };
	struct DailyMetricsData: Codable {
		let updateCalls: UInt64
		let canisterHeapMemorySize: NumericEntity
		let canisterCycles: NumericEntity
		let canisterMemorySize: NumericEntity
		let timeMillis: BigInt
	}
	
	/// type DataCertificate = record { certificate : vec nat8; hash_tree : vec nat8 };
	struct DataCertificate: Codable {
		let certificate: Data
		let hash_tree: Data
	}
	
	/// type DepositDetail = record {
	///   token : TokenSpec__1;
	///   trx_id : opt TransactionID__1;
	///   seller : Account;
	///   buyer : Account;
	///   amount : nat;
	///   sale_id : opt text;
	/// };
	struct DepositDetail: Codable {
		let token: TokenSpec__1
		let trx_id: TransactionID__1?
		let seller: Account
		let buyer: Account
		let amount: BigUInt
		let sale_id: String?
	}
	
	/// type DepositWithdrawDescription = record {
	///   token : TokenSpec__1;
	///   withdraw_to : Account;
	///   buyer : Account;
	///   amount : nat;
	/// };
	struct DepositWithdrawDescription: Codable {
		let token: TokenSpec__1
		let withdraw_to: Account
		let buyer: Account
		let amount: BigUInt
	}
	
	/// type DistributeSaleRequest = record { seller : opt Account };
	struct DistributeSaleRequest: Codable {
		let seller: Account?
	}
	
	/// type DutchParams = record {
	///   time_unit : variant { day : nat; hour : nat; minute : nat };
	///   decay_type : variant { flat : nat; percent : float64 };
	/// };
	struct DutchParams: Codable {
		let time_unit: UnnamedType7
		let decay_type: UnnamedType8
	}
	
	/// type EXTBalanceRequest = record { token : EXTTokenIdentifier; user : EXTUser };
	struct EXTBalanceRequest: Codable {
		let token: EXTTokenIdentifier
		let user: EXTUser
	}
	
	/// type EXTBalanceResult = variant { ok : EXTBalance; err : EXTCommonError };
	enum EXTBalanceResult: Codable {
		case ok(EXTBalance)
		case err(EXTCommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type EXTBearerResult = variant {
	///   ok : EXTAccountIdentifier;
	///   err : EXTCommonError;
	/// };
	enum EXTBearerResult: Codable {
		case ok(EXTAccountIdentifier)
		case err(EXTCommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type EXTCommonError = variant {
	///   InvalidToken : EXTTokenIdentifier;
	///   Other : text;
	/// };
	enum EXTCommonError: Codable {
		case InvalidToken(EXTTokenIdentifier)
		case Other(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case InvalidToken
			case Other
		}
	}
	
	/// type EXTMetadata = variant {
	///   fungible : record {
	///     decimals : nat8;
	///     metadata : opt vec nat8;
	///     name : text;
	///     symbol : text;
	///   };
	///   nonfungible : record { metadata : opt vec nat8 };
	/// };
	enum EXTMetadata: Codable {
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
	
	/// type EXTMetadataResult = variant { ok : EXTMetadata; err : EXTCommonError };
	enum EXTMetadataResult: Codable {
		case ok(EXTMetadata)
		case err(EXTCommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type EXTTokensResult = variant {
	///   ok : vec EXTTokensResponse;
	///   err : EXTCommonError;
	/// };
	enum EXTTokensResult: Codable {
		case ok([EXTTokensResponse])
		case err(EXTCommonError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type EXTTransferRequest = record {
	///   to : EXTUser;
	///   token : EXTTokenIdentifier;
	///   notify : bool;
	///   from : EXTUser;
	///   memo : EXTMemo;
	///   subaccount : opt EXTSubAccount;
	///   amount : EXTBalance;
	/// };
	struct EXTTransferRequest: Codable {
		let to: EXTUser
		let token: EXTTokenIdentifier
		let notify: Bool
		let from: EXTUser
		let memo: EXTMemo
		let subaccount: EXTSubAccount?
		let amount: EXTBalance
	}
	
	/// type EXTTransferResponse = variant {
	///   ok : EXTBalance;
	///   err : variant {
	///     CannotNotify : EXTAccountIdentifier;
	///     InsufficientBalance;
	///     InvalidToken : EXTTokenIdentifier;
	///     Rejected;
	///     Unauthorized : EXTAccountIdentifier;
	///     Other : text;
	///   };
	/// };
	enum EXTTransferResponse: Codable {
		case ok(EXTBalance)
		case err(UnnamedType10)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type EXTUser = variant { "principal" : principal; address : text };
	enum EXTUser: Codable {
		case principal(ICPPrincipal)
		case address(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case principal
			case address
		}
	}
	
	/// type EndingType = variant { date : int; timeout : nat };
	enum EndingType: Codable {
		case date(BigInt)
		case timeout(BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case date
			case timeout
		}
	}
	
	/// type Errors = variant {
	///   nyi;
	///   storage_configuration_error;
	///   escrow_withdraw_payment_failed;
	///   token_not_found;
	///   owner_not_found;
	///   content_not_found;
	///   auction_ended;
	///   out_of_range;
	///   sale_id_does_not_match;
	///   sale_not_found;
	///   kyc_fail;
	///   item_not_owned;
	///   property_not_found;
	///   validate_trx_wrong_host;
	///   withdraw_too_large;
	///   content_not_deserializable;
	///   bid_too_low;
	///   validate_deposit_wrong_amount;
	///   existing_sale_found;
	///   noop;
	///   asset_mismatch;
	///   escrow_cannot_be_removed;
	///   deposit_burned;
	///   cannot_restage_minted_token;
	///   cannot_find_status_in_metadata;
	///   receipt_data_mismatch;
	///   validate_deposit_failed;
	///   unreachable;
	///   unauthorized_access;
	///   item_already_minted;
	///   no_escrow_found;
	///   escrow_owner_not_the_owner;
	///   improper_interface;
	///   app_id_not_found;
	///   token_non_transferable;
	///   kyc_error;
	///   sale_not_over;
	///   escrow_not_large_enough;
	///   update_class_error;
	///   malformed_metadata;
	///   token_id_mismatch;
	///   id_not_found_in_metadata;
	///   auction_not_started;
	///   low_fee_balance;
	///   library_not_found;
	///   attempt_to_stage_system_data;
	///   no_fee_accounts_provided;
	///   validate_deposit_wrong_buyer;
	///   not_enough_storage;
	///   sales_withdraw_payment_failed;
	/// };
	enum Errors: Codable {
		case nyi
		case storage_configuration_error
		case escrow_withdraw_payment_failed
		case token_not_found
		case owner_not_found
		case content_not_found
		case auction_ended
		case out_of_range
		case sale_id_does_not_match
		case sale_not_found
		case kyc_fail
		case item_not_owned
		case property_not_found
		case validate_trx_wrong_host
		case withdraw_too_large
		case content_not_deserializable
		case bid_too_low
		case validate_deposit_wrong_amount
		case existing_sale_found
		case noop
		case asset_mismatch
		case escrow_cannot_be_removed
		case deposit_burned
		case cannot_restage_minted_token
		case cannot_find_status_in_metadata
		case receipt_data_mismatch
		case validate_deposit_failed
		case unreachable
		case unauthorized_access
		case item_already_minted
		case no_escrow_found
		case escrow_owner_not_the_owner
		case improper_interface
		case app_id_not_found
		case token_non_transferable
		case kyc_error
		case sale_not_over
		case escrow_not_large_enough
		case update_class_error
		case malformed_metadata
		case token_id_mismatch
		case id_not_found_in_metadata
		case auction_not_started
		case low_fee_balance
		case library_not_found
		case attempt_to_stage_system_data
		case no_fee_accounts_provided
		case validate_deposit_wrong_buyer
		case not_enough_storage
		case sales_withdraw_payment_failed
	
		enum CodingKeys: String, CandidCodingKey {
			case nyi
			case storage_configuration_error
			case escrow_withdraw_payment_failed
			case token_not_found
			case owner_not_found
			case content_not_found
			case auction_ended
			case out_of_range
			case sale_id_does_not_match
			case sale_not_found
			case kyc_fail
			case item_not_owned
			case property_not_found
			case validate_trx_wrong_host
			case withdraw_too_large
			case content_not_deserializable
			case bid_too_low
			case validate_deposit_wrong_amount
			case existing_sale_found
			case noop
			case asset_mismatch
			case escrow_cannot_be_removed
			case deposit_burned
			case cannot_restage_minted_token
			case cannot_find_status_in_metadata
			case receipt_data_mismatch
			case validate_deposit_failed
			case unreachable
			case unauthorized_access
			case item_already_minted
			case no_escrow_found
			case escrow_owner_not_the_owner
			case improper_interface
			case app_id_not_found
			case token_non_transferable
			case kyc_error
			case sale_not_over
			case escrow_not_large_enough
			case update_class_error
			case malformed_metadata
			case token_id_mismatch
			case id_not_found_in_metadata
			case auction_not_started
			case low_fee_balance
			case library_not_found
			case attempt_to_stage_system_data
			case no_fee_accounts_provided
			case validate_deposit_wrong_buyer
			case not_enough_storage
			case sales_withdraw_payment_failed
		}
	}
	
	/// type EscrowReceipt = record {
	///   token : TokenSpec;
	///   token_id : text;
	///   seller : Account__1;
	///   buyer : Account__1;
	///   amount : nat;
	/// };
	struct EscrowReceipt: Codable {
		let token: TokenSpec
		let token_id: String
		let seller: Account__1
		let buyer: Account__1
		let amount: BigUInt
	}
	
	/// type EscrowRecord = record {
	///   token : TokenSpec__2;
	///   token_id : text;
	///   seller : Account__2;
	///   lock_to_date : opt int;
	///   buyer : Account__2;
	///   amount : nat;
	///   sale_id : opt text;
	///   account_hash : opt vec nat8;
	/// };
	struct EscrowRecord: Codable {
		let token: TokenSpec__2
		let token_id: String
		let seller: Account__2
		let lock_to_date: BigInt?
		let buyer: Account__2
		let amount: BigUInt
		let sale_id: String?
		let account_hash: Data?
	}
	
	/// type EscrowRecord__1 = record {
	///   token : TokenSpec__1;
	///   token_id : text;
	///   seller : Account;
	///   lock_to_date : opt int;
	///   buyer : Account;
	///   amount : nat;
	///   sale_id : opt text;
	///   account_hash : opt vec nat8;
	/// };
	struct EscrowRecord__1: Codable {
		let token: TokenSpec__1
		let token_id: String
		let seller: Account
		let lock_to_date: BigInt?
		let buyer: Account
		let amount: BigUInt
		let sale_id: String?
		let account_hash: Data?
	}
	
	/// type EscrowRequest = record {
	///   token_id : text;
	///   deposit : DepositDetail;
	///   lock_to_date : opt int;
	/// };
	struct EscrowRequest: Codable {
		let token_id: String
		let deposit: DepositDetail
		let lock_to_date: BigInt?
	}
	
	/// type EscrowResponse = record {
	///   balance : nat;
	///   receipt : EscrowReceipt;
	///   transaction : TransactionRecord;
	/// };
	struct EscrowResponse: Codable {
		let balance: BigUInt
		let receipt: EscrowReceipt
		let transaction: TransactionRecord
	}
	
	/// type FeeDepositRequest = record { token : TokenSpec__1; account : Account };
	struct FeeDepositRequest: Codable {
		let token: TokenSpec__1
		let account: Account
	}
	
	/// type FeeDepositResponse = record {
	///   balance : nat;
	///   transaction : TransactionRecord;
	/// };
	struct FeeDepositResponse: Codable {
		let balance: BigUInt
		let transaction: TransactionRecord
	}
	
	/// type FeeDepositWithdrawDescription = record {
	///   status : variant { locked : record { sale_id : text }; unlocked };
	///   token : TokenSpec__1;
	///   withdraw_to : Account;
	///   account : Account;
	///   amount : nat;
	/// };
	struct FeeDepositWithdrawDescription: Codable {
		let status: UnnamedType11
		let token: TokenSpec__1
		let withdraw_to: Account
		let account: Account
		let amount: BigUInt
	}
	
	/// type GenericValue = variant {
	///   Nat64Content : nat64;
	///   Nat32Content : nat32;
	///   BoolContent : bool;
	///   Nat8Content : nat8;
	///   Int64Content : int64;
	///   IntContent : int;
	///   NatContent : nat;
	///   Nat16Content : nat16;
	///   Int32Content : int32;
	///   Int8Content : int8;
	///   FloatContent : float64;
	///   Int16Content : int16;
	///   BlobContent : vec nat8;
	///   NestedContent : Vec;
	///   Principal : principal;
	///   TextContent : text;
	/// };
	enum GenericValue: Codable {
		case Nat64Content(UInt64)
		case Nat32Content(UInt32)
		case BoolContent(Bool)
		case Nat8Content(UInt8)
		case Int64Content(Int64)
		case IntContent(BigInt)
		case NatContent(BigUInt)
		case Nat16Content(UInt16)
		case Int32Content(Int32)
		case Int8Content(Int8)
		case FloatContent(Double)
		case Int16Content(Int16)
		case BlobContent(Data)
		case NestedContent(Vec)
		case Principal(ICPPrincipal)
		case TextContent(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case Nat64Content
			case Nat32Content
			case BoolContent
			case Nat8Content
			case Int64Content
			case IntContent
			case NatContent
			case Nat16Content
			case Int32Content
			case Int8Content
			case FloatContent
			case Int16Content
			case BlobContent
			case NestedContent
			case Principal
			case TextContent
		}
	}
	
	/// type GetArchivesArgs = record { from : opt principal };
	struct GetArchivesArgs: Codable {
		let from: ICPPrincipal?
	}
	
	/// type GetArchivesResultItem = record {
	///   end : nat;
	///   canister_id : principal;
	///   start : nat;
	/// };
	struct GetArchivesResultItem: Codable {
		let end: BigUInt
		let canister_id: ICPPrincipal
		let start: BigUInt
	}
	
	/// type GetLatestLogMessagesParameters = record {
	///   upToTimeNanos : opt Nanos;
	///   count : nat32;
	///   filter : opt GetLogMessagesFilter;
	/// };
	struct GetLatestLogMessagesParameters: Codable {
		let upToTimeNanos: Nanos?
		let count: UInt32
		let filter: GetLogMessagesFilter?
	}
	
	/// type GetLogMessagesFilter = record {
	///   analyzeCount : nat32;
	///   messageRegex : opt text;
	///   messageContains : opt text;
	/// };
	struct GetLogMessagesFilter: Codable {
		let analyzeCount: UInt32
		let messageRegex: String?
		let messageContains: String?
	}
	
	/// type GetLogMessagesParameters = record {
	///   count : nat32;
	///   filter : opt GetLogMessagesFilter;
	///   fromTimeNanos : opt Nanos;
	/// };
	struct GetLogMessagesParameters: Codable {
		let count: UInt32
		let filter: GetLogMessagesFilter?
		let fromTimeNanos: Nanos?
	}
	
	/// type GetMetricsParameters = record {
	///   dateToMillis : nat;
	///   granularity : MetricsGranularity;
	///   dateFromMillis : nat;
	/// };
	struct GetMetricsParameters: Codable {
		let dateToMillis: BigUInt
		let granularity: MetricsGranularity
		let dateFromMillis: BigUInt
	}
	
	/// type GetTransactionsResult = record {
	///   log_length : nat;
	///   blocks : vec record { id : nat; block : Value__1 };
	///   archived_blocks : vec ArchivedTransactionResponse;
	/// };
	struct GetTransactionsResult: Codable {
		let log_length: BigUInt
		let blocks: [UnnamedType12]
		let archived_blocks: [ArchivedTransactionResponse]
	}
	
	/// type GovernanceRequest = variant {
	///   update_system_var : record { key : text; val : CandyShared; token_id : text };
	///   clear_shared_wallets : text;
	/// };
	enum GovernanceRequest: Codable {
		case update_system_var(key: String, val: CandyShared, token_id: String)
		case clear_shared_wallets(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case update_system_var
			case clear_shared_wallets
		}
		enum Update_system_varCodingKeys: String, CandidCodingKey {
			case key
			case val
			case token_id
		}
	}
	
	/// type GovernanceResponse = variant {
	///   update_system_var : bool;
	///   clear_shared_wallets : bool;
	/// };
	enum GovernanceResponse: Codable {
		case update_system_var(Bool)
		case clear_shared_wallets(Bool)
	
		enum CodingKeys: String, CandidCodingKey {
			case update_system_var
			case clear_shared_wallets
		}
	}
	
	/// type GovernanceResult = variant { ok : GovernanceResponse; err : OrigynError };
	enum GovernanceResult: Codable {
		case ok(GovernanceResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type HTTPResponse = record {
	///   body : vec nat8;
	///   headers : vec HeaderField;
	///   streaming_strategy : opt StreamingStrategy;
	///   status_code : nat16;
	/// };
	struct HTTPResponse: Codable {
		let body: Data
		let headers: [HeaderField]
		let streaming_strategy: StreamingStrategy?
		let status_code: UInt16
	}
	
	/// type HistoryResult = variant { ok : vec TransactionRecord; err : OrigynError };
	enum HistoryResult: Codable {
		case ok([TransactionRecord])
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type HourlyMetricsData = record {
	///   updateCalls : UpdateCallsAggregatedData;
	///   canisterHeapMemorySize : CanisterHeapMemoryAggregatedData;
	///   canisterCycles : CanisterCyclesAggregatedData;
	///   canisterMemorySize : CanisterMemoryAggregatedData;
	///   timeMillis : int;
	/// };
	struct HourlyMetricsData: Codable {
		let updateCalls: UpdateCallsAggregatedData
		let canisterHeapMemorySize: CanisterHeapMemoryAggregatedData
		let canisterCycles: CanisterCyclesAggregatedData
		let canisterMemorySize: CanisterMemoryAggregatedData
		let timeMillis: BigInt
	}
	
	/// type HttpRequest = record {
	///   url : text;
	///   method : text;
	///   body : vec nat8;
	///   headers : vec HeaderField;
	/// };
	struct HttpRequest: Codable {
		let url: String
		let method: String
		let body: Data
		let headers: [HeaderField]
	}
	
	/// type ICTokenSpec = record {
	///   id : opt nat;
	///   fee : opt nat;
	///   decimals : nat;
	///   canister : principal;
	///   standard : variant { ICRC1; EXTFungible; DIP20; Other : CandyShared; Ledger };
	///   symbol : text;
	/// };
	struct ICTokenSpec: Codable {
		let id: BigUInt?
		let fee: BigUInt?
		let decimals: BigUInt
		let canister: ICPPrincipal
		let standard: UnnamedType13
		let symbol: String
	}
	
	/// type IndexType = variant { Stable; StableTyped; Managed };
	enum IndexType: Codable {
		case Stable
		case StableTyped
		case Managed
	
		enum CodingKeys: String, CandidCodingKey {
			case Stable
			case StableTyped
			case Managed
		}
	}
	
	/// type InstantFeature = variant {
	///   fee_schema : text;
	///   fee_accounts : FeeAccountsParams;
	/// };
	enum InstantFeature: Codable {
		case fee_schema(String)
		case fee_accounts(FeeAccountsParams)
	
		enum CodingKeys: String, CandidCodingKey {
			case fee_schema
			case fee_accounts
		}
	}
	
	/// type LogMessagesData = record {
	///   data : Data;
	///   timeNanos : Nanos;
	///   message : text;
	///   caller : Caller;
	/// };
	struct LogMessagesData: Codable {
		let data: C_Data
		let timeNanos: Nanos
		let message: String
		let caller: Caller
	}
	
	/// type ManageCollectionCommand = variant {
	///   UpdateOwner : principal;
	///   UpdateManagers : vec principal;
	///   UpdateMetadata : record { text; opt CandyShared; bool };
	///   UpdateAnnounceCanister : opt principal;
	///   UpdateNetwork : opt principal;
	///   UpdateSymbol : opt text;
	///   UpdateLogo : opt text;
	///   UpdateName : opt text;
	/// };
	enum ManageCollectionCommand: Codable {
		case UpdateOwner(ICPPrincipal)
		case UpdateManagers([ICPPrincipal])
		case UpdateMetadata(String, CandyShared?, Bool)
		case UpdateAnnounceCanister(ICPPrincipal?)
		case UpdateNetwork(ICPPrincipal?)
		case UpdateSymbol(String?)
		case UpdateLogo(String?)
		case UpdateName(String?)
	
		enum CodingKeys: String, CandidCodingKey {
			case UpdateOwner
			case UpdateManagers
			case UpdateMetadata
			case UpdateAnnounceCanister
			case UpdateNetwork
			case UpdateSymbol
			case UpdateLogo
			case UpdateName
		}
	}
	
	/// type ManageSaleRequest = variant {
	///   bid : BidRequest;
	///   escrow_deposit : EscrowRequest;
	///   fee_deposit : FeeDepositRequest;
	///   recognize_escrow : EscrowRequest;
	///   withdraw : WithdrawRequest;
	///   ask_subscribe : AskSubscribeRequest;
	///   end_sale : text;
	///   refresh_offers : opt Account;
	///   distribute_sale : DistributeSaleRequest;
	///   open_sale : text;
	/// };
	enum ManageSaleRequest: Codable {
		case bid(BidRequest)
		case escrow_deposit(EscrowRequest)
		case fee_deposit(FeeDepositRequest)
		case recognize_escrow(EscrowRequest)
		case withdraw(WithdrawRequest)
		case ask_subscribe(AskSubscribeRequest)
		case end_sale(String)
		case refresh_offers(Account?)
		case distribute_sale(DistributeSaleRequest)
		case open_sale(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case bid
			case escrow_deposit
			case fee_deposit
			case recognize_escrow
			case withdraw
			case ask_subscribe
			case end_sale
			case refresh_offers
			case distribute_sale
			case open_sale
		}
	}
	
	/// type ManageSaleResponse = variant {
	///   bid : BidResponse;
	///   escrow_deposit : EscrowResponse;
	///   fee_deposit : FeeDepositResponse;
	///   recognize_escrow : RecognizeEscrowResponse;
	///   withdraw : WithdrawResponse;
	///   ask_subscribe : AskSubscribeResponse;
	///   end_sale : EndSaleResponse;
	///   refresh_offers : vec EscrowRecord__1;
	///   distribute_sale : DistributeSaleResponse;
	///   open_sale : bool;
	/// };
	enum ManageSaleResponse: Codable {
		case bid(BidResponse)
		case escrow_deposit(EscrowResponse)
		case fee_deposit(FeeDepositResponse)
		case recognize_escrow(RecognizeEscrowResponse)
		case withdraw(WithdrawResponse)
		case ask_subscribe(AskSubscribeResponse)
		case end_sale(EndSaleResponse)
		case refresh_offers([EscrowRecord__1])
		case distribute_sale(DistributeSaleResponse)
		case open_sale(Bool)
	
		enum CodingKeys: String, CandidCodingKey {
			case bid
			case escrow_deposit
			case fee_deposit
			case recognize_escrow
			case withdraw
			case ask_subscribe
			case end_sale
			case refresh_offers
			case distribute_sale
			case open_sale
		}
	}
	
	/// type ManageSaleResult = variant { ok : ManageSaleResponse; err : OrigynError };
	enum ManageSaleResult: Codable {
		case ok(ManageSaleResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type ManageStorageRequest = variant {
	///   add_storage_canisters : vec record {
	///     principal;
	///     nat;
	///     record { nat; nat; nat };
	///   };
	///   configure_storage : variant { stableBtree : opt nat; heap : opt nat };
	/// };
	enum ManageStorageRequest: Codable {
		case add_storage_canisters([CandidTuple3<ICPPrincipal, BigUInt, CandidTuple3<BigUInt, BigUInt, BigUInt>>])
		case configure_storage(UnnamedType14)
	
		enum CodingKeys: String, CandidCodingKey {
			case add_storage_canisters
			case configure_storage
		}
	}
	
	/// type ManageStorageResponse = variant {
	///   add_storage_canisters : record { nat; nat };
	///   configure_storage : record { nat; nat };
	/// };
	enum ManageStorageResponse: Codable {
		case add_storage_canisters(BigUInt, BigUInt)
		case configure_storage(BigUInt, BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case add_storage_canisters
			case configure_storage
		}
	}
	
	/// type ManageStorageResult = variant {
	///   ok : ManageStorageResponse;
	///   err : OrigynError;
	/// };
	enum ManageStorageResult: Codable {
		case ok(ManageStorageResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type MarketTransferRequest = record {
	///   token_id : text;
	///   sales_config : SalesConfig;
	/// };
	struct MarketTransferRequest: Codable {
		let token_id: String
		let sales_config: SalesConfig
	}
	
	/// type MarketTransferResult = variant {
	///   ok : MarketTransferRequestReponse;
	///   err : OrigynError;
	/// };
	enum MarketTransferResult: Codable {
		case ok(MarketTransferRequestReponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type MetricsGranularity = variant { hourly; daily };
	enum MetricsGranularity: Codable {
		case hourly
		case daily
	
		enum CodingKeys: String, CandidCodingKey {
			case hourly
			case daily
		}
	}
	
	/// type MinIncreaseType = variant { amount : nat; percentage : float64 };
	enum MinIncreaseType: Codable {
		case amount(BigUInt)
		case percentage(Double)
	
		enum CodingKeys: String, CandidCodingKey {
			case amount
			case percentage
		}
	}
	
	/// type NFTBackupChunk = record {
	///   sales_balances : StableSalesBalances;
	///   offers : StableOffers;
	///   collection_data : StableCollectionData;
	///   nft_ledgers : StableNftLedger;
	///   canister : principal;
	///   allocations : vec record { record { text; text }; AllocationRecordStable };
	///   nft_sales : vec record { text; SaleStatusShared };
	///   buckets : vec record { principal; StableBucketData };
	///   escrow_balances : StableEscrowBalances;
	/// };
	struct NFTBackupChunk: Codable {
		let sales_balances: StableSalesBalances
		let offers: StableOffers
		let collection_data: StableCollectionData
		let nft_ledgers: StableNftLedger
		let canister: ICPPrincipal
		let allocations: [CandidTuple2<CandidTuple2<String, String>, AllocationRecordStable>]
		let nft_sales: [CandidTuple2<String, SaleStatusShared>]
		let buckets: [CandidTuple2<ICPPrincipal, StableBucketData>]
		let escrow_balances: StableEscrowBalances
	}
	
	/// type NFTInfoResult = variant { ok : NFTInfoStable; err : OrigynError };
	enum NFTInfoResult: Codable {
		case ok(NFTInfoStable)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type NFTInfoStable = record {
	///   metadata : CandyShared;
	///   current_sale : opt SaleStatusShared;
	/// };
	struct NFTInfoStable: Codable {
		let metadata: CandyShared
		let current_sale: SaleStatusShared?
	}
	
	/// type NFTUpdateRequest = variant {
	///   update : record {
	///     token_id : text;
	///     update : UpdateRequestShared;
	///     app_id : text;
	///   };
	///   replace : record { token_id : text; data : CandyShared };
	/// };
	enum NFTUpdateRequest: Codable {
		case update(token_id: String, update: UpdateRequestShared, app_id: String)
		case replace(token_id: String, data: CandyShared)
	
		enum CodingKeys: String, CandidCodingKey {
			case update
			case replace
		}
		enum UpdateCodingKeys: String, CandidCodingKey {
			case token_id
			case update
			case app_id
		}
		enum ReplaceCodingKeys: String, CandidCodingKey {
			case token_id
			case data
		}
	}
	
	/// type NFTUpdateResult = variant { ok : NFTUpdateResponse; err : OrigynError };
	enum NFTUpdateResult: Codable {
		case ok(NFTUpdateResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type NftError = variant {
	///   UnauthorizedOperator;
	///   SelfTransfer;
	///   TokenNotFound;
	///   UnauthorizedOwner;
	///   TxNotFound;
	///   SelfApprove;
	///   OperatorNotFound;
	///   ExistedNFT;
	///   OwnerNotFound;
	///   Other : text;
	/// };
	enum NftError: Codable {
		case UnauthorizedOperator
		case SelfTransfer
		case TokenNotFound
		case UnauthorizedOwner
		case TxNotFound
		case SelfApprove
		case OperatorNotFound
		case ExistedNFT
		case OwnerNotFound
		case Other(String)
	
		enum CodingKeys: String, CandidCodingKey {
			case UnauthorizedOperator
			case SelfTransfer
			case TokenNotFound
			case UnauthorizedOwner
			case TxNotFound
			case SelfApprove
			case OperatorNotFound
			case ExistedNFT
			case OwnerNotFound
			case Other
		}
	}
	
	/// type Nft_Canister = service {
	///   __advance_time : (int) -> (int);
	///   __set_time_mode : (variant { test; standard }) -> (bool);
	///   __supports : () -> (vec record { text; text }) query;
	///   __version : () -> (text) query;
	///   back_up : (nat) -> (
	///       variant { eof : NFTBackupChunk; data : NFTBackupChunk },
	///     ) query;
	///   balance : (EXTBalanceRequest) -> (EXTBalanceResult) query;
	///   balanceEXT : (EXTBalanceRequest) -> (EXTBalanceResult) query;
	///   balance_of_batch_nft_origyn : (vec Account) -> (vec BalanceResult) query;
	///   balance_of_nft_origyn : (Account) -> (BalanceResult) query;
	///   balance_of_secure_batch_nft_origyn : (vec Account) -> (vec BalanceResult);
	///   balance_of_secure_nft_origyn : (Account) -> (BalanceResult);
	///   bearer : (EXTTokenIdentifier) -> (EXTBearerResult) query;
	///   bearerEXT : (EXTTokenIdentifier) -> (EXTBearerResult) query;
	///   bearer_batch_nft_origyn : (vec text) -> (vec BearerResult) query;
	///   bearer_batch_secure_nft_origyn : (vec text) -> (vec BearerResult);
	///   bearer_nft_origyn : (text) -> (BearerResult) query;
	///   bearer_secure_nft_origyn : (text) -> (BearerResult);
	///   canister_status : (record { canister_id : canister_id }) -> (canister_status);
	///   chunk_nft_origyn : (ChunkRequest) -> (ChunkResult) query;
	///   chunk_secure_nft_origyn : (ChunkRequest) -> (ChunkResult);
	///   collectCanisterMetrics : () -> () query;
	///   collection_nft_origyn : (opt vec record { text; opt nat; opt nat }) -> (
	///       CollectionResult,
	///     ) query;
	///   collection_secure_nft_origyn : (
	///       opt vec record { text; opt nat; opt nat },
	///     ) -> (CollectionResult);
	///   collection_update_batch_nft_origyn : (vec ManageCollectionCommand) -> (
	///       vec OrigynBoolResult,
	///     );
	///   collection_update_nft_origyn : (ManageCollectionCommand) -> (
	///       OrigynBoolResult,
	///     );
	///   cycles : () -> (nat) query;
	///   dip721_balance_of : (principal) -> (nat) query;
	///   dip721_custodians : () -> (vec principal) query;
	///   dip721_is_approved_for_all : (principal, principal) -> (
	///       DIP721BoolResult,
	///     ) query;
	///   dip721_logo : () -> (opt text) query;
	///   dip721_metadata : () -> (DIP721Metadata) query;
	///   dip721_name : () -> (opt text) query;
	///   dip721_operator_token_identifiers : (principal) -> (
	///       DIP721TokensListMetadata,
	///     ) query;
	///   dip721_operator_token_metadata : (principal) -> (DIP721TokensMetadata) query;
	///   dip721_owner_of : (nat) -> (OwnerOfResponse) query;
	///   dip721_owner_token_identifiers : (principal) -> (
	///       DIP721TokensListMetadata,
	///     ) query;
	///   dip721_owner_token_metadata : (principal) -> (DIP721TokensMetadata) query;
	///   dip721_stats : () -> (DIP721Stats) query;
	///   dip721_supported_interfaces : () -> (vec DIP721SupportedInterface) query;
	///   dip721_symbol : () -> (opt text) query;
	///   dip721_token_metadata : (nat) -> (DIP721TokenMetadata) query;
	///   dip721_total_supply : () -> (nat) query;
	///   dip721_total_transactions : () -> (nat) query;
	///   dip721_transfer : (principal, nat) -> (DIP721NatResult);
	///   dip721_transfer_from : (principal, principal, nat) -> (DIP721NatResult);
	///   getCanisterLog : (opt CanisterLogRequest) -> (opt CanisterLogResponse) query;
	///   getCanisterMetrics : (GetMetricsParameters) -> (opt CanisterMetrics) query;
	///   getEXTTokenIdentifier : (text) -> (text) query;
	///   get_access_key : () -> (OrigynTextResult) query;
	///   get_halt : () -> (bool) query;
	///   get_nat_as_token_id_origyn : (nat) -> (text) query;
	///   get_tip : () -> (Tip) query;
	///   get_token_id_as_nat : (text) -> (nat) query;
	///   governance_batch_nft_origyn : (vec GovernanceRequest) -> (
	///       vec GovernanceResult,
	///     );
	///   governance_nft_origyn : (GovernanceRequest) -> (GovernanceResult);
	///   history_batch_nft_origyn : (vec record { text; opt nat; opt nat }) -> (
	///       vec HistoryResult,
	///     ) query;
	///   history_batch_secure_nft_origyn : (vec record { text; opt nat; opt nat }) -> (
	///       vec HistoryResult,
	///     );
	///   history_nft_origyn : (text, opt nat, opt nat) -> (HistoryResult) query;
	///   history_secure_nft_origyn : (text, opt nat, opt nat) -> (HistoryResult);
	///   http_access_key : () -> (OrigynTextResult);
	///   http_request : (HttpRequest) -> (HTTPResponse) query;
	///   http_request_streaming_callback : (StreamingCallbackToken) -> (
	///       StreamingCallbackResponse,
	///     ) query;
	///   icrc3_get_archives : (GetArchivesArgs) -> (GetArchivesResult) query;
	///   icrc3_get_blocks : (vec TransactionRange) -> (GetTransactionsResult) query;
	///   icrc3_get_tip_certificate : () -> (opt DataCertificate) query;
	///   icrc3_supported_block_types : () -> (vec BlockType) query;
	///   icrc7_approve : (ApprovalArgs) -> (ApprovalResult);
	///   icrc7_atomic_batch_transfers : () -> (opt bool) query;
	///   icrc7_balance_of : (vec Account__3) -> (vec nat) query;
	///   icrc7_collection_metadata : () -> (CollectionMetadata) query;
	///   icrc7_default_take_value : () -> (opt nat) query;
	///   icrc7_description : () -> (opt text) query;
	///   icrc7_logo : () -> (opt text) query;
	///   icrc7_max_approvals_per_token_or_collection : () -> (opt nat) query;
	///   icrc7_max_memo_size : () -> (opt nat) query;
	///   icrc7_max_query_batch_size : () -> (opt nat) query;
	///   icrc7_max_revoke_approvals : () -> (opt nat) query;
	///   icrc7_max_take_value : () -> (opt nat) query;
	///   icrc7_max_update_batch_size : () -> (opt nat) query;
	///   icrc7_name : () -> (text) query;
	///   icrc7_owner_of : (vec nat) -> (vec opt Account__3) query;
	///   icrc7_permitted_drift : () -> (opt nat) query;
	///   icrc7_supply_cap : () -> (opt nat) query;
	///   icrc7_supported_standards : () -> (vec SupportedStandard) query;
	///   icrc7_symbol : () -> (text) query;
	///   icrc7_token_metadata : (vec nat) -> (
	///       vec opt vec record { text; Value },
	///     ) query;
	///   icrc7_tokens : (opt nat, opt nat32) -> (vec nat) query;
	///   icrc7_tokens_of : (Account__3, opt nat, opt nat32) -> (vec nat) query;
	///   icrc7_total_supply : () -> (nat) query;
	///   icrc7_transfer : (vec TransferArgs) -> (TransferResult);
	///   icrc7_transfer_fee : (nat) -> (opt nat) query;
	///   icrc7_tx_window : () -> (opt nat) query;
	///   manage_storage_nft_origyn : (ManageStorageRequest) -> (ManageStorageResult);
	///   market_transfer_batch_nft_origyn : (vec MarketTransferRequest) -> (
	///       vec MarketTransferResult,
	///     );
	///   market_transfer_nft_origyn : (MarketTransferRequest) -> (
	///       MarketTransferResult,
	///     );
	///   metadata : () -> (DIP721Metadata) query;
	///   metadataExt : (EXTTokenIdentifier) -> (EXTMetadataResult) query;
	///   mint_batch_nft_origyn : (vec record { text; Account }) -> (
	///       vec OrigynTextResult,
	///     );
	///   mint_nft_origyn : (text, Account) -> (OrigynTextResult);
	///   nftStreamingCallback : (StreamingCallbackToken) -> (
	///       StreamingCallbackResponse,
	///     ) query;
	///   nft_batch_origyn : (vec text) -> (vec NFTInfoResult) query;
	///   nft_batch_secure_origyn : (vec text) -> (vec NFTInfoResult);
	///   nft_origyn : (text) -> (NFTInfoResult) query;
	///   nft_secure_origyn : (text) -> (NFTInfoResult);
	///   operaterTokenMetadata : (principal) -> (DIP721TokensMetadata) query;
	///   ownerOf : (nat) -> (OwnerOfResponse) query;
	///   ownerTokenMetadata : (principal) -> (DIP721TokensMetadata) query;
	///   sale_batch_nft_origyn : (vec ManageSaleRequest) -> (vec ManageSaleResult);
	///   sale_info_batch_nft_origyn : (vec SaleInfoRequest) -> (
	///       vec SaleInfoResult,
	///     ) query;
	///   sale_info_batch_secure_nft_origyn : (vec SaleInfoRequest) -> (
	///       vec SaleInfoResult,
	///     );
	///   sale_info_nft_origyn : (SaleInfoRequest) -> (SaleInfoResult) query;
	///   sale_info_secure_nft_origyn : (SaleInfoRequest) -> (SaleInfoResult);
	///   sale_nft_origyn : (ManageSaleRequest) -> (ManageSaleResult);
	///   set_data_harvester : (nat) -> ();
	///   set_halt : (bool) -> ();
	///   share_wallet_nft_origyn : (ShareWalletRequest) -> (OwnerUpdateResult);
	///   stage_batch_nft_origyn : (vec record { metadata : CandyShared }) -> (
	///       vec OrigynTextResult,
	///     );
	///   stage_library_batch_nft_origyn : (vec StageChunkArg) -> (
	///       vec StageLibraryResult,
	///     );
	///   stage_library_nft_origyn : (StageChunkArg) -> (StageLibraryResult);
	///   stage_nft_origyn : (record { metadata : CandyShared }) -> (OrigynTextResult);
	///   state_size : () -> (StateSize) query;
	///   storage_info_nft_origyn : () -> (StorageMetricsResult) query;
	///   storage_info_secure_nft_origyn : () -> (StorageMetricsResult);
	///   tokens_ext : (text) -> (EXTTokensResult) query;
	///   transfer : (EXTTransferRequest) -> (EXTTransferResponse);
	///   transferDip721 : (principal, nat) -> (DIP721NatResult);
	///   transferEXT : (EXTTransferRequest) -> (EXTTransferResponse);
	///   transferFrom : (principal, principal, nat) -> (DIP721NatResult);
	///   transferFromDip721 : (principal, principal, nat) -> (DIP721NatResult);
	///   update_app_nft_origyn : (NFTUpdateRequest) -> (NFTUpdateResult);
	///   update_icrc3 : (vec UpdateSetting) -> (vec bool);
	///   wallet_receive : () -> (nat);
	///   whoami : () -> (principal) query;
	/// };
	class Nft_Canister: ICPService {
		/// __advance_time : (int) -> (int);
		func __advance_time(_ arg0: BigInt, sender: ICPSigningPrincipal? = nil) async throws -> BigInt {
			let caller = ICPCall<BigInt, BigInt>(canister, "__advance_time")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// __set_time_mode : (variant { test; standard }) -> (bool);
		func __set_time_mode(_ arg0: UnnamedType15, sender: ICPSigningPrincipal? = nil) async throws -> Bool {
			let caller = ICPCall<UnnamedType15, Bool>(canister, "__set_time_mode")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// __supports : () -> (vec record { text; text }) query;
		func __supports(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<String, String>] {
			let caller = ICPQueryNoArgs<[CandidTuple2<String, String>]>(canister, "__supports")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// __version : () -> (text) query;
		func __version(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "__version")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// back_up : (nat) -> (
		///       variant { eof : NFTBackupChunk; data : NFTBackupChunk },
		///     ) query;
		func back_up(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> UnnamedType16 {
			let caller = ICPQuery<BigUInt, UnnamedType16>(canister, "back_up")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balance : (EXTBalanceRequest) -> (EXTBalanceResult) query;
		func balance(_ arg0: EXTBalanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTBalanceResult {
			let caller = ICPQuery<EXTBalanceRequest, EXTBalanceResult>(canister, "balance")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balanceEXT : (EXTBalanceRequest) -> (EXTBalanceResult) query;
		func balanceEXT(_ arg0: EXTBalanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTBalanceResult {
			let caller = ICPQuery<EXTBalanceRequest, EXTBalanceResult>(canister, "balanceEXT")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balance_of_batch_nft_origyn : (vec Account) -> (vec BalanceResult) query;
		func balance_of_batch_nft_origyn(_ arg0: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BalanceResult] {
			let caller = ICPQuery<[Account], [BalanceResult]>(canister, "balance_of_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balance_of_nft_origyn : (Account) -> (BalanceResult) query;
		func balance_of_nft_origyn(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> BalanceResult {
			let caller = ICPQuery<Account, BalanceResult>(canister, "balance_of_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balance_of_secure_batch_nft_origyn : (vec Account) -> (vec BalanceResult);
		func balance_of_secure_batch_nft_origyn(_ arg0: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BalanceResult] {
			let caller = ICPCall<[Account], [BalanceResult]>(canister, "balance_of_secure_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balance_of_secure_nft_origyn : (Account) -> (BalanceResult);
		func balance_of_secure_nft_origyn(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> BalanceResult {
			let caller = ICPCall<Account, BalanceResult>(canister, "balance_of_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearer : (EXTTokenIdentifier) -> (EXTBearerResult) query;
		func bearer(_ arg0: EXTTokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> EXTBearerResult {
			let caller = ICPQuery<EXTTokenIdentifier, EXTBearerResult>(canister, "bearer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearerEXT : (EXTTokenIdentifier) -> (EXTBearerResult) query;
		func bearerEXT(_ arg0: EXTTokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> EXTBearerResult {
			let caller = ICPQuery<EXTTokenIdentifier, EXTBearerResult>(canister, "bearerEXT")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearer_batch_nft_origyn : (vec text) -> (vec BearerResult) query;
		func bearer_batch_nft_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [BearerResult] {
			let caller = ICPQuery<[String], [BearerResult]>(canister, "bearer_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearer_batch_secure_nft_origyn : (vec text) -> (vec BearerResult);
		func bearer_batch_secure_nft_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [BearerResult] {
			let caller = ICPCall<[String], [BearerResult]>(canister, "bearer_batch_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearer_nft_origyn : (text) -> (BearerResult) query;
		func bearer_nft_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> BearerResult {
			let caller = ICPQuery<String, BearerResult>(canister, "bearer_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// bearer_secure_nft_origyn : (text) -> (BearerResult);
		func bearer_secure_nft_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> BearerResult {
			let caller = ICPCall<String, BearerResult>(canister, "bearer_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// canister_status : (record { canister_id : canister_id }) -> (canister_status);
		func canister_status(_ arg0: UnnamedType17, sender: ICPSigningPrincipal? = nil) async throws -> canister_status {
			let caller = ICPCall<UnnamedType17, canister_status>(canister, "canister_status")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// chunk_nft_origyn : (ChunkRequest) -> (ChunkResult) query;
		func chunk_nft_origyn(_ arg0: ChunkRequest, sender: ICPSigningPrincipal? = nil) async throws -> ChunkResult {
			let caller = ICPQuery<ChunkRequest, ChunkResult>(canister, "chunk_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// chunk_secure_nft_origyn : (ChunkRequest) -> (ChunkResult);
		func chunk_secure_nft_origyn(_ arg0: ChunkRequest, sender: ICPSigningPrincipal? = nil) async throws -> ChunkResult {
			let caller = ICPCall<ChunkRequest, ChunkResult>(canister, "chunk_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// collectCanisterMetrics : () -> () query;
		func collectCanisterMetrics(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPQueryNoArgsNoResult(canister, "collectCanisterMetrics")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// collection_nft_origyn : (opt vec record { text; opt nat; opt nat }) -> (
		///       CollectionResult,
		///     ) query;
		func collection_nft_origyn(_ arg0: [CandidTuple3<String, BigUInt?, BigUInt?>]?, sender: ICPSigningPrincipal? = nil) async throws -> CollectionResult {
			let caller = ICPQuery<[CandidTuple3<String, BigUInt?, BigUInt?>]?, CollectionResult>(canister, "collection_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// collection_secure_nft_origyn : (
		///       opt vec record { text; opt nat; opt nat },
		///     ) -> (CollectionResult);
		func collection_secure_nft_origyn(_ arg0: [CandidTuple3<String, BigUInt?, BigUInt?>]?, sender: ICPSigningPrincipal? = nil) async throws -> CollectionResult {
			let caller = ICPCall<[CandidTuple3<String, BigUInt?, BigUInt?>]?, CollectionResult>(canister, "collection_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// collection_update_batch_nft_origyn : (vec ManageCollectionCommand) -> (
		///       vec OrigynBoolResult,
		///     );
		func collection_update_batch_nft_origyn(_ arg0: [ManageCollectionCommand], sender: ICPSigningPrincipal? = nil) async throws -> [OrigynBoolResult] {
			let caller = ICPCall<[ManageCollectionCommand], [OrigynBoolResult]>(canister, "collection_update_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// collection_update_nft_origyn : (ManageCollectionCommand) -> (
		///       OrigynBoolResult,
		///     );
		func collection_update_nft_origyn(_ arg0: ManageCollectionCommand, sender: ICPSigningPrincipal? = nil) async throws -> OrigynBoolResult {
			let caller = ICPCall<ManageCollectionCommand, OrigynBoolResult>(canister, "collection_update_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// cycles : () -> (nat) query;
		func cycles(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "cycles")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_balance_of : (principal) -> (nat) query;
		func dip721_balance_of(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQuery<ICPPrincipal, BigUInt>(canister, "dip721_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_custodians : () -> (vec principal) query;
		func dip721_custodians(sender: ICPSigningPrincipal? = nil) async throws -> [ICPPrincipal] {
			let caller = ICPQueryNoArgs<[ICPPrincipal]>(canister, "dip721_custodians")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_is_approved_for_all : (principal, principal) -> (
		///       DIP721BoolResult,
		///     ) query;
		func dip721_is_approved_for_all(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721BoolResult {
			let caller = ICPQuery<ICPFunctionArgs2<ICPPrincipal, ICPPrincipal>, DIP721BoolResult>(canister, "dip721_is_approved_for_all")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_logo : () -> (opt text) query;
		func dip721_logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "dip721_logo")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_metadata : () -> (DIP721Metadata) query;
		func dip721_metadata(sender: ICPSigningPrincipal? = nil) async throws -> DIP721Metadata {
			let caller = ICPQueryNoArgs<DIP721Metadata>(canister, "dip721_metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_name : () -> (opt text) query;
		func dip721_name(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "dip721_name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_operator_token_identifiers : (principal) -> (
		///       DIP721TokensListMetadata,
		///     ) query;
		func dip721_operator_token_identifiers(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensListMetadata {
			let caller = ICPQuery<ICPPrincipal, DIP721TokensListMetadata>(canister, "dip721_operator_token_identifiers")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_operator_token_metadata : (principal) -> (DIP721TokensMetadata) query;
		func dip721_operator_token_metadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
			let caller = ICPQuery<ICPPrincipal, DIP721TokensMetadata>(canister, "dip721_operator_token_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_owner_of : (nat) -> (OwnerOfResponse) query;
		func dip721_owner_of(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> OwnerOfResponse {
			let caller = ICPQuery<BigUInt, OwnerOfResponse>(canister, "dip721_owner_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_owner_token_identifiers : (principal) -> (
		///       DIP721TokensListMetadata,
		///     ) query;
		func dip721_owner_token_identifiers(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensListMetadata {
			let caller = ICPQuery<ICPPrincipal, DIP721TokensListMetadata>(canister, "dip721_owner_token_identifiers")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_owner_token_metadata : (principal) -> (DIP721TokensMetadata) query;
		func dip721_owner_token_metadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
			let caller = ICPQuery<ICPPrincipal, DIP721TokensMetadata>(canister, "dip721_owner_token_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_stats : () -> (DIP721Stats) query;
		func dip721_stats(sender: ICPSigningPrincipal? = nil) async throws -> DIP721Stats {
			let caller = ICPQueryNoArgs<DIP721Stats>(canister, "dip721_stats")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_supported_interfaces : () -> (vec DIP721SupportedInterface) query;
		func dip721_supported_interfaces(sender: ICPSigningPrincipal? = nil) async throws -> [DIP721SupportedInterface] {
			let caller = ICPQueryNoArgs<[DIP721SupportedInterface]>(canister, "dip721_supported_interfaces")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_symbol : () -> (opt text) query;
		func dip721_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "dip721_symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_token_metadata : (nat) -> (DIP721TokenMetadata) query;
		func dip721_token_metadata(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokenMetadata {
			let caller = ICPQuery<BigUInt, DIP721TokenMetadata>(canister, "dip721_token_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_total_supply : () -> (nat) query;
		func dip721_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "dip721_total_supply")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_total_transactions : () -> (nat) query;
		func dip721_total_transactions(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "dip721_total_transactions")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_transfer : (principal, nat) -> (DIP721NatResult);
		func dip721_transfer(_ arg0: ICPPrincipal, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, DIP721NatResult>(canister, "dip721_transfer")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_transfer_from : (principal, principal, nat) -> (DIP721NatResult);
		func dip721_transfer_from(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, _ arg2: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, ICPPrincipal, BigUInt>, DIP721NatResult>(canister, "dip721_transfer_from")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// getCanisterLog : (opt CanisterLogRequest) -> (opt CanisterLogResponse) query;
		func getCanisterLog(_ arg0: CanisterLogRequest?, sender: ICPSigningPrincipal? = nil) async throws -> CanisterLogResponse? {
			let caller = ICPQuery<CanisterLogRequest?, CanisterLogResponse?>(canister, "getCanisterLog")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// getCanisterMetrics : (GetMetricsParameters) -> (opt CanisterMetrics) query;
		func getCanisterMetrics(_ arg0: GetMetricsParameters, sender: ICPSigningPrincipal? = nil) async throws -> CanisterMetrics? {
			let caller = ICPQuery<GetMetricsParameters, CanisterMetrics?>(canister, "getCanisterMetrics")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// getEXTTokenIdentifier : (text) -> (text) query;
		func getEXTTokenIdentifier(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQuery<String, String>(canister, "getEXTTokenIdentifier")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_access_key : () -> (OrigynTextResult) query;
		func get_access_key(sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
			let caller = ICPQueryNoArgs<OrigynTextResult>(canister, "get_access_key")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_halt : () -> (bool) query;
		func get_halt(sender: ICPSigningPrincipal? = nil) async throws -> Bool {
			let caller = ICPQueryNoArgs<Bool>(canister, "get_halt")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_nat_as_token_id_origyn : (nat) -> (text) query;
		func get_nat_as_token_id_origyn(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQuery<BigUInt, String>(canister, "get_nat_as_token_id_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_tip : () -> (Tip) query;
		func get_tip(sender: ICPSigningPrincipal? = nil) async throws -> Tip {
			let caller = ICPQueryNoArgs<Tip>(canister, "get_tip")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_token_id_as_nat : (text) -> (nat) query;
		func get_token_id_as_nat(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQuery<String, BigUInt>(canister, "get_token_id_as_nat")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// governance_batch_nft_origyn : (vec GovernanceRequest) -> (
		///       vec GovernanceResult,
		///     );
		func governance_batch_nft_origyn(_ arg0: [GovernanceRequest], sender: ICPSigningPrincipal? = nil) async throws -> [GovernanceResult] {
			let caller = ICPCall<[GovernanceRequest], [GovernanceResult]>(canister, "governance_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// governance_nft_origyn : (GovernanceRequest) -> (GovernanceResult);
		func governance_nft_origyn(_ arg0: GovernanceRequest, sender: ICPSigningPrincipal? = nil) async throws -> GovernanceResult {
			let caller = ICPCall<GovernanceRequest, GovernanceResult>(canister, "governance_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// history_batch_nft_origyn : (vec record { text; opt nat; opt nat }) -> (
		///       vec HistoryResult,
		///     ) query;
		func history_batch_nft_origyn(_ arg0: [CandidTuple3<String, BigUInt?, BigUInt?>], sender: ICPSigningPrincipal? = nil) async throws -> [HistoryResult] {
			let caller = ICPQuery<[CandidTuple3<String, BigUInt?, BigUInt?>], [HistoryResult]>(canister, "history_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// history_batch_secure_nft_origyn : (vec record { text; opt nat; opt nat }) -> (
		///       vec HistoryResult,
		///     );
		func history_batch_secure_nft_origyn(_ arg0: [CandidTuple3<String, BigUInt?, BigUInt?>], sender: ICPSigningPrincipal? = nil) async throws -> [HistoryResult] {
			let caller = ICPCall<[CandidTuple3<String, BigUInt?, BigUInt?>], [HistoryResult]>(canister, "history_batch_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// history_nft_origyn : (text, opt nat, opt nat) -> (HistoryResult) query;
		func history_nft_origyn(_ arg0: String, _ arg1: BigUInt?, _ arg2: BigUInt?, sender: ICPSigningPrincipal? = nil) async throws -> HistoryResult {
			let caller = ICPQuery<ICPFunctionArgs3<String, BigUInt?, BigUInt?>, HistoryResult>(canister, "history_nft_origyn")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// history_secure_nft_origyn : (text, opt nat, opt nat) -> (HistoryResult);
		func history_secure_nft_origyn(_ arg0: String, _ arg1: BigUInt?, _ arg2: BigUInt?, sender: ICPSigningPrincipal? = nil) async throws -> HistoryResult {
			let caller = ICPCall<ICPFunctionArgs3<String, BigUInt?, BigUInt?>, HistoryResult>(canister, "history_secure_nft_origyn")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// http_access_key : () -> (OrigynTextResult);
		func http_access_key(sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
			let caller = ICPCallNoArgs<OrigynTextResult>(canister, "http_access_key")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// http_request : (HttpRequest) -> (HTTPResponse) query;
		func http_request(_ arg0: HttpRequest, sender: ICPSigningPrincipal? = nil) async throws -> HTTPResponse {
			let caller = ICPQuery<HttpRequest, HTTPResponse>(canister, "http_request")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// http_request_streaming_callback : (StreamingCallbackToken) -> (
		///       StreamingCallbackResponse,
		///     ) query;
		func http_request_streaming_callback(_ arg0: StreamingCallbackToken, sender: ICPSigningPrincipal? = nil) async throws -> StreamingCallbackResponse {
			let caller = ICPQuery<StreamingCallbackToken, StreamingCallbackResponse>(canister, "http_request_streaming_callback")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc3_get_archives : (GetArchivesArgs) -> (GetArchivesResult) query;
		func icrc3_get_archives(_ arg0: GetArchivesArgs, sender: ICPSigningPrincipal? = nil) async throws -> GetArchivesResult {
			let caller = ICPQuery<GetArchivesArgs, GetArchivesResult>(canister, "icrc3_get_archives")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc3_get_blocks : (vec TransactionRange) -> (GetTransactionsResult) query;
		func icrc3_get_blocks(_ arg0: [TransactionRange], sender: ICPSigningPrincipal? = nil) async throws -> GetTransactionsResult {
			let caller = ICPQuery<[TransactionRange], GetTransactionsResult>(canister, "icrc3_get_blocks")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc3_get_tip_certificate : () -> (opt DataCertificate) query;
		func icrc3_get_tip_certificate(sender: ICPSigningPrincipal? = nil) async throws -> DataCertificate? {
			let caller = ICPQueryNoArgs<DataCertificate?>(canister, "icrc3_get_tip_certificate")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc3_supported_block_types : () -> (vec BlockType) query;
		func icrc3_supported_block_types(sender: ICPSigningPrincipal? = nil) async throws -> [BlockType] {
			let caller = ICPQueryNoArgs<[BlockType]>(canister, "icrc3_supported_block_types")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_approve : (ApprovalArgs) -> (ApprovalResult);
		func icrc7_approve(_ arg0: ApprovalArgs, sender: ICPSigningPrincipal? = nil) async throws -> ApprovalResult {
			let caller = ICPCall<ApprovalArgs, ApprovalResult>(canister, "icrc7_approve")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_atomic_batch_transfers : () -> (opt bool) query;
		func icrc7_atomic_batch_transfers(sender: ICPSigningPrincipal? = nil) async throws -> Bool? {
			let caller = ICPQueryNoArgs<Bool?>(canister, "icrc7_atomic_batch_transfers")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_balance_of : (vec Account__3) -> (vec nat) query;
		func icrc7_balance_of(_ arg0: [Account__3], sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
			let caller = ICPQuery<[Account__3], [BigUInt]>(canister, "icrc7_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_collection_metadata : () -> (CollectionMetadata) query;
		func icrc7_collection_metadata(sender: ICPSigningPrincipal? = nil) async throws -> CollectionMetadata {
			let caller = ICPQueryNoArgs<CollectionMetadata>(canister, "icrc7_collection_metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_default_take_value : () -> (opt nat) query;
		func icrc7_default_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_default_take_value")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_description : () -> (opt text) query;
		func icrc7_description(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "icrc7_description")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_logo : () -> (opt text) query;
		func icrc7_logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "icrc7_logo")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_approvals_per_token_or_collection : () -> (opt nat) query;
		func icrc7_max_approvals_per_token_or_collection(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_approvals_per_token_or_collection")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_memo_size : () -> (opt nat) query;
		func icrc7_max_memo_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_memo_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_query_batch_size : () -> (opt nat) query;
		func icrc7_max_query_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_query_batch_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_revoke_approvals : () -> (opt nat) query;
		func icrc7_max_revoke_approvals(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_revoke_approvals")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_take_value : () -> (opt nat) query;
		func icrc7_max_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_take_value")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_update_batch_size : () -> (opt nat) query;
		func icrc7_max_update_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_update_batch_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_name : () -> (text) query;
		func icrc7_name(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "icrc7_name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_owner_of : (vec nat) -> (vec opt Account__3) query;
		func icrc7_owner_of(_ arg0: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [Account__3?] {
			let caller = ICPQuery<[BigUInt], [Account__3?]>(canister, "icrc7_owner_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_permitted_drift : () -> (opt nat) query;
		func icrc7_permitted_drift(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_permitted_drift")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_supply_cap : () -> (opt nat) query;
		func icrc7_supply_cap(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_supply_cap")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_supported_standards : () -> (vec SupportedStandard) query;
		func icrc7_supported_standards(sender: ICPSigningPrincipal? = nil) async throws -> [SupportedStandard] {
			let caller = ICPQueryNoArgs<[SupportedStandard]>(canister, "icrc7_supported_standards")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_symbol : () -> (text) query;
		func icrc7_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "icrc7_symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_token_metadata : (vec nat) -> (
		///       vec opt vec record { text; Value },
		///     ) query;
		func icrc7_token_metadata(_ arg0: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [[CandidTuple2<String, Value>]?] {
			let caller = ICPQuery<[BigUInt], [[CandidTuple2<String, Value>]?]>(canister, "icrc7_token_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_tokens : (opt nat, opt nat32) -> (vec nat) query;
		func icrc7_tokens(_ arg0: BigUInt?, _ arg1: UInt32?, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
			let caller = ICPQuery<ICPFunctionArgs2<BigUInt?, UInt32?>, [BigUInt]>(canister, "icrc7_tokens")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// icrc7_tokens_of : (Account__3, opt nat, opt nat32) -> (vec nat) query;
		func icrc7_tokens_of(_ arg0: Account__3, _ arg1: BigUInt?, _ arg2: UInt32?, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
			let caller = ICPQuery<ICPFunctionArgs3<Account__3, BigUInt?, UInt32?>, [BigUInt]>(canister, "icrc7_tokens_of")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// icrc7_total_supply : () -> (nat) query;
		func icrc7_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "icrc7_total_supply")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_transfer : (vec TransferArgs) -> (TransferResult);
		func icrc7_transfer(_ arg0: [TransferArgs], sender: ICPSigningPrincipal? = nil) async throws -> TransferResult {
			let caller = ICPCall<[TransferArgs], TransferResult>(canister, "icrc7_transfer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_transfer_fee : (nat) -> (opt nat) query;
		func icrc7_transfer_fee(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQuery<BigUInt, BigUInt?>(canister, "icrc7_transfer_fee")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_tx_window : () -> (opt nat) query;
		func icrc7_tx_window(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_tx_window")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// manage_storage_nft_origyn : (ManageStorageRequest) -> (ManageStorageResult);
		func manage_storage_nft_origyn(_ arg0: ManageStorageRequest, sender: ICPSigningPrincipal? = nil) async throws -> ManageStorageResult {
			let caller = ICPCall<ManageStorageRequest, ManageStorageResult>(canister, "manage_storage_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// market_transfer_batch_nft_origyn : (vec MarketTransferRequest) -> (
		///       vec MarketTransferResult,
		///     );
		func market_transfer_batch_nft_origyn(_ arg0: [MarketTransferRequest], sender: ICPSigningPrincipal? = nil) async throws -> [MarketTransferResult] {
			let caller = ICPCall<[MarketTransferRequest], [MarketTransferResult]>(canister, "market_transfer_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// market_transfer_nft_origyn : (MarketTransferRequest) -> (
		///       MarketTransferResult,
		///     );
		func market_transfer_nft_origyn(_ arg0: MarketTransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> MarketTransferResult {
			let caller = ICPCall<MarketTransferRequest, MarketTransferResult>(canister, "market_transfer_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_metadata : () -> (DIP721Metadata) query;
		func metadata(sender: ICPSigningPrincipal? = nil) async throws -> DIP721Metadata {
			let caller = ICPQueryNoArgs<DIP721Metadata>(canister, "metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// metadataExt : (EXTTokenIdentifier) -> (EXTMetadataResult) query;
		func metadataExt(_ arg0: EXTTokenIdentifier, sender: ICPSigningPrincipal? = nil) async throws -> EXTMetadataResult {
			let caller = ICPQuery<EXTTokenIdentifier, EXTMetadataResult>(canister, "metadataExt")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// mint_batch_nft_origyn : (vec record { text; Account }) -> (
		///       vec OrigynTextResult,
		///     );
		func mint_batch_nft_origyn(_ arg0: [CandidTuple2<String, Account>], sender: ICPSigningPrincipal? = nil) async throws -> [OrigynTextResult] {
			let caller = ICPCall<[CandidTuple2<String, Account>], [OrigynTextResult]>(canister, "mint_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// mint_nft_origyn : (text, Account) -> (OrigynTextResult);
		func mint_nft_origyn(_ arg0: String, _ arg1: Account, sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
			let caller = ICPCall<ICPFunctionArgs2<String, Account>, OrigynTextResult>(canister, "mint_nft_origyn")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// nftStreamingCallback : (StreamingCallbackToken) -> (
		///       StreamingCallbackResponse,
		///     ) query;
		func nftStreamingCallback(_ arg0: StreamingCallbackToken, sender: ICPSigningPrincipal? = nil) async throws -> StreamingCallbackResponse {
			let caller = ICPQuery<StreamingCallbackToken, StreamingCallbackResponse>(canister, "nftStreamingCallback")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// nft_batch_origyn : (vec text) -> (vec NFTInfoResult) query;
		func nft_batch_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [NFTInfoResult] {
			let caller = ICPQuery<[String], [NFTInfoResult]>(canister, "nft_batch_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// nft_batch_secure_origyn : (vec text) -> (vec NFTInfoResult);
		func nft_batch_secure_origyn(_ arg0: [String], sender: ICPSigningPrincipal? = nil) async throws -> [NFTInfoResult] {
			let caller = ICPCall<[String], [NFTInfoResult]>(canister, "nft_batch_secure_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// balance_of_batch_nft_origyn : (vec Account) -> (vec BalanceResult) query;
		func nft_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> NFTInfoResult {
			let caller = ICPQuery<String, NFTInfoResult>(canister, "nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// nft_secure_origyn : (text) -> (NFTInfoResult);
		func nft_secure_origyn(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> NFTInfoResult {
			let caller = ICPCall<String, NFTInfoResult>(canister, "nft_secure_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// operaterTokenMetadata : (principal) -> (DIP721TokensMetadata) query;
		func operaterTokenMetadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
			let caller = ICPQuery<ICPPrincipal, DIP721TokensMetadata>(canister, "operaterTokenMetadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ownerOf : (nat) -> (OwnerOfResponse) query;
		func ownerOf(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> OwnerOfResponse {
			let caller = ICPQuery<BigUInt, OwnerOfResponse>(canister, "ownerOf")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ownerTokenMetadata : (principal) -> (DIP721TokensMetadata) query;
		func ownerTokenMetadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> DIP721TokensMetadata {
			let caller = ICPQuery<ICPPrincipal, DIP721TokensMetadata>(canister, "ownerTokenMetadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// sale_batch_nft_origyn : (vec ManageSaleRequest) -> (vec ManageSaleResult);
		func sale_batch_nft_origyn(_ arg0: [ManageSaleRequest], sender: ICPSigningPrincipal? = nil) async throws -> [ManageSaleResult] {
			let caller = ICPCall<[ManageSaleRequest], [ManageSaleResult]>(canister, "sale_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// sale_info_batch_nft_origyn : (vec SaleInfoRequest) -> (
		///       vec SaleInfoResult,
		///     ) query;
		func sale_info_batch_nft_origyn(_ arg0: [SaleInfoRequest], sender: ICPSigningPrincipal? = nil) async throws -> [SaleInfoResult] {
			let caller = ICPQuery<[SaleInfoRequest], [SaleInfoResult]>(canister, "sale_info_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// sale_info_batch_secure_nft_origyn : (vec SaleInfoRequest) -> (
		///       vec SaleInfoResult,
		///     );
		func sale_info_batch_secure_nft_origyn(_ arg0: [SaleInfoRequest], sender: ICPSigningPrincipal? = nil) async throws -> [SaleInfoResult] {
			let caller = ICPCall<[SaleInfoRequest], [SaleInfoResult]>(canister, "sale_info_batch_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// sale_info_nft_origyn : (SaleInfoRequest) -> (SaleInfoResult) query;
		func sale_info_nft_origyn(_ arg0: SaleInfoRequest, sender: ICPSigningPrincipal? = nil) async throws -> SaleInfoResult {
			let caller = ICPQuery<SaleInfoRequest, SaleInfoResult>(canister, "sale_info_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// sale_info_secure_nft_origyn : (SaleInfoRequest) -> (SaleInfoResult);
		func sale_info_secure_nft_origyn(_ arg0: SaleInfoRequest, sender: ICPSigningPrincipal? = nil) async throws -> SaleInfoResult {
			let caller = ICPCall<SaleInfoRequest, SaleInfoResult>(canister, "sale_info_secure_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// sale_nft_origyn : (ManageSaleRequest) -> (ManageSaleResult);
		func sale_nft_origyn(_ arg0: ManageSaleRequest, sender: ICPSigningPrincipal? = nil) async throws -> ManageSaleResult {
			let caller = ICPCall<ManageSaleRequest, ManageSaleResult>(canister, "sale_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// set_data_harvester : (nat) -> ();
		func set_data_harvester(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<BigUInt>(canister, "set_data_harvester")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// set_halt : (bool) -> ();
		func set_halt(_ arg0: Bool, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<Bool>(canister, "set_halt")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// share_wallet_nft_origyn : (ShareWalletRequest) -> (OwnerUpdateResult);
		func share_wallet_nft_origyn(_ arg0: ShareWalletRequest, sender: ICPSigningPrincipal? = nil) async throws -> OwnerUpdateResult {
			let caller = ICPCall<ShareWalletRequest, OwnerUpdateResult>(canister, "share_wallet_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// stage_batch_nft_origyn : (vec record { metadata : CandyShared }) -> (
		///       vec OrigynTextResult,
		///     );
		func stage_batch_nft_origyn(_ arg0: [UnnamedType18], sender: ICPSigningPrincipal? = nil) async throws -> [OrigynTextResult] {
			let caller = ICPCall<[UnnamedType18], [OrigynTextResult]>(canister, "stage_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// stage_library_batch_nft_origyn : (vec StageChunkArg) -> (
		///       vec StageLibraryResult,
		///     );
		func stage_library_batch_nft_origyn(_ arg0: [StageChunkArg], sender: ICPSigningPrincipal? = nil) async throws -> [StageLibraryResult] {
			let caller = ICPCall<[StageChunkArg], [StageLibraryResult]>(canister, "stage_library_batch_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// stage_library_nft_origyn : (StageChunkArg) -> (StageLibraryResult);
		func stage_library_nft_origyn(_ arg0: StageChunkArg, sender: ICPSigningPrincipal? = nil) async throws -> StageLibraryResult {
			let caller = ICPCall<StageChunkArg, StageLibraryResult>(canister, "stage_library_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// stage_nft_origyn : (record { metadata : CandyShared }) -> (OrigynTextResult);
		func stage_nft_origyn(_ arg0: UnnamedType18, sender: ICPSigningPrincipal? = nil) async throws -> OrigynTextResult {
			let caller = ICPCall<UnnamedType18, OrigynTextResult>(canister, "stage_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// state_size : () -> (StateSize) query;
		func state_size(sender: ICPSigningPrincipal? = nil) async throws -> StateSize {
			let caller = ICPQueryNoArgs<StateSize>(canister, "state_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// storage_info_nft_origyn : () -> (StorageMetricsResult) query;
		func storage_info_nft_origyn(sender: ICPSigningPrincipal? = nil) async throws -> StorageMetricsResult {
			let caller = ICPQueryNoArgs<StorageMetricsResult>(canister, "storage_info_nft_origyn")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// storage_info_secure_nft_origyn : () -> (StorageMetricsResult);
		func storage_info_secure_nft_origyn(sender: ICPSigningPrincipal? = nil) async throws -> StorageMetricsResult {
			let caller = ICPCallNoArgs<StorageMetricsResult>(canister, "storage_info_secure_nft_origyn")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// tokens_ext : (text) -> (EXTTokensResult) query;
		func tokens_ext(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> EXTTokensResult {
			let caller = ICPQuery<String, EXTTokensResult>(canister, "tokens_ext")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_transfer : (principal, nat) -> (DIP721NatResult);
		func transfer(_ arg0: EXTTransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTTransferResponse {
			let caller = ICPCall<EXTTransferRequest, EXTTransferResponse>(canister, "transfer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// transferDip721 : (principal, nat) -> (DIP721NatResult);
		func transferDip721(_ arg0: ICPPrincipal, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, DIP721NatResult>(canister, "transferDip721")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// transferEXT : (EXTTransferRequest) -> (EXTTransferResponse);
		func transferEXT(_ arg0: EXTTransferRequest, sender: ICPSigningPrincipal? = nil) async throws -> EXTTransferResponse {
			let caller = ICPCall<EXTTransferRequest, EXTTransferResponse>(canister, "transferEXT")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// transferFrom : (principal, principal, nat) -> (DIP721NatResult);
		func transferFrom(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, _ arg2: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, ICPPrincipal, BigUInt>, DIP721NatResult>(canister, "transferFrom")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// transferFromDip721 : (principal, principal, nat) -> (DIP721NatResult);
		func transferFromDip721(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, _ arg2: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> DIP721NatResult {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, ICPPrincipal, BigUInt>, DIP721NatResult>(canister, "transferFromDip721")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// update_app_nft_origyn : (NFTUpdateRequest) -> (NFTUpdateResult);
		func update_app_nft_origyn(_ arg0: NFTUpdateRequest, sender: ICPSigningPrincipal? = nil) async throws -> NFTUpdateResult {
			let caller = ICPCall<NFTUpdateRequest, NFTUpdateResult>(canister, "update_app_nft_origyn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// update_icrc3 : (vec UpdateSetting) -> (vec bool);
		func update_icrc3(_ arg0: [UpdateSetting], sender: ICPSigningPrincipal? = nil) async throws -> [Bool] {
			let caller = ICPCall<[UpdateSetting], [Bool]>(canister, "update_icrc3")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// wallet_receive : () -> (nat);
		func wallet_receive(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPCallNoArgs<BigUInt>(canister, "wallet_receive")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// whoami : () -> (principal) query;
		func whoami(sender: ICPSigningPrincipal? = nil) async throws -> ICPPrincipal {
			let caller = ICPQueryNoArgs<ICPPrincipal>(canister, "whoami")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
	}
	
	/// type NiftySettlementType = record {
	///   fixed : bool;
	///   interestRatePerSecond : float64;
	///   duration : opt int;
	///   expiration : opt int;
	///   lenderOffer : bool;
	/// };
	struct NiftySettlementType: Codable {
		let fixed: Bool
		let interestRatePerSecond: Double
		let duration: BigInt?
		let expiration: BigInt?
		let lenderOffer: Bool
	}
	
	/// type NumericEntity = record {
	///   avg : nat64;
	///   max : nat64;
	///   min : nat64;
	///   first : nat64;
	///   last : nat64;
	/// };
	struct NumericEntity: Codable {
		let avg: UInt64
		let max: UInt64
		let min: UInt64
		let first: UInt64
		let last: UInt64
	}
	
	/// type OrigynBoolResult = variant { ok : bool; err : OrigynError };
	enum OrigynBoolResult: Codable {
		case ok(Bool)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type OrigynError = record {
	///   "text" : text;
	///   error : Errors;
	///   number : nat32;
	///   flag_point : text;
	/// };
	struct OrigynError: Codable {
		let text: String
		let error: Errors
		let number: UInt32
		let flag_point: String
	}
	
	/// type OrigynTextResult = variant { ok : text; err : OrigynError };
	enum OrigynTextResult: Codable {
		case ok(String)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type OwnerOfResponse = variant { Ok : opt principal; Err : NftError };
	enum OwnerOfResponse: Codable {
		case Ok(ICPPrincipal?)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type OwnerTransferResponse = record {
	///   transaction : TransactionRecord;
	///   assets : vec CandyShared;
	/// };
	struct OwnerTransferResponse: Codable {
		let transaction: TransactionRecord
		let assets: [CandyShared]
	}
	
	/// type OwnerUpdateResult = variant {
	///   ok : OwnerTransferResponse;
	///   err : OrigynError;
	/// };
	enum OwnerUpdateResult: Codable {
		case ok(OwnerTransferResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type PricingConfigShared = variant {
	///   ask : AskConfigShared;
	///   extensible : CandyShared;
	///   instant : InstantConfigShared;
	///   auction : AuctionConfig;
	/// };
	enum PricingConfigShared: Codable {
		case ask(AskConfigShared)
		case extensible(CandyShared)
		case instant(InstantConfigShared)
		case auction(AuctionConfig)
	
		enum CodingKeys: String, CandidCodingKey {
			case ask
			case extensible
			case instant
			case auction
		}
	}
	
	/// type PropertyShared = record {
	///   value : CandyShared;
	///   name : text;
	///   immutable : bool;
	/// };
	struct PropertyShared: Codable {
		let value: CandyShared
		let name: String
		let immutable: Bool
	}
	
	/// type RecognizeEscrowResponse = record {
	///   balance : nat;
	///   receipt : EscrowReceipt;
	///   transaction : opt TransactionRecord;
	/// };
	struct RecognizeEscrowResponse: Codable {
		let balance: BigUInt
		let receipt: EscrowReceipt
		let transaction: TransactionRecord?
	}
	
	/// type RejectDescription = record {
	///   token : TokenSpec__1;
	///   token_id : text;
	///   seller : Account;
	///   buyer : Account;
	/// };
	struct RejectDescription: Codable {
		let token: TokenSpec__1
		let token_id: String
		let seller: Account
		let buyer: Account
	}
	
	/// type SaleInfoRequest = variant {
	///   status : text;
	///   fee_deposit_info : opt Account;
	///   active : opt record { nat; nat };
	///   deposit_info : opt Account;
	///   history : opt record { nat; nat };
	///   escrow_info : EscrowReceipt;
	/// };
	enum SaleInfoRequest: Codable {
		case status(String)
		case fee_deposit_info(Account?)
		case active(CandidTuple2<BigUInt, BigUInt>?)
		case deposit_info(Account?)
		case history(CandidTuple2<BigUInt, BigUInt>?)
		case escrow_info(EscrowReceipt)
	
		enum CodingKeys: String, CandidCodingKey {
			case status
			case fee_deposit_info
			case active
			case deposit_info
			case history
			case escrow_info
		}
	}
	
	/// type SaleInfoResponse = variant {
	///   status : opt SaleStatusShared;
	///   fee_deposit_info : SubAccountInfo;
	///   active : record {
	///     eof : bool;
	///     records : vec record { text; opt SaleStatusShared };
	///     count : nat;
	///   };
	///   deposit_info : SubAccountInfo;
	///   history : record {
	///     eof : bool;
	///     records : vec opt SaleStatusShared;
	///     count : nat;
	///   };
	///   escrow_info : SubAccountInfo;
	/// };
	enum SaleInfoResponse: Codable {
		case status(SaleStatusShared?)
		case fee_deposit_info(SubAccountInfo)
		case active(eof: Bool, records: [CandidTuple2<String, SaleStatusShared?>], count: BigUInt)
		case deposit_info(SubAccountInfo)
		case history(eof: Bool, records: [SaleStatusShared?], count: BigUInt)
		case escrow_info(SubAccountInfo)
	
		enum CodingKeys: String, CandidCodingKey {
			case status
			case fee_deposit_info
			case active
			case deposit_info
			case history
			case escrow_info
		}
		enum ActiveCodingKeys: String, CandidCodingKey {
			case eof
			case records
			case count
		}
		enum HistoryCodingKeys: String, CandidCodingKey {
			case eof
			case records
			case count
		}
	}
	
	/// type SaleInfoResult = variant { ok : SaleInfoResponse; err : OrigynError };
	enum SaleInfoResult: Codable {
		case ok(SaleInfoResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type SaleStatusShared = record {
	///   token_id : text;
	///   sale_type : variant { auction : AuctionStateShared };
	///   broker_id : opt principal;
	///   original_broker_id : opt principal;
	///   sale_id : text;
	/// };
	struct SaleStatusShared: Codable {
		let token_id: String
		let sale_type: UnnamedType19
		let broker_id: ICPPrincipal?
		let original_broker_id: ICPPrincipal?
		let sale_id: String
	}
	
	/// type SalesConfig = record {
	///   broker_id : opt Account__1;
	///   pricing : PricingConfigShared;
	///   escrow_receipt : opt EscrowReceipt__1;
	/// };
	struct SalesConfig: Codable {
		let broker_id: Account__1?
		let pricing: PricingConfigShared
		let escrow_receipt: EscrowReceipt__1?
	}
	
	/// type ShareWalletRequest = record {
	///   to : Account;
	///   token_id : text;
	///   from : Account;
	/// };
	struct ShareWalletRequest: Codable {
		let to: Account
		let token_id: String
		let from: Account
	}
	
	/// type StableBucketData = record {
	///   "principal" : principal;
	///   allocated_space : nat;
	///   date_added : int;
	///   version : record { nat; nat; nat };
	///   b_gateway : bool;
	///   available_space : nat;
	///   allocations : vec record { record { text; text }; int };
	/// };
	struct StableBucketData: Codable {
		let principal: ICPPrincipal
		let allocated_space: BigUInt
		let date_added: BigInt
		let version: CandidTuple3<BigUInt, BigUInt, BigUInt>
		let b_gateway: Bool
		let available_space: BigUInt
		let allocations: [CandidTuple2<CandidTuple2<String, String>, BigInt>]
	}
	
	/// type StableCollectionData = record {
	///   active_bucket : opt principal;
	///   managers : vec principal;
	///   owner : principal;
	///   metadata : opt CandyShared;
	///   logo : opt text;
	///   name : opt text;
	///   network : opt principal;
	///   available_space : nat;
	///   symbol : opt text;
	///   allocated_storage : nat;
	/// };
	struct StableCollectionData: Codable {
		let active_bucket: ICPPrincipal?
		let managers: [ICPPrincipal]
		let owner: ICPPrincipal
		let metadata: CandyShared?
		let logo: String?
		let name: String?
		let network: ICPPrincipal?
		let available_space: BigUInt
		let symbol: String?
		let allocated_storage: BigUInt
	}
	
	/// type StageChunkArg = record {
	///   content : vec nat8;
	///   token_id : text;
	///   chunk : nat;
	///   filedata : CandyShared;
	///   library_id : text;
	/// };
	struct StageChunkArg: Codable {
		let content: Data
		let token_id: String
		let chunk: BigUInt
		let filedata: CandyShared
		let library_id: String
	}
	
	/// type StageLibraryResponse = record { canister : principal };
	struct StageLibraryResponse: Codable {
		let canister: ICPPrincipal
	}
	
	/// type StageLibraryResult = variant {
	///   ok : StageLibraryResponse;
	///   err : OrigynError;
	/// };
	enum StageLibraryResult: Codable {
		case ok(StageLibraryResponse)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type StakeRecord = record { staker : Account; token_id : text; amount : nat };
	struct StakeRecord: Codable {
		let staker: Account
		let token_id: String
		let amount: BigUInt
	}
	
	/// type StateSize = record {
	///   sales_balances : nat;
	///   offers : nat;
	///   nft_ledgers : nat;
	///   allocations : nat;
	///   nft_sales : nat;
	///   buckets : nat;
	///   escrow_balances : nat;
	/// };
	struct StateSize: Codable {
		let sales_balances: BigUInt
		let offers: BigUInt
		let nft_ledgers: BigUInt
		let allocations: BigUInt
		let nft_sales: BigUInt
		let buckets: BigUInt
		let escrow_balances: BigUInt
	}
	
	/// type StorageMetrics = record {
	///   gateway : principal;
	///   available_space : nat;
	///   allocations : vec AllocationRecordStable;
	///   allocated_storage : nat;
	/// };
	struct StorageMetrics: Codable {
		let gateway: ICPPrincipal
		let available_space: BigUInt
		let allocations: [AllocationRecordStable]
		let allocated_storage: BigUInt
	}
	
	/// type StorageMetricsResult = variant { ok : StorageMetrics; err : OrigynError };
	enum StorageMetricsResult: Codable {
		case ok(StorageMetrics)
		case err(OrigynError)
	
		enum CodingKeys: String, CandidCodingKey {
			case ok
			case err
		}
	}
	
	/// type StreamingCallbackResponse = record {
	///   token : opt StreamingCallbackToken;
	///   body : vec nat8;
	/// };
	struct StreamingCallbackResponse: Codable {
		let token: StreamingCallbackToken?
		let body: Data
	}
	
	/// type StreamingCallbackToken = record {
	///   key : text;
	///   index : nat;
	///   content_encoding : text;
	/// };
	struct StreamingCallbackToken: Codable {
		let key: String
		let index: BigUInt
		let content_encoding: String
	}
	
	/// type StreamingStrategy = variant {
	///   Callback : record {
	///     token : StreamingCallbackToken;
	///     callback : func () -> ();
	///   };
	/// };
	enum StreamingStrategy: Codable {
		case Callback(token: StreamingCallbackToken, callback: ICPCallNoArgsNoResult)
	
		enum CodingKeys: String, CandidCodingKey {
			case Callback
		}
		enum CallbackCodingKeys: String, CandidCodingKey {
			case token
			case callback
		}
	}
	
	/// type SubAccountInfo = record {
	///   account_id : vec nat8;
	///   "principal" : principal;
	///   account_id_text : text;
	///   account : record { "principal" : principal; sub_account : vec nat8 };
	/// };
	struct SubAccountInfo: Codable {
		let account_id: Data
		let principal: ICPPrincipal
		let account_id_text: String
		let account: UnnamedType20
	}
	
	/// type SupportedStandard = record { url : text; name : text };
	struct SupportedStandard: Codable {
		let url: String
		let name: String
	}
	
	/// type Tip = record {
	///   last_block_index : vec nat8;
	///   hash_tree : vec nat8;
	///   last_block_hash : vec nat8;
	/// };
	struct Tip: Codable {
		let last_block_index: Data
		let hash_tree: Data
		let last_block_hash: Data
	}
	
	/// type TokenIDFilter = record {
	///   filter_type : variant { allow; block };
	///   token_id : text;
	///   tokens : vec record {
	///     token : TokenSpec__1;
	///     min_amount : opt nat;
	///     max_amount : opt nat;
	///   };
	/// };
	struct TokenIDFilter: Codable {
		let filter_type: UnnamedType21
		let token_id: String
		let tokens: [UnnamedType22]
	}
	
	/// type TokenMetadata = record {
	///   transferred_at : opt nat64;
	///   transferred_by : opt principal;
	///   owner : opt principal;
	///   operator : opt principal;
	///   approved_at : opt nat64;
	///   approved_by : opt principal;
	///   properties : vec record { text; GenericValue };
	///   is_burned : bool;
	///   token_identifier : nat;
	///   burned_at : opt nat64;
	///   burned_by : opt principal;
	///   minted_at : nat64;
	///   minted_by : principal;
	/// };
	struct TokenMetadata: Codable {
		let transferred_at: UInt64?
		let transferred_by: ICPPrincipal?
		let owner: ICPPrincipal?
		let `operator`: ICPPrincipal?
		let approved_at: UInt64?
		let approved_by: ICPPrincipal?
		let properties: [CandidTuple2<String, GenericValue>]
		let is_burned: Bool
		let token_identifier: BigUInt
		let burned_at: UInt64?
		let burned_by: ICPPrincipal?
		let minted_at: UInt64
		let minted_by: ICPPrincipal
	}
	
	/// type TokenSpec = variant { ic : ICTokenSpec; extensible : CandyShared };
	enum TokenSpec: Codable {
		case ic(ICTokenSpec)
		case extensible(CandyShared)
	
		enum CodingKeys: String, CandidCodingKey {
			case ic
			case extensible
		}
	}
	
	/// type TokenSpecFilter = record {
	///   token : TokenSpec__1;
	///   filter_type : variant { allow; block };
	/// };
	struct TokenSpecFilter: Codable {
		let token: TokenSpec__1
		let filter_type: UnnamedType21
	}
	
	/// type TokenSpec__1 = variant { ic : ICTokenSpec__1; extensible : CandyShared };
	enum TokenSpec__1: Codable {
		case ic(ICTokenSpec__1)
		case extensible(CandyShared)
	
		enum CodingKeys: String, CandidCodingKey {
			case ic
			case extensible
		}
	}
	
	/// type TransactionID = variant {
	///   "nat" : nat;
	///   "text" : text;
	///   extensible : CandyShared;
	/// };
	enum TransactionID: Codable {
		case nat(BigUInt)
		case text(String)
		case extensible(CandyShared)
	
		enum CodingKeys: String, CandidCodingKey {
			case nat
			case text
			case extensible
		}
	}
	
	/// type TransactionRange = record { start : nat; length : nat };
	struct TransactionRange: Codable {
		let start: BigUInt
		let length: BigUInt
	}
	
	/// type TransferArgs = record {
	///   to : Account__3;
	///   token_id : nat;
	///   memo : opt vec nat8;
	///   from_subaccount : opt vec nat8;
	///   created_at_time : opt nat64;
	/// };
	struct TransferArgs: Codable {
		let to: Account__3
		let token_id: BigUInt
		let memo: Data?
		let from_subaccount: Data?
		let created_at_time: UInt64?
	}
	
	/// type TransferError = variant {
	///   GenericError : record { message : text; error_code : nat };
	///   Duplicate : record { duplicate_of : nat };
	///   NonExistingTokenId;
	///   Unauthorized;
	///   CreatedInFuture : record { ledger_time : nat64 };
	///   TooOld;
	/// };
	enum TransferError: Codable {
		case GenericError(message: String, error_code: BigUInt)
		case Duplicate(duplicate_of: BigUInt)
		case NonExistingTokenId
		case Unauthorized
		case CreatedInFuture(ledger_time: UInt64)
		case TooOld
	
		enum CodingKeys: String, CandidCodingKey {
			case GenericError
			case Duplicate
			case NonExistingTokenId
			case Unauthorized
			case CreatedInFuture
			case TooOld
		}
		enum GenericErrorCodingKeys: String, CandidCodingKey {
			case message
			case error_code
		}
		enum DuplicateCodingKeys: String, CandidCodingKey {
			case duplicate_of
		}
		enum CreatedInFutureCodingKeys: String, CandidCodingKey {
			case ledger_time
		}
	}
	
	/// type TransferResultItem = record {
	///   token_id : nat;
	///   transfer_result : variant { Ok : nat; Err : TransferError };
	/// };
	struct TransferResultItem: Codable {
		let token_id: BigUInt
		let transfer_result: UnnamedType23
	}
	
	enum UnnamedType0: Codable {
		case Ok(BigUInt)
		case Err(ApprovalError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	struct UnnamedType1: Codable {
		let token_id: BigUInt
		let approval_result: UnnamedType0
	}
	
	enum UnnamedType10: Codable {
		case CannotNotify(EXTAccountIdentifier)
		case InsufficientBalance
		case InvalidToken(EXTTokenIdentifier)
		case Rejected
		case Unauthorized(EXTAccountIdentifier)
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
	
	enum UnnamedType11: Codable {
		case locked(sale_id: String)
		case unlocked
	
		enum CodingKeys: String, CandidCodingKey {
			case locked
			case unlocked
		}
		enum LockedCodingKeys: String, CandidCodingKey {
			case sale_id
		}
	}
	
	struct UnnamedType12: Codable {
		let id: BigUInt
		let block: Value__1
	}
	
	enum UnnamedType13: Codable {
		case ICRC1
		case EXTFungible
		case DIP20
		case Other(CandyShared)
		case Ledger
	
		enum CodingKeys: String, CandidCodingKey {
			case ICRC1
			case EXTFungible
			case DIP20
			case Other
			case Ledger
		}
	}
	
	enum UnnamedType14: Codable {
		case stableBtree(BigUInt?)
		case heap(BigUInt?)
	
		enum CodingKeys: String, CandidCodingKey {
			case stableBtree
			case heap
		}
	}
	
	enum UnnamedType15: Codable {
		case test
		case standard
	
		enum CodingKeys: String, CandidCodingKey {
			case test
			case standard
		}
	}
	
	enum UnnamedType16: Codable {
		case eof(NFTBackupChunk)
		case data(NFTBackupChunk)
	
		enum CodingKeys: String, CandidCodingKey {
			case eof
			case data
		}
	}
	
	struct UnnamedType17: Codable {
		let canister_id: canister_id
	}
	
	struct UnnamedType18: Codable {
		let metadata: CandyShared
	}
	
	enum UnnamedType19: Codable {
		case auction(AuctionStateShared)
	
		enum CodingKeys: String, CandidCodingKey {
			case auction
		}
	}
	
	struct UnnamedType2: Codable {
		let tokens: [TokenSpecFilter]?
		let token_ids: [TokenIDFilter]?
	}
	
	struct UnnamedType20: Codable {
		let principal: ICPPrincipal
		let sub_account: Data
	}
	
	enum UnnamedType21: Codable {
		case allow
		case block
	
		enum CodingKeys: String, CandidCodingKey {
			case allow
			case block
		}
	}
	
	struct UnnamedType22: Codable {
		let token: TokenSpec__1
		let min_amount: BigUInt?
		let max_amount: BigUInt?
	}
	
	enum UnnamedType23: Codable {
		case Ok(BigUInt)
		case Err(TransferError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	enum UnnamedType24: Codable {
		case stopped
		case stopping
		case running
	
		enum CodingKeys: String, CandidCodingKey {
			case stopped
			case stopping
			case running
		}
	}
	
	enum UnnamedType3: Codable {
		case date(BigInt)
		case wait_for_quiet(max: BigUInt, date: BigInt, fade: Double, extension: UInt64)
	
		enum CodingKeys: String, CandidCodingKey {
			case date
			case wait_for_quiet
		}
		enum Wait_for_quietCodingKeys: String, CandidCodingKey {
			case max
			case date
			case fade
			case `extension`
		}
	}
	
	enum UnnamedType4: Codable {
		case closed
		case open
		case not_started
	
		enum CodingKeys: String, CandidCodingKey {
			case closed
			case open
			case not_started
		}
	}
	
	struct UnnamedType5: Codable {
		let token: TokenSpec
		let amount: BigUInt
	}
	
	enum UnnamedType6: Codable {
		case escrow_deposit(token: TokenSpec, token_id: String, trx_id: TransactionID, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
		case fee_deposit(token: TokenSpec, extensible: CandyShared, account: Account__1, amount: BigUInt)
		case canister_network_updated(network: ICPPrincipal, extensible: CandyShared)
		case escrow_withdraw(fee: BigUInt, token: TokenSpec, token_id: String, trx_id: TransactionID, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
		case canister_managers_updated(managers: [ICPPrincipal], extensible: CandyShared)
		case auction_bid(token: TokenSpec, extensible: CandyShared, buyer: Account__1, amount: BigUInt, sale_id: String)
		case burn(from: Account__1?, extensible: CandyShared)
		case data(hash: Data?, extensible: CandyShared, data_dapp: String?, data_path: String?)
		case sale_ended(token: TokenSpec, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt, sale_id: String?)
		case mint(to: Account__1, from: Account__1, sale: UnnamedType5?, extensible: CandyShared)
		case royalty_paid(tag: String, token: TokenSpec, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt, receiver: Account__1, sale_id: String?)
		case extensible(CandyShared)
		case fee_deposit_withdraw(fee: BigUInt, token: TokenSpec, trx_id: TransactionID, extensible: CandyShared, account: Account__1, amount: BigUInt)
		case owner_transfer(to: Account__1, from: Account__1, extensible: CandyShared)
		case sale_opened(pricing: PricingConfigShared, extensible: CandyShared, sale_id: String)
		case canister_owner_updated(owner: ICPPrincipal, extensible: CandyShared)
		case sale_withdraw(fee: BigUInt, token: TokenSpec, token_id: String, trx_id: TransactionID, seller: Account__1, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
		case deposit_withdraw(fee: BigUInt, token: TokenSpec, trx_id: TransactionID, extensible: CandyShared, buyer: Account__1, amount: BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case escrow_deposit
			case fee_deposit
			case canister_network_updated
			case escrow_withdraw
			case canister_managers_updated
			case auction_bid
			case burn
			case data
			case sale_ended
			case mint
			case royalty_paid
			case extensible
			case fee_deposit_withdraw
			case owner_transfer
			case sale_opened
			case canister_owner_updated
			case sale_withdraw
			case deposit_withdraw
		}
		enum Escrow_depositCodingKeys: String, CandidCodingKey {
			case token
			case token_id
			case trx_id
			case seller
			case extensible
			case buyer
			case amount
		}
		enum Fee_depositCodingKeys: String, CandidCodingKey {
			case token
			case extensible
			case account
			case amount
		}
		enum Canister_network_updatedCodingKeys: String, CandidCodingKey {
			case network
			case extensible
		}
		enum Escrow_withdrawCodingKeys: String, CandidCodingKey {
			case fee
			case token
			case token_id
			case trx_id
			case seller
			case extensible
			case buyer
			case amount
		}
		enum Canister_managers_updatedCodingKeys: String, CandidCodingKey {
			case managers
			case extensible
		}
		enum Auction_bidCodingKeys: String, CandidCodingKey {
			case token
			case extensible
			case buyer
			case amount
			case sale_id
		}
		enum BurnCodingKeys: String, CandidCodingKey {
			case from
			case extensible
		}
		enum DataCodingKeys: String, CandidCodingKey {
			case hash
			case extensible
			case data_dapp
			case data_path
		}
		enum Sale_endedCodingKeys: String, CandidCodingKey {
			case token
			case seller
			case extensible
			case buyer
			case amount
			case sale_id
		}
		enum MintCodingKeys: String, CandidCodingKey {
			case to
			case from
			case sale
			case extensible
		}
		enum Royalty_paidCodingKeys: String, CandidCodingKey {
			case tag
			case token
			case seller
			case extensible
			case buyer
			case amount
			case receiver
			case sale_id
		}
		enum Fee_deposit_withdrawCodingKeys: String, CandidCodingKey {
			case fee
			case token
			case trx_id
			case extensible
			case account
			case amount
		}
		enum Owner_transferCodingKeys: String, CandidCodingKey {
			case to
			case from
			case extensible
		}
		enum Sale_openedCodingKeys: String, CandidCodingKey {
			case pricing
			case extensible
			case sale_id
		}
		enum Canister_owner_updatedCodingKeys: String, CandidCodingKey {
			case owner
			case extensible
		}
		enum Sale_withdrawCodingKeys: String, CandidCodingKey {
			case fee
			case token
			case token_id
			case trx_id
			case seller
			case extensible
			case buyer
			case amount
		}
		enum Deposit_withdrawCodingKeys: String, CandidCodingKey {
			case fee
			case token
			case trx_id
			case extensible
			case buyer
			case amount
		}
	}
	
	enum UnnamedType7: Codable {
		case day(BigUInt)
		case hour(BigUInt)
		case minute(BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case day
			case hour
			case minute
		}
	}
	
	enum UnnamedType8: Codable {
		case flat(BigUInt)
		case percent(Double)
	
		enum CodingKeys: String, CandidCodingKey {
			case flat
			case percent
		}
	}
	
	struct UnnamedType9: Codable {
		let locked: BigInt?
		let seller: ICPPrincipal
		let price: UInt64
	}
	
	/// type UpdateModeShared = variant {
	///   Set : CandyShared;
	///   Lock : CandyShared;
	///   Next : vec UpdateShared;
	/// };
	enum UpdateModeShared: Codable {
		case Set(CandyShared)
		case Lock(CandyShared)
		case Next([UpdateShared])
	
		enum CodingKeys: String, CandidCodingKey {
			case Set
			case Lock
			case Next
		}
	}
	
	/// type UpdateRequestShared = record { id : text; update : vec UpdateShared };
	struct UpdateRequestShared: Codable {
		let id: String
		let update: [UpdateShared]
	}
	
	/// type UpdateSetting = variant {
	///   maxRecordsToArchive : nat;
	///   archiveIndexType : IndexType;
	///   maxArchivePages : nat;
	///   settleToRecords : nat;
	///   archiveCycles : nat;
	///   maxActiveRecords : nat;
	///   maxRecordsInArchiveInstance : nat;
	///   archiveControllers : opt opt vec principal;
	/// };
	enum UpdateSetting: Codable {
		case maxRecordsToArchive(BigUInt)
		case archiveIndexType(IndexType)
		case maxArchivePages(BigUInt)
		case settleToRecords(BigUInt)
		case archiveCycles(BigUInt)
		case maxActiveRecords(BigUInt)
		case maxRecordsInArchiveInstance(BigUInt)
		case archiveControllers([ICPPrincipal]??)
	
		enum CodingKeys: String, CandidCodingKey {
			case maxRecordsToArchive
			case archiveIndexType
			case maxArchivePages
			case settleToRecords
			case archiveCycles
			case maxActiveRecords
			case maxRecordsInArchiveInstance
			case archiveControllers
		}
	}
	
	/// type UpdateShared = record { mode : UpdateModeShared; name : text };
	struct UpdateShared: Codable {
		let mode: UpdateModeShared
		let name: String
	}
	
	/// type Value = variant {
	///   Int : int;
	///   Map : vec record { text; Value };
	///   Nat : nat;
	///   Blob : vec nat8;
	///   Text : text;
	///   Array : vec Value;
	/// };
	enum Value: Codable {
		case Int(BigInt)
		case Map([CandidTuple2<String, Value>])
		case Nat(BigUInt)
		case Blob(Data)
		case Text(String)
		case Array([Value])
	
		enum CodingKeys: String, CandidCodingKey {
			case Int
			case Map
			case Nat
			case Blob
			case Text
			case Array
		}
	}
	
	/// type Value__1 = variant {
	///   Int : int;
	///   Map : vec record { text; Value__1 };
	///   Nat : nat;
	///   Blob : vec nat8;
	///   Text : text;
	///   Array : vec Value__1;
	/// };
	enum Value__1: Codable {
		case Int(BigInt)
		case Map([CandidTuple2<String, Value__1>])
		case Nat(BigUInt)
		case Blob(Data)
		case Text(String)
		case Array([Value__1])
	
		enum CodingKeys: String, CandidCodingKey {
			case Int
			case Map
			case Nat
			case Blob
			case Text
			case Array
		}
	}
	
	/// type WaitForQuietType = record { max : nat; fade : float64; extension : nat64 };
	struct WaitForQuietType: Codable {
		let max: BigUInt
		let fade: Double
		let `extension`: UInt64
	}
	
	/// type WithdrawDescription = record {
	///   token : TokenSpec__1;
	///   token_id : text;
	///   seller : Account;
	///   withdraw_to : Account;
	///   buyer : Account;
	///   amount : nat;
	/// };
	struct WithdrawDescription: Codable {
		let token: TokenSpec__1
		let token_id: String
		let seller: Account
		let withdraw_to: Account
		let buyer: Account
		let amount: BigUInt
	}
	
	/// type WithdrawRequest = variant {
	///   reject : RejectDescription;
	///   fee_deposit : FeeDepositWithdrawDescription;
	///   sale : WithdrawDescription;
	///   deposit : DepositWithdrawDescription;
	///   escrow : WithdrawDescription;
	/// };
	enum WithdrawRequest: Codable {
		case reject(RejectDescription)
		case fee_deposit(FeeDepositWithdrawDescription)
		case sale(WithdrawDescription)
		case deposit(DepositWithdrawDescription)
		case escrow(WithdrawDescription)
	
		enum CodingKeys: String, CandidCodingKey {
			case reject
			case fee_deposit
			case sale
			case deposit
			case escrow
		}
	}
	
	/// type canister_status = record {
	///   status : variant { stopped; stopping; running };
	///   memory_size : nat;
	///   cycles : nat;
	///   settings : definite_canister_settings;
	///   module_hash : opt vec nat8;
	/// };
	struct canister_status: Codable {
		let status: UnnamedType24
		let memory_size: BigUInt
		let cycles: BigUInt
		let settings: definite_canister_settings
		let module_hash: Data?
	}
	
	/// type definite_canister_settings = record {
	///   freezing_threshold : nat;
	///   controllers : opt vec principal;
	///   memory_allocation : nat;
	///   compute_allocation : nat;
	/// };
	struct definite_canister_settings: Codable {
		let freezing_threshold: BigUInt
		let controllers: [ICPPrincipal]?
		let memory_allocation: BigUInt
		let compute_allocation: BigUInt
	}
	

	typealias Service = Nft_Canister

}
