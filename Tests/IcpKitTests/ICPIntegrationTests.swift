////
////  ICPIntegrationTests.swift
////  IntegrationTests
////
////  Created by Konstantinos Gaitanis on 02.05.23.
////

import Foundation
import Testing
import PotentCBOR
@testable import IcpKit
import Candid

struct ICPIntegrationTests {
    private let client = ICPRequestClient()
    
    @Test func accountBalance() async throws {
        let mock = try LedgerMockClient(query: CandidEncoder().encode(LedgerCanister.Tokens(e8s: 123456)))
        #expect(try await ICPLedgerCanister.accountBalance(of: mainAccount1, mock.client) == 123456)
        let balance = try await ICPLedgerCanister.accountBalance(of: mainAccount1, client)
        print("Test Wallet 1 - Main Account Balance: \(balance)")
    }

    @Test func readState() async throws {
        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger)
        guard let timeLeb128 = response.rawValueForPath(endingWith: "time") else {
            Issue.record("Unexpected response")
            return
        }
        let timeSince1970s: Int = try Leb128.decodeUnsigned(timeLeb128) / 1_000_000_000
        let time = Date(timeIntervalSince1970: TimeInterval(timeSince1970s))
        #expect(Date.now > time)
        #expect(time.addingTimeInterval(10) > Date.now)
    }
    
//    @Test func readStateSigned() async throws {
//        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger, sender: signingPrincipal1)
//        print(response)
//    }
//   
//    @Test func transfer() async throws {
//        let block = try await ICPLedgerCanister.transfer(
//            from: mainAccount1,
//            to: mainAccount1.accountId.hex,
//            amount: 10000,
//            signingPrincipal: signingPrincipal1,
//            client)
//        print("Transaction sent in block \(block)")
//    }
    
    @Test func queryBlock() async throws {
        let from = Data([1]), to = Data([2]), spender = Data([3])
        let operations: [LedgerCanister.Operation] = [
            .Mint(to: to, amount: .init(e8s: 12)),
            .Burn(from: from, amount: .init(e8s: 12), spender: spender),
            .Transfer(to: to, fee: .init(e8s: 3), from: from, amount: .init(e8s: 12), spender: spender),
            .Approve(from: from, allowance: .init(e8s: 12), fee: .init(e8s: 3), expires_at: .init(timestamp_nanos: 2_000_000_000), expected_allowance: .init(e8s: 4), spender: spender),
            .Approve(from: from, allowance: .init(e8s: 12), fee: .init(e8s: 3), expires_at: nil, expected_allowance: nil, spender: spender)
        ]
        for operation in operations {
            let fixture = LedgerCanister.Block(transaction: .init(memo: 7, operation: operation, created_at_time: .init(timestamp_nanos: 99)), timestamp: .init(timestamp_nanos: 100), parent_hash: Data([42]))
            for archived in [false, true] {
                let mock = try LedgerMockClient(query: ledgerResponse(blocks: archived ? [] : [fixture], archived: archived), archive: CandidEncoder().encode(LedgerCanister.QueryArchiveResult.Ok(.init(blocks: [fixture]))))
                let actual = try await ICPLedgerCanister.queryBlock(index: 8, mock.client)
                #expect(actual.parentHash == Data([42]))
                #expect(actual.timestamp == 100)
                #expect(actual.transaction.memo == 7)
                #expect(actual.transaction.createdNanos == 99)
                #expect(actual.transaction.operation.amount == 12)
                switch actual.transaction.operation {
                case .mint(let address, _): #expect(address == to)
                case .burn(let address, _, let delegate):
                    #expect(address == from); #expect(delegate == spender)
                case .transfer(let source, let destination, _, let fee, let delegate):
                    #expect(source == from); #expect(destination == to); #expect(fee == 3); #expect(delegate == spender)
                case .approve(let source, _, let expected, let fee, let expiry, let delegate):
                    #expect(source == from); #expect(fee == 3); #expect(delegate == spender)
                    if case .Approve(_, _, _, let date, let allowance, _) = operation {
                        #expect(expected == allowance?.e8s)
                        #expect(expiry == date.map { Date(timeIntervalSince1970: Double($0.timestamp_nanos) / 1_000_000_000) })
                    }
                }
            }
        }
        for parentMissing in [false, true] {
            let fixture = LedgerCanister.Block(transaction: .init(memo: 0, operation: parentMissing ? operations[0] : nil, created_at_time: .init(timestamp_nanos: 1)), timestamp: .init(timestamp_nanos: 1), parent_hash: parentMissing ? nil : Data([1]))
            let mock = try LedgerMockClient(query: ledgerResponse(blocks: [fixture]))
            await #expect { _ = try await ICPLedgerCanister.queryBlock(index: 0, mock.client) } throws: { error in
                guard case ICPLedgerCanisterError.invalidBlock = error else { return false }; return true
            }
        }
        for archive: LedgerCanister.QueryArchiveResult? in [nil, .Err, .Ok(.init(blocks: []))] {
            let mock = try LedgerMockClient(query: ledgerResponse(blocks: [], archived: archive != nil), archive: archive.map { try CandidEncoder().encode($0) })
            await #expect { _ = try await ICPLedgerCanister.queryBlock(index: 0, mock.client) } throws: { error in
                guard case ICPLedgerCanisterError.blockNotFound = error else { return false }; return true
            }
        }
        let block = try await ICPLedgerCanister.queryBlock(index: 13309698, client)
        #expect(block.timestamp == 1723103842536019792)
        #expect(block.transaction.createdNanos == 1723103842536019792)
        #expect(block.transaction.memo == 0)
        #expect(block.parentHash == Data.fromHex("7f944c23b83cc7d5457b6503f95430cb751f8cfe561374470e672c70fb850342"))
        guard case .transfer(let from, let to, let amount, let fee, _) = block.transaction.operation else {
            Issue.record("operation is not a transfer")
            return
        }
        #expect(from == Data.fromHex("07537100d2fb357209a2283d6c5cb588ef7ee09db32fb7cc6f6241e44b155e4c"))
        #expect(to == Data.fromHex("57271f92125bdfd4fe0605f2e22c3ad549fc27cf2e85bae080645a5b516154ec"))
        #expect(amount == 190612587)
        #expect(fee == 10000)
    }
    
    @Test func generatedLedger() async throws {
        let archivesMock = try LedgerMockClient(query: CandidEncoder().encode(LedgerCanister.Archives(archives: [.init(canister_id: ICPSystemCanisters.ledger)])))
        let archives = try await LedgerCanister.Service(ICPSystemCanisters.ledger, client: archivesMock.client).archives()
        #expect(archives.archives.map(\.canister_id) == [ICPSystemCanisters.ledger])
        let results: [LedgerCanister.TransferResult] = [.Ok(123), .Err(.BadFee(expected_fee: .init(e8s: 10))), .Err(.InsufficientFunds(balance: .init(e8s: 20))), .Err(.TxTooOld(allowed_window_nanos: 30)), .Err(.TxDuplicate(duplicate_of: 40)), .Err(.TxCreatedInFuture)]
        for result in results {
            let mock = try LedgerMockClient(query: CandidEncoder().encode(result))
            do {
                let index = try await ICPLedgerCanister.transfer(from: mainAccount1, to: mainAccount1.accountId.hex, amount: 55, signingPrincipal: LedgerMockSigner(), fee: 10, memo: 77, mock.client)
                guard case .Ok(let expected) = result else { Issue.record("Expected transfer error"); continue }
                #expect(index == expected)
            } catch ICPLedgerCanisterError.transferFailed(let error) {
                switch (result, error) {
                case (.Err(.BadFee(let value)), .badFee(let actual)): #expect(actual == value.e8s)
                case (.Err(.InsufficientFunds(let value)), .insufficientFunds(let actual)): #expect(actual == value.e8s)
                case (.Err(.TxTooOld(let value)), .txTooOld(let actual)): #expect(actual == value)
                case (.Err(.TxDuplicate(let value)), .txDuplicate(let actual)): #expect(actual == value)
                case (.Err(.TxCreatedInFuture), .txCreatedInFuture): break
                default: Issue.record("Incorrect transfer error mapping")
                }
            }
        }
        await #expect {
            _ = try await ICPLedgerCanister.transfer(from: mainAccount1, to: "invalid", amount: 1, signingPrincipal: LedgerMockSigner(), archivesMock.client)
        } throws: { error in
            guard case ICPLedgerCanisterError.invalidAddress = error else { return false }; return true
        }
        let nBlocks: UInt64 = 3
        let ledger = LedgerCanister.Service(ICPSystemCanisters.ledger, client: client)
        let blocks = try await ledger.query_blocks(.init(start: 11268933, length: nBlocks))
        #expect(blocks.archived_blocks.map { $0.length }.reduce(0, +) + UInt64(blocks.blocks.count) == nBlocks)
        for archive in blocks.archived_blocks {
            let archiveResponse = try await archive.callback.callMethod(.init(start: archive.start, length: archive.length), client)
            print(archiveResponse)
            guard case .Ok = archiveResponse else { Issue.record("Unexpected response"); return }
        }
    }
}

private let testWallet1PublicKey: Data = Data.fromHex("046acf4c93dd993cd736420302eb70da254532ec3179250a21eec4ce823ff289aaa382cb19576b2c6447db09cb45926ebd69ce288b1804580fe62c343d3252ec6e")!
private let testWallet2PublicKey: Data = Data.fromHex("04723cdc9bd653014a501159fb89dcc6e2cf03f242955b987b53dd6193815d8a9d4a4f5b902b2819d270c28f0710ad96fea5b13f5fe30c6e244bf2941ebf4ec36e")!

private let principal1 = try! ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet1PublicKey)
private let mainAccount1 = ICPAccount.mainAccount(of: principal1)


// Every transport operation stays in memory, including calls that represent transfers.
private final class LedgerMockClient: HttpClient, Sendable {
    let query: Data
    let archive: Data?
    var client: ICPRequestClient {
        ICPRequestClient(network: ICPNetwork(baseURL: URL(string: "https://ledger.invalid")!), client: self)
    }

    init(query: CandidValue, archive: CandidValue? = nil) throws {
        self.query = CandidSerialiser().encode(query)
        self.archive = archive.map { CandidSerialiser().encode($0) }
    }

    func fetch(_ request: HttpRequest) async throws -> HttpResponse {
        let body = try #require(request.body)
        let envelope = try ICPCryptography.CBOR.deserialiseCbor(from: body)
        let content = try #require(envelope["content"])
        if request.url.lastPathComponent == "call" {
            let argument = try #require(content["arg"]?.bytesStringValue)
            let values = try CandidDeserialiser().decode(argument)
            let args = try CandidDecoder().decode(LedgerCanister.TransferArgs.self, from: #require(values.first))
            #expect(args.amount.e8s == 55)
            #expect(args.fee.e8s == 10)
            #expect(args.memo == 77)
            #expect(args.to == mainAccount1.accountId)
            #expect(args.from_subaccount == mainAccount1.subAccountId)
            #expect(args.created_at_time != nil)
            return HttpResponse(statusCode: 202)
        }
        if request.url.lastPathComponent == "read_state" {
            let paths = try #require(content["paths"]?.arrayValue)
            let path = try #require(paths.first { $0.arrayValue?.count == 3 }?.arrayValue)
            let requestId = try #require(path[1].bytesStringValue)
            let status: CBOR = .array([2, .byteString(Data("status".utf8)), .array([3, .byteString(Data("replied".utf8))])])
            let reply: CBOR = .array([2, .byteString(Data("reply".utf8)), .array([3, .byteString(query)])])
            let tree: CBOR = .array([2, .byteString(Data("request_status".utf8)), .array([2, .byteString(requestId), .array([1, status, reply])])])
            let certificate = try CBORSerialization.data(from: .map(["tree": tree, "signature": .byteString(Data())]))
            return HttpResponse(data: try CBORSerialization.data(from: .map(["certificate": .byteString(certificate)])), statusCode: 200)
        }
        let result = content["method_name"]?.utf8StringValue == "archive_blocks" ? try #require(archive) : query
        return HttpResponse(data: try CBORSerialization.data(from: .map(["status": "replied", "reply": .map(["arg": .byteString(result)])])), statusCode: 200)
    }
}

private struct LedgerMockSigner: ICPSigningPrincipal {
    var principal: ICPPrincipal { principal1 }
    var rawPublicKey: Data { testWallet1PublicKey }
    func sign(_ message: Data, domain: ICPDomainSeparator) async throws -> Data { Data(repeating: 0, count: 64) }
}

private func ledgerResponse(blocks: [LedgerCanister.Block], archived: Bool = false) throws -> CandidValue {
    let encodedBlocks = try blocks.map { try CandidEncoder().encode($0) }
    let callback = CandidValue.function(CandidFunction(signature: CandidFunctionSignature([CandidType](), [CandidType](), query: true), principal: ICPSystemCanisters.ledger, methodName: "archive_blocks"))
    let archive: CandidValue = .record(["callback": callback, "start": .natural64(8), "length": .natural64(1)])
    return .record([
        "certificate": .option(CandidType.vector(.natural8)),
        "blocks": .vector(encodedBlocks.isEmpty ? CandidVector(.null) : try CandidVector(encodedBlocks)),
        "chain_length": .natural64(100), "first_block_index": .natural64(8),
        "archived_blocks": .vector(archived ? try CandidVector([archive]) : CandidVector(archive.candidType))
    ])
}
