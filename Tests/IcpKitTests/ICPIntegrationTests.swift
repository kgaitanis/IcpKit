////
////  ICPIntegrationTests.swift
////  IntegrationTests
////
////  Created by Konstantinos Gaitanis on 02.05.23.
////

import XCTest
@testable import IcpKit
import Candid

final class ICPIntegrationTests: XCTestCase {
    private let client = ICPRequestClient()
    
    func testAccountBalance() async throws {
        let balance = try await ICPLedgerCanister.accountBalance(of: mainAccount1, client)
        print("Test Wallet 1 - Main Account Balance: \(balance)")
    }

    func testReadState() async throws {
        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger)
        guard let timeLeb128 = response.rawValueForPath(endingWith: "time") else {
            XCTFail()
            return
        }
        let timeSince1970s: Int = try Leb128.decodeUnsigned(timeLeb128) / 1_000_000_000
        let time = Date(timeIntervalSince1970: TimeInterval(timeSince1970s))
        XCTAssertGreaterThan(.now, time)
        XCTAssertGreaterThan(time.addingTimeInterval(10), .now)
    }
    
//    func testReadStateSigned() async throws {
//        let response = try await client.readState(paths: ["time"], effectiveCanister: ICPSystemCanisters.ledger, sender: signingPrincipal1)
//        print(response)
//    }
//   
//    func testTransfer() async throws {
//        let block = try await ICPLedgerCanister.transfer(
//            from: mainAccount1,
//            to: mainAccount1.accountId.hex,
//            amount: 10000,
//            signingPrincipal: signingPrincipal1,
//            client)
//        print("Transaction sent in block \(block)")
//    }
    
    func testQueryBlock() async throws {
        let block = try await ICPLedgerCanister.queryBlock(index: 13309698, client)
        XCTAssertEqual(block.timestamp, 1723103842536019792)
        XCTAssertEqual(block.transaction.createdNanos, 1723103842536019792)
        XCTAssertEqual(block.transaction.memo, 0)
        XCTAssertEqual(block.parentHash, Data.fromHex("7f944c23b83cc7d5457b6503f95430cb751f8cfe561374470e672c70fb850342"))
        guard case .transfer(let from, let to, let amount, let fee, _) = block.transaction.operation else {
            XCTFail("operation is not a transfer")
            return
        }
        XCTAssertEqual(from, Data.fromHex("07537100d2fb357209a2283d6c5cb588ef7ee09db32fb7cc6f6241e44b155e4c"))
        XCTAssertEqual(to, Data.fromHex("57271f92125bdfd4fe0605f2e22c3ad549fc27cf2e85bae080645a5b516154ec"))
        XCTAssertEqual(amount, 190612587)
        XCTAssertEqual(fee, 10000)
    }
    
    func testGeneratedLedger() async throws {
        let nBlocks: UInt64 = 3
        let ledger = LedgerCanister.Service(ICPSystemCanisters.ledger, client: client)
        let blocks = try await ledger.query_blocks(.init(start: 11268933, length: nBlocks))
        XCTAssertEqual(blocks.archived_blocks.map { $0.length }.reduce(0, +) + UInt64(blocks.blocks.count), nBlocks)
        for archive in blocks.archived_blocks {
            let archiveResponse = try await archive.callback.callMethod(.init(start: archive.start, length: archive.length), client)
            print(archiveResponse)
            guard case .Ok = archiveResponse else { XCTFail(); return }
        }
    }
}

private let testWallet1PublicKey: Data = Data.fromHex("046acf4c93dd993cd736420302eb70da254532ec3179250a21eec4ce823ff289aaa382cb19576b2c6447db09cb45926ebd69ce288b1804580fe62c343d3252ec6e")!
private let testWallet2PublicKey: Data = Data.fromHex("04723cdc9bd653014a501159fb89dcc6e2cf03f242955b987b53dd6193815d8a9d4a4f5b902b2819d270c28f0710ad96fea5b13f5fe30c6e244bf2941ebf4ec36e")!

private let principal1 = try! ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet1PublicKey)
private let mainAccount1 = ICPAccount.mainAccount(of: principal1)
