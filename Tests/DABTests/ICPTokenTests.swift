import Foundation
import BigInt
import IcpKit
import Testing
@testable import DAB

struct ICPTokenTests {
    private let canister = ICPPrincipal("aaaaa-aa")

    private var sampleToken: ICPToken {
        ICPToken(standard: .icrc1, canister: canister, name: "Test Token",
                 decimals: 8, symbol: "TST", verified: true, logo: nil)
    }

    @Test(arguments: ICPTokenStandard.allCases)
    func factorySelectsActorType(standard: ICPTokenStandard) {
        let actorType = ICPTokenActorFactory.actorType(for: standard)
        switch standard {
        case .dip20:
            #expect(actorType == DIP20TokenActor.self)
        case .icp, .icrc1, .icrc2:
            #expect(actorType == ICRC1TokenActor.self)
        case .xtc, .wIcp, .ext, .rosetta, .drc20:
            #expect(actorType == nil)
        }
    }

    @Test(arguments: ICPTokenStandard.allCases, [false, true])
    func factoryCreatesActorsWithSuppliedCanisterAndClient(standard: ICPTokenStandard, useToken: Bool) async throws {
        let method = standard == .dip20 ? "balanceOf" : "icrc1_balance_of"
        let amount = BigUInt(1) << 100
        let http = DABMockResponses.client(queries: [method: try DABMockResponses.candid(amount)])
        let client = DABMockResponses.requestClient(http)
        let token = ICPToken(standard: standard, canister: canister, name: "Factory Token",
                             decimals: 8, symbol: "FACT", verified: true, logo: nil)
        let actor = useToken
            ? ICPTokenActorFactory.actor(for: token, client)
            : ICPTokenActorFactory.actor(for: standard, canister, client)

        switch standard {
        case .dip20, .icp, .icrc1, .icrc2:
            let actor = try #require(actor)
            #expect(actor.standard == (standard == .dip20 ? .dip20 : .icrc1))
            #expect(try await actor.balance(of: .mainAccount(of: canister)) == amount)
            #expect(http.requests.count == 1)
            let request = try #require(http.lastRequest)
            let content = try DABMockResponses.envelope(request).content
            #expect(content.canister_id == canister.bytes)
            #expect(content.method_name == method)
            #expect(content.request_type == "query")
        case .xtc, .wIcp, .ext, .rosetta, .drc20:
            #expect(actor == nil)
            #expect(http.requests.isEmpty)
        }
    }

    @Test(arguments: [
        (UInt64(0), "0", "Test Token: 0"),
        (UInt64(1), "0.00000001", "Test Token: 0.00000001"),
        (UInt64(123456789), "1.23456789", "Test Token: 1.23456789")
    ])
    func tokenBalancePreservesAndFormatsAmount(rawAmount: UInt64, decimal: String, description: String) throws {
        let balance = ICPTokenBalance(token: sampleToken, balance: BigUInt(rawAmount))
        let expected = try #require(Decimal(string: decimal, locale: Locale(identifier: "en_US_POSIX")))

        #expect(balance.token == sampleToken)
        #expect(balance.balance == BigUInt(rawAmount))
        #expect(balance.decimalBalance == expected)
        #expect(balance.description == description)
    }

    @Test func transactionDestinationPreservesAccountId() {
        let address = "0123456789abcdef"
        #expect(ICPTokenTransaction.Destination.accountId(address).address == address)
    }

    @Test(arguments: [false, true])
    func transactionDestinationFormatsAccount(customSubaccount: Bool) throws {
        let account = try ICPAccount(principal: DABTestSigner().principal,
                                     subAccountId: Data(repeating: customSubaccount ? 7 : 0, count: 32))

        #expect(ICPTokenTransaction.Destination.account(account).address == account.textualRepresentation())
    }

    @Test(arguments: ["mint", "burn", "approve", "transfer"])
    func transactionDerivesEndpointsFromOperation(kind: String) throws {
        let from = ICPTokenTransaction.Destination.accountId("source")
        let to = ICPTokenTransaction.Destination.accountId("destination")
        let operation: ICPTokenTransaction.Operation
        switch kind {
        case "mint": operation = .mint(to: to)
        case "burn": operation = .burn(from: from)
        case "approve": operation = .approve(from: from, expectedAllowance: nil, expires: nil)
        default: operation = .transfer(from: from, to: to)
        }
        let transaction = ICPTokenTransaction(index: 1, operation: operation, memo: nil,
                                              icrc1Memo: nil, amount: 100, fee: 10, created: nil,
                                              timeStamp: nil, spender: nil, token: sampleToken)

        #expect(transaction.from?.address == (kind == "mint" ? nil : "source"))
        #expect(transaction.to?.address == (kind == "mint" || kind == "transfer" ? "destination" : nil))
        #expect(transaction.memo == nil)
        #expect(transaction.icrc1Memo == nil)
        #expect(transaction.created == nil)
        #expect(transaction.timeStamp == nil)
        #expect(transaction.spender == nil)
    }

    @Test func transactionInitializerPreservesFields() throws {
        let amount = BigUInt(1) << 100
        let index = BigUInt(1) << 80
        let created = Date(timeIntervalSince1970: 123)
        let timestamp = Date(timeIntervalSince1970: 456)
        let expires = Date(timeIntervalSince1970: 789)
        let transaction = ICPTokenTransaction(
            index: index, operation: .approve(from: .accountId("owner"), expectedAllowance: amount, expires: expires),
            memo: UInt64.max, icrc1Memo: Data([0, 1, 255]), amount: amount, fee: 10_000,
            created: created, timeStamp: timestamp, spender: .accountId("spender"), token: sampleToken)

        #expect(transaction.index == index)
        #expect(transaction.amount == amount)
        #expect(transaction.fee == 10_000)
        #expect(transaction.memo == UInt64.max)
        #expect(transaction.icrc1Memo == Data([0, 1, 255]))
        #expect(transaction.created == created)
        #expect(transaction.timeStamp == timestamp)
        #expect(transaction.spender?.address == "spender")
        #expect(transaction.token == sampleToken)
        guard case .approve(let from, let allowance, let expiry) = transaction.operation else {
            Issue.record("Expected approval operation")
            return
        }
        #expect(from.address == "owner")
        #expect(allowance == amount)
        #expect(expiry == expires)
    }

    @Test(arguments: [false, true])
    func initializerPreservesFields(withLogo: Bool) throws {
        let logo = withLogo ? try #require(URL(string: "https://example.com/token.png")) : nil
        let token = ICPToken(standard: .icrc1, canister: canister, name: "Test Token",
                             decimals: 8, symbol: "TST", verified: false, logo: logo)

        #expect(token.standard == .icrc1)
        #expect(token.canister == canister)
        #expect(token.name == "Test Token")
        #expect(token.decimals == 8)
        #expect(token.symbol == "TST")
        #expect(!token.verified)
        #expect(token.logo == logo)
    }

    @Test(arguments: [false, true])
    func metadataInitializerMapsFieldsAndDefaultsToVerified(withLogo: Bool) throws {
        let logo = withLogo ? try #require(URL(string: "https://example.com/metadata.png")) : nil
        let metadata = ICPTokenMetadata(name: "Metadata Token", symbol: "META", decimals: 6,
                                        totalSupply: 1_000_000, logo: logo, fee: 10)
        let token = ICPToken(standard: .dip20, canister: canister, metadata: metadata)
        let expected = ICPToken(standard: .dip20, canister: canister, name: "Metadata Token",
                                decimals: 6, symbol: "META", verified: true, logo: logo)

        #expect(token == expected)
        #expect(!ICPToken(standard: .dip20, canister: canister,
                         metadata: metadata, verified: false).verified)
    }

    @Test(arguments: [
        (UInt(0), "0", "0"),
        (UInt(0), "123", "123"),
        (UInt(8), "0", "0"),
        (UInt(8), "1", "0.00000001"),
        (UInt(8), "100000000", "1"),
        (UInt(8), "123456789", "1.23456789"),
        (UInt(18), "123456789012345678901234567890", "123456789012.345678901234567890")
    ])
    func decimalScalesBaseUnits(decimals: UInt, rawAmount: String, expected: String) throws {
        let token = ICPToken(standard: .icrc1, canister: canister, name: "Test",
                             decimals: decimals, symbol: "TST", verified: true, logo: nil)
        let amount = try #require(BigUInt(rawAmount))
        let expectedAmount = try #require(Decimal(string: expected, locale: Locale(identifier: "en_US_POSIX")))

        #expect(token.decimal(amount) == expectedAmount)
    }

    @Test func equalTokensHaveEqualHashesAndDeduplicateInSets() {
        let first = ICPToken(standard: .icrc1, canister: canister, name: "Test",
                             decimals: 8, symbol: "TST", verified: true, logo: nil)
        let second = ICPToken(standard: .icrc1, canister: canister, name: "Test",
                              decimals: 8, symbol: "TST", verified: true, logo: nil)

        #expect(first == second)
        #expect(first.hashValue == second.hashValue)
        #expect(Set([first, second]).count == 1)
    }

    @Test func equalityIncludesAllStoredFields() throws {
        let original = ICPToken(standard: .icrc1, canister: canister, name: "Test",
                                decimals: 8, symbol: "TST", verified: true, logo: nil)
        let logo = try #require(URL(string: "https://example.com/token.png"))
        let variants = [
            ICPToken(standard: .dip20, canister: canister, name: "Test",
                     decimals: 8, symbol: "TST", verified: true, logo: nil),
            ICPToken(standard: .icrc1, canister: ICPSystemCanisters.ledger, name: "Test",
                     decimals: 8, symbol: "TST", verified: true, logo: nil),
            ICPToken(standard: .icrc1, canister: canister, name: "Renamed",
                     decimals: 8, symbol: "TST", verified: true, logo: nil),
            ICPToken(standard: .icrc1, canister: canister, name: "Test",
                     decimals: 6, symbol: "TST", verified: true, logo: nil),
            ICPToken(standard: .icrc1, canister: canister, name: "Test",
                     decimals: 8, symbol: "NEW", verified: true, logo: nil),
            ICPToken(standard: .icrc1, canister: canister, name: "Test",
                     decimals: 8, symbol: "TST", verified: false, logo: nil),
            ICPToken(standard: .icrc1, canister: canister, name: "Test",
                     decimals: 8, symbol: "TST", verified: true, logo: logo)
        ]

        for variant in variants {
            #expect(original != variant)
        }
        // Tokens sharing a canister hash must still coexist when their metadata differs.
        #expect(Set([original] + variants).count == 8)
    }
}
