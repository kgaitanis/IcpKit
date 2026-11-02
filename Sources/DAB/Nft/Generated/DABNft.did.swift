//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum DABNft {
	/// type add_nft_input = record {
	///     name        : text;
	///     description : text;
	///     thumbnail   : text;
	///     frontend    : opt text;
	///     principal_id : principal;
	///     details     : vec record { text; detail_value }
	/// };
	struct add_nft_input: Codable {
		let thumbnail: String
		let name: String
		let frontend: String?
		let description: String
		let details: [CandidTuple2<String, detail_value>]
		let principal_id: ICPPrincipal
	}
	
	/// type detail_value = variant {
	///   True;
	///   False;
	///   I64       : int64;
	///   U64       : nat64;
	///   Vec       : vec detail_value;
	///   Slice     : vec nat8;
	///   Text      : text;
	///   Float     : float64;
	///   Principal : principal;
	/// };
	enum detail_value: Codable {
		case I64(Int64)
		case U64(UInt64)
		case Vec([detail_value])
		case Slice(Data)
		case Text(String)
		case True
		case False
		case Float(Double)
		case Principal(ICPPrincipal)
	
		enum CodingKeys: String, CandidCodingKey {
			case I64
			case U64
			case Vec
			case Slice
			case Text
			case True
			case False
			case Float
			case Principal
		}
	}
	
	/// type nft_canister = record {
	///     name         : text;
	///     description  : text;
	///     thumbnail    : text;
	///     frontend     : opt text;
	///     principal_id : principal;
	///     submitter   : principal;
	///     last_updated_by: principal;
	///     last_updated_at: nat64;
	///     details      : vec record { text; detail_value };
	/// };
	struct nft_canister: Codable {
		let thumbnail: String
		let submitter: ICPPrincipal
		let name: String
		let frontend: String?
		let description: String
		let last_updated_at: UInt64
		let last_updated_by: ICPPrincipal
		let details: [CandidTuple2<String, detail_value>]
		let principal_id: ICPPrincipal
	}
	
	/// type operation_error = variant {
	///     NotAuthorized;
	///     NonExistentItem;
	///     BadParameters;
	///     Unknown : text;
	/// };
	enum operation_error: Codable {
		case NotAuthorized
		case BadParameters
		case Unknown(String)
		case NonExistentItem
	
		enum CodingKeys: String, CandidCodingKey {
			case NotAuthorized
			case BadParameters
			case Unknown
			case NonExistentItem
		}
	}
	
	/// type operation_response = variant {
	///     Ok  : opt text;
	///     Err : operation_error;
	/// };
	enum operation_response: Codable {
		case Ok(String?)
		case Err(operation_error)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	

	/// service : (opt principal) -> {
	///     // DRS methods
	///     "name"   : () -> (text) query;
	///     "get"    : (nft_id: principal) -> (opt nft_canister) query;
	///     "add"    : (trusted_source: opt principal, nft: add_nft_input) -> (operation_response);
	///     "remove" : (trusted_source: opt principal, nft_id: principal) -> (operation_response);
	///     // Canister methods
	///     "get_all"      : () -> (vec nft_canister) query;
	///     "add_admin"    : (admin: principal) -> (operation_response);
	/// }
	class Service: ICPService {
		func name(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		func get(nft_id: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> nft_canister? {
			let caller = ICPQuery<ICPPrincipal, nft_canister?>(canister, "get")
			let response = try await caller.callMethod(nft_id, client, sender: sender)
			return response
		}
	
		func add(trusted_source: ICPPrincipal?, nft: add_nft_input, sender: ICPSigningPrincipal? = nil) async throws -> operation_response {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal?, add_nft_input>, operation_response>(canister, "add")
			let response = try await caller.callMethod(.init(trusted_source, nft), client, sender: sender)
			return response
		}
	
		func remove(trusted_source: ICPPrincipal?, nft_id: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> operation_response {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal?, ICPPrincipal>, operation_response>(canister, "remove")
			let response = try await caller.callMethod(.init(trusted_source, nft_id), client, sender: sender)
			return response
		}
	
		func get_all(sender: ICPSigningPrincipal? = nil) async throws -> [nft_canister] {
			let caller = ICPQueryNoArgs<[nft_canister]>(canister, "get_all")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		func add_admin(admin: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> operation_response {
			let caller = ICPCall<ICPPrincipal, operation_response>(canister, "add_admin")
			let response = try await caller.callMethod(admin, client, sender: sender)
			return response
		}
	
	}

}
