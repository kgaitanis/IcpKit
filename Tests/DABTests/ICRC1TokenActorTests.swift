import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct ICRC1TokenActorTests {
    private let canister = ICPPrincipal("aaaaa-aa")

    @Test(arguments: [false, true])
    func balancePreservesAccountAndLargeAmount(customSubaccount: Bool) async throws {
        let account = try ICPAccount(principal: DABTestSigner().principal,
                                     subAccountId: Data(repeating: customSubaccount ? 7 : 0, count: 32))
        let amount = BigUInt(1) << 100
        let http = DABMockResponses.client(queries: ["icrc1_balance_of": try DABMockResponses.candid(amount)])
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))

        #expect(try await actor.balance(of: account) == amount)
        let request = try #require(http.lastRequest)
        let args = try DABMockResponses.arguments(ICRC1.Account.self, from: request)
        #expect(args.owner == account.principal)
        #expect(args.subaccount == account.subAccountId)
        #expect(try DABMockResponses.envelope(request).content.canister_id == canister.bytes)
        #expect(request.url.path.hasSuffix("/aaaaa-aa/query"))
    }

    @Test func feeReturnsLedgerFee() async throws {
        let http = DABMockResponses.client(queries: ["icrc1_fee": try DABMockResponses.candid(BigUInt(10_000))])
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        #expect(try await actor.fee() == 10_000)
    }

    @Test func metadataWithoutLogo() async throws {
        try await checkMetadata(hasLogo: false)
    }

    @Test func metadataWithLogo() async throws {
        try await checkMetadata(hasLogo: true)
    }

    private func checkMetadata(hasLogo: Bool) async throws {
        var fields = metadataFields()
        if hasLogo { fields.append(.init("icrc1:logo", .Text("https://example.com/token.png"))) }
        let http = try metadataClient(fields)
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        let metadata = try await actor.metaData()

        #expect(metadata.name == "Test Token")
        #expect(metadata.symbol == "TST")
        #expect(metadata.decimals == 8)
        #expect(metadata.fee == 10_000)
        #expect(metadata.totalSupply == BigUInt(1) << 100)
        #expect(metadata.logo?.absoluteString == (hasLogo ? "https://example.com/token.png" : nil))
        #expect(try http.requests.map { try DABMockResponses.envelope($0).content.method_name }
                == ["icrc1_metadata", "icrc1_total_supply"])
    }

    @Test(arguments: ["icrc1:name", "icrc1:symbol", "icrc1:decimals", "icrc1:fee"])
    func metadataRejectsMissingRequiredField(key: String) async throws {
        let http = try metadataClient(metadataFields().filter { $0._0 != key })
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            _ = try await actor.metaData()
        } throws: { error in
            guard case ICRC1TokenError.invalidMetadata = error else { return false }
            return true
        }
    }

    @Test(arguments: ["icrc1:name", "icrc1:symbol", "icrc1:decimals", "icrc1:fee", "icrc1:logo"])
    func metadataRejectsWrongValueType(key: String) async throws {
        var fields = metadataFields().filter { $0._0 != key }
        fields.append(.init(key, .Blob(Data([1]))))
        let http = try metadataClient(fields)
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: (any Error).self) { _ = try await actor.metaData() }
    }

    @Test(arguments: [false, true])
    func transferMapsArgumentsAndReturnsBlockHeight(withOptions: Bool) async throws {
        let height = BigUInt(1) << 80
        let http = DABMockResponses.client(update: try DABMockResponses.candid(ICRC1.TransferResult.Ok(height)))
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        let sender = DABTestSigner()
        let from = try ICPAccount(principal: sender.principal, subAccountId: Data(repeating: 1, count: 32))
        let to = try ICPAccount(principal: canister, subAccountId: Data(repeating: 2, count: 32))
        let response = try await actor.transfer(.init(sender: sender, from: from, to: to, amount: 123_456,
            fee: withOptions ? 10_000 : nil, memo: withOptions ? Data([3, 4]) : nil,
            createdAtTime: withOptions ? Date(timeIntervalSince1970: 123) : nil))

        guard case .height(let value) = response else {
            Issue.record("Expected a block height"); return
        }
        #expect(value == height)
        let request = try #require(http.requests.first)
        let envelope = try DABMockResponses.envelope(request)
        let args = try DABMockResponses.arguments(ICRC1.TransferArgs.self, from: request)
        #expect(envelope.content.method_name == "icrc1_transfer")
        #expect(envelope.content.canister_id == canister.bytes)
        #expect(envelope.content.sender == sender.principal.bytes)
        #expect(envelope.sender_sig != nil)
        #expect(args.to.owner == to.principal)
        #expect(args.to.subaccount == Data(repeating: 2, count: 32))
        #expect(args.from_subaccount == Data(repeating: 1, count: 32))
        #expect(args.amount == 123_456)
        #expect(args.fee == (withOptions ? 10_000 : nil))
        #expect(args.memo == (withOptions ? Data([3, 4]) : nil))
        #expect(args.created_at_time == (withOptions ? 123_000_000_000 : nil))
        #expect(try http.requests.map { try DABMockResponses.envelope($0).content.request_type } == ["call", "read_state"])
    }

    @Test func transferPropagatesLedgerError() async throws {
        let http = DABMockResponses.client(update: try DABMockResponses.candid(
            ICRC1.TransferResult.Err(.InsufficientFunds(balance: 12))))
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        let sender = DABTestSigner()
        let account = ICPAccount.mainAccount(of: sender.principal)
        await #expect {
            _ = try await actor.transfer(.init(sender: sender, from: account, to: account,
                amount: 100, fee: nil, memo: nil, createdAtTime: nil))
        } throws: { error in
            guard case ICRC1.TransferError.InsufficientFunds(let balance) = error else { return false }
            return balance == 12
        }
    }

    @Test func approveRejectsUnsupportedStandardWithoutSubmittingUpdate() async throws {
        let http = DABMockResponses.client(queries: ["icrc1_supported_standards": try DABMockResponses.candid(
            [ICRC1.SupportedStandard(url: "https://example.com", name: "ICRC-1")])])
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            try await actor.approve(approvalArgs())
        } throws: { error in
            guard case ICRC1TokenError.approveNotSupported = error else { return false }
            return true
        }
        #expect(http.requests.count == 1)
    }

    @Test func approveSuccessReturnsNormally() async throws {
        let http = try approvalClient(.Ok(42))
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        try await actor.approve(approvalArgs())
    }

    @Test func approveMapsArgumentsAndPropagatesLedgerError() async throws {
        let http = try approvalClient(.Err(.BadFee(expected_fee: 20_000)))
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        let before = Date().timeIntervalSince1970
        await #expect {
            try await actor.approve(approvalArgs())
        } throws: { error in
            guard case ICRC2.ApproveError.BadFee(let fee) = error else { return false }
            return fee == 20_000
        }
        let after = Date().timeIntervalSince1970
        let request = try #require(http.requests.first { $0.url.lastPathComponent == "call" })
        let args = try DABMockResponses.arguments(ICRC2.ApproveArgs.self, from: request)
        #expect(try DABMockResponses.envelope(request).content.method_name == "icrc2_approve")
        #expect(try DABMockResponses.envelope(request).content.canister_id == canister.bytes)
        #expect(args.spender.owner == canister)
        #expect(args.spender.subaccount == nil)
        #expect(args.amount == 500)
        #expect(args.fee == 10_000)
        #expect(args.memo == Data([8, 9]))
        #expect(args.from_subaccount == nil)
        #expect(args.expected_allowance == nil)
        let created = Double(try #require(args.created_at_time)) / 1_000_000_000
        let expires = Double(try #require(args.expires_at)) / 1_000_000_000
        #expect(created >= before - 0.001 && created <= after + 0.001)
        #expect(expires >= before + 86_400 - 0.001 && expires <= after + 86_400 + 0.001)
    }

    @Test func approveUsesSuppliedSender() async throws {
        let http = try approvalClient(.Err(.BadFee(expected_fee: 20_000)))
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        await #expect(throws: ICRC2.ApproveError.self) { try await actor.approve(approvalArgs()) }
        let request = try #require(http.requests.first { $0.url.lastPathComponent == "call" })
        let envelope = try DABMockResponses.envelope(request)
        #expect(envelope.content.sender == DABTestSigner().principal.bytes)
        #expect(envelope.sender_sig != nil)
    }

    @Test func balancePropagatesHTTPFailure() async throws {
        let http = MockHttpClient(response: HttpResponse(data: Data("unavailable".utf8), statusCode: 503))
        let actor = ICRC1TokenActor(canister, DABMockResponses.requestClient(http))
        await #expect {
            _ = try await actor.balance(of: .mainAccount(of: canister))
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
            return code == 503 && message == "unavailable"
        }
    }

    private func metadataFields() -> [ICRC1.MetadataField] {
        [.init("icrc1:fee", .Nat(10_000)), .init("icrc1:symbol", .Text("TST")),
         .init("unrelated", .Blob(Data([0]))), .init("icrc1:name", .Text("Test Token")),
         .init("icrc1:decimals", .Nat(8))]
    }

    private func metadataClient(_ fields: [ICRC1.MetadataField]) throws -> MockHttpClient {
        // Declare the full wire variant so heterogeneous metadata values share one vector type.
        let types: [(String, CandidType)] = [("Nat", .natural), ("Int", .integer), ("Text", .text), ("Blob", .vector(.natural8))]
        let values = try fields.map { field -> CandidValue in
            let value: (String, CandidValue)
            switch field._1 {
            case .Nat(let number): value = ("Nat", .natural(number))
            case .Int(let number): value = ("Int", .integer(number))
            case .Text(let text): value = ("Text", .text(text))
            case .Blob(let data): value = ("Blob", .blob(data))
            }
            return .record([.text(field._0), .variant(try CandidVariant(candidTypes: types, value: value))])
        }
        return DABMockResponses.client(queries: [
            "icrc1_metadata": try CandidSerialiser().encode([.vector(CandidVector(values))]),
            "icrc1_total_supply": try DABMockResponses.candid(BigUInt(1) << 100)
        ])
    }

    private func approvalArgs() -> ICPTokenApproveArgs {
        .init(sender: DABTestSigner(), spender: canister, amount: 500, memo: Data([8, 9]))
    }

    private func approvalClient(_ result: ICRC2.ApproveResult) throws -> MockHttpClient {
        DABMockResponses.client(queries: [
            "icrc1_supported_standards": try DABMockResponses.candid([
                ICRC1.SupportedStandard(url: "https://example.com", name: "ICRC-1"),
                ICRC1.SupportedStandard(url: "https://example.com", name: "ICRC-2")]),
            "icrc1_fee": try DABMockResponses.candid(BigUInt(10_000))
        ], update: try DABMockResponses.candid(result))
    }
}
