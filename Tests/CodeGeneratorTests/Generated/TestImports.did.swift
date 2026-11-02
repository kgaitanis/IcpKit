//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum TestImports {
	/// type ABool = bool;
	typealias ABool = Bool
	
	/// type AData = blob;
	typealias AData = Data
	
	typealias EmptyRecord = CandidTuple0
	
	/// type Function00 = func () -> ();
	typealias Function00 = ICPCallNoArgsNoResult
	
	/// type Function01q = func () -> (bool) query;
	typealias Function01q = ICPQueryNoArgs<Bool>
	
	/// type Function02 = func () -> (bool, text);
	typealias Function02 = ICPCallNoArgs<ICPFunctionArgs2<Bool, String>>
	
	/// type Function03q = func () -> (bool, text, opt bool) query;
	typealias Function03q = ICPQueryNoArgs<ICPFunctionArgs3<Bool, String, Bool?>>
	
	/// type Function10 = func (bool) -> ();
	typealias Function10 = ICPCallNoResult<Bool>
	
	/// type Function20 = func (bool, text) -> ();
	typealias Function20 = ICPCallNoResult<ICPFunctionArgs2<Bool, String>>
	
	/// type Function30q = func (bool, text, opt bool) -> () query;
	typealias Function30q = ICPQueryNoResult<ICPFunctionArgs3<Bool, String, Bool?>>
	
	typealias RepeatedRecord = CandidTuple2<[Int8?], UInt8>
	
	typealias UnnamedType0 = CandidTuple2<[Int8?], UInt8>
	
	/// type VectorBool = vec bool;
	typealias VectorBool = [Bool]
	
	
	/// type Record = record {
	///     a: vec opt int;
	///     b: nat;
	///     c: record { bool; text };
	/// };
	struct Record: Codable {
		let a: [BigInt?]
		let b: BigUInt
		let c: CandidTuple2<Bool, String>
	}
	
	/// type TestServiceDef = service {
	///     foo: (nat8) -> (int8);
	///     ref: Function01q;
	/// };
	class TestServiceDef: ICPService {
		/// foo: (nat8) -> (int8);
		func foo(_ arg0: UInt8, sender: ICPSigningPrincipal? = nil) async throws -> Int8 {
			let caller = ICPCall<UInt8, Int8>(canister, "foo")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		func ref(sender: ICPSigningPrincipal? = nil) async throws -> Bool {
			let caller = Function01q(canister, "ref")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
	}
	
	/// type UnnamedVariant = variant { spring; winter; summer; fall };
	enum UnnamedVariant: Codable {
		case fall
		case winter
		case summer
		case spring
	
		enum CodingKeys: String, CandidCodingKey {
			case fall
			case winter
			case summer
			case spring
		}
	}
	
	/// type Variant = variant {
	///     a: null;
	///     b: text;
	///     c: record { text; int };
	///     d: record {
	///         one: bool;
	///         two: blob;
	///         three: record { vec opt int8; nat8; };
	///     };
	/// };
	enum Variant: Codable {
		case a
		case b(String)
		case c(String, BigInt)
		case d(one: Bool, two: Data, three: CandidTuple2<[Int8?], UInt8>)
	
		enum CodingKeys: String, CandidCodingKey {
			case a
			case b
			case c
			case d
		}
		enum DCodingKeys: String, CandidCodingKey {
			case one
			case two
			case three
		}
	}
	

	/// service : {
	///   noArgsNoResults: () -> ();
	///   singleUnnamedArg: (text) -> () query;
	///   singleUnnamedArgRecordWithUnnamedFields: (record { bool; text }) -> ();
	///   singleNamedArg: (myString: text) -> () query;
	///   singleUnnamedResult: () -> (opt bool);
	///   singleNamedResult: () -> (myString: text) query;
	///   multipleUnnamedArgsAndResults: (text, vec nat) -> (opt bool, vec bool);
	///   multipleNamedArgsAndResults: (name: text, ids: vec nat) -> (out1: opt bool, out2: vec blob);
	///   functionReference: Function20;
	/// };
	class Service: ICPService {
		/// noArgsNoResults: () -> ();
		func noArgsNoResults(sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoArgsNoResult(canister, "noArgsNoResults")
			let _ = try await caller.callMethod(client, sender: sender)
		}
	
		/// singleUnnamedArg: (text) -> () query;
		func singleUnnamedArg(_ arg0: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPQueryNoResult<String>(canister, "singleUnnamedArg")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// singleUnnamedArgRecordWithUnnamedFields: (record { bool; text }) -> ();
		func singleUnnamedArgRecordWithUnnamedFields(_ arg0: CandidTuple2<Bool, String>, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPCallNoResult<CandidTuple2<Bool, String>>(canister, "singleUnnamedArgRecordWithUnnamedFields")
			let _ = try await caller.callMethod(arg0, client, sender: sender)
		}
	
		/// singleNamedArg: (myString: text) -> () query;
		func singleNamedArg(myString: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = ICPQueryNoResult<String>(canister, "singleNamedArg")
			let _ = try await caller.callMethod(myString, client, sender: sender)
		}
	
		/// singleUnnamedResult: () -> (opt bool);
		func singleUnnamedResult(sender: ICPSigningPrincipal? = nil) async throws -> Bool? {
			let caller = ICPCallNoArgs<Bool?>(canister, "singleUnnamedResult")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// singleNamedResult: () -> (myString: text) query;
		func singleNamedResult(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "singleNamedResult")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// multipleUnnamedArgsAndResults: (text, vec nat) -> (opt bool, vec bool);
		func multipleUnnamedArgsAndResults(_ arg0: String, _ arg1: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> (Bool?, [Bool]) {
			let caller = ICPCall<ICPFunctionArgs2<String, [BigUInt]>, ICPFunctionArgs2<Bool?, [Bool]>>(canister, "multipleUnnamedArgsAndResults")
			let response = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
			return response.tuple
		}
	
		/// multipleNamedArgsAndResults: (name: text, ids: vec nat) -> (out1: opt bool, out2: vec blob);
		func multipleNamedArgsAndResults(name: String, ids: [BigUInt], sender: ICPSigningPrincipal? = nil) async throws -> (out1: Bool?, out2: [Data]) {
			let caller = ICPCall<ICPFunctionArgs2<String, [BigUInt]>, ICPFunctionArgs2<Bool?, [Data]>>(canister, "multipleNamedArgsAndResults")
			let response = try await caller.callMethod(.init(name, ids), client, sender: sender)
			return response.tuple
		}
	
		func functionReference(_ arg0: Bool, _ arg1: String, sender: ICPSigningPrincipal? = nil) async throws {
			let caller = Function20(canister, "functionReference")
			let _ = try await caller.callMethod(.init(arg0, arg1), client, sender: sender)
		}
	
	}

}
