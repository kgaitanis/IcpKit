//
//  ICPFunctionTests.swift
//  
//
//  Created by Konstantinos Gaitanis on 10.09.24.
//

import Foundation
import Testing
@testable import IcpKit
import Candid

struct ICPFunctionTests {
    let coder = ICPFunctionArgsCoder()
    
    @Test func `ICP function args coder`() async throws {
        let testVectors: [(any CodableEquatable.Type, any CodableEquatable, [CandidValue])] = [
            (CandidTuple3<Int, Int, Int>.self, CandidTuple3(1, 2, 3), [.record([.integer64(1), .integer64(2), .integer64(3)])]),
            (CandidTuple4<Int, Int, Int, Int>.self, CandidTuple4(1, 2, 3, 4), [.record([.integer64(1), .integer64(2), .integer64(3), .integer64(4)])]),
            (CandidTuple5<Int, Int, Int, Int, Int>.self, CandidTuple5(1, 2, 3, 4, 5), [.record([.integer64(1), .integer64(2), .integer64(3), .integer64(4), .integer64(5)])]),
            (CandidTuple6<Int, Int, Int, Int, Int, Int>.self, CandidTuple6(1, 2, 3, 4, 5, 6), [.record([.integer64(1), .integer64(2), .integer64(3), .integer64(4), .integer64(5), .integer64(6)])]),
            (CandidTuple7<Int, Int, Int, Int, Int, Int, Int>.self, CandidTuple7(1, 2, 3, 4, 5, 6, _6: 7), [.record([.integer64(1), .integer64(2), .integer64(3), .integer64(4), .integer64(5), .integer64(6), .integer64(7)])]),
            (Bool.self, true, [.bool(true)]),
            (CandidTuple2<Bool, Int>.self, CandidTuple2(true, 1), [.record([.bool(true), .integer64(1)])]),
            (ICPFunctionArgs2<Bool, Int>.self, ICPFunctionArgs2(true, 1), [.bool(true), .integer64(1)]),
            (ICPFunctionArgs3<Bool, Int, Data>.self, ICPFunctionArgs3(true, 1, Data()), [.bool(true), .integer64(1), .blob(Data())]),
            (ICPFunctionArgs4<Bool, Int, Data, Bool?>.self, ICPFunctionArgs4(true, 1, Data(), Bool?.none), [.bool(true), .integer64(1), .blob(Data()), .option(.bool)]),
            (ICPFunctionArgs5<Bool, Int, Data, Bool?, Int?>.self, ICPFunctionArgs5(true, 1, Data(), Bool?.none, Int?.none), [.bool(true), .integer64(1), .blob(Data()), .option(.bool), .option(.integer64)]),
            (ICPFunctionArgs6<Bool, Int, Data, Bool?, Int?, ICPPrincipal>.self, ICPFunctionArgs6(true, 1, Data(), Bool?.none, Int?.none, ICPPrincipal("aaaaa-aa")), [.bool(true), .integer64(1), .blob(Data()), .option(.bool), .option(.integer64), .principal("aaaaa-aa")]),
            (ICPFunctionArgs7<Bool, Int, Data, Bool?, Int?, ICPPrincipal, String>.self, ICPFunctionArgs7(true, 1, Data(), Bool?.none, Int?.none, ICPPrincipal("aaaaa-aa"), "text"), [.bool(true), .integer64(1), .blob(Data()), .option(.bool), .option(.integer64), .principal("aaaaa-aa"), .text("text")]),
        ]
        
        for (type, value, candidValue) in testVectors {
            let encoded = try coder.encode(value)
            let decoded = try coder.decode(type, from: candidValue)
            #expect(encoded == candidValue)
            let matches = compare(type, decoded, value)
            #expect(matches)

            for malformed in [Array(candidValue.dropLast()), candidValue + [.null]] {
                #expect {
                    _ = try coder.decode(type, from: malformed)
                } throws: { error in
                    if candidValue.count > 1 {
                        guard case DecodingError.dataCorrupted(let context) = error else { return false }
                        return context.codingPath.isEmpty
                            && context.debugDescription == "Trying to decode \(candidValue.count) values but instead have \(malformed.count) Candid Values"
                    }
                    guard case DecodingError.typeMismatch(_, let context) = error else { return false }
                    return context.codingPath.isEmpty
                        && context.debugDescription == "Trying to decode a single value but instead have \(malformed.count) values"
                }
            }
            var wrongType = candidValue
            wrongType[0] = .text("not the expected type")
            #expect(throws: (any Error).self) {
                _ = try coder.decode(type, from: wrongType)
            }
        }

        let inferred: Bool = try coder.decode([.bool(true)])
        #expect(inferred)
        let emptyTuple = CandidTuple0()
        #expect(try coder.encode(emptyTuple) == [.record([CandidValue]())])
        _ = try coder.decode(CandidTuple0.self, from: [.record([CandidValue]())])
        #expect(try coder.encode(CandidTuple1(42)) == [.record([.integer64(42)])])
        let singleTuple = try coder.decode(CandidTuple1<Int>.self, from: [.record([.integer64(42)])])
        #expect(singleTuple.tuple == 42)
        let tuple2 = CandidTuple2(1, 2).tuple
        #expect([tuple2.0, tuple2.1] == ([1, 2] as [Int]))
        let args2 = ICPFunctionArgs2(1, 2).tuple
        #expect([args2.0, args2.1] == ([1, 2] as [Int]))
        let tuple3 = CandidTuple3(1, 2, 3).tuple
        #expect([tuple3.0, tuple3.1, tuple3.2] == ([1, 2, 3] as [Int]))
        let args3 = ICPFunctionArgs3(1, 2, 3).tuple
        #expect([args3.0, args3.1, args3.2] == ([1, 2, 3] as [Int]))
        let tuple4 = CandidTuple4(1, 2, 3, 4).tuple
        #expect([tuple4.0, tuple4.1, tuple4.2, tuple4.3] == ([1, 2, 3, 4] as [Int]))
        let args4 = ICPFunctionArgs4(1, 2, 3, 4).tuple
        #expect([args4.0, args4.1, args4.2, args4.3] == ([1, 2, 3, 4] as [Int]))
        let tuple5 = CandidTuple5(1, 2, 3, 4, 5).tuple
        #expect([tuple5.0, tuple5.1, tuple5.2, tuple5.3, tuple5.4] == ([1, 2, 3, 4, 5] as [Int]))
        let args5 = ICPFunctionArgs5(1, 2, 3, 4, 5).tuple
        #expect([args5.0, args5.1, args5.2, args5.3, args5.4] == ([1, 2, 3, 4, 5] as [Int]))
        let tuple6 = CandidTuple6(1, 2, 3, 4, 5, 6).tuple
        #expect([tuple6.0, tuple6.1, tuple6.2, tuple6.3, tuple6.4, tuple6.5] == ([1, 2, 3, 4, 5, 6] as [Int]))
        let args6 = ICPFunctionArgs6(1, 2, 3, 4, 5, 6).tuple
        #expect([args6.0, args6.1, args6.2, args6.3, args6.4, args6.5] == ([1, 2, 3, 4, 5, 6] as [Int]))
        let tuple7 = CandidTuple7(1, 2, 3, 4, 5, 6, _6: 7).tuple
        #expect([tuple7.0, tuple7.1, tuple7.2, tuple7.3, tuple7.4, tuple7.5, tuple7.6] == ([1, 2, 3, 4, 5, 6, 7] as [Int]))
        let args7 = ICPFunctionArgs7(1, 2, 3, 4, 5, 6, 7).tuple
        #expect([args7.0, args7.1, args7.2, args7.3, args7.4, args7.5, args7.6] == ([1, 2, 3, 4, 5, 6, 7] as [Int]))

        let canister = ICPPrincipal("aaaaa-aa")
        let query = ICPQuery<Bool, Bool>(canister, "echo")
        let call = query.toCall()
        #expect(query.isQuery)
        #expect(!call.isQuery)
        #expect(call.canister == canister)
        #expect(call.methodName == "echo")
        let reply = try ICPCryptography.CBOR.serialise(FunctionReply(
            status: "replied", reply: .init(arg: CandidSerialiser().encode([.bool(true)]))))
        let client = ICPRequestClient(FunctionHttpClient(response: HttpResponse(data: reply, statusCode: 200)))
        #expect(try await query.callMethod(true, client))
        #expect(try await ICPQueryNoArgs<Bool>(canister, "read").callMethod(client))
        try await ICPQueryNoResult<Bool>(canister, "write").callMethod(true, client)
        try await ICPQueryNoArgsNoResult(canister, "ping").callMethod(client)

        let failingClient = ICPRequestClient(FunctionHttpClient(response: HttpResponse(statusCode: 503)))
        await #expect(throws: ICPRemoteClientError.self) {
            _ = try await call.callMethod(true, failingClient)
        }
        let method = ICPMethod(canister: canister, methodName: "echo", arg: .bool(true))
        #expect(method.args == [.bool(true)])
        #expect(ICPMethod(canister: canister, methodName: "ping").args == nil)
    }
    
    private func compare<T: Equatable>(_ type: T.Type, _ a: Any, _ b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }
        return a == b
    }
}

private typealias CodableEquatable = Codable & Equatable

private struct FunctionReply: Encodable {
    let status: String
    let reply: Reply

    struct Reply: Encodable {
        let arg: Data
    }
}

private final class FunctionHttpClient: HttpClient {
    let data: Data?
    let statusCode: Int

    init(response: HttpResponse) {
        data = response.data
        statusCode = response.statusCode
    }

    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        HttpResponse(data: data, statusCode: statusCode)
    }
}
