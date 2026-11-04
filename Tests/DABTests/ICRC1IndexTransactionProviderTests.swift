import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct ICRC1IndexTransactionProviderTests {
    private let indexCanister = ICPPrincipal("aaaaa-aa")
    private let owner = DABTestSigner().principal
    private var token: ICPToken {
        ICPToken(standard: .icrc1, canister: ICPSystemCanisters.ledger, name: "Test Token",
                 decimals: 8, symbol: "TST", verified: true, logo: nil)
    }

    @Test func emptyHistoryPreservesRequestAccount() async throws {
        let http = try historyClient([])
        let user = try ICPAccount(principal: owner, subAccountId: Data(repeating: 3, count: 32))
        #expect(try await provider(http).transactions(of: user).isEmpty)

        let request = try #require(http.lastRequest)
        let envelope = try DABMockResponses.envelope(request)
        let args = try DABMockResponses.arguments(Index.GetAccountTransactionsArgs.self, from: request)
        #expect(envelope.content.method_name == "get_account_transactions")
        #expect(envelope.content.canister_id == indexCanister.bytes)
        #expect(request.url.path.hasSuffix("/aaaaa-aa/query"))
        #expect(args.account.owner == owner)
        #expect(args.account.subaccount == Data(repeating: 3, count: 32))
        #expect(args.start == nil)
        #expect(args.max_results == 1000)
    }

    @Test func mapsOperationsWithoutOptionalFields() async throws {
        try await checkOperations(withOptions: false)
    }

    @Test func mapsOperationsWithOptionalFields() async throws {
        try await checkOperations(withOptions: true)
    }

    private func checkOperations(withOptions: Bool) async throws {
        let from = Index.Account(owner: owner, subaccount: nil)
        let to = Index.Account(owner: indexCanister, subaccount: Data(repeating: 2, count: 32))
        let spender = Index.Account(owner: owner, subaccount: Data(repeating: 3, count: 32))
        let memo: Data? = withOptions ? Data([4, 5]) : nil
        let created: UInt64? = withOptions ? 123_000_000_000 : nil
        let largeAmount = BigUInt(1) << 100
        let transactions: [Index.TransactionWithId] = [
            transaction(10, burn: .init(from: from, memo: memo, created_at_time: created,
                                      amount: largeAmount, spender: withOptions ? spender : nil)),
            transaction(11, approve: .init(fee: withOptions ? 8 : nil, from: from, memo: memo,
                created_at_time: created, amount: 200, expected_allowance: withOptions ? 150 : nil,
                expires_at: withOptions ? 456_000_000_000 : nil, spender: spender)),
            transaction(12, transfer: .init(to: to, fee: withOptions ? 9 : nil, from: from,
                memo: memo, created_at_time: created, amount: 300, spender: withOptions ? spender : nil)),
            transaction(13, mint: .init(to: to, memo: memo, created_at_time: created, amount: 400))
        ]
        let http = try historyClient(transactions)
        let results = try await provider(http).transactions(of: .mainAccount(of: owner))
        #expect(results.map(\.index) == [10, 11, 12, 13])
        #expect(results.map(\.amount) == [largeAmount, 200, 300, 400])
        #expect(results.map(\.fee) == (withOptions ? [0, 8, 9, 0] : [0, 0, 0, 0]))
        try #require(results.count == 4)
        for result in results {
            #expect(result.token == token)
            #expect(result.memo == nil)
            #expect(result.icrc1Memo == memo)
            #expect(result.timeStamp == Date(timeIntervalSince1970: 789))
            #expect(result.created == (withOptions ? Date(timeIntervalSince1970: 123) : nil))
        }

        guard case .burn(let burnFrom) = results[0].operation,
              case .approve(let approveFrom, let allowance, let expires) = results[1].operation,
              case .transfer(let transferFrom, let transferTo) = results[2].operation,
              case .mint(let mintTo) = results[3].operation else {
            Issue.record("Transaction operation was mapped incorrectly"); return
        }
        for destination in [burnFrom, approveFrom, transferFrom] {
            assertAccount(destination, principal: owner, subaccount: Data(repeating: 0, count: 32))
        }
        for destination in [transferTo, mintTo] {
            assertAccount(destination, principal: indexCanister, subaccount: Data(repeating: 2, count: 32))
        }
        #expect(allowance == (withOptions ? 150 : nil))
        #expect(expires == (withOptions ? Date(timeIntervalSince1970: 456) : nil))
        assertAccount(try #require(results[1].spender), principal: owner, subaccount: Data(repeating: 3, count: 32))
        for result in [results[0], results[2]] {
            if withOptions {
                assertAccount(try #require(result.spender), principal: owner, subaccount: Data(repeating: 3, count: 32))
            } else {
                #expect(result.spender == nil)
            }
        }
        #expect(results[3].spender == nil)
    }

    @Test func skipsUnknownAndMalformedTransactionsWithoutDroppingValidOnes() async throws {
        let valid = Index.Account(owner: owner, subaccount: nil)
        let invalid = Index.Account(owner: owner, subaccount: Data([1]))
        let http = try historyClient([
            transaction(1, mint: .init(to: valid, memo: nil, created_at_time: nil, amount: 10)),
            transaction(2),
            transaction(3, burn: .init(from: invalid, memo: nil, created_at_time: nil, amount: 20, spender: nil)),
            transaction(4, transfer: .init(to: valid, fee: nil, from: valid, memo: nil,
                created_at_time: nil, amount: 30, spender: invalid)),
            transaction(5, mint: .init(to: valid, memo: nil, created_at_time: nil, amount: 40))
        ])
        let results = try await provider(http).transactions(of: .mainAccount(of: owner))
        #expect(results.map(\.index) == [1, 5])
        #expect(results.map(\.amount) == [10, 40])
    }

    @Test func propagatesIndexError() async throws {
        let http = DABMockResponses.client(queries: ["get_account_transactions": try DABMockResponses.candid(
            Index.GetTransactionsResult.Err(.init(message: "Index is syncing")))])
        await #expect {
            _ = try await provider(http).transactions(of: .mainAccount(of: owner))
        } throws: { error in
            (error as? Index.GetTransactionsErr)?.message == "Index is syncing"
        }
    }

    @Test func propagatesHTTPFailure() async throws {
        let http = MockHttpClient(response: HttpResponse(statusCode: 503))
        await #expect {
            _ = try await provider(http).transactions(of: .mainAccount(of: owner))
        } throws: { error in
            guard case ICPRemoteClientError.failed(let code, _) = error else { return false }
            return code == 503
        }
    }

    private func provider(_ http: MockHttpClient) -> ICPICRC1IndexTransactionProvider {
        ICPICRC1IndexTransactionProvider(client: DABMockResponses.requestClient(http),
                                        token: token, indexCanister: indexCanister)
    }

    private func historyClient(_ transactions: [Index.TransactionWithId]) throws -> MockHttpClient {
        // Supply complete optional types, including absent operations, as the canister does.
        // Swift's encoder cannot infer record types from nil optional values in a mixed vector.
        let accountType = try CandidParser().parseSingleType("record { owner : principal; subaccount : opt blob }")
        let sampleAccount = Index.Account(owner: owner, subaccount: nil)
        func account(_ value: Index.Account) -> CandidValue {
            .record(["owner": .principal(value.owner.bytes), "subaccount": CandidValue(value.subaccount)])
        }
        func optionalAccount(_ value: Index.Account?) -> CandidValue {
            .option(accountType, value.map(account))
        }
        func burn(_ value: Index.Burn) -> CandidValue {
            .record(["from": account(value.from), "memo": CandidValue(value.memo),
                     "created_at_time": CandidValue(value.created_at_time), "amount": .natural(value.amount),
                     "spender": optionalAccount(value.spender)])
        }
        func mint(_ value: Index.Mint) -> CandidValue {
            .record(["to": account(value.to), "memo": CandidValue(value.memo),
                     "created_at_time": CandidValue(value.created_at_time), "amount": .natural(value.amount)])
        }
        func approve(_ value: Index.Approve) -> CandidValue {
            .record(["fee": CandidValue(value.fee), "from": account(value.from), "memo": CandidValue(value.memo),
                     "created_at_time": CandidValue(value.created_at_time), "amount": .natural(value.amount),
                     "expected_allowance": CandidValue(value.expected_allowance),
                     "expires_at": CandidValue(value.expires_at), "spender": account(value.spender)])
        }
        func transfer(_ value: Index.Transfer) -> CandidValue {
            .record(["to": account(value.to), "fee": CandidValue(value.fee), "from": account(value.from),
                     "memo": CandidValue(value.memo), "created_at_time": CandidValue(value.created_at_time),
                     "amount": .natural(value.amount), "spender": optionalAccount(value.spender)])
        }
        let burnType = burn(.init(from: sampleAccount, memo: nil, created_at_time: nil, amount: 0, spender: nil)).candidType
        let mintType = mint(.init(to: sampleAccount, memo: nil, created_at_time: nil, amount: 0)).candidType
        let approveType = approve(.init(fee: nil, from: sampleAccount, memo: nil, created_at_time: nil,
            amount: 0, expected_allowance: nil, expires_at: nil, spender: sampleAccount)).candidType
        let transferType = transfer(.init(to: sampleAccount, fee: nil, from: sampleAccount, memo: nil,
            created_at_time: nil, amount: 0, spender: nil)).candidType
        func wireTransaction(_ item: Index.TransactionWithId) -> CandidValue {
            let value = item.transaction
            return .record(["id": .natural(item.id), "transaction": .record([
                "kind": .text(value.kind), "timestamp": .natural64(value.timestamp),
                "burn": .option(burnType, value.burn.map(burn)),
                "mint": .option(mintType, value.mint.map(mint)),
                "approve": .option(approveType, value.approve.map(approve)),
                "transfer": .option(transferType, value.transfer.map(transfer))
            ])])
        }
        let itemType = wireTransaction(transaction(0)).candidType
        let history: CandidValue = .record([
            "balance": .natural(1000), "oldest_tx_id": .option(.natural),
            "transactions": .vector(try CandidVector(itemType, transactions.map(wireTransaction)))
        ])
        let result = CandidValue.variant(.init("Ok", history))
        return DABMockResponses.client(queries: ["get_account_transactions": try CandidSerialiser().encode([result])])
    }

    private func transaction(_ id: BigUInt, burn: Index.Burn? = nil, approve: Index.Approve? = nil,
                             transfer: Index.Transfer? = nil, mint: Index.Mint? = nil) -> Index.TransactionWithId {
        let kind = burn != nil ? "burn" : approve != nil ? "approve" : transfer != nil ? "transfer" : mint != nil ? "mint" : "unknown"
        return .init(id: id, transaction: .init(burn: burn, kind: kind, mint: mint,
            approve: approve, timestamp: 789_000_000_000, transfer: transfer))
    }

    private func assertAccount(_ destination: ICPTokenTransaction.Destination, principal: ICPPrincipal,
                               subaccount: Data, sourceLocation: SourceLocation = #_sourceLocation) {
        guard case .account(let account) = destination else {
            Issue.record("Expected an ICRC account", sourceLocation: sourceLocation); return
        }
        #expect(account.principal == principal, sourceLocation: sourceLocation)
        #expect(account.subAccountId == subaccount, sourceLocation: sourceLocation)
    }
}
