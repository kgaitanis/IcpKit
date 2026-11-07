import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct DIP20TokenActorTests {
    private let fixtures = DABTokenFixtures()
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")

    @Test func dip20ActorIsResolvedFromRegistry() async throws {
        let http = try fixtures.client(tokens: [fixtures.registryToken(standard: "DIP20")])
        let service = DABTokenService(DABMockResponses.requestClient(http))
        let token = try #require(await service.allTokens().first { $0.canister == canister })

        #expect(service.actor(for: .dip20, canister) is DIP20TokenActor)
        #expect(service.actor(for: token) is DIP20TokenActor)
        let actor = try #require(await service.actor(for: canister))
        #expect(actor is DIP20TokenActor)
        #expect(actor.standard == .dip20)
    }

    @Test(arguments: [UInt8(0), 8, .max])
    func dip20MetadataMapsAllFieldsAndFee(decimals: UInt8) async throws {
        let metadata = DIP20.Metadata(fee: 10_000, decimals: decimals, owner: unknown,
            logo: "https://example.com/dip20.png", name: "DIP20 Token",
            totalSupply: BigUInt(1) << 100, symbol: "DIP")
        let http = DABMockResponses.client(queries: [
            "getMetadata": try DABMockResponses.candid(metadata)
        ])
        let actor = DIP20TokenActor(canister, DABMockResponses.requestClient(http))

        let result = try await actor.metaData()
        #expect(result.name == "DIP20 Token")
        #expect(result.symbol == "DIP")
        #expect(result.decimals == Int(decimals))
        #expect(result.totalSupply == BigUInt(1) << 100)
        #expect(result.logo?.absoluteString == "https://example.com/dip20.png")
        #expect(result.fee == 10_000)
        #expect(try await actor.fee() == 10_000)
        #expect(http.requests.count == 2)
        for request in http.requests {
            let content = try DABMockResponses.envelope(request).content
            #expect(content.method_name == "getMetadata")
            #expect(content.request_type == "query")
            #expect(content.canister_id == canister.bytes)
            #expect(try CandidDeserialiser().decode(#require(content.arg)).isEmpty)
        }
    }

    @Test(arguments: [BigUInt(0), BigUInt(1) << 100], [false, true])
    func dip20BalanceUsesPrincipal(amount: BigUInt, customSubaccount: Bool) async throws {
        let account = try ICPAccount(principal: DABTestSigner().principal,
            subAccountId: Data(repeating: customSubaccount ? 7 : 0, count: 32))
        let http = DABMockResponses.client(queries: [
            "balanceOf": try DABMockResponses.candid(amount)
        ])
        let actor = DIP20TokenActor(canister, DABMockResponses.requestClient(http))

        #expect(try await actor.balance(of: account) == amount)
        #expect(http.requests.count == 1)
        let request = try #require(http.lastRequest)
        let content = try DABMockResponses.envelope(request).content
        #expect(content.method_name == "balanceOf")
        #expect(content.request_type == "query")
        #expect(content.canister_id == canister.bytes)
        #expect(try DABMockResponses.arguments(ICPPrincipal.self, from: request) == account.principal)
    }

    @Test(arguments: [BigUInt(0), BigUInt(1) << 100])
    func dip20TransferSignsArgumentsAndReturnsHeight(amount: BigUInt) async throws {
        let height = BigUInt(1) << 80
        let http = DABMockResponses.client(update: try DABMockResponses.candid(DIP20.TxReceipt.Ok(height)))
        let actor = DIP20TokenActor(canister, DABMockResponses.requestClient(http))
        let sender = DABTestSigner()
        let from = ICPAccount.mainAccount(of: sender.principal)
        let to = try ICPAccount(principal: unknown, subAccountId: Data(repeating: 2, count: 32))

        let result = try await actor.transfer(.init(sender: sender, from: from, to: to,
            amount: amount, fee: 10_000, memo: Data([3]), createdAtTime: Date(timeIntervalSince1970: 123)))
        guard case .height(let value) = result else {
            Issue.record("Expected a block height")
            return
        }
        #expect(value == height)
        try assertDIP20Update(http, method: "transfer", recipient: unknown, amount: amount)
    }

    @Test(arguments: [BigUInt(0), BigUInt(1) << 100])
    func dip20ApproveSignsArguments(amount: BigUInt) async throws {
        let http = DABMockResponses.client(update: try DABMockResponses.candid(DIP20.TxReceipt.Ok(42)))
        let actor = DIP20TokenActor(canister, DABMockResponses.requestClient(http))

        try await actor.approve(.init(sender: DABTestSigner(), spender: unknown,
            amount: amount, memo: Data([8, 9])))
        try assertDIP20Update(http, method: "approve", recipient: unknown, amount: amount)
    }

    @Test(arguments: ["transfer", "approve"], [
        DIP20.TxError.InsufficientAllowance, .InsufficientBalance, .ErrorOperationStyle,
        .Unauthorized, .LedgerTrap, .ErrorTo, .Other("Rejected by token"), .BlockUsed, .AmountTooSmall
    ])
    func dip20UpdatesPropagateTokenErrors(method: String, tokenError: DIP20.TxError) async throws {
        let http = DABMockResponses.client(update: try DABMockResponses.candid(DIP20.TxReceipt.Err(tokenError)))
        let actor = DIP20TokenActor(canister, DABMockResponses.requestClient(http))
        let sender = DABTestSigner()
        let account = ICPAccount.mainAccount(of: unknown)

        await #expect {
            if method == "transfer" {
                _ = try await actor.transfer(.init(sender: sender, from: .mainAccount(of: sender.principal),
                    to: account, amount: 100, fee: nil, memo: nil, createdAtTime: nil))
            } else {
                try await actor.approve(.init(sender: sender, spender: unknown, amount: 100, memo: nil))
            }
        } throws: { error in
            guard let actual = error as? DIP20.TxError else { return false }
            // Compare the encoded variants, including the associated text of Other.
            return try CandidEncoder().encode(actual) == CandidEncoder().encode(tokenError)
        }
        try assertDIP20Update(http, method: method, recipient: unknown, amount: 100)
    }

    @Test(arguments: ["metadata", "fee", "balance", "transfer", "approve"])
    func dip20PropagatesHTTPFailure(operation: String) async throws {
        let http = MockHttpClient(response: HttpResponse(data: Data("unavailable".utf8), statusCode: 503))
        let actor = DIP20TokenActor(canister, DABMockResponses.requestClient(http))
        let sender = DABTestSigner()
        let account = ICPAccount.mainAccount(of: unknown)

        await #expect {
            switch operation {
            case "metadata": _ = try await actor.metaData()
            case "fee": _ = try await actor.fee()
            case "balance": _ = try await actor.balance(of: account)
            case "transfer":
                _ = try await actor.transfer(.init(sender: sender, from: .mainAccount(of: sender.principal),
                    to: account, amount: 100, fee: nil, memo: nil, createdAtTime: nil))
            default:
                try await actor.approve(.init(sender: sender, spender: unknown, amount: 100, memo: nil))
            }
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, let message) = error else { return false }
            return code == 503 && message == "unavailable"
        }
        #expect(http.requests.count == 1)
    }

    private func assertDIP20Update(_ http: MockHttpClient, method: String,
                                   recipient: ICPPrincipal, amount: BigUInt,
                                   sourceLocation: SourceLocation = #_sourceLocation) throws {
        #expect(try http.requests.map { try DABMockResponses.envelope($0).content.request_type }
                == ["call", "read_state"], sourceLocation: sourceLocation)
        let request = try #require(http.requests.first, sourceLocation: sourceLocation)
        let envelope = try DABMockResponses.envelope(request)
        #expect(envelope.content.method_name == method, sourceLocation: sourceLocation)
        #expect(envelope.content.canister_id == canister.bytes, sourceLocation: sourceLocation)
        #expect(envelope.content.sender == DABTestSigner().principal.bytes, sourceLocation: sourceLocation)
        #expect(envelope.sender_sig != nil, sourceLocation: sourceLocation)
        let args = try CandidDeserialiser().decode(#require(envelope.content.arg))
        #expect(args == [.principal(recipient.bytes), .natural(amount)], sourceLocation: sourceLocation)
    }

}
