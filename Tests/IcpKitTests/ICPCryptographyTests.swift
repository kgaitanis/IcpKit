//
//  SHA224Tests.swift
//  UnitTests
//
//  Created by Konstantinos Gaitanis on 19.04.23.
//

import XCTest
@testable import IcpKit
import Candid

final class ICPCryptographyTests: XCTestCase {
    // test vectors generated using https://pi7.org/hash/sha224
    func testSHA224() throws {
        XCTAssertEqual(ICPCryptography.sha224(Data()).hex, "D14A028C2A3A2BC9476102BB288234C415A2B01F828EA62AC5B3E42F".lowercased())
        XCTAssertEqual(ICPCryptography.sha224("0".data(using: .utf8)!).hex, "dfd5f9139a820075df69d7895015360b76d0360f3d4b77a845689614")
        XCTAssertEqual(ICPCryptography.sha224("abcd".data(using: .utf8)!).hex, "a76654d8e3550e9a2d67a0eeb6c67b220e5885eddd3fde135806e601")
        XCTAssertEqual(ICPCryptography.sha224("./`~.?!@#$".data(using: .utf8)!).hex, "c30cf54e8acd816aa0ab041605279563175199d2661f8e7aae37fa1e")
        XCTAssertEqual(ICPCryptography.sha224("Lorem ipsum dolor sit amet, consectetur adipiscing elit".data(using: .utf8)!).hex, "ff40dac83c1c21b71126074ced5c2f6195b6c993b53394ffb2e75f43")
    }
    
    // test vectors generated using https://crccalc.com/
    func testCRC32() {
        XCTAssertEqual(CRC32.checksum(Data()).hex, "00000000")
        XCTAssertEqual(CRC32.checksum("0".data(using: .utf8)!).hex, "F4DBDF21".lowercased())
        XCTAssertEqual(CRC32.checksum("abcd".data(using: .utf8)!).hex, "ED82CD11".lowercased())
        XCTAssertEqual(CRC32.checksum("./`~.?!@#$".data(using: .utf8)!).hex, "77838090".lowercased())
        XCTAssertEqual(CRC32.checksum("Lorem ipsum dolor sit amet, consectetur adipiscing elit".data(using: .utf8)!).hex, "6C8ADA71".lowercased())
    }
    
    // test vectors generated using keysmith https://github.com/dfinity/keysmith and following procedure
    // 1. generate public key from seed `./keysmith public-key`
    // 2. generate principal `./keysmith principal`
    // 3. a. Remove dashes from principal and make uppercase
    //    b. Base32 decode principal using https://cryptii.com/pipes/hex-to-base32
    //    c. remove first 4 bytes and last byte
    //    d. This is the hash of the serialized public key
    // 4. Serialize publicKey from 1 using ICPCrypto.serialiseDER
    // 5. Compare hash224 of publicKey with the one obtained at 3.d
    func testDerSerialiser() throws {
        XCTAssertEqual(try ICPCryptography.der(uncompressedEcPublicKey: Data.fromHex("046acf4c93dd993cd736420302eb70da254532ec3179250a21eec4ce823ff289aaa382cb19576b2c6447db09cb45926ebd69ce288b1804580fe62c343d3252ec6e")!).hex, "3056301006072a8648ce3d020106052b8104000a034200046acf4c93dd993cd736420302eb70da254532ec3179250a21eec4ce823ff289aaa382cb19576b2c6447db09cb45926ebd69ce288b1804580fe62c343d3252ec6e")
        
        XCTAssertEqual(try ICPCryptography.der(uncompressedEcPublicKey: Data.fromHex("04723cdc9bd653014a501159fb89dcc6e2cf03f242955b987b53dd6193815d8a9d4a4f5b902b2819d270c28f0710ad96fea5b13f5fe30c6e244bf2941ebf4ec36e")!).hex, "3056301006072a8648ce3d020106052b8104000a03420004723cdc9bd653014a501159fb89dcc6e2cf03f242955b987b53dd6193815d8a9d4a4f5b902b2819d270c28f0710ad96fea5b13f5fe30c6e244bf2941ebf4ec36e")
    }
    
    // test vectors from https://internetcomputer.org/docs/current/references/id-encoding-spec#test-vectors
    func testCanonicalText() throws {
        let testVectors: [(String, String)] = [
            ("000102030405060708", "xtqug-aqaae-bagba-faydq-q"),
            ("00","2ibo7-dia"),
            ("","aaaaa-aa"),
            ("0102030405060708091011121314151617181920212223242526272829","iineg-fibai-bqibi-ga4ea-searc-ijrif-iwc4m-bsibb-eirsi-jjge4-ucs"),
        ]
        for (dataHex, canonical) in testVectors {
            let data = Data.fromHex(dataHex)!
            XCTAssertEqual(CanonicalText.encode(data), canonical)
            XCTAssertEqual(try CanonicalText.decode(canonical), data)
        }
    }
    
    func testAccountTextualRepresentation() throws {
        let principal: ICPPrincipal = "k2t6j-2nvnp-4zjm3-25dtz-6xhaa-c7boj-5gayf-oj3xs-i43lp-teztq-6ae"
        let testVectors: [(ICPAccount, String)] = [
            (.mainAccount(of: principal), principal.string),
            (try! ICPAccount(principal: principal, subAccountId: Data([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32])), "k2t6j-2nvnp-4zjm3-25dtz-6xhaa-c7boj-5gayf-oj3xs-i43lp-teztq-6ae-dfxgiyy.102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20")
        ]
        for (account, text) in testVectors {
            let decodedAccount = try ICPAccount(textualRepresentation: text)
            XCTAssertEqual(account.textualRepresentation(), text)
            XCTAssertEqual(decodedAccount.textualRepresentation(), text)
        }
    }
    
    // test vectors generated using keysmith https://github.com/dfinity/keysmith
    // `./keysmith principal`
//    func testPrincipal() throws {
//        let principal1 = try ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet1PublicKey)
//        XCTAssertEqual(principal1.string, "mi5lp-tjcms-b77vo-qbfgp-cjzyc-imkew-uowpv-ca7f4-l5fzx-yy6ba-qqe")
//        let principal2 = try ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet2PublicKey)
//        XCTAssertEqual(principal2.string, "sxmip-mryjb-rjp3v-ol36n-miqtr-ji4i6-5k6h3-fdy2n-gz5lr-c2s6s-sqe")
//    }
//    
//    // test vectors generated using keysmith https://github.com/dfinity/keysmith
//    // `./keysmith account`
//    func testAccount() throws {
//        let principal1 = try ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet1PublicKey)
//        let mainAccount1 = try ICPAccount.mainAccount(of: principal1)
//        XCTAssertEqual(mainAccount1.accountId.hex, "cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c")
//        
//        let principal2 = try ICPCryptography.selfAuthenticatingPrincipal(uncompressedPublicKey: testWallet2PublicKey)
//        let mainAccount2 = try ICPAccount.mainAccount(of: principal2)
//        XCTAssertEqual(mainAccount2.accountId.hex, "6c14be31a1df0f5f061520e5d8e0c08bb3743a671ab4a3bb7b05743a8ca3c1f0")
//    }
    
    func testValidateAccountId() {
        XCTAssertTrue(ICPCryptography.validateAccountId("6c14be31a1df0f5f061520e5d8e0c08bb3743a671ab4a3bb7b05743a8ca3c1f0"))
        XCTAssertTrue(ICPCryptography.validateAccountId("cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a1c"))
        XCTAssertFalse(ICPCryptography.validateAccountId("6c14be31a1df0f5f061520e5d8e0c08bb3743a671ab4a3bb7b05743a8ca3c1f1"))
        XCTAssertFalse(ICPCryptography.validateAccountId("cafd0a2c27f41a851837b00f019b93e741f76e4147fe74435fb7efb836826a10"))
    }
    
    func testOrderIndependentHash() throws {
        let hash = { try OrderIndependentHasher.orderIndependentHash($0) }
        XCTAssertEqual(try hash(0).base64EncodedString(), "bjQLnP+zepicpUTmu3gKLHiQHT+zNzh2hRGjBhevoB0=")
        XCTAssertEqual(try hash(624485).base64EncodedString(), "feIrCG+oMpxyE/8xmkTcLKgeI+6pn1/YvXIiLU/8tsI=")
        XCTAssertEqual(try hash("abcd").base64EncodedString(), "iNQmb9TmM40TuEX88olXnSCciXgjuSF9o+Fhk28DFYk=")
        XCTAssertEqual(try hash(Data([0x47, 0x98, 0xfd])).base64EncodedString(), "6aHlLhIiGuehu602UlJY0yLJa4O2mqHUSz5JCuDg4X0=")
        XCTAssertEqual(try hash([
            Data([0x47, 0x98, 0xfd]),
            Data([0x47, 0x98, 0xfd]),
        ]).base64EncodedString(), "PpjoUxKzZoOgTSezNZvEfnq0yClqvqXdJwcpYBgxLbg=")
        
        XCTAssertThrowsError(try hash(-1))
        
        XCTAssertEqual(try hash([
            "abcd": Data([0x47, 0x98, 0xfd]),
            "fngt": Data([0x47, 0x98, 0xfd]),
        ]).base64EncodedString(), "CxCF+O8wyQLiW2Dy18SkenGre+PaEtsrMptNi1fql/o=")
    }
    
    func testBlsSignatureVerification() throws {
        let publicKey = ICPStateCertificate.icpRootRawPublicKey
        XCTAssertNoThrow(try ICPCryptography.verifyBlsSignature(
            message: Data.fromHex("0d69632d73746174652d726f6f74d37ba673431b273a9db85cc2dcf236496decd32c2ba7d160b19f74c1a3e336a3")!,
            publicKey: publicKey,
            signature: Data.fromHex("b5a4e1b143d6f7c311b1f651f370177a7c5a3c2e7d9d337a28d72815000e34b35ca1dfbe6ca953aa0962116da29a8ee1")!))
        
        XCTAssertNoThrow(try ICPCryptography.verifyBlsSignature(
            message: Data.fromHex("0d69632d73746174652d726f6f7424c20a5ca11f8f672b907cba5d0eb29945307b622da2d21aa01f6d202b8b8de3")!,
            publicKey: publicKey,
            signature: Data.fromHex("83cad0cad53d26b4b8e3445db4a6503f5304215686678c852977e161cbd0ccdc7bdfb207c496d09b01b01f4174a72cdc")!))
        
        XCTAssertNoThrow(try ICPCryptography.verifyBlsSignature(
            message: Data.fromHex("0d69632d73746174652d726f6f7456912744b5e7dd38529eb78faecf748ba0ef4ec3e0af35092f84298e87d6e1c2")!,
            publicKey: publicKey,
            signature: Data.fromHex("b931848dc01a3640f6610e82581b6b200ed00ae31ae3503c8dd363238c010960bc90afb295ff02dd1639aecf1efc8d4e")!))
        
        XCTAssertNoThrow(try ICPCryptography.verifyBlsSignature(
            message: "hello".data,
            publicKey: Data.fromHex("a7623a93cdb56c4d23d99c14216afaab3dfd6d4f9eb3db23d038280b6d5cb2caaee2a19dd92c9df7001dede23bf036bc0f33982dfb41e8fa9b8e96b5dc3e83d55ca4dd146c7eb2e8b6859cb5a5db815db86810b8d12cee1588b5dbf34a4dc9a5")!,
            signature: Data.fromHex("b89e13a212c830586eaa9ad53946cd968718ebecc27eda849d9232673dcd4f440e8b5df39bf14a88048c15e16cbcaabe")!))
        
        XCTAssertThrowsError(try ICPCryptography.verifyBlsSignature(
            message: "hallo".data,
            publicKey: Data.fromHex("a7623a93cdb56c4d23d99c14216afaab3dfd6d4f9eb3db23d038280b6d5cb2caaee2a19dd92c9df7001dede23bf036bc0f33982dfb41e8fa9b8e96b5dc3e83d55ca4dd146c7eb2e8b6859cb5a5db815db86810b8d12cee1588b5dbf34a4dc9a5")!,
            signature: Data.fromHex("b89e13a212c830586eaa9ad53946cd968718ebecc27eda849d9232673dcd4f440e8b5df39bf14a88048c15e16cbcaabe")!))
        
        XCTAssertThrowsError(try ICPCryptography.verifyBlsSignature(
            message: Data.fromHex("0d69632d73746174652d726f6f74d37ba673431b273a9db85cc2dcf236496decd32c2ba7d160b19f74c1a3e336a4")!, // same as first test, changed last byte from 3 to 4
            publicKey: publicKey,
            signature: Data.fromHex("b5a4e1b143d6f7c311b1f651f370177a7c5a3c2e7d9d337a28d72815000e34b35ca1dfbe6ca953aa0962116da29a8ee1")!))
    }
}
