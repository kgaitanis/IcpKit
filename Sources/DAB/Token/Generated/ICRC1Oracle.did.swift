//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum ICRC1Oracle {
	/// type Category = variant {
	///     Sns;
	///     Known;
	///     Spam;
	///     ChainFusionTestnet;
	///     ChainFusion;
	///     Community;
	///     Native;
	/// };
	enum Category: Codable {
		case Sns
		case Spam
		case Native
		case Known
		case ChainFusionTestnet
		case ChainFusion
		case Community
	
		enum CodingKeys: String, CandidCodingKey {
			case Sns
			case Spam
			case Native
			case Known
			case ChainFusionTestnet
			case ChainFusion
			case Community
		}
	}
	
	/// type Conf = record {
	///     controllers : opt vec principal;
	///     im_canister : opt principal;
	/// };
	struct Conf: Codable {
		let controllers: [ICPPrincipal]?
		let im_canister: ICPPrincipal?
	}
	
	/// type ICRC1 = record {
	///     logo : opt text;
	///     name : text;
	///     ledger : text;
	///     category : Category;
	///     index : opt text;
	///     symbol : text;
	///     decimals : nat8;
	///     fee : nat;
	/// };
	struct ICRC1: Codable {
		let fee: BigUInt
		let decimals: UInt8
		let logo: String?
		let name: String
		let ledger: String
		let category: Category
		let index: String?
		let symbol: String
	}
	
	/// type ICRC1Request = record {
	///     logo : opt text;
	///     name : text;
	///     ledger : text;
	///     index : opt text;
	///     symbol : text;
	///     decimals : nat8;
	///     fee : nat;
	/// };
	struct ICRC1Request: Codable {
		let fee: BigUInt
		let decimals: UInt8
		let logo: String?
		let name: String
		let ledger: String
		let index: String?
		let symbol: String
	}
	

	/// service : {
	///   count_icrc1_canisters : () -> (nat64) query;
	///   get_all_icrc1_canisters : () -> (vec ICRC1) query;
	///   get_icrc1_paginated : (nat64, nat64) -> (vec ICRC1) query;
	///   replace_icrc1_canisters : (vec ICRC1) -> ();
	///   set_operator : (principal) -> ();
	///   store_icrc1_canister : (ICRC1Request) -> ();
	///   store_new_icrc1_canisters : (vec ICRC1) -> ();
	/// }
	class Service: ICPService {
		/// count_icrc1_canisters : () -> (nat64) query;
		func count_icrc1_canisters(sender: ICPSigningPrincipal? = nil) async throws -> UInt64 {
			let caller = ICPQueryNoArgs<UInt64>(canister, "count_icrc1_canisters")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_all_icrc1_canisters : () -> (vec ICRC1) query;
		func get_all_icrc1_canisters(sender: ICPSigningPrincipal? = nil) async throws -> [ICRC1] {
			let caller = ICPQueryNoArgs<[ICRC1]>(canister, "get_all_icrc1_canisters")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// get_icrc1_paginated : (nat64, nat64) -> (vec ICRC1) query;
		func get_icrc1_paginated(_ arg0: UInt64, _ arg1: UInt64, sender: ICPSigningPrincipal? = nil) async throws -> [ICRC1] {
			let caller = ICPQuery<ICPFunctionArgs2<UInt64, UInt64>, [ICRC1]>(canister, "get_icrc1_paginated")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response
		}
	
		/// replace_icrc1_canisters : (vec ICRC1) -> ();
		func replace_icrc1_canisters(_ arg0: [ICRC1], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[ICRC1]>(canister, "replace_icrc1_canisters")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// set_operator : (principal) -> ();
		func set_operator(_ arg0: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICPPrincipal>(canister, "set_operator")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// store_icrc1_canister : (ICRC1Request) -> ();
		func store_icrc1_canister(_ arg0: ICRC1Request, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<ICRC1Request>(canister, "store_icrc1_canister")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// store_new_icrc1_canisters : (vec ICRC1) -> ();
		func store_new_icrc1_canisters(_ arg0: [ICRC1], sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<[ICRC1]>(canister, "store_new_icrc1_canisters")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
	}

}
