//
//  ICPTransactionHashTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 16.11.23.
//

import Foundation
import Testing
@testable import IcpKit

struct ICPTransactionHashTests {
    @Test func hash() throws {
        for (transaction, expectedHash) in testVectors {
            let calculatedHash = try ICPCryptography.transactionHash(transaction).hex
            #expect(calculatedHash == expectedHash)
            #expect(try ICPCryptography.transactionHash(
                transaction.operation, memo: transaction.memo, createdNanos: transaction.createdNanos).hex == expectedHash)
        }

        let operations: [(ICPBlock.Transaction.Operation, String?, String?, UInt64?)] = [
            (.approve(from: Data([0xaa]), allowance: 42, expectedAllowance: 12,
                      fee: 10, expiresAt: Date(timeIntervalSince1970: 2), spender: Data([0xcc])),
             "aa", nil, 10),
            (.burn(from: Data([0xaa]), amount: 42, spender: nil), "aa", nil, nil),
            (.mint(to: Data([0xbb]), amount: 42), nil, "bb", nil),
            (.transfer(from: Data([0xaa]), to: Data([0xbb]), amount: 42, fee: 10, spender: Data([0xcc])),
             "aa", "bb", 10)
        ]
        for (operation, from, to, fee) in operations {
            #expect(operation.amount == 42)
            #expect(operation.fee == fee)
            let transaction = ICPBlock.Transaction(memo: 7, createdNanos: 1_000_000_000, operation: operation)
            let block = ICPBlock(parentHash: Data([0xdd]), timestamp: 2_000_000_000, transaction: transaction)
            let hash = Data([1, 2, 3])
            let converted = block.icpTransaction(blockIndex: 99, hash: hash)
            #expect(converted.type.from == from)
            #expect(converted.type.to == to)
            #expect(converted.amount == 42)
            #expect(converted.fee == fee.map(UInt.init))
            #expect(converted.hash == hash)
            #expect(converted.blockIndex == 99)
            #expect(converted.memo == 7)
            #expect(converted.createdNanos == 1_000_000_000)
            #expect(converted.created == Date(timeIntervalSince1970: 1))
        }
    }
}

// https://cbor.nemo157.com/#type=hex&value=a300a102a4007840653933343436313363393631356138336366313537343864393236356337376237363234343136363637386434613066643564663133313836633634623963340178406238376636303164353038633266653139363764316561636562346538313230356537376532396463343665623936646632303238383831656434633966386302a1001a549411b003a100192710011a654b4fd802a1001b17959aa2607b5b8f
// https://dashboard.internetcomputer.org/transaction/e609323577ef35afca168a5b45504549889f4086dba5ef4fae8d9dfb2e9666e0

nonisolated(unsafe) private let testVectors: [(ICPBlock.Transaction, String)] = [
    (.init(
        memo: 1699434456,
        createdNanos: 1699434456596306831,
        operation: .transfer(
            from: Data.fromHex("e9344613c9615a83cf15748d9265c77b76244166678d4a0fd5df13186c64b9c4")!,
            to: Data.fromHex("b87f601d508c2fe1967d1eaceb4e81205e77e29dc46eb96df2028881ed4c9f8c")!,
            amount: 1_418_990_000,
            fee: 10_000,
            spender: nil
        )
    ), "e609323577ef35afca168a5b45504549889f4086dba5ef4fae8d9dfb2e9666e0"),
    
    (.init(
        memo: 1234,
        createdNanos: 1728037586000000000,
        operation: .transfer(
            from: Data.fromHex("cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c")!,
            to: Data.fromHex("cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c")!,
            amount: 1_000_000,
            fee: 10_000,
            spender: nil
        )
    ), "e7fb27fc14d6439b3aceee0b88125d7f4ab902a583edfb2586ff8f32e9866f4b"),
    // SHA-256 of independently encoded CBOR:
    // a300a100a20062616101182a010702a1001a3b9aca00 (burn)
    // a300a101a20062626201182a010702a1001a3b9aca00 (mint)
    (.init(memo: 7, createdNanos: 1_000_000_000,
           operation: .burn(from: Data([0xaa]), amount: 42, spender: nil)),
     "d1d25e80dda380e18093cc862cf982593ea2f3c80eb6991b7ac57370a1406fc0"),
    (.init(memo: 7, createdNanos: 1_000_000_000,
           operation: .mint(to: Data([0xbb]), amount: 42)),
     "3f371f123d8bdc8fb7a0f7598c7fb9b1cc84e6cd84b9f3e329591db749330487"),
    // TODO: Find some examples for approve operations
//    (.init(
//        memo: 0,
//        createdNanos: 1_728_385_862_598_091_123,
//        operation: .approve(
//            from: Data.fromHex("cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c")!,
//            allowance: 9_950_000,
//            expectedAllowance: nil,
//            fee: 10_000,
//            expiresAt: nil,
//            spender: Data.fromHex("7d18876a5c92295f1fbd1d9a110ca4892dbd191825fa9c2015fda82cc4ebb51e")!
//        )
//    ),"3a191f8ee50921015adf6914e6b9d7f201afed91ef49998d5801745a0d89cf54"),
    
]
