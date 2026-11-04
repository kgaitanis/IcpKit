//
//  ICPCertificateTests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 04.05.23.
//

import Foundation
import Testing
import PotentCBOR
@testable import IcpKit

struct ICPCertificateTests {

    @Test func cborParsing() throws {
// from https://internetcomputer.org/docs/current/references/ic-interface-spec/#example
//       ─┬─┬╴"a" ─┬─┬╴"x" ─╴"hello"
//        │ │      │ └╴Empty
//        │ │      └╴  "y" ─╴"world"
//        │ └╴"b" ──╴"good"
//        └─┬╴"c" ──╴Empty
//          └╴"d" ──╴"morning"
        let cborData = Data.fromHex( "8301830183024161830183018302417882034568656c6c6f810083024179820345776f726c6483024162820344676f6f648301830241638100830241648203476d6f726e696e67")!
        let cbor = try ICPCryptography.CBOR.deserialiseCbor(from: cborData)
        let certificate = try ICPStateCertificate.HashTreeNode.buildTree(from: cbor)
        
        #expect(certificate == .fork(
                left: .fork(
                    left: .labeled("a", .fork(
                        left: .fork(
                            left: .labeled("x", .leaf("hello".data)),
                            right: .empty),
                        right: .labeled("y", .leaf("world".data)))),
                    right: .labeled("b", .leaf("good".data))),
                right: .fork(
                    left: .labeled("c", .empty),
                    right: .labeled("d", .leaf("morning".data)))
            )
        )
        
        #expect(certificate.getNode(for: "/a/x") == .leaf("hello".data))
        #expect(certificate.getNode(for: "/a/y") == .leaf("world".data))
        #expect(certificate.getNode(for: "/b") == .leaf("good".data))
        #expect(certificate.getNode(for: "/c") == .empty)
        #expect(certificate.getNode(for: "/d") == .leaf("morning".data))
        #expect(certificate.getNode(for: "/x") == nil)
        #expect(certificate.getNode(for: "/a/c") == nil)
        #expect(certificate.getNode(for: "/a/x/x") == nil)
        #expect(certificate.getNode(for: "/a") == .fork(
            left: .fork(
                left: .labeled("x", .leaf("hello".data)),
                right: .empty),
            right: .labeled("y", .leaf("world".data))))
        
        #expect(certificate.getValue(for: "/a/x") == "hello".data)
        #expect(certificate.getValue(for: "/a/y") == "world".data)
        #expect(certificate.getValue(for: "/b") == "good".data)
        #expect(certificate.getValue(for: "/d") == "morning".data)
        #expect(certificate.getValue(for: "/unknown_path") == nil)
        #expect(certificate.getValue(for: "/c") == nil)
        #expect(certificate.getValue(for: "/a") == nil)
        
        #expect(certificate.hash().hex == "eb5c5b2195e62d996b84c9bcc8259d19a83786a2f59e0878cec84c811f669aa0")

        // Reject malformed certificates and each malformed hash-tree node shape.
        for malformed: CBOR in [.null, .map([:]), .map(["signature": .utf8String("bad"), "tree": .array([0])]), .map(["signature": .byteString(Data())])] {
            #expect(throws: ICPStateCertificateError.invalidCertificateStructure) {
                try ICPStateCertificate.parse(malformed)
            }
        }
        for malformed: CBOR in [
            .null, .array([]), .array([.utf8String("leaf")]), .array([9]),
            .array([1]), .array([1, .array([0])]),
            .array([2]), .array([2, .utf8String("label"), .array([0])]),
            .array([3]), .array([3, .utf8String("value")]),
            .array([4]), .array([4, .utf8String("hash")])
        ] {
            #expect(throws: ICPStateCertificateError.invalidCertificateStructure) {
                try ICPStateCertificate.HashTreeNode.buildTree(from: malformed)
            }
        }

        let path: ICPStateTreePath = ["a", .data(Data([0xff]))]
        #expect(path.components.count == 2)
        #expect(path.firstComponent?.stringValue == "a")
        #expect(path.firstComponent?.dataValue == nil)
        #expect(path.removingFirstComponent.firstComponent?.dataValue == Data([0xff]))
        #expect(path.removingFirstComponent.firstComponent?.stringValue == nil)
        #expect(path.encodedComponents() == [Data("a".utf8), Data([0xff])])
        #expect(ICPStateTreePath("/").isEmpty)
        #expect(certificate.getNode(for: ICPStateTreePath("/")) == certificate)
    }
    
    @Test func cborPrunedParsing() throws {
// from https://internetcomputer.org/docs/current/references/ic-interface-spec/#example
// This tree represents the same state tree as in previous state,
// some of the branches have been pruned but the hash of the tree is the same for both trees
//       ─┬─┬╴"a" ─┬─ 1B4FEFF9BEF8131788B0C9DC6DBAD6E81E524249C879E9F10F71CE3749F5A638
//        │ │      └╴ "y" ─╴"world"
//        │ └╴"b" ──╴7B32AC0C6BA8CE35AC82C255FC7906F7FC130DAB2A090F80FE12F9C2CAE83BA6
//        └─┬╴EC8324B8A1F1AC16BD2E806EDBA78006479C9877FED4EB464A25485465AF601D
//          └╴"d" ──╴"morning"
        let cborData = Data.fromHex( "83018301830241618301820458201b4feff9bef8131788b0c9dc6dbad6e81e524249c879e9f10f71ce3749f5a63883024179820345776f726c6483024162820458207b32ac0c6ba8ce35ac82c255fc7906f7fc130dab2a090f80fe12f9c2cae83ba6830182045820ec8324b8a1f1ac16bd2e806edba78006479c9877fed4eb464a25485465af601d830241648203476d6f726e696e67")!
        let cbor = try ICPCryptography.CBOR.deserialiseCbor(from: cborData)
        let certificate = try ICPStateCertificate.HashTreeNode.buildTree(from: cbor)
        
        #expect(certificate == .fork(
            left: .fork(
                left: .labeled("a", .fork(
                    left: .pruned(.fromHex("1B4FEFF9BEF8131788B0C9DC6DBAD6E81E524249C879E9F10F71CE3749F5A638")!),
                    right: .labeled("y", .leaf("world".data))
                )),
                right: .labeled("b", .pruned(.fromHex("7B32AC0C6BA8CE35AC82C255FC7906F7FC130DAB2A090F80FE12F9C2CAE83BA6")!))
            ),
            right: .fork(
                left: .pruned(.fromHex("EC8324B8A1F1AC16BD2E806EDBA78006479C9877FED4EB464A25485465AF601D")!),
                right: .labeled("d", .leaf("morning".data)))))
        
        #expect(certificate.getValue(for: "/a/x") == nil)
        #expect(certificate.getValue(for: "/a/y") == "world".data)
        #expect(certificate.getValue(for: "/b") == nil)
        #expect(certificate.getValue(for: "/d") == "morning".data)
        #expect(certificate.getValue(for: "/unknown_path") == nil)
        #expect(certificate.getValue(for: "/c") == nil)
        #expect(certificate.getValue(for: "/a") == nil)
        
        #expect(certificate.hash().hex == "eb5c5b2195e62d996b84c9bcc8259d19a83786a2f59e0878cec84c811f669aa0")
    }
}

extension String {
    var data: Data {
        Data(utf8)
    }
}
