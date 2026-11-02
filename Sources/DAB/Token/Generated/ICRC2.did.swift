//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum ICRC2 {
	/// // https://github.com/dfinity/ICRC-1/blob/main/standards/ICRC-2/README.md
	/// type Account = record {
	///     owner : principal;
	///     subaccount : opt blob;
	/// };
	struct Account: Codable {
		let owner: ICPPrincipal
		let subaccount: Data?
	}
	
	/// type Allowance = record {
	///   allowance : nat;
	///   expires_at : opt nat64;
	/// };
	struct Allowance: Codable {
		let allowance: BigUInt
		let expires_at: UInt64?
	}
	
	/// type AllowanceArgs = record {
	///     account : Account;
	///     spender : Account;
	/// };
	struct AllowanceArgs: Codable {
		let account: Account
		let spender: Account
	}
	
	/// type ApproveArgs = record {
	///     from_subaccount : opt blob;
	///     spender : Account;
	///     amount : nat;
	///     expected_allowance : opt nat;
	///     expires_at : opt nat64;
	///     fee : opt nat;
	///     memo : opt blob;
	///     created_at_time : opt nat64;
	/// };
	struct ApproveArgs: Codable {
		let fee: BigUInt?
		let memo: Data?
		let from_subaccount: Data?
		let created_at_time: UInt64?
		let amount: BigUInt
		let expected_allowance: BigUInt?
		let expires_at: UInt64?
		let spender: Account
	}
	
	/// type ApproveError = variant {
	///     BadFee : record { expected_fee : nat };
	///     // The caller does not have enough funds to pay the approval fee.
	///     InsufficientFunds : record { balance : nat };
	///     // The caller specified the [expected_allowance] field, and the current
	///     // allowance did not match the given value.
	///     AllowanceChanged : record { current_allowance : nat };
	///     // The approval request expired before the ledger had a chance to apply it.
	///     Expired : record { ledger_time : nat64; };
	///     TooOld;
	///     CreatedInFuture: record { ledger_time : nat64 };
	///     Duplicate : record { duplicate_of : nat };
	///     TemporarilyUnavailable;
	///     GenericError : record { error_code : nat; message : text };
	/// };
	enum ApproveError: Codable {
		case GenericError(message: String, error_code: BigUInt)
		case TemporarilyUnavailable
		case Duplicate(duplicate_of: BigUInt)
		case BadFee(expected_fee: BigUInt)
		case AllowanceChanged(current_allowance: BigUInt)
		case CreatedInFuture(ledger_time: UInt64)
		case TooOld
		case Expired(ledger_time: UInt64)
		case InsufficientFunds(balance: BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case GenericError
			case TemporarilyUnavailable
			case Duplicate
			case BadFee
			case AllowanceChanged
			case CreatedInFuture
			case TooOld
			case Expired
			case InsufficientFunds
		}
		enum GenericErrorCodingKeys: String, CandidCodingKey {
			case message
			case error_code
		}
		enum DuplicateCodingKeys: String, CandidCodingKey {
			case duplicate_of
		}
		enum BadFeeCodingKeys: String, CandidCodingKey {
			case expected_fee
		}
		enum AllowanceChangedCodingKeys: String, CandidCodingKey {
			case current_allowance
		}
		enum CreatedInFutureCodingKeys: String, CandidCodingKey {
			case ledger_time
		}
		enum ExpiredCodingKeys: String, CandidCodingKey {
			case ledger_time
		}
		enum InsufficientFundsCodingKeys: String, CandidCodingKey {
			case balance
		}
	}
	
	/// type ApproveResult = variant {
	///     Ok : nat;
	///     Err : ApproveError;
	/// };
	enum ApproveResult: Codable {
		case Ok(BigUInt)
		case Err(ApproveError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	
	/// type TransferFromArgs = record {
	///     spender_subaccount : opt blob;
	///     from : Account;
	///     to : Account;
	///     amount : nat;
	///     fee : opt nat;
	///     memo : opt blob;
	///     created_at_time : opt nat64;
	/// };
	struct TransferFromArgs: Codable {
		let to: Account
		let fee: BigUInt?
		let spender_subaccount: Data?
		let from: Account
		let memo: Data?
		let created_at_time: UInt64?
		let amount: BigUInt
	}
	
	/// type TransferFromError = variant {
	///     BadFee : record { expected_fee : nat };
	///     BadBurn : record { min_burn_amount : nat };
	///     // The [from] account does not hold enough funds for the transfer.
	///     InsufficientFunds : record { balance : nat };
	///     // The caller exceeded its allowance.
	///     InsufficientAllowance : record { allowance : nat };
	///     TooOld;
	///     CreatedInFuture: record { ledger_time : nat64 };
	///     Duplicate : record { duplicate_of : nat };
	///     TemporarilyUnavailable;
	///     GenericError : record { error_code : nat; message : text };
	/// };
	enum TransferFromError: Codable {
		case GenericError(message: String, error_code: BigUInt)
		case TemporarilyUnavailable
		case InsufficientAllowance(allowance: BigUInt)
		case BadBurn(min_burn_amount: BigUInt)
		case Duplicate(duplicate_of: BigUInt)
		case BadFee(expected_fee: BigUInt)
		case CreatedInFuture(ledger_time: UInt64)
		case TooOld
		case InsufficientFunds(balance: BigUInt)
	
		enum CodingKeys: String, CandidCodingKey {
			case GenericError
			case TemporarilyUnavailable
			case InsufficientAllowance
			case BadBurn
			case Duplicate
			case BadFee
			case CreatedInFuture
			case TooOld
			case InsufficientFunds
		}
		enum GenericErrorCodingKeys: String, CandidCodingKey {
			case message
			case error_code
		}
		enum InsufficientAllowanceCodingKeys: String, CandidCodingKey {
			case allowance
		}
		enum BadBurnCodingKeys: String, CandidCodingKey {
			case min_burn_amount
		}
		enum DuplicateCodingKeys: String, CandidCodingKey {
			case duplicate_of
		}
		enum BadFeeCodingKeys: String, CandidCodingKey {
			case expected_fee
		}
		enum CreatedInFutureCodingKeys: String, CandidCodingKey {
			case ledger_time
		}
		enum InsufficientFundsCodingKeys: String, CandidCodingKey {
			case balance
		}
	}
	
	/// type TransferFromResult = variant {
	///     Ok : nat;
	///     Err : TransferFromError;
	/// };
	enum TransferFromResult: Codable {
		case Ok(BigUInt)
		case Err(TransferFromError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Err
		}
	}
	

	/// service: {
	///     // This method entitles the spender to transfer token amount on behalf of the caller from account.
	///     // The number of transfers the spender can initiate from the caller's account is unlimited as long as the total amounts and fees of these transfers do not exceed the allowance.
	///     // The caller does not need to have the full token amount on the specified account for the approval to succeed, just enough tokens to pay the approval fee.
	///     // The call resets the allowance and the expiration date for the spender account to the given values.
	///     icrc2_approve : (ApproveArgs) -> (ApproveResult);
	///     
	///     // Transfers a token amount from the from account to the to account using the allowance of the spender's account.
	///     // The ledger draws the fees from the from account.
	///     icrc2_transfer_from : (TransferFromArgs) -> (TransferFromResult);
	///     
	///     // Returns the token allowance that the spender account can transfer from the specified account, and the expiration time for that allowance, if any.
	///     icrc2_allowance : (AllowanceArgs) -> (Allowance) query;
	/// };
	class Service: ICPService {
		/// // This method entitles the spender to transfer token amount on behalf of the caller from account.
		///     // The number of transfers the spender can initiate from the caller's account is unlimited as long as the total amounts and fees of these transfers do not exceed the allowance.
		///     // The caller does not need to have the full token amount on the specified account for the approval to succeed, just enough tokens to pay the approval fee.
		///     // The call resets the allowance and the expiration date for the spender account to the given values.
		///     icrc2_approve : (ApproveArgs) -> (ApproveResult);
		func icrc2_approve(_ arg0: ApproveArgs, sender: ICPSigningPrincipal? = nil) async throws -> ApproveResult {
			let caller = ICPCall<ApproveArgs, ApproveResult>(canister, "icrc2_approve")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// // Transfers a token amount from the from account to the to account using the allowance of the spender's account.
		///     // The ledger draws the fees from the from account.
		///     icrc2_transfer_from : (TransferFromArgs) -> (TransferFromResult);
		func icrc2_transfer_from(_ arg0: TransferFromArgs, sender: ICPSigningPrincipal? = nil) async throws -> TransferFromResult {
			let caller = ICPCall<TransferFromArgs, TransferFromResult>(canister, "icrc2_transfer_from")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// // Returns the token allowance that the spender account can transfer from the specified account, and the expiration time for that allowance, if any.
		///     icrc2_allowance : (AllowanceArgs) -> (Allowance) query;
		func icrc2_allowance(_ arg0: AllowanceArgs, sender: ICPSigningPrincipal? = nil) async throws -> Allowance {
			let caller = ICPQuery<AllowanceArgs, Allowance>(canister, "icrc2_allowance")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
	}

}
