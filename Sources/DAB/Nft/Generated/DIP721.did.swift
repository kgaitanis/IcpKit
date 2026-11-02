//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum DIP721 {
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
	
	
	/// // https://internetcomputer.org/docs/current/references/samples/motoko/dip721-nft-container
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
	
	/// type InitArgs = record {
	///   cap : opt principal;
	///   logo : opt text;
	///   name : opt text;
	///   custodians : opt vec principal;
	///   symbol : opt text;
	/// };
	struct InitArgs: Codable {
		let cap: ICPPrincipal?
		let logo: String?
		let name: String?
		let custodians: [ICPPrincipal]?
		let symbol: String?
	}
	
	/// type ManualReply = record {
	///   logo : opt text;
	///   name : opt text;
	///   created_at : nat64;
	///   upgraded_at : nat64;
	///   custodians : vec principal;
	///   symbol : opt text;
	/// };
	struct ManualReply: Codable {
		let logo: String?
		let name: String?
		let created_at: UInt64
		let upgraded_at: UInt64
		let custodians: [ICPPrincipal]
		let symbol: String?
	}
	
	/// type ManualReply_1 = variant { Ok : vec nat; Err : NftError };
	enum ManualReply_1: Codable {
		case Ok([BigUInt])
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type ManualReply_2 = variant { Ok : vec TokenMetadata; Err : NftError };
	enum ManualReply_2: Codable {
		case Ok([TokenMetadata])
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type ManualReply_3 = variant { Ok : TokenMetadata; Err : NftError };
	enum ManualReply_3: Codable {
		case Ok(TokenMetadata)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type NftError = variant {
	///   UnauthorizedOperator;
	///   SelfTransfer;
	///   TokenNotFound;
	///   UnauthorizedOwner;
	///   SelfApprove;
	///   OperatorNotFound;
	///   ExistedNFT;
	///   OwnerNotFound;
	/// };
	enum NftError: Codable {
		case UnauthorizedOperator
		case SelfTransfer
		case TokenNotFound
		case UnauthorizedOwner
		case SelfApprove
		case OperatorNotFound
		case ExistedNFT
		case OwnerNotFound
	
		enum CodingKeys: String, CandidCodingKey {
			case UnauthorizedOperator
			case SelfTransfer
			case TokenNotFound
			case UnauthorizedOwner
			case SelfApprove
			case OperatorNotFound
			case ExistedNFT
			case OwnerNotFound
		}
	}
	
	/// type Result = variant { Ok : nat; Err : NftError };
	enum Result: Codable {
		case Ok(BigUInt)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type Result_1 = variant { Ok : bool; Err : NftError };
	enum Result_1: Codable {
		case Ok(Bool)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type Result_2 = variant { Ok : opt principal; Err : NftError };
	enum Result_2: Codable {
		case Ok(ICPPrincipal?)
		case Err(NftError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type Stats = record {
	///   cycles : nat;
	///   total_transactions : nat;
	///   total_unique_holders : nat;
	///   total_supply : nat;
	/// };
	struct Stats: Codable {
		let cycles: BigUInt
		let total_transactions: BigUInt
		let total_unique_holders: BigUInt
		let total_supply: BigUInt
	}
	
	/// type SupportedInterface = variant { Burn; Mint; Approval };
	enum SupportedInterface: Codable {
		case Burn
		case Mint
		case Approval
	
		enum CodingKeys: String, CandidCodingKey {
			case Burn
			case Mint
			case Approval
		}
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
	

	/// service : (opt InitArgs) -> {
	///   approve : (principal, nat) -> (Result);
	///   balanceOf : (principal) -> (Result) query;
	///   burn : (nat) -> (Result);
	///   custodians : () -> (vec principal) query;
	///   cycles : () -> (nat) query;
	///   dfx_info : () -> (text) query;
	///   dip721_approve : (principal, nat) -> (Result);
	///   dip721_balance_of : (principal) -> (Result) query;
	///   dip721_burn : (nat) -> (Result);
	///   dip721_custodians : () -> (vec principal) query;
	///   dip721_cycles : () -> (nat) query;
	///   dip721_is_approved_for_all : (principal, principal) -> (Result_1) query;
	///   dip721_logo : () -> (opt text) query;
	///   dip721_metadata : () -> (ManualReply) query;
	///   dip721_mint : (principal, nat, vec record { text; GenericValue }) -> (Result);
	///   dip721_name : () -> (opt text) query;
	///   dip721_operator_of : (nat) -> (Result_2) query;
	///   dip721_operator_token_identifiers : (principal) -> (ManualReply_1) query;
	///   dip721_operator_token_metadata : (principal) -> (ManualReply_2) query;
	///   dip721_owner_of : (nat) -> (Result_2) query;
	///   dip721_owner_token_identifiers : (principal) -> (ManualReply_1) query;
	///   dip721_owner_token_metadata : (principal) -> (ManualReply_2) query;
	///   dip721_set_approval_for_all : (principal, bool) -> (Result);
	///   dip721_set_custodians : (vec principal) -> ();
	///   dip721_set_logo : (text) -> ();
	///   dip721_set_name : (text) -> ();
	///   dip721_set_symbol : (text) -> ();
	///   dip721_stats : () -> (Stats) query;
	///   dip721_supported_interfaces : () -> (vec SupportedInterface) query;
	///   dip721_symbol : () -> (opt text) query;
	///   dip721_token_metadata : (nat) -> (ManualReply_3) query;
	///   dip721_total_supply : () -> (nat) query;
	///   dip721_total_transactions : () -> (nat) query;
	///   dip721_total_unique_holders : () -> (nat) query;
	///   dip721_transfer : (principal, nat) -> (Result);
	///   dip721_transfer_from : (principal, principal, nat) -> (Result);
	///   git_commit_hash : () -> (text) query;
	///   isApprovedForAll : (principal, principal) -> (Result_1) query;
	///   logo : () -> (opt text) query;
	///   metadata : () -> (ManualReply) query;
	///   mint : (principal, nat, vec record { text; GenericValue }) -> (Result);
	///   name : () -> (opt text) query;
	///   operatorOf : (nat) -> (Result_2) query;
	///   operatorTokenIdentifiers : (principal) -> (ManualReply_1) query;
	///   operatorTokenMetadata : (principal) -> (ManualReply_2) query;
	///   ownerOf : (nat) -> (Result_2) query;
	///   ownerTokenIdentifiers : (principal) -> (ManualReply_1) query;
	///   ownerTokenMetadata : (principal) -> (ManualReply_2) query;
	///   rust_toolchain_info : () -> (text) query;
	///   setApprovalForAll : (principal, bool) -> (Result);
	///   setCustodians : (vec principal) -> ();
	///   setLogo : (text) -> ();
	///   setName : (text) -> ();
	///   setSymbol : (text) -> ();
	///   stats : () -> (Stats) query;
	///   supportedInterfaces : () -> (vec SupportedInterface) query;
	///   symbol : () -> (opt text) query;
	///   tokenMetadata : (nat) -> (ManualReply_3) query;
	///   totalSupply : () -> (nat) query;
	///   totalTransactions : () -> (nat) query;
	///   totalUniqueHolders : () -> (nat) query;
	///   transfer : (principal, nat) -> (Result);
	///   transferFrom : (principal, principal, nat) -> (Result);
	/// }
	class Service: ICPService {
		/// approve : (principal, nat) -> (Result);
		func approve(_ arg0: ICPPrincipal, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, Result>(canister, "approve")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// balanceOf : (principal) -> (Result) query;
		func balanceOf(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPQuery<ICPPrincipal, Result>(canister, "balanceOf")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// burn : (nat) -> (Result);
		func burn(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<BigUInt, Result>(canister, "burn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// custodians : () -> (vec principal) query;
		func custodians(sender: ICPSigningPrincipal? = nil) async throws -> [ICPPrincipal] {
			let caller = ICPQueryNoArgs<[ICPPrincipal]>(canister, "custodians")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// cycles : () -> (nat) query;
		func cycles(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "cycles")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dfx_info : () -> (text) query;
		func dfx_info(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "dfx_info")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_approve : (principal, nat) -> (Result);
		func dip721_approve(_ arg0: ICPPrincipal, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, Result>(canister, "dip721_approve")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_balance_of : (principal) -> (Result) query;
		func dip721_balance_of(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPQuery<ICPPrincipal, Result>(canister, "dip721_balance_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_burn : (nat) -> (Result);
		func dip721_burn(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<BigUInt, Result>(canister, "dip721_burn")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_custodians : () -> (vec principal) query;
		func dip721_custodians(sender: ICPSigningPrincipal? = nil) async throws -> [ICPPrincipal] {
			let caller = ICPQueryNoArgs<[ICPPrincipal]>(canister, "dip721_custodians")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_cycles : () -> (nat) query;
		func dip721_cycles(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "dip721_cycles")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_is_approved_for_all : (principal, principal) -> (Result_1) query;
		func dip721_is_approved_for_all(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> Result_1 {
			let caller = ICPQuery<ICPFunctionArgs2<ICPPrincipal, ICPPrincipal>, Result_1>(canister, "dip721_is_approved_for_all")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_logo : () -> (opt text) query;
		func dip721_logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "dip721_logo")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_metadata : () -> (ManualReply) query;
		func dip721_metadata(sender: ICPSigningPrincipal? = nil) async throws -> ManualReply {
			let caller = ICPQueryNoArgs<ManualReply>(canister, "dip721_metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_mint : (principal, nat, vec record { text; GenericValue }) -> (Result);
		func dip721_mint(_ arg0: ICPPrincipal, _ arg1: BigUInt, _ arg2: [CandidTuple2<String, GenericValue>], sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, BigUInt, [CandidTuple2<String, GenericValue>]>, Result>(canister, "dip721_mint")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// dip721_name : () -> (opt text) query;
		func dip721_name(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "dip721_name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_operator_of : (nat) -> (Result_2) query;
		func dip721_operator_of(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result_2 {
			let caller = ICPQuery<BigUInt, Result_2>(canister, "dip721_operator_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_operator_token_identifiers : (principal) -> (ManualReply_1) query;
		func dip721_operator_token_identifiers(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_1 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_1>(canister, "dip721_operator_token_identifiers")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_operator_token_metadata : (principal) -> (ManualReply_2) query;
		func dip721_operator_token_metadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_2 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_2>(canister, "dip721_operator_token_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_owner_of : (nat) -> (Result_2) query;
		func dip721_owner_of(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result_2 {
			let caller = ICPQuery<BigUInt, Result_2>(canister, "dip721_owner_of")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_owner_token_identifiers : (principal) -> (ManualReply_1) query;
		func dip721_owner_token_identifiers(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_1 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_1>(canister, "dip721_owner_token_identifiers")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_owner_token_metadata : (principal) -> (ManualReply_2) query;
		func dip721_owner_token_metadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_2 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_2>(canister, "dip721_owner_token_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// dip721_set_approval_for_all : (principal, bool) -> (Result);
		func dip721_set_approval_for_all(_ arg0: ICPPrincipal, _ arg1: Bool, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, Bool>, Result>(canister, "dip721_set_approval_for_all")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_set_custodians : (vec principal) -> ();
		func dip721_set_custodians(_ arg0: [ICPPrincipal], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[ICPPrincipal]>(canister, "dip721_set_custodians")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// dip721_set_logo : (text) -> ();
		func dip721_set_logo(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<String>(canister, "dip721_set_logo")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// dip721_set_name : (text) -> ();
		func dip721_set_name(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<String>(canister, "dip721_set_name")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// dip721_set_symbol : (text) -> ();
		func dip721_set_symbol(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<String>(canister, "dip721_set_symbol")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// dip721_stats : () -> (Stats) query;
		func dip721_stats(sender: ICPSigningPrincipal? = nil) async throws -> Stats {
			let caller = ICPQueryNoArgs<Stats>(canister, "dip721_stats")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_supported_interfaces : () -> (vec SupportedInterface) query;
		func dip721_supported_interfaces(sender: ICPSigningPrincipal? = nil) async throws -> [SupportedInterface] {
			let caller = ICPQueryNoArgs<[SupportedInterface]>(canister, "dip721_supported_interfaces")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_symbol : () -> (opt text) query;
		func dip721_symbol(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "dip721_symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_token_metadata : (nat) -> (ManualReply_3) query;
		func dip721_token_metadata(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_3 {
			let caller = ICPQuery<BigUInt, ManualReply_3>(canister, "dip721_token_metadata")
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
	
		/// dip721_total_unique_holders : () -> (nat) query;
		func dip721_total_unique_holders(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "dip721_total_unique_holders")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_transfer : (principal, nat) -> (Result);
		func dip721_transfer(_ arg0: ICPPrincipal, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, Result>(canister, "dip721_transfer")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_transfer_from : (principal, principal, nat) -> (Result);
		func dip721_transfer_from(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, _ arg2: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, ICPPrincipal, BigUInt>, Result>(canister, "dip721_transfer_from")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// git_commit_hash : () -> (text) query;
		func git_commit_hash(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "git_commit_hash")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// isApprovedForAll : (principal, principal) -> (Result_1) query;
		func isApprovedForAll(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> Result_1 {
			let caller = ICPQuery<ICPFunctionArgs2<ICPPrincipal, ICPPrincipal>, Result_1>(canister, "isApprovedForAll")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// dip721_logo : () -> (opt text) query;
		func logo(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "logo")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_metadata : () -> (ManualReply) query;
		func metadata(sender: ICPSigningPrincipal? = nil) async throws -> ManualReply {
			let caller = ICPQueryNoArgs<ManualReply>(canister, "metadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_mint : (principal, nat, vec record { text; GenericValue }) -> (Result);
		func mint(_ arg0: ICPPrincipal, _ arg1: BigUInt, _ arg2: [CandidTuple2<String, GenericValue>], sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, BigUInt, [CandidTuple2<String, GenericValue>]>, Result>(canister, "mint")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
		/// dip721_name : () -> (opt text) query;
		func name(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// operatorOf : (nat) -> (Result_2) query;
		func operatorOf(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result_2 {
			let caller = ICPQuery<BigUInt, Result_2>(canister, "operatorOf")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// operatorTokenIdentifiers : (principal) -> (ManualReply_1) query;
		func operatorTokenIdentifiers(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_1 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_1>(canister, "operatorTokenIdentifiers")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// operatorTokenMetadata : (principal) -> (ManualReply_2) query;
		func operatorTokenMetadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_2 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_2>(canister, "operatorTokenMetadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ownerOf : (nat) -> (Result_2) query;
		func ownerOf(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result_2 {
			let caller = ICPQuery<BigUInt, Result_2>(canister, "ownerOf")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ownerTokenIdentifiers : (principal) -> (ManualReply_1) query;
		func ownerTokenIdentifiers(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_1 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_1>(canister, "ownerTokenIdentifiers")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// ownerTokenMetadata : (principal) -> (ManualReply_2) query;
		func ownerTokenMetadata(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_2 {
			let caller = ICPQuery<ICPPrincipal, ManualReply_2>(canister, "ownerTokenMetadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// rust_toolchain_info : () -> (text) query;
		func rust_toolchain_info(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "rust_toolchain_info")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// setApprovalForAll : (principal, bool) -> (Result);
		func setApprovalForAll(_ arg0: ICPPrincipal, _ arg1: Bool, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, Bool>, Result>(canister, "setApprovalForAll")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// setCustodians : (vec principal) -> ();
		func setCustodians(_ arg0: [ICPPrincipal], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[ICPPrincipal]>(canister, "setCustodians")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// setLogo : (text) -> ();
		func setLogo(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<String>(canister, "setLogo")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// setName : (text) -> ();
		func setName(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<String>(canister, "setName")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// setSymbol : (text) -> ();
		func setSymbol(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<String>(canister, "setSymbol")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// dip721_stats : () -> (Stats) query;
		func stats(sender: ICPSigningPrincipal? = nil) async throws -> Stats {
			let caller = ICPQueryNoArgs<Stats>(canister, "stats")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// supportedInterfaces : () -> (vec SupportedInterface) query;
		func supportedInterfaces(sender: ICPSigningPrincipal? = nil) async throws -> [SupportedInterface] {
			let caller = ICPQueryNoArgs<[SupportedInterface]>(canister, "supportedInterfaces")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_set_symbol : (text) -> ();
		func symbol(sender: ICPSigningPrincipal? = nil) async throws -> String? {
			let caller = ICPQueryNoArgs<String?>(canister, "symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// tokenMetadata : (nat) -> (ManualReply_3) query;
		func tokenMetadata(_ arg0: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> ManualReply_3 {
			let caller = ICPQuery<BigUInt, ManualReply_3>(canister, "tokenMetadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// totalSupply : () -> (nat) query;
		func totalSupply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "totalSupply")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// totalTransactions : () -> (nat) query;
		func totalTransactions(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "totalTransactions")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// totalUniqueHolders : () -> (nat) query;
		func totalUniqueHolders(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "totalUniqueHolders")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// dip721_transfer : (principal, nat) -> (Result);
		func transfer(_ arg0: ICPPrincipal, _ arg1: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, Result>(canister, "transfer")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// transferFrom : (principal, principal, nat) -> (Result);
		func transferFrom(_ arg0: ICPPrincipal, _ arg1: ICPPrincipal, _ arg2: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> Result {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, ICPPrincipal, BigUInt>, Result>(canister, "transferFrom")
			let response = try await caller.callMethod(.init(arg0, arg1, arg2), client, sender: sender)
			return response
		}
	
	}

}
