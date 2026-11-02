//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum Index {
	/// type Block = Value;
	typealias Block = Value
	
	/// type BlockIndex = nat;
	typealias BlockIndex = BigUInt
	
	/// type Map = vec record { text; Value };
	typealias Map = [CandidTuple2<String, Value>]
	
	/// type SubAccount = blob;
	typealias SubAccount = Data
	
	/// // curl -o index.did "https://raw.githubusercontent.com/dfinity/ic/b9a0f18dd5d6019e3241f205de797bca0d9cc3f8/rs/rosetta-api/icrc1/index-ng/index-ng.did"
	/// type Tokens = nat;
	typealias Tokens = BigUInt
	
	
	/// type Account = record { owner : principal; subaccount : opt SubAccount };
	struct Account: Codable {
		let owner: ICPPrincipal
		let subaccount: SubAccount?
	}
	
	/// type Approve = record {
	///   fee : opt nat;
	///   from : Account;
	///   memo : opt vec nat8;
	///   created_at_time : opt nat64;
	///   amount : nat;
	///   expected_allowance : opt nat;
	///   expires_at : opt nat64;
	///   spender : Account;
	/// };
	struct Approve: Codable {
		let fee: BigUInt?
		let from: Account
		let memo: Data?
		let created_at_time: UInt64?
		let amount: BigUInt
		let expected_allowance: BigUInt?
		let expires_at: UInt64?
		let spender: Account
	}
	
	/// type Burn = record {
	///   from : Account;
	///   memo : opt vec nat8;
	///   created_at_time : opt nat64;
	///   amount : nat;
	///   spender : opt Account;
	/// };
	struct Burn: Codable {
		let from: Account
		let memo: Data?
		let created_at_time: UInt64?
		let amount: BigUInt
		let spender: Account?
	}
	
	/// type FeeCollectorRanges = record {
	///     ranges : vec  record { Account; vec record { BlockIndex; BlockIndex } };
	/// };
	struct FeeCollectorRanges: Codable {
		let ranges: [CandidTuple2<Account, [CandidTuple2<BlockIndex, BlockIndex>]>]
	}
	
	/// type GetAccountTransactionsArgs = record {
	///     account : Account;
	///     // The txid of the last transaction seen by the client.
	///     // If None then the results will start from the most recent
	///     // txid.
	///     start : opt BlockIndex;
	///     // Maximum number of transactions to fetch.
	///     max_results : nat;
	/// };
	struct GetAccountTransactionsArgs: Codable {
		let max_results: BigUInt
		let start: BlockIndex?
		let account: Account
	}
	
	/// type GetBlocksRequest = record {
	///     start : nat;
	///     length : nat;
	/// };
	struct GetBlocksRequest: Codable {
		let start: BigUInt
		let length: BigUInt
	}
	
	/// type GetBlocksResponse = record {
	///     chain_length: nat64;
	///     blocks: vec Block;
	/// };
	struct GetBlocksResponse: Codable {
		let blocks: [Block]
		let chain_length: UInt64
	}
	
	/// type GetTransactions = record {
	///   balance : Tokens;
	///   transactions : vec TransactionWithId;
	///   // The txid of the oldest transaction the account has
	///   oldest_tx_id : opt BlockIndex;
	/// };
	struct GetTransactions: Codable {
		let balance: Tokens
		let transactions: [TransactionWithId]
		let oldest_tx_id: BlockIndex?
	}
	
	/// type GetTransactionsErr = record {
	///   message : text;
	/// };
	struct GetTransactionsErr: Codable {
		let message: String
	}
	
	/// type GetTransactionsResult = variant {
	///   Ok : GetTransactions;
	///   Err : GetTransactionsErr;
	/// };
	enum GetTransactionsResult: Codable {
		case Ok(GetTransactions)
		case Err(GetTransactionsErr)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type IndexArg = variant {
	///     Init: InitArg;
	///     Upgrade: UpgradeArg;
	/// };
	enum IndexArg: Codable {
		case Upgrade(UpgradeArg)
		case Init(InitArg)
	
		enum CodingKeys: String, CandidCodingKey {
			case Upgrade
			case Init
		}
	}
	
	/// type InitArg = record {
	///     ledger_id: principal;
	///     // The interval in seconds in which to retrieve blocks from the ledger. A lower value makes the index more
	///     // responsive in showing new blocks, but increases the consumption of cycles of both the index and ledger canisters.
	///     // A higher values means that it takes longer for new blocks to show up in the index.
	///     retrieve_blocks_from_ledger_interval_seconds : opt nat64;
	/// };
	struct InitArg: Codable {
		let ledger_id: ICPPrincipal
		let retrieve_blocks_from_ledger_interval_seconds: UInt64?
	}
	
	/// type ListSubaccountsArgs = record {
	///     owner: principal;
	///     start: opt SubAccount;
	/// };
	struct ListSubaccountsArgs: Codable {
		let owner: ICPPrincipal
		let start: SubAccount?
	}
	
	/// type Mint = record {
	///   to : Account;
	///   memo : opt vec nat8;
	///   created_at_time : opt nat64;
	///   amount : nat;
	/// };
	struct Mint: Codable {
		let to: Account
		let memo: Data?
		let created_at_time: UInt64?
		let amount: BigUInt
	}
	
	/// type Status = record {
	///     num_blocks_synced : BlockIndex;
	/// };
	struct Status: Codable {
		let num_blocks_synced: BlockIndex
	}
	
	/// type Transaction = record {
	///   burn : opt Burn;
	///   kind : text;
	///   mint : opt Mint;
	///   approve : opt Approve;
	///   timestamp : nat64;
	///   transfer : opt Transfer;
	/// };
	struct Transaction: Codable {
		let burn: Burn?
		let kind: String
		let mint: Mint?
		let approve: Approve?
		let timestamp: UInt64
		let transfer: Transfer?
	}
	
	/// type TransactionWithId = record {
	///   id : BlockIndex;
	///   transaction : Transaction;
	/// };
	struct TransactionWithId: Codable {
		let id: BlockIndex
		let transaction: Transaction
	}
	
	/// type Transfer = record {
	///   to : Account;
	///   fee : opt nat;
	///   from : Account;
	///   memo : opt vec nat8;
	///   created_at_time : opt nat64;
	///   amount : nat;
	///   spender : opt Account;
	/// };
	struct Transfer: Codable {
		let to: Account
		let fee: BigUInt?
		let from: Account
		let memo: Data?
		let created_at_time: UInt64?
		let amount: BigUInt
		let spender: Account?
	}
	
	/// type UpgradeArg = record {
	///     ledger_id: opt principal;
	///     // The interval in seconds in which to retrieve blocks from the ledger. A lower value makes the index more
	///     // responsive in showing new blocks, but increases the consumption of cycles of both the index and ledger canisters.
	///     // A higher values means that it takes longer for new blocks to show up in the index.
	///     retrieve_blocks_from_ledger_interval_seconds : opt nat64;
	/// };
	struct UpgradeArg: Codable {
		let ledger_id: ICPPrincipal?
		let retrieve_blocks_from_ledger_interval_seconds: UInt64?
	}
	
	/// type Value = variant {
	///     Blob : blob;
	///     Text : text;
	///     Nat : nat;
	///     Nat64: nat64;
	///     Int : int;
	///     Array : vec Value;
	///     Map : Map;
	/// };
	enum Value: Codable {
		case Int(BigInt)
		case Map(Map)
		case Nat(BigUInt)
		case Nat64(UInt64)
		case Blob(Data)
		case Text(String)
		case Array([Value])
	
		enum CodingKeys: String, CandidCodingKey {
			case Int
			case Map
			case Nat
			case Nat64
			case Blob
			case Text
			case Array
		}
	}
	

	/// service : (index_arg: opt IndexArg) -> {
	///     get_account_transactions : (GetAccountTransactionsArgs) -> (GetTransactionsResult) query;
	///     get_blocks : (GetBlocksRequest) -> (GetBlocksResponse) query;
	///     get_fee_collectors_ranges : () -> (FeeCollectorRanges) query;
	///     icrc1_balance_of : (Account) -> (Tokens) query;
	///     ledger_id : () -> (principal) query;
	///     list_subaccounts : (ListSubaccountsArgs) -> (vec SubAccount) query;
	///     status : () -> (Status) query;
	/// }
	class Service: ICPService {
		/// get_account_transactions : (GetAccountTransactionsArgs) -> (GetTransactionsResult) query;
		func get_account_transactions(_ arg0: GetAccountTransactionsArgs, sender: ICPSigningPrincipal? = nil) async throws -> GetTransactionsResult {
			let caller = ICPQuery<GetAccountTransactionsArgs, GetTransactionsResult>(canister, "get_account_transactions")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_blocks : (GetBlocksRequest) -> (GetBlocksResponse) query;
		func get_blocks(_ arg0: GetBlocksRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetBlocksResponse {
			let caller = ICPQuery<GetBlocksRequest, GetBlocksResponse>(canister, "get_blocks")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_fee_collectors_ranges : () -> (FeeCollectorRanges) query;
		func get_fee_collectors_ranges(sender: ICPSigningPrincipal? = nil) async throws -> FeeCollectorRanges {
			let caller = ICPQueryNoArgs<FeeCollectorRanges>(canister, "get_fee_collectors_ranges")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_balance_of : (Account) -> (Tokens) query;
		func icrc1_balance_of(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> Tokens {
			let caller = ICPQuery<Account, Tokens>(canister, "icrc1_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ledger_id : () -> (principal) query;
		func ledger_id(sender: ICPSigningPrincipal? = nil) async throws -> ICPPrincipal {
			let caller = ICPQueryNoArgs<ICPPrincipal>(canister, "ledger_id")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// list_subaccounts : (ListSubaccountsArgs) -> (vec SubAccount) query;
		func list_subaccounts(_ arg0: ListSubaccountsArgs, sender: ICPSigningPrincipal? = nil) async throws -> [SubAccount] {
			let caller = ICPQuery<ListSubaccountsArgs, [SubAccount]>(canister, "list_subaccounts")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// status : () -> (Status) query;
		func status(sender: ICPSigningPrincipal? = nil) async throws -> Status {
			let caller = ICPQueryNoArgs<Status>(canister, "status")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
	}

}
