//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum LedgerCanister {
	/// // Account identifier  is a 32-byte array.
	/// // The first 4 bytes is big-endian encoding of a CRC32 checksum of the last 28 bytes
	/// type AccountIdentifier = blob;
	typealias AccountIdentifier = Data
	
	/// type BlockIndex = nat64;
	typealias BlockIndex = UInt64
	
	/// type Hash = blob;
	typealias Hash = Data
	
	/// // The ledger is a list of blocks
	/// type Ledger = vec Block;
	typealias Ledger = [Block]
	
	/// type Memo = nat64;
	typealias Memo = UInt64
	
	/// // A function that is used for fetching archived ledger blocks.
	/// type QueryArchiveFn = func (GetBlocksArgs) -> (QueryArchiveResult) query;
	typealias QueryArchiveFn = ICPQuery<GetBlocksArgs, QueryArchiveResult>
	
	/// type SubAccount = blob;
	typealias SubAccount = Data
	
	
	/// type AccountBalanceArgs = record {
	///     account: AccountIdentifier;
	/// };
	struct AccountBalanceArgs: Codable {
		let account: AccountIdentifier
	}
	
	/// type Archive = record {
	///     canister_id: principal;
	/// };
	struct Archive: Codable {
		let canister_id: ICPPrincipal
	}
	
	/// type Archives = record {
	///     archives: vec Archive;
	/// };
	struct Archives: Codable {
		let archives: [Archive]
	}
	
	/// type Block = record {
	///     parent_hash: opt Hash;
	///     transaction: Transaction;
	///     timestamp: TimeStamp;
	/// };
	struct Block: Codable {
		let transaction: Transaction
		let timestamp: TimeStamp
		let parent_hash: Hash?
	}
	
	/// // A prefix of the block range specified in the [GetBlocksArgs] request.
	/// type BlockRange = record {
	///     // A prefix of the requested block range.
	///     // The index of the first block is equal to [GetBlocksArgs.from].
	///     //
	///     // Note that the number of blocks might be less than the requested
	///     // [GetBlocksArgs.len] for various reasons, for example:
	///     //
	///     // 1. The query might have hit the replica with an outdated state
	///     //    that doesn't have the full block range yet.
	///     // 2. The requested range is too large to fit into a single reply.
	///     //
	///     // NOTE: the list of blocks can be empty if:
	///     // 1. [GetBlocksArgs.len] was zero.
	///     // 2. [GetBlocksArgs.from] was larger than the last block known to the canister.
	///     blocks : vec Block;
	/// };
	struct BlockRange: Codable {
		let blocks: [Block]
	}
	
	/// type GetBlocksArgs = record {
	///     // The index of the first block to fetch.
	///     start : BlockIndex;
	///     // Max number of blocks to fetch.
	///     length : nat64;
	/// };
	struct GetBlocksArgs: Codable {
		let start: BlockIndex
		let length: UInt64
	}
	
	/// //There are three types of operations: minting tokens, burning tokens & transferring tokens
	/// type Operation = variant {
	///     Mint: record {
	///         to: AccountIdentifier;
	///         amount: Tokens;
	///     };
	///     Burn: record {
	///          from: AccountIdentifier;
	///          amount: Tokens;
	///    };
	///     Transfer: record {
	///         from: AccountIdentifier;
	///         to: AccountIdentifier;
	///         amount: Tokens;
	///         fee: Tokens;
	///     };
	/// };
	enum Operation: Codable {
		case Burn(from: AccountIdentifier, amount: Tokens)
		case Mint(to: AccountIdentifier, amount: Tokens)
		case Transfer(to: AccountIdentifier, fee: Tokens, from: AccountIdentifier, amount: Tokens)
	
		enum CodingKeys: String, CandidCodingKey {
			case Burn
			case Mint
			case Transfer
		}
		enum BurnCodingKeys: String, CandidCodingKey {
			case from
			case amount
		}
		enum MintCodingKeys: String, CandidCodingKey {
			case to
			case amount
		}
		enum TransferCodingKeys: String, CandidCodingKey {
			case to
			case fee
			case from
			case amount
		}
	}
	
	/// type QueryArchiveResult = variant {
	///     Ok : BlockRange;
	///     Err : null;      // we don't know the values here...
	/// };
	enum QueryArchiveResult: Codable {
		case Ok(BlockRange)
		case Err
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// // The result of a "query_blocks" call.
	/// //
	/// // The structure of the result is somewhat complicated because the main ledger canister might
	/// // not have all the blocks that the caller requested: One or more "archive" canisters might
	/// // store some of the requested blocks.
	/// //
	/// // Note: as of Q4 2021 when this interface is authored, ICP doesn't support making nested
	/// // query calls within a query call.
	/// type QueryBlocksResponse = record {
	///     // The total number of blocks in the chain.
	///     // If the chain length is positive, the index of the last block is `chain_len - 1`.
	///     chain_length : nat64;
	///     // System certificate for the hash of the latest block in the chain.
	///     // Only present if `query_blocks` is called in a non-replicated query context.
	///     certificate : opt blob;
	///     // List of blocks that were available in the ledger when it processed the call.
	///     //
	///     // The blocks form a contiguous range, with the first block having index
	///     // [first_block_index] (see below), and the last block having index
	///     // [first_block_index] + len(blocks) - 1.
	///     //
	///     // The block range can be an arbitrary sub-range of the originally requested range.
	///     blocks : vec Block;
	///     // The index of the first block in "blocks".
	///     // If the blocks vector is empty, the exact value of this field is not specified.
	///     first_block_index : BlockIndex;
	///     // Encoding of instructions for fetching archived blocks whose indices fall into the
	///     // requested range.
	///     //
	///     // For each entry `e` in [archived_blocks], `[e.from, e.from + len)` is a sub-range
	///     // of the originally requested block range.
	///     archived_blocks : vec record {
	///         // The index of the first archived block that can be fetched using the callback.
	///         start : BlockIndex;
	///         // The number of blocks that can be fetched using the callback.
	///         length : nat64;
	///         // The function that should be called to fetch the archived blocks.
	///         // The range of the blocks accessible using this function is given by [from]
	///         // and [len] fields above.
	///         callback : QueryArchiveFn;
	///     };
	/// };
	struct QueryBlocksResponse: Codable {
		let certificate: Data?
		let blocks: [Block]
		let chain_length: UInt64
		let first_block_index: BlockIndex
		let archived_blocks: [UnnamedType0]
	}
	
	/// // Timestamps are represented as nanoseconds from the UNIX epoch in UTC timezone
	/// type TimeStamp = record {
	///     timestamp_nanos: nat64;
	/// };
	struct TimeStamp: Codable {
		let timestamp_nanos: UInt64
	}
	
	/// // https://internetcomputer.org/docs/current/references/ledger/
	/// type Tokens = record {
	///      e8s : nat64;
	/// };
	struct Tokens: Codable {
		let e8s: UInt64
	}
	
	/// type Transaction = record {
	///     operation: opt Operation;
	///     memo: Memo;
	///     created_at_time: TimeStamp;
	/// };
	struct Transaction: Codable {
		let memo: Memo
		let operation: Operation?
		let created_at_time: TimeStamp
	}
	
	/// // Arguments for the `transfer` call.
	/// type TransferArgs = record {
	///     // Transaction memo.
	///     // See comments for the `Memo` type.
	///     memo: Memo;
	///     // The amount that the caller wants to transfer to the destination address.
	///     amount: Tokens;
	///     // The amount that the caller pays for the transaction.
	///     // Must be 10000 e8s.
	///     fee: Tokens;
	///     // The subaccount from which the caller wants to transfer funds.
	///     // If null, the ledger uses the default (all zeros) subaccount to compute the source address.
	///     // See comments for the `SubAccount` type.
	///     from_subaccount: opt SubAccount;
	///     // The destination account.
	///     // If the transfer is successful, the balance of this address increases by `amount`.
	///     to: AccountIdentifier;
	///     // The point in time when the caller created this request.
	///     // If null, the ledger uses current ICP time as the timestamp.
	///     created_at_time: opt TimeStamp;
	/// };
	struct TransferArgs: Codable {
		let to: AccountIdentifier
		let fee: Tokens
		let memo: Memo
		let from_subaccount: SubAccount?
		let created_at_time: TimeStamp?
		let amount: Tokens
	}
	
	/// type TransferError = variant {
	///     // The fee that the caller specified in the transfer request was not the one that ledger expects.
	///     // The caller can change the transfer fee to the `expected_fee` and retry the request.
	///     BadFee : record { expected_fee : Tokens; };
	///     // The account specified by the caller doesn't have enough funds.
	///     InsufficientFunds : record { balance: Tokens; };
	///     // The request is too old.
	///     // The ledger only accepts requests created within 24 hours window.
	///     // This is a non-recoverable error.
	///     TxTooOld : record { allowed_window_nanos: nat64 };
	///     // The caller specified `created_at_time` that is too far in future.
	///     // The caller can retry the request later.
	///     TxCreatedInFuture : null;
	///     // The ledger has already executed the request.
	///     // `duplicate_of` field is equal to the index of the block containing the original transaction.
	///     TxDuplicate : record { duplicate_of: BlockIndex; }
	/// };
	enum TransferError: Codable {
		case TxTooOld(allowed_window_nanos: UInt64)
		case BadFee(expected_fee: Tokens)
		case TxDuplicate(duplicate_of: BlockIndex)
		case TxCreatedInFuture
		case InsufficientFunds(balance: Tokens)
	
		enum CodingKeys: String, CandidCodingKey {
			case TxTooOld
			case BadFee
			case TxDuplicate
			case TxCreatedInFuture
			case InsufficientFunds
		}
		enum TxTooOldCodingKeys: String, CandidCodingKey {
			case allowed_window_nanos
		}
		enum BadFeeCodingKeys: String, CandidCodingKey {
			case expected_fee
		}
		enum TxDuplicateCodingKeys: String, CandidCodingKey {
			case duplicate_of
		}
		enum InsufficientFundsCodingKeys: String, CandidCodingKey {
			case balance
		}
	}
	
	/// type TransferResult = variant {
	///     Ok : BlockIndex;
	///     Err : TransferError;
	/// };
	enum TransferResult: Codable {
		case Ok(BlockIndex)
		case Err(TransferError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	struct UnnamedType0: Codable {
		let callback: QueryArchiveFn
		let start: BlockIndex
		let length: UInt64
	}
	

	/// service : {
	///   // Queries blocks in the specified range.
	///   query_blocks : (GetBlocksArgs) -> (QueryBlocksResponse) query;
	///   // Returns the existing archive canisters information.
	///   archives : () -> (Archives) query;
	///   
	///   // Get the amount of ICP on the specified account.
	///   account_balance : (AccountBalanceArgs) -> (Tokens) query;
	///   transfer : (TransferArgs) -> (TransferResult);
	/// }
	class Service: ICPService {
		/// // Queries blocks in the specified range.
		///   query_blocks : (GetBlocksArgs) -> (QueryBlocksResponse) query;
		func query_blocks(_ arg0: GetBlocksArgs, sender: ICPSigningPrincipal? = nil) async throws -> QueryBlocksResponse {
			let caller = ICPQuery<GetBlocksArgs, QueryBlocksResponse>(canister, "query_blocks")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// // Returns the existing archive canisters information.
		///   archives : () -> (Archives) query;
		func archives(sender: ICPSigningPrincipal? = nil) async throws -> Archives {
			let caller = ICPQueryNoArgs<Archives>(canister, "archives")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Get the amount of ICP on the specified account.
		///   account_balance : (AccountBalanceArgs) -> (Tokens) query;
		func account_balance(_ arg0: AccountBalanceArgs, sender: ICPSigningPrincipal? = nil) async throws -> Tokens {
			let caller = ICPQuery<AccountBalanceArgs, Tokens>(canister, "account_balance")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// transfer : (TransferArgs) -> (TransferResult);
		func transfer(_ arg0: TransferArgs, sender: ICPSigningPrincipal? = nil) async throws -> TransferResult {
			let caller = ICPCall<TransferArgs, TransferResult>(canister, "transfer")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
	}

}
