import Foundation
import Testing
@testable import IcpKit

struct EllipticSignTests {
    // Independent OpenSSL fixture also used by DelegationWireTests.
    private let message = Data("icp delegation verification".utf8)
    private var publicKey: Data {
        get throws {
            try #require(Data.fromHex("041b84c5567b126440995d3ed5aaba0565d71e1834604819ff9c17f5e9d5dd078f70beaf8f588b541507fed6a642c5ab42dfdf8120a7f639de5122d47a69a8e8d1"))
        }
    }
    private var signature: Data {
        get throws {
            try #require(Data.fromHex("ed11fc29f1b635add0037fdf9e279cb928052553dc4068d380e52f0cae14c365afe56a0378d479e8ed3787e9769cb832bed98edaeaab70e174e94fe7291228ed"))
        }
    }

    @Test(arguments: [UInt8(0), UInt8(255)])
    func rejectsInvalidPrivateScalars(byte: UInt8) {
        #expect(throws: ICPCryptography.SignError.signFailed) {
            try ICPCryptography.ellipticSign(Data(repeating: 1, count: 32),
                                           privateKey: Data(repeating: byte, count: 32))
        }
    }

    @Test func signingProducesVerifiableCompactSignature() throws {
        let signed = try ICPCryptography.ellipticSign(
            ICPCryptography.sha256(message), privateKey: Data(repeating: 1, count: 32))
        #expect(signed.count == 65)
        let recoveryID = try #require(signed.last)
        #expect((27...30).contains(recoveryID))
        #expect(try ICPCryptography.verifySecp256k1(
            signature: Data(signed.prefix(64)), message: message, publicKeyUncompressed: publicKey))
    }

    @Test func verifiesIndependentSignatureAndRejectsChangedMessage() throws {
        #expect(try ICPCryptography.verifySecp256k1(
            signature: signature, message: message, publicKeyUncompressed: publicKey))
        #expect(try !ICPCryptography.verifySecp256k1(
            signature: signature, message: Data("changed".utf8), publicKeyUncompressed: publicKey))
    }

    @Test(arguments: [0, 63, 65])
    func rejectsWrongSignatureLength(count: Int) throws {
        let key = try publicKey
        #expect(throws: ICPPublicKey.Error.invalidSignature) {
            try ICPCryptography.verifySecp256k1(
                signature: Data(repeating: 0, count: count), message: message, publicKeyUncompressed: key)
        }
    }

    @Test func rejectsOverflowingSignatureScalars() throws {
        let key = try publicKey
        #expect(throws: ICPPublicKey.Error.invalidSignature) {
            try ICPCryptography.verifySecp256k1(
                signature: Data(repeating: 255, count: 64), message: message, publicKeyUncompressed: key)
        }
    }

    @Test func zeroSignatureIsInvalidRatherThanMalformed() throws {
        #expect(try !ICPCryptography.verifySecp256k1(
            signature: Data(repeating: 0, count: 64), message: message, publicKeyUncompressed: publicKey))
    }

    @Test func rejectsMalformedPublicKeys() throws {
        let validSignature = try signature
        let keys = [Data(), Data([2]) + Data(repeating: 1, count: 32),
                    Data([5]) + Data(repeating: 1, count: 64), Data([4]) + Data(repeating: 0, count: 64)]
        for key in keys {
            #expect(throws: ICPPublicKey.Error.invalidPublicKey) {
                try ICPCryptography.verifySecp256k1(
                    signature: validSignature, message: message, publicKeyUncompressed: key)
            }
        }
    }
}
