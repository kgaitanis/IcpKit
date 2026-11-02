//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum ICPIndex {
	/// // https://dashboard.internetcomputer.org/canister/qhbym-qaaaa-aaaaa-aaafq-cai
	/// type Account = record { owner : principal; subaccount : opt vec nat8 };
	struct Account: Codable {
		let owner: ICPPrincipal
		let subaccount: Data?
	}
	
	/// type GetAccountIdentifierTransactionsArgs = record {
	///   max_results : nat64;
	///   start : opt nat64;
	///   account_identifier : text;
	/// };
	struct GetAccountIdentifierTransactionsArgs: Codable {
		let max_results: UInt64
		let start: UInt64?
		let account_identifier: String
	}
	
	/// type GetAccountIdentifierTransactionsError = record { message : text };
	struct GetAccountIdentifierTransactionsError: Codable {
		let message: String
	}
	
	/// type GetAccountIdentifierTransactionsResponse = record {
	///   balance : nat64;
	///   transactions : vec TransactionWithId;
	///   oldest_tx_id : opt nat64;
	/// };
	struct GetAccountIdentifierTransactionsResponse: Codable {
		let balance: UInt64
		let transactions: [TransactionWithId]
		let oldest_tx_id: UInt64?
	}
	
	/// type GetAccountIdentifierTransactionsResult = variant {
	///   Ok : GetAccountIdentifierTransactionsResponse;
	///   Err : GetAccountIdentifierTransactionsError;
	/// };
	enum GetAccountIdentifierTransactionsResult: Codable {
		case Ok(GetAccountIdentifierTransactionsResponse)
		case Err(GetAccountIdentifierTransactionsError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type GetAccountTransactionsArgs = record {
	///     account : Account;
	///     // The txid of the last transaction seen by the client.
	///     // If None then the results will start from the most recent
	///     // txid.
	///     start : opt nat;
	///     // Maximum number of transactions to fetch.
	///     max_results : nat;
	/// };
	struct GetAccountTransactionsArgs: Codable {
		let max_results: BigUInt
		let start: BigUInt?
		let account: Account
	}
	
	/// type GetBlocksRequest = record { start : nat; length : nat };
	struct GetBlocksRequest: Codable {
		let start: BigUInt
		let length: BigUInt
	}
	
	/// type GetBlocksResponse = record { blocks : vec vec nat8; chain_length : nat64 };
	struct GetBlocksResponse: Codable {
		let blocks: [Data]
		let chain_length: UInt64
	}
	
	/// type HttpRequest = record {
	///   url : text;
	///   method : text;
	///   body : vec nat8;
	///   headers : vec record { text; text };
	/// };
	struct HttpRequest: Codable {
		let url: String
		let method: String
		let body: Data
		let headers: [CandidTuple2<String, String>]
	}
	
	/// type HttpResponse = record {
	///   body : vec nat8;
	///   headers : vec record { text; text };
	///   status_code : nat16;
	/// };
	struct HttpResponse: Codable {
		let body: Data
		let headers: [CandidTuple2<String, String>]
		let status_code: UInt16
	}
	
	/// type InitArg = record { ledger_id : principal };
	struct InitArg: Codable {
		let ledger_id: ICPPrincipal
	}
	
	/// type Operation = variant {
	///   Approve : record {
	///     fee : Tokens;
	///     from : text;
	///     allowance : Tokens;
	///     expires_at : opt TimeStamp;
	///     spender : text;
	///     expected_allowance : opt Tokens;
	///   };
	///   Burn : record { from : text; amount : Tokens; spender : opt text };
	///   Mint : record { to : text; amount : Tokens };
	///   Transfer : record { to : text; fee : Tokens; from : text; amount : Tokens; spender : opt text };
	/// };
	enum Operation: Codable {
		case Approve(fee: Tokens, from: String, allowance: Tokens, expected_allowance: Tokens?, expires_at: TimeStamp?, spender: String)
		case Burn(from: String, amount: Tokens, spender: String?)
		case Mint(to: String, amount: Tokens)
		case Transfer(to: String, fee: Tokens, from: String, amount: Tokens, spender: String?)
	
		enum CodingKeys: String, CandidCodingKey {
			case Approve
			case Burn
			case Mint
			case Transfer
		}
		enum ApproveCodingKeys: String, CandidCodingKey {
			case fee
			case from
			case allowance
			case expected_allowance
			case expires_at
			case spender
		}
		enum BurnCodingKeys: String, CandidCodingKey {
			case from
			case amount
			case spender
		}
		enum MintCodingKeys: String, CandidCodingKey {
			case to
			case amount
		}
		enum TransferCodingKeys: String, CandidCodingKey {
			case to
			case fee
			case from
			case amount
			case spender
		}
	}
	
	/// type Status = record { num_blocks_synced : nat64 };
	struct Status: Codable {
		let num_blocks_synced: UInt64
	}
	
	/// type TimeStamp = record { timestamp_nanos : nat64 };
	struct TimeStamp: Codable {
		let timestamp_nanos: UInt64
	}
	
	/// type Tokens = record { e8s : nat64 };
	struct Tokens: Codable {
		let e8s: UInt64
	}
	
	/// type Transaction = record {
	///   memo : nat64;
	///   icrc1_memo : opt vec nat8;
	///   operation : Operation;
	///   created_at_time : opt TimeStamp;
	///   timestamp : opt TimeStamp;
	/// };
	struct Transaction: Codable {
		let memo: UInt64
		let icrc1_memo: Data?
		let operation: Operation
		let timestamp: TimeStamp?
		let created_at_time: TimeStamp?
	}
	
	/// type TransactionWithId = record { id : nat64; transaction : Transaction };
	struct TransactionWithId: Codable {
		let id: UInt64
		let transaction: Transaction
	}
	

	/// service : (InitArg) -> {
	///   get_account_identifier_balance : (text) -> (nat64) query;
	///   get_account_identifier_transactions : (
	///       GetAccountIdentifierTransactionsArgs,
	///     ) -> (GetAccountIdentifierTransactionsResult) query;
	///   get_account_transactions : (GetAccountTransactionsArgs) -> (GetAccountIdentifierTransactionsResult) query;
	///   get_blocks : (GetBlocksRequest) -> (GetBlocksResponse) query;
	///   http_request : (HttpRequest) -> (HttpResponse) query;
	///   ledger_id : () -> (principal) query;
	///   status : () -> (Status) query;
	///   icrc1_balance_of : (Account) -> (nat64) query;
	/// }
	class Service: ICPService {
		/// get_account_identifier_balance : (text) -> (nat64) query;
		func get_account_identifier_balance(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws -> UInt64 {
			let caller = ICPQuery<String, UInt64>(canister, "get_account_identifier_balance")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_account_identifier_transactions : (
		///       GetAccountIdentifierTransactionsArgs,
		///     ) -> (GetAccountIdentifierTransactionsResult) query;
		func get_account_identifier_transactions(_ arg0: GetAccountIdentifierTransactionsArgs, sender: ICPSigningPrincipal? = nil) async throws -> GetAccountIdentifierTransactionsResult {
			let caller = ICPQuery<GetAccountIdentifierTransactionsArgs, GetAccountIdentifierTransactionsResult>(canister, "get_account_identifier_transactions")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_account_transactions : (GetAccountTransactionsArgs) -> (GetAccountIdentifierTransactionsResult) query;
		func get_account_transactions(_ arg0: GetAccountTransactionsArgs, sender: ICPSigningPrincipal? = nil) async throws -> GetAccountIdentifierTransactionsResult {
			let caller = ICPQuery<GetAccountTransactionsArgs, GetAccountIdentifierTransactionsResult>(canister, "get_account_transactions")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_blocks : (GetBlocksRequest) -> (GetBlocksResponse) query;
		func get_blocks(_ arg0: GetBlocksRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetBlocksResponse {
			let caller = ICPQuery<GetBlocksRequest, GetBlocksResponse>(canister, "get_blocks")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// http_request : (HttpRequest) -> (HttpResponse) query;
		func http_request(_ arg0: HttpRequest, sender: ICPSigningPrincipal? = nil) async throws -> HttpResponse {
			let caller = ICPQuery<HttpRequest, HttpResponse>(canister, "http_request")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ledger_id : () -> (principal) query;
		func ledger_id(sender: ICPSigningPrincipal? = nil) async throws -> ICPPrincipal {
			let caller = ICPQueryNoArgs<ICPPrincipal>(canister, "ledger_id")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// status : () -> (Status) query;
		func status(sender: ICPSigningPrincipal? = nil) async throws -> Status {
			let caller = ICPQueryNoArgs<Status>(canister, "status")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc1_balance_of : (Account) -> (nat64) query;
		func icrc1_balance_of(_ arg0: Account, sender: ICPSigningPrincipal? = nil) async throws -> UInt64 {
			let caller = ICPQuery<Account, UInt64>(canister, "icrc1_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
	}

}
