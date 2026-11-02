//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum ICRC7 {
	/// // https://github.com/dfinity/ICRC/blob/main/ICRCs/ICRC-7/ICRC-7.did
	/// type Subaccount = blob;
	typealias Subaccount = Data
	
	
	/// type Account = record { owner : principal; subaccount : opt Subaccount };
	struct Account: Codable {
		let owner: ICPPrincipal
		let subaccount: Subaccount?
	}
	
	/// type TransferArg = record {
	///     from_subaccount: opt blob; // The subaccount to transfer the token from
	///     to : Account;
	///     token_id : nat;
	///     memo : opt blob;
	///     created_at_time : opt nat64;
	/// };
	struct TransferArg: Codable {
		let to: Account
		let token_id: BigUInt
		let memo: Data?
		let from_subaccount: Data?
		let created_at_time: UInt64?
	}
	
	/// type TransferError = variant {
	///     NonExistingTokenId;
	///     InvalidRecipient;
	///     Unauthorized;
	///     TooOld;
	///     CreatedInFuture : record { ledger_time: nat64 };
	///     Duplicate : record { duplicate_of : nat };
	///     GenericError : record { error_code : nat; message : text };
	///     GenericBatchError : record { error_code : nat; message : text };
	/// };
	enum TransferError: Codable {
		case GenericError(message: String, error_code: BigUInt)
		case Duplicate(duplicate_of: BigUInt)
		case NonExistingTokenId
		case Unauthorized
		case CreatedInFuture(ledger_time: UInt64)
		case InvalidRecipient
		case GenericBatchError(message: String, error_code: BigUInt)
		case TooOld
	
		enum CodingKeys: String, CandidCodingKey {
			case GenericError
			case Duplicate
			case NonExistingTokenId
			case Unauthorized
			case CreatedInFuture
			case InvalidRecipient
			case GenericBatchError
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
		enum GenericBatchErrorCodingKeys: String, CandidCodingKey {
			case message
			case error_code
		}
	}
	
	/// type TransferResult = variant {
	///     Ok : nat; // Transaction index for successful transfer
	///     Err : TransferError;
	/// };
	enum TransferResult: Codable {
		case Ok(BigUInt)
		case Err(TransferError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// // Generic value in accordance with ICRC-3
	/// type Value = variant { 
	///     Blob : blob; 
	///     Text : text; 
	///     Nat : nat;
	///     Int : int;
	///     Array : vec Value; 
	///     Map : vec record { text; Value }; 
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
	

	/// service : {
	///   icrc7_collection_metadata : () -> (vec record { text; Value } ) query;
	///   icrc7_symbol : () -> (text) query;
	///   icrc7_name : () -> (text) query;
	///   icrc7_description : () -> (opt text) query;
	///   icrc7_logo : () -> (opt text) query;
	///   icrc7_total_supply : () -> (nat) query;
	///   icrc7_supply_cap : () -> (opt nat) query;
	///   icrc7_max_query_batch_size : () -> (opt nat) query;
	///   icrc7_max_update_batch_size : () -> (opt nat) query;
	///   icrc7_default_take_value : () -> (opt nat) query;
	///   icrc7_max_take_value : () -> (opt nat) query;
	///   icrc7_max_memo_size : () -> (opt nat) query;
	///   icrc7_atomic_batch_transfers : () -> (opt bool) query;
	///   icrc7_tx_window : () -> (opt nat) query;
	///   icrc7_permitted_drift : () -> (opt nat) query;
	///   icrc7_token_metadata : (token_ids : vec nat)
	///     -> (vec opt vec record { text; Value }) query;
	///   icrc7_owner_of : (token_ids : vec nat)
	///       -> (vec opt Account) query;
	///   icrc7_balance_of : (vec Account) -> (vec nat) query;
	///   icrc7_tokens : (prev : opt nat, take : opt nat)
	///       -> (vec nat) query;
	///   icrc7_tokens_of : (account : Account, prev : opt nat, take : opt nat)
	///       -> (vec nat) query;
	///   icrc7_transfer : (vec TransferArg) -> (vec opt TransferResult);
	/// }
	class Service: ICPService {
		/// icrc7_collection_metadata : () -> (vec record { text; Value } ) query;
		func icrc7_collection_metadata(sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<String, Value>] {
			let caller = ICPQueryNoArgs<[CandidTuple2<String, Value>]>(canister, "icrc7_collection_metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_symbol : () -> (text) query;
		func icrc7_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "icrc7_symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_name : () -> (text) query;
		func icrc7_name(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "icrc7_name")
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
	
		/// icrc7_total_supply : () -> (nat) query;
		func icrc7_total_supply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "icrc7_total_supply")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_supply_cap : () -> (opt nat) query;
		func icrc7_supply_cap(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_supply_cap")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_query_batch_size : () -> (opt nat) query;
		func icrc7_max_query_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_query_batch_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_update_batch_size : () -> (opt nat) query;
		func icrc7_max_update_batch_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_update_batch_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_default_take_value : () -> (opt nat) query;
		func icrc7_default_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_default_take_value")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_take_value : () -> (opt nat) query;
		func icrc7_max_take_value(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_take_value")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_max_memo_size : () -> (opt nat) query;
		func icrc7_max_memo_size(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_max_memo_size")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_atomic_batch_transfers : () -> (opt bool) query;
		func icrc7_atomic_batch_transfers(sender: ICPSigningPrincipal? = nil) async throws -> Bool? {
			let caller = ICPQueryNoArgs<Bool?>(canister, "icrc7_atomic_batch_transfers")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_tx_window : () -> (opt nat) query;
		func icrc7_tx_window(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_tx_window")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_permitted_drift : () -> (opt nat) query;
		func icrc7_permitted_drift(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt? {
			let caller = ICPQueryNoArgs<BigUInt?>(canister, "icrc7_permitted_drift")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// icrc7_token_metadata : (token_ids : vec nat)
		///     -> (vec opt vec record { text; Value }) query;
		func icrc7_token_metadata(token_ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [[CandidTuple2<String, Value>]?] {
			let caller = ICPQuery<[BigUInt], [[CandidTuple2<String, Value>]?]>(canister, "icrc7_token_metadata")
			let response = try await caller.callMethod(token_ids, client, sender: sender)
			return response
		}
	
		/// icrc7_owner_of : (token_ids : vec nat)
		///       -> (vec opt Account) query;
		func icrc7_owner_of(token_ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> [Account?] {
			let caller = ICPQuery<[BigUInt], [Account?]>(canister, "icrc7_owner_of")
			let response = try await caller.callMethod(token_ids, client, sender: sender)
			return response
		}
	
		/// icrc7_balance_of : (vec Account) -> (vec nat) query;
		func icrc7_balance_of(_ arg0: [Account], sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
			let caller = ICPQuery<[Account], [BigUInt]>(canister, "icrc7_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// icrc7_tokens : (prev : opt nat, take : opt nat)
		///       -> (vec nat) query;
		func icrc7_tokens(prev: BigUInt?, take: BigUInt?, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
			let caller = ICPQuery<ICPFunctionArgs2<BigUInt?, BigUInt?>, [BigUInt]>(canister, "icrc7_tokens")
			let response = try await caller.callMethod(.init(prev, take), client, sender: sender)
			return response
		}
	
		/// icrc7_tokens_of : (account : Account, prev : opt nat, take : opt nat)
		///       -> (vec nat) query;
		func icrc7_tokens_of(account: Account, prev: BigUInt?, take: BigUInt?, sender: ICPSigningPrincipal? = nil) async throws -> [BigUInt] {
			let caller = ICPQuery<ICPFunctionArgs3<Account, BigUInt?, BigUInt?>, [BigUInt]>(canister, "icrc7_tokens_of")
			let response = try await caller.callMethod(.init(account, prev, take), client, sender: sender)
			return response
		}
	
		/// icrc7_transfer : (vec TransferArg) -> (vec opt TransferResult);
		func icrc7_transfer(_ arg0: [TransferArg], sender: ICPSigningPrincipal? = nil) async throws -> [TransferResult?] {
			let caller = ICPCall<[TransferArg], [TransferResult?]>(canister, "icrc7_transfer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
	}

}
