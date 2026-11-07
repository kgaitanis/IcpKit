import Foundation
import BigInt
import Candid
import IcpKit
import Testing
import TestSupport
@testable import DAB

struct DABTokenFixtures {
    private let canister = ICPPrincipal("aaaaa-aa")
    private let unknown = ICPPrincipal("2vxsx-fae")

    func registryToken(canister: ICPPrincipal? = nil, standard: String = "ICRC1",
                               verified: Bool = true, omitting: String? = nil,
                               invalid: String? = nil) throws -> CandidValue {
        // Every detail uses the same wire variant, even when its selected case differs.
        let types: [String: CandidType] = ["Text": .text, "U64": .natural64, "True": .null, "False": .null]
        let fields: [(String, String, CandidValue)] = [
            ("standard", "Text", .text(invalid == "unknownStandard" ? "UNKNOWN" : standard)),
            ("decimals", "U64", .natural64(6)),
            ("symbol", "Text", .text("TST")),
            ("verified", verified ? "True" : "False", .null)
        ]
        let details = try fields.filter { $0.0 != omitting }.map { key, variant, value in
            CandidValue.record([.text(key), try .variant(types,
                invalid == key ? (variant == "Text" ? "U64" : "Text",
                                  variant == "Text" ? .natural64(1) : .text("invalid")) : (variant, value))])
        }
        return .record([
            .init("thumbnail", .text("https://example.com/token.png")),
            .init("submitter", .principal(unknown.bytes)),
            .init("name", .text("Test Token")),
            .init("frontend", .option(.text)),
            .init("description", .text("Fixture")),
            .init("last_updated_at", .natural64(0)),
            .init("last_updated_by", .principal(unknown.bytes)),
            .init("details", try .vector(details)),
            .init("principal_id", .principal((canister ?? self.canister).bytes))
        ])
    }

    func queries(tokens: [CandidValue]) throws -> [String: Data] {
        let types: [String: CandidType] = ["Nat": .natural, "Text": .text]
        let metadata = try [
            ("icrc1:name", "Text", CandidValue.text("Internet Computer")),
            ("icrc1:symbol", "Text", .text("ICP")),
            ("icrc1:decimals", "Nat", .natural(8)),
            ("icrc1:fee", "Nat", .natural(10_000))
        ].map { key, variant, value in
            CandidValue.record([.text(key), try .variant(types, (variant, value))])
        }
        let registry = tokens.isEmpty ? CandidValue.vector(try registryToken().candidType) : try .vector(tokens)
        return [
            "get_all": CandidSerialiser().encode([registry]),
            "icrc1_metadata": try CandidSerialiser().encode([.vector(metadata)]),
            "icrc1_total_supply": try DABMockResponses.candid(BigUInt(1_000_000)),
            "icrc1_balance_of": try DABMockResponses.candid(BigUInt(123))
        ]
    }

    func client(tokens: [CandidValue]) throws -> MockHttpClient {
        DABMockResponses.client(queries: try queries(tokens: tokens))
    }

}

enum ICRC1IndexFixtures {
    static func historyReply(_ transactions: [Index.TransactionWithId]) throws -> Data {
        // Supply complete optional types, including absent operations, as the canister does.
        // Swift's encoder cannot infer record types from nil optional values in a mixed vector.
        let accountType = try CandidParser().parseSingleType("record { owner : principal; subaccount : opt blob }")
        let sampleAccount = Index.Account(owner: ICPPrincipal("2vxsx-fae"), subaccount: nil)
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
        let itemType = wireTransaction(.init(id: 0, transaction: .init(burn: nil, kind: "unknown", mint: nil,
            approve: nil, timestamp: 0, transfer: nil))).candidType
        let history: CandidValue = .record([
            "balance": .natural(1000), "oldest_tx_id": .option(.natural),
            "transactions": .vector(try CandidVector(itemType, transactions.map(wireTransaction)))
        ])
        let result = CandidValue.variant(.init("Ok", history))
        return CandidSerialiser().encode([result])
    }

}

struct OracleTokenFixtures {
    func token(ledger: String = "aaaaa-aa", category: String = "Known", name: String = "Test Token",
                       logo: String? = "https://example.com/token.png", index: String? = nil) throws -> CandidValue {
        // Declare every category and optional's wire type so mixed records share one vector type.
        let categories = ["Sns", "Known", "Spam", "ChainFusionTestnet", "ChainFusion", "Community", "Native"]
        return .record([
            "fee": .natural(10_000), "decimals": .natural8(6), "logo": CandidValue(logo),
            "name": .text(name), "ledger": .text(ledger), "index": CandidValue(index), "symbol": .text("TST"),
            "category": try .variant(Dictionary(uniqueKeysWithValues: categories.map { ($0, CandidType.null) }),
                                     (category, .null))
        ])
    }

    func client(count: UInt64, pages: [UInt64: [CandidValue]], queries: [String: Data] = [:],
                        failedPage: UInt64? = nil, malformedPage: Bool = false,
                        balances: [String: BigUInt] = [:], failedBalance: ICPPrincipal? = nil) throws -> MockHttpClient {
        let countReply = try DABMockResponses.candid(count)
        let type = try token().candidType
        let pageReplies = try pages.mapValues { CandidSerialiser().encode([.vector(try CandidVector(type, $0))]) }
        return MockHttpClient { request in
            let content = try DABMockResponses.envelope(request).content
            let method = try #require(content.method_name)
            switch method {
            case "count_icrc1_canisters": return try TokenServiceTestResponses.reply(countReply)
            case "get_icrc1_paginated":
                let args = try CandidDeserialiser().decode(#require(content.arg))
                let start = try CandidDecoder().decode(UInt64.self, from: #require(args.first))
                if start == failedPage {
                    return malformedPage ? try TokenServiceTestResponses.reply(Data([0])) : HttpResponse(statusCode: 503)
                }
                return try TokenServiceTestResponses.reply(#require(pageReplies[start], "Unexpected page: \(start)"))
            case "icrc1_balance_of" where !balances.isEmpty:
                if content.canister_id == failedBalance?.bytes { return HttpResponse(statusCode: 503) }
                let principal = ICPPrincipal(try #require(content.canister_id))
                return try TokenServiceTestResponses.reply(DABMockResponses.candid(#require(balances[principal.string])))
            default: return try TokenServiceTestResponses.reply(#require(queries[method], "Unexpected query: \(method)"))
            }
        }
    }

}

enum TokenServiceTestResponses {
    static func reply(_ data: Data) throws -> HttpResponse {
        HttpResponse(data: try ICPCryptography.CBOR.serialise(QueryReply(reply: .init(arg: data))), statusCode: 200)
    }

    static func reply(for request: HttpRequest, queries: [String: Data]) throws -> HttpResponse {
        let method = try #require(DABMockResponses.envelope(request).content.method_name)
        return try reply(#require(queries[method], "Unexpected query: \(method)"))
    }

    private struct QueryReply: Encodable {
        let status = "replied"
        let reply: Reply
        struct Reply: Encodable { let arg: Data }
    }
}

final class TokenServiceAttemptCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    var count: Int { lock.withLock { value } }
    func next() -> Int { lock.withLock { value += 1; return value } }
}

enum TokenServiceBackend: CaseIterable, Sendable {
    case dab, oracle

    var registryRequestCount: Int { self == .dab ? 3 : 2 }
    var noIndexRequestCount: Int { registryRequestCount + (self == .dab ? 1 : 0) }

    func service(_ http: MockHttpClient) -> any TokenService {
        let client = DABMockResponses.requestClient(http)
        switch self {
        case .dab: return DABTokenService(client)
        case .oracle: return TokenOracle(client)
        }
    }

    func client() throws -> MockHttpClient {
        switch self {
        case .dab:
            let fixtures = DABTokenFixtures()
            var queries = try fixtures.queries(tokens: [fixtures.registryToken()])
            queries["list_deployed_snses"] = try DABMockResponses.candid(
                NNS_SNS_W.ListDeployedSnsesResponse(instances: []))
            return DABMockResponses.client(queries: queries)
        case .oracle:
            let fixtures = OracleTokenFixtures()
            return try fixtures.client(count: 1, pages: [0: [fixtures.token()]],
                queries: ["icrc1_balance_of": DABMockResponses.candid(BigUInt(123))])
        }
    }

    func balanceClient(positive: ICPPrincipal, zero: ICPPrincipal, failed: ICPPrincipal,
                       unsupported: ICPPrincipal, amount: BigUInt) throws -> MockHttpClient {
        switch self {
        case .dab:
            let fixtures = DABTokenFixtures()
            let queries = try fixtures.queries(tokens: [
                fixtures.registryToken(canister: positive), fixtures.registryToken(canister: zero),
                fixtures.registryToken(canister: unsupported, standard: "EXT")
            ])
            return MockHttpClient { request in
                let content = try DABMockResponses.envelope(request).content
                if content.method_name == "icrc1_balance_of" {
                    if content.canister_id == failed.bytes { return HttpResponse(statusCode: 503) }
                    let balance = content.canister_id == positive.bytes ? amount : .zero
                    return try TokenServiceTestResponses.reply(DABMockResponses.candid(balance))
                }
                return try TokenServiceTestResponses.reply(for: request, queries: queries)
            }
        case .oracle:
            let fixtures = OracleTokenFixtures()
            return try fixtures.client(count: 3, pages: [0: [
                fixtures.token(ledger: positive.string), fixtures.token(ledger: zero.string),
                fixtures.token(ledger: failed.string)
            ]], balances: [positive.string: amount, zero.string: .zero], failedBalance: failed)
        }
    }
}
