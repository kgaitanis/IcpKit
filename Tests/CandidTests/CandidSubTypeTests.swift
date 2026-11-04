//
//  CandidSubTypeTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 24.07.24.
//

import Testing
import Candid

struct CandidSubTypeTests {
    @Test(arguments: TestCases.subTypes) func `Sub types`(input: (subType: CandidType, superType: CandidType, result: Bool)) {
        #expect(input.subType.isSubType(of: input.superType) == input.result, "\(input.superType) isSubTypeOf \(input.subType) failed to return \(input.result)")
    }

    @Test func compositeSubtypingChecksContainedTypes() {
        #expect(CandidType.option(.natural).isSubType(of: .option(.integer)))
        #expect(!CandidType.option(.integer).isSubType(of: .option(.natural)))
        #expect(CandidType.vector(.natural).isSubType(of: .vector(.integer)))
        #expect(!CandidType.vector(.integer).isSubType(of: .vector(.natural)))
        let types: [CandidType] = [
            .option(.bool), .vector(.bool), .record(["a": .bool]),
            .variant("a"), .function(), .service(), .named("Missing")
        ]
        for type in types {
            #expect(!type.isSubType(of: .bool))
        }
        let unresolved = CandidType.service([.init(name: "f", signatureType: .reference("Missing"))])
        let concrete = CandidType.service(["f": .init([CandidType.bool], [])])
        #expect(!unresolved.isSubType(of: concrete))
    }

}

private enum TestCases {
    static let subTypes: [(subType: CandidType, superType: CandidType, result: Bool)] = [
        (.null, .null, true),
        (.null, .natural, false),
        (.null, .option(.natural), true),
        (.natural, .natural, true),
        (.natural, .integer, true),
        (.natural, .natural64, false),
        (.natural64, .natural64, true),
        (.natural64, .natural32, false),
        (.natural8, .option(.natural8), true),
        (.natural8, .option(.natural16), false),
        (.reserved, .option(.reserved), false),
        (.null, .option(.null), false),
        (.empty, .text, true),
        (.option(.empty), .option(.text), true),
        (.option(.empty), .text, true),
        (.option(.null), .text, true),
        (.integer, .option(.integer), true),
        (.option(.bool), .option(.option(.bool)), false),
        (.record(), .record(), true),
        (.record(), .record(["a":.bool]), false),
        (.record(["a":.text, "b":.option(.empty), "c":.natural, "d": .text]), .record(["a":.text, "b":.text, "c":.integer]), true),
        (.record(["a":.text, "b":.text, "c":.natural]), .record(["a":.text, "b":.option(.text), "c":.integer]), true),
        (.variant(["a": .text]), .variant(["a": .text]), true),
        (.variant(["a": .text]), .variant(["a": .text, "b":.bool]), true),
        (.variant(["a": .text, "c": .natural]), .variant(["a": .text, "b":.bool]), false),
        (.variant(["a": .text, "b": .natural]), .variant(["a": .text, "b":.bool]), false),
        (.variant(["b": .natural]), .variant(["a": .text, "b":.integer]), true),
        (.function([CandidType](),[]), .function([CandidType](),[]), true),
        (.function([],[.natural]), .function([CandidType](),[]), true),
        (.function([],[.natural]), .function([],[.integer]), true),
        (.function([.natural],[]), .function([CandidType](),[]), false),
        (.function([.option(.natural)],[]), .function([CandidType](),[]), true),
        (.function([.integer],[]), .function([.natural],[]), true),
        (.function([.integer],[], query: true), .function([.natural],[]), false),
        (.service([]), .service([]), true),
        (.service(["a": .init([CandidType](), [])]), .service([]), true),
        (.service(["a": .init([], [.natural])]), .service(["a": .init([], [.integer])]), true),
        (.service([]), .service(["a": .init([], [.integer])]), false),
    ]
}
