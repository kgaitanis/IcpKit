//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum DIP20 {
	/// // https://github.com/Psychedelic/DIP20/blob/main/spec.md
	/// type Metadata = record {
	///     logo : text; // base64 encoded logo or logo url
	///     name : text; // token name
	///     symbol : text; // token symbol
	///     decimals : nat8; // token decimal
	///     totalSupply : nat; // token total supply
	///     owner : principal; // token owner
	///     fee : nat; // fee for update calls
	/// };
	struct Metadata: Codable {
		let fee: BigUInt
		let decimals: UInt8
		let owner: ICPPrincipal
		let logo: String
		let name: String
		let totalSupply: BigUInt
		let symbol: String
	}
	
	/// type Operation = variant {
	///     approve;
	///     mint;
	///     transfer;
	///     transferFrom;
	/// };
	enum Operation: Codable {
		case transferFrom
		case mint
		case approve
		case transfer
	
		enum CodingKeys: String, CandidCodingKey {
			case transferFrom
			case mint
			case approve
			case transfer
		}
	}
	
	/// // Timestamps are represented as nanoseconds from the UNIX epoch in UTC timezone
	/// type TimeStamp = record {
	///     timestamp_nanos: nat64;
	/// };
	struct TimeStamp: Codable {
		let timestamp_nanos: UInt64
	}
	
	/// type TransactionStatus = variant {
	///     succeeded;
	///     failed;
	/// };
	enum TransactionStatus: Codable {
		case failed
		case succeeded
	
		enum CodingKeys: String, CandidCodingKey {
			case failed
			case succeeded
		}
	}
	
	/// type TxError = variant {
	///     InsufficientAllowance;
	///     InsufficientBalance;
	///     ErrorOperationStyle;
	///     Unauthorized;
	///     LedgerTrap;
	///     ErrorTo;
	///     Other: text;
	///     BlockUsed;
	///     AmountTooSmall;
	/// };
	enum TxError: Codable {
		case InsufficientAllowance
		case InsufficientBalance
		case ErrorOperationStyle
		case Unauthorized
		case LedgerTrap
		case ErrorTo
		case Other(String)
		case BlockUsed
		case AmountTooSmall
	
		enum CodingKeys: String, CandidCodingKey {
			case InsufficientAllowance
			case InsufficientBalance
			case ErrorOperationStyle
			case Unauthorized
			case LedgerTrap
			case ErrorTo
			case Other
			case BlockUsed
			case AmountTooSmall
		}
	}
	
	/// type TxReceipt = variant {
	///     Ok: nat;
	///     Err: TxError;
	/// };
	enum TxReceipt: Codable {
		case Ok(BigUInt)
		case Err(TxError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type TxRecord = record {
	///     caller: opt principal;
	///     op: Operation; // operation type
	///     index: nat; // transaction index
	///     from: principal;
	///     to: principal;
	///     amount: nat;
	///     fee: nat;
	///     timestamp: TimeStamp;
	///     status: TransactionStatus;
	/// };
	struct TxRecord: Codable {
		let op: Operation
		let to: ICPPrincipal
		let fee: BigUInt
		let status: TransactionStatus
		let from: ICPPrincipal
		let timestamp: TimeStamp
		let caller: ICPPrincipal?
		let index: BigUInt
		let amount: BigUInt
	}
	

	/// service: {
	///     // Returns the logo of the token.
	///     logo: () -> (text) query;
	///     
	///     // Returns the name of the token.
	///     name: () -> (text) query;
	///     
	///     // Returns the symbol of the token.
	///     symbol: () -> (text) query;
	///     
	///     // Returns the decimals of the token.
	///     decimals: () -> (nat8) query;
	///     
	///     // Returns the total supply of the token.
	///     totalSupply: () -> (nat) query;
	///     
	///     // Returns the balance of user who.
	///     balanceOf: (who: principal) -> (nat) query;
	///     
	///     //Returns the amount which spender is still allowed to withdraw from owner.
	///     allowance: (owner: principal, spender: principal) -> (nat) query;
	///     // Returns the metadata of the token.
	///     getMetadata: () -> (Metadata) query;
	///     
	///     // Returns the history size.
	///     historySize: () -> (nat) query;
	///     // Returns transaction detail of the transaction identified by index.
	///     // If the index is out of range, the execution traps. Transactions are indexed from zero.
	///     getTransaction: (index: nat) -> (TxRecord) query;
	///     
	///     // Returns an array of transaction records in the range [start, start + limit).
	///     // To fend off DoS attacks, this function is allowed to trap, if limit is greater than the limit allowed by the token.
	///     // This function is also allowed to trap if start + limit > historySize()
	///     getTransactions: (start: nat, limit: nat) -> (vec TxRecord) query;
	///     
	///     // Returns an array of transaction records in range [start, start + limit) related to user who.
	///     // Unlike getTransactions function, the range [start, start + limit) for getUserTransactions is not the global range of all transactions.
	///     // The range [start, start + limit) here pertains to the transactions of user who.
	///     // Implementations are allowed to return less TxRecords than requested to fend off DoS attacks.
	///     getUserTransactions: (who: principal, start: nat, limit: nat) -> (vec TxRecord) query;
	///     // Returns total number of transactions related to the user who.
	///     getUserTransactionAmount: (who: principal) -> (nat) query;
	///     
	///     // Transfers value amount of tokens to user to, returns a TxReceipt which contains the transaction index or an error message.
	///     transfer: (to: principal, value: nat) -> (TxReceipt);
	///     
	///     // Transfers value amount of tokens from user from to user to,
	///     // this method allows canister smart contracts to transfer tokens on your behalf,
	///     // it returns a TxReceipt which contains the transaction index or an error message.
	///     transferFrom: (from: principal, to: principal, value: nat) -> (TxReceipt);
	///     
	///     // Allows spender to withdraw tokens from your account, up to the value amount.
	///     // If it is called again it overwrites the current allowance with value.
	///     // There is no upper limit for value.
	///     approve: (spender: principal, value: nat) -> (TxReceipt);
	/// };
	class Service: ICPService {
		/// // Returns the logo of the token.
		///     logo: () -> (text) query;
		func logo(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "logo")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns the name of the token.
		///     name: () -> (text) query;
		func name(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "name")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns the symbol of the token.
		///     symbol: () -> (text) query;
		func symbol(sender: ICPSigningPrincipal? = nil) async throws -> String {
			let caller = ICPQueryNoArgs<String>(canister, "symbol")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns the decimals of the token.
		///     decimals: () -> (nat8) query;
		func decimals(sender: ICPSigningPrincipal? = nil) async throws -> UInt8 {
			let caller = ICPQueryNoArgs<UInt8>(canister, "decimals")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns the total supply of the token.
		///     totalSupply: () -> (nat) query;
		func totalSupply(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "totalSupply")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns the balance of user who.
		///     balanceOf: (who: principal) -> (nat) query;
		func balanceOf(who: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQuery<ICPPrincipal, BigUInt>(canister, "balanceOf")
			let response = try await caller.callMethod(who, client, sender: sender)
			return response
		}
	
		/// //Returns the amount which spender is still allowed to withdraw from owner.
		///     allowance: (owner: principal, spender: principal) -> (nat) query;
		func allowance(owner: ICPPrincipal, spender: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQuery<ICPFunctionArgs2<ICPPrincipal, ICPPrincipal>, BigUInt>(canister, "allowance")
			let response = try await caller.callMethod(.init(owner, spender), client, sender: sender)
			return response
		}
	
		/// // Returns the metadata of the token.
		///     getMetadata: () -> (Metadata) query;
		func getMetadata(sender: ICPSigningPrincipal? = nil) async throws -> Metadata {
			let caller = ICPQueryNoArgs<Metadata>(canister, "getMetadata")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns the history size.
		///     historySize: () -> (nat) query;
		func historySize(sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQueryNoArgs<BigUInt>(canister, "historySize")
			let response = try await caller.callMethod(client, sender: sender)
			return response
		}
	
		/// // Returns transaction detail of the transaction identified by index.
		///     // If the index is out of range, the execution traps. Transactions are indexed from zero.
		///     getTransaction: (index: nat) -> (TxRecord) query;
		func getTransaction(index: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> TxRecord {
			let caller = ICPQuery<BigUInt, TxRecord>(canister, "getTransaction")
			let response = try await caller.callMethod(index, client, sender: sender)
			return response
		}
	
		/// // Returns an array of transaction records in the range [start, start + limit).
		///     // To fend off DoS attacks, this function is allowed to trap, if limit is greater than the limit allowed by the token.
		///     // This function is also allowed to trap if start + limit > historySize()
		///     getTransactions: (start: nat, limit: nat) -> (vec TxRecord) query;
		func getTransactions(start: BigUInt, limit: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> [TxRecord] {
			let caller = ICPQuery<ICPFunctionArgs2<BigUInt, BigUInt>, [TxRecord]>(canister, "getTransactions")
			let response = try await caller.callMethod(.init(start, limit), client, sender: sender)
			return response
		}
	
		/// // Returns an array of transaction records in range [start, start + limit) related to user who.
		///     // Unlike getTransactions function, the range [start, start + limit) for getUserTransactions is not the global range of all transactions.
		///     // The range [start, start + limit) here pertains to the transactions of user who.
		///     // Implementations are allowed to return less TxRecords than requested to fend off DoS attacks.
		///     getUserTransactions: (who: principal, start: nat, limit: nat) -> (vec TxRecord) query;
		func getUserTransactions(who: ICPPrincipal, start: BigUInt, limit: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> [TxRecord] {
			let caller = ICPQuery<ICPFunctionArgs3<ICPPrincipal, BigUInt, BigUInt>, [TxRecord]>(canister, "getUserTransactions")
			let response = try await caller.callMethod(.init(who, start, limit), client, sender: sender)
			return response
		}
	
		/// // Returns total number of transactions related to the user who.
		///     getUserTransactionAmount: (who: principal) -> (nat) query;
		func getUserTransactionAmount(who: ICPPrincipal, sender: ICPSigningPrincipal? = nil) async throws -> BigUInt {
			let caller = ICPQuery<ICPPrincipal, BigUInt>(canister, "getUserTransactionAmount")
			let response = try await caller.callMethod(who, client, sender: sender)
			return response
		}
	
		/// // Transfers value amount of tokens to user to, returns a TxReceipt which contains the transaction index or an error message.
		///     transfer: (to: principal, value: nat) -> (TxReceipt);
		func transfer(to: ICPPrincipal, value: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> TxReceipt {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, TxReceipt>(canister, "transfer")
			let response = try await caller.callMethod(.init(to, value), client, sender: sender)
			return response
		}
	
		/// // Transfers value amount of tokens from user from to user to,
		///     // this method allows canister smart contracts to transfer tokens on your behalf,
		///     // it returns a TxReceipt which contains the transaction index or an error message.
		///     transferFrom: (from: principal, to: principal, value: nat) -> (TxReceipt);
		func transferFrom(from: ICPPrincipal, to: ICPPrincipal, value: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> TxReceipt {
			let caller = ICPCall<ICPFunctionArgs3<ICPPrincipal, ICPPrincipal, BigUInt>, TxReceipt>(canister, "transferFrom")
			let response = try await caller.callMethod(.init(from, to, value), client, sender: sender)
			return response
		}
	
		/// // Allows spender to withdraw tokens from your account, up to the value amount.
		///     // If it is called again it overwrites the current allowance with value.
		///     // There is no upper limit for value.
		///     approve: (spender: principal, value: nat) -> (TxReceipt);
		func approve(spender: ICPPrincipal, value: BigUInt, sender: ICPSigningPrincipal? = nil) async throws -> TxReceipt {
			let caller = ICPCall<ICPFunctionArgs2<ICPPrincipal, BigUInt>, TxReceipt>(canister, "approve")
			let response = try await caller.callMethod(.init(spender, value), client, sender: sender)
			return response
		}
	
	}

}
