//
// This file was generated using IcpKit CandidCodeGenerator
// For more information visit https://github.com/kgaitanis/IcpKit
//

import Foundation
import IcpKit
import BigInt

enum NNS_SNS_W {
	/// type GetWasmRequest = record {
	///     hash : blob;
	/// };
	typealias GetWasmRequest = GetProposalIdThatAddedWasmRequest
	
	/// type UpdateSnsSubnetListResponse = record {
	///     error : opt SnsWasmError;
	/// };
	typealias UpdateSnsSubnetListResponse = InsertUpgradePathEntriesResponse
	
	
	/// // https://github.com/dfinity/nns-dapp/blob/main/declarations/used_by_sns_aggregator/sns_wasm/sns_wasm.did
	/// //! Candid for canister `sns_wasm` obtained by `scripts/update_ic_commit` from: <https://raw.githubusercontent.com/dfinity/ic/release-2024-09-19_01-31-base/rs/nns/sns-wasm/canister/sns-wasm.did>
	/// type AddWasmRequest = record {
	///     hash : blob;
	///     wasm : opt SnsWasm;
	/// };
	struct AddWasmRequest: Codable {
		let hash: Data
		let wasm: SnsWasm?
	}
	
	/// type AddWasmResponse = record {
	///     result : opt Result;
	/// };
	struct AddWasmResponse: Codable {
		let result: Result?
	}
	
	/// type AirdropDistribution = record {
	///     airdrop_neurons : vec NeuronDistribution;
	/// };
	struct AirdropDistribution: Codable {
		let airdrop_neurons: [NeuronDistribution]
	}
	
	/// type Canister = record {
	///     id : opt principal;
	/// };
	struct Canister: Codable {
		let id: ICPPrincipal?
	}
	
	/// type Countries = record {
	///     iso_codes : vec text;
	/// };
	struct Countries: Codable {
		let iso_codes: [String]
	}
	
	/// type DappCanisters = record {
	///     canisters : vec Canister;
	/// };
	struct DappCanisters: Codable {
		let canisters: [Canister]
	}
	
	/// type DappCanistersTransferResult = record {
	///     restored_dapp_canisters : vec Canister;
	///     nns_controlled_dapp_canisters : vec Canister;
	///     sns_controlled_dapp_canisters : vec Canister;
	/// };
	struct DappCanistersTransferResult: Codable {
		let restored_dapp_canisters: [Canister]
		let nns_controlled_dapp_canisters: [Canister]
		let sns_controlled_dapp_canisters: [Canister]
	}
	
	/// type DeployNewSnsRequest = record {
	///     sns_init_payload : opt SnsInitPayload;
	/// };
	struct DeployNewSnsRequest: Codable {
		let sns_init_payload: SnsInitPayload?
	}
	
	/// type DeployNewSnsResponse = record {
	///     dapp_canisters_transfer_result : opt DappCanistersTransferResult;
	///     subnet_id : opt principal;
	///     error : opt SnsWasmError;
	///     canisters : opt SnsCanisterIds;
	/// };
	struct DeployNewSnsResponse: Codable {
		let dapp_canisters_transfer_result: DappCanistersTransferResult?
		let subnet_id: ICPPrincipal?
		let error: SnsWasmError?
		let canisters: SnsCanisterIds?
	}
	
	/// type DeployedSns = record {
	///     root_canister_id : opt principal;
	///     governance_canister_id : opt principal;
	///     index_canister_id : opt principal;
	///     swap_canister_id : opt principal;
	///     ledger_canister_id : opt principal;
	/// };
	struct DeployedSns: Codable {
		let root_canister_id: ICPPrincipal?
		let governance_canister_id: ICPPrincipal?
		let index_canister_id: ICPPrincipal?
		let swap_canister_id: ICPPrincipal?
		let ledger_canister_id: ICPPrincipal?
	}
	
	/// type DeveloperDistribution = record {
	///     developer_neurons : vec NeuronDistribution;
	/// };
	struct DeveloperDistribution: Codable {
		let developer_neurons: [NeuronDistribution]
	}
	
	/// type FractionalDeveloperVotingPower = record {
	///     treasury_distribution : opt TreasuryDistribution;
	///     developer_distribution : opt DeveloperDistribution;
	///     airdrop_distribution : opt AirdropDistribution;
	///     swap_distribution : opt SwapDistribution;
	/// };
	struct FractionalDeveloperVotingPower: Codable {
		let treasury_distribution: TreasuryDistribution?
		let developer_distribution: DeveloperDistribution?
		let airdrop_distribution: AirdropDistribution?
		let swap_distribution: SwapDistribution?
	}
	
	/// type GetAllowedPrincipalsResponse = record {
	///     allowed_principals : vec principal;
	/// };
	struct GetAllowedPrincipalsResponse: Codable {
		let allowed_principals: [ICPPrincipal]
	}
	
	/// type GetDeployedSnsByProposalIdRequest = record {
	///     proposal_id : nat64;
	/// };
	struct GetDeployedSnsByProposalIdRequest: Codable {
		let proposal_id: UInt64
	}
	
	/// type GetDeployedSnsByProposalIdResponse = record {
	///     get_deployed_sns_by_proposal_id_result : opt GetDeployedSnsByProposalIdResult;
	/// };
	struct GetDeployedSnsByProposalIdResponse: Codable {
		let get_deployed_sns_by_proposal_id_result: GetDeployedSnsByProposalIdResult?
	}
	
	/// type GetDeployedSnsByProposalIdResult = variant {
	///     Error : SnsWasmError;
	///     DeployedSns : DeployedSns;
	/// };
	enum GetDeployedSnsByProposalIdResult: Codable {
		case Error(SnsWasmError)
		case DeployedSns(DeployedSns)
	
		enum CodingKeys: String, CandidCodingKey {
			case Error
			case DeployedSns
		}
	}
	
	/// type GetNextSnsVersionRequest = record {
	///     governance_canister_id : opt principal;
	///     current_version : opt SnsVersion;
	/// };
	struct GetNextSnsVersionRequest: Codable {
		let governance_canister_id: ICPPrincipal?
		let current_version: SnsVersion?
	}
	
	/// type GetNextSnsVersionResponse = record {
	///     next_version : opt SnsVersion;
	/// };
	struct GetNextSnsVersionResponse: Codable {
		let next_version: SnsVersion?
	}
	
	/// type GetProposalIdThatAddedWasmRequest = record {
	///     hash : blob;
	/// };
	struct GetProposalIdThatAddedWasmRequest: Codable {
		let hash: Data
	}
	
	/// type GetProposalIdThatAddedWasmResponse = record {
	///     proposal_id : opt nat64;
	/// };
	struct GetProposalIdThatAddedWasmResponse: Codable {
		let proposal_id: UInt64?
	}
	
	/// type GetSnsSubnetIdsResponse = record {
	///     sns_subnet_ids : vec principal;
	/// };
	struct GetSnsSubnetIdsResponse: Codable {
		let sns_subnet_ids: [ICPPrincipal]
	}
	
	/// type GetWasmMetadataRequest = record {
	///     hash : opt blob;
	/// };
	struct GetWasmMetadataRequest: Codable {
		let hash: Data?
	}
	
	/// type GetWasmMetadataResponse = record {
	///     result : opt Result_1;
	/// };
	struct GetWasmMetadataResponse: Codable {
		let result: Result_1?
	}
	
	/// type GetWasmResponse = record {
	///     wasm : opt SnsWasm;
	/// };
	struct GetWasmResponse: Codable {
		let wasm: SnsWasm?
	}
	
	/// type IdealMatchedParticipationFunction = record {
	///     serialized_representation : opt text;
	/// };
	struct IdealMatchedParticipationFunction: Codable {
		let serialized_representation: String?
	}
	
	/// type InitialTokenDistribution = variant {
	///     FractionalDeveloperVotingPower : FractionalDeveloperVotingPower;
	/// };
	enum InitialTokenDistribution: Codable {
		case FractionalDeveloperVotingPower(FractionalDeveloperVotingPower)
	
		enum CodingKeys: String, CandidCodingKey {
			case FractionalDeveloperVotingPower
		}
	}
	
	/// type InsertUpgradePathEntriesRequest = record {
	///     upgrade_path : vec SnsUpgrade;
	///     sns_governance_canister_id : opt principal;
	/// };
	struct InsertUpgradePathEntriesRequest: Codable {
		let upgrade_path: [SnsUpgrade]
		let sns_governance_canister_id: ICPPrincipal?
	}
	
	/// type InsertUpgradePathEntriesResponse = record {
	///     error : opt SnsWasmError;
	/// };
	struct InsertUpgradePathEntriesResponse: Codable {
		let error: SnsWasmError?
	}
	
	/// type LinearScalingCoefficient = record {
	///     slope_numerator : opt nat64;
	///     intercept_icp_e8s : opt nat64;
	///     from_direct_participation_icp_e8s : opt nat64;
	///     slope_denominator : opt nat64;
	///     to_direct_participation_icp_e8s : opt nat64;
	/// };
	struct LinearScalingCoefficient: Codable {
		let slope_numerator: UInt64?
		let intercept_icp_e8s: UInt64?
		let from_direct_participation_icp_e8s: UInt64?
		let slope_denominator: UInt64?
		let to_direct_participation_icp_e8s: UInt64?
	}
	
	/// type ListDeployedSnsesResponse = record {
	///     instances : vec DeployedSns;
	/// };
	struct ListDeployedSnsesResponse: Codable {
		let instances: [DeployedSns]
	}
	
	/// type ListUpgradeStep = record {
	///     pretty_version : opt PrettySnsVersion;
	///     version : opt SnsVersion;
	/// };
	struct ListUpgradeStep: Codable {
		let pretty_version: PrettySnsVersion?
		let version: SnsVersion?
	}
	
	/// type ListUpgradeStepsRequest = record {
	///     limit : nat32;
	///     starting_at : opt SnsVersion;
	///     sns_governance_canister_id : opt principal;
	/// };
	struct ListUpgradeStepsRequest: Codable {
		let limit: UInt32
		let starting_at: SnsVersion?
		let sns_governance_canister_id: ICPPrincipal?
	}
	
	/// type ListUpgradeStepsResponse = record {
	///     steps : vec ListUpgradeStep;
	/// };
	struct ListUpgradeStepsResponse: Codable {
		let steps: [ListUpgradeStep]
	}
	
	/// type MetadataSection = record {
	///     contents : opt blob;
	///     name : opt text;
	///     visibility : opt text;
	/// };
	struct MetadataSection: Codable {
		let contents: Data?
		let name: String?
		let visibility: String?
	}
	
	/// type NeuronBasketConstructionParameters = record {
	///     dissolve_delay_interval_seconds : nat64;
	///     count : nat64;
	/// };
	struct NeuronBasketConstructionParameters: Codable {
		let dissolve_delay_interval_seconds: UInt64
		let count: UInt64
	}
	
	/// type NeuronDistribution = record {
	///     controller : opt principal;
	///     dissolve_delay_seconds : nat64;
	///     memo : nat64;
	///     stake_e8s : nat64;
	///     vesting_period_seconds : opt nat64;
	/// };
	struct NeuronDistribution: Codable {
		let controller: ICPPrincipal?
		let dissolve_delay_seconds: UInt64
		let memo: UInt64
		let stake_e8s: UInt64
		let vesting_period_seconds: UInt64?
	}
	
	/// type NeuronsFundParticipationConstraints = record {
	///     coefficient_intervals : vec LinearScalingCoefficient;
	///     max_neurons_fund_participation_icp_e8s : opt nat64;
	///     min_direct_participation_threshold_icp_e8s : opt nat64;
	///     ideal_matched_participation_function : opt IdealMatchedParticipationFunction;
	/// };
	struct NeuronsFundParticipationConstraints: Codable {
		let coefficient_intervals: [LinearScalingCoefficient]
		let max_neurons_fund_participation_icp_e8s: UInt64?
		let min_direct_participation_threshold_icp_e8s: UInt64?
		let ideal_matched_participation_function: IdealMatchedParticipationFunction?
	}
	
	/// type Ok = record {
	///     sections : vec MetadataSection;
	/// };
	struct Ok: Codable {
		let sections: [MetadataSection]
	}
	
	/// type PrettySnsVersion = record {
	///     archive_wasm_hash : text;
	///     root_wasm_hash : text;
	///     swap_wasm_hash : text;
	///     ledger_wasm_hash : text;
	///     governance_wasm_hash : text;
	///     index_wasm_hash : text;
	/// };
	struct PrettySnsVersion: Codable {
		let archive_wasm_hash: String
		let root_wasm_hash: String
		let swap_wasm_hash: String
		let ledger_wasm_hash: String
		let governance_wasm_hash: String
		let index_wasm_hash: String
	}
	
	/// type Result = variant {
	///     Error : SnsWasmError;
	///     Hash : blob;
	/// };
	enum Result: Codable {
		case Error(SnsWasmError)
		case Hash(Data)
	
		enum CodingKeys: String, CandidCodingKey {
			case Error
			case Hash
		}
	}
	
	/// type Result_1 = variant {
	///     Ok : Ok;
	///     Error : SnsWasmError;
	/// };
	enum Result_1: Codable {
		case Ok(Ok)
		case Error(SnsWasmError)
	
		enum CodingKeys: String, CandidCodingKey {
			case Ok
			case Error
		}
	}
	
	/// type SnsCanisterIds = record {
	///     root : opt principal;
	///     swap : opt principal;
	///     ledger : opt principal;
	///     index : opt principal;
	///     governance : opt principal;
	/// };
	struct SnsCanisterIds: Codable {
		let root: ICPPrincipal?
		let swap: ICPPrincipal?
		let ledger: ICPPrincipal?
		let index: ICPPrincipal?
		let governance: ICPPrincipal?
	}
	
	/// type SnsInitPayload = record {
	///     url : opt text;
	///     max_dissolve_delay_seconds : opt nat64;
	///     max_dissolve_delay_bonus_percentage : opt nat64;
	///     nns_proposal_id : opt nat64;
	///     neurons_fund_participation : opt bool;
	///     min_participant_icp_e8s : opt nat64;
	///     neuron_basket_construction_parameters : opt NeuronBasketConstructionParameters;
	///     fallback_controller_principal_ids : vec text;
	///     token_symbol : opt text;
	///     final_reward_rate_basis_points : opt nat64;
	///     max_icp_e8s : opt nat64;
	///     neuron_minimum_stake_e8s : opt nat64;
	///     confirmation_text : opt text;
	///     logo : opt text;
	///     name : opt text;
	///     swap_start_timestamp_seconds : opt nat64;
	///     swap_due_timestamp_seconds : opt nat64;
	///     initial_voting_period_seconds : opt nat64;
	///     neuron_minimum_dissolve_delay_to_vote_seconds : opt nat64;
	///     description : opt text;
	///     max_neuron_age_seconds_for_age_bonus : opt nat64;
	///     min_participants : opt nat64;
	///     initial_reward_rate_basis_points : opt nat64;
	///     wait_for_quiet_deadline_increase_seconds : opt nat64;
	///     transaction_fee_e8s : opt nat64;
	///     dapp_canisters : opt DappCanisters;
	///     neurons_fund_participation_constraints : opt NeuronsFundParticipationConstraints;
	///     max_age_bonus_percentage : opt nat64;
	///     initial_token_distribution : opt InitialTokenDistribution;
	///     reward_rate_transition_duration_seconds : opt nat64;
	///     token_logo : opt text;
	///     token_name : opt text;
	///     max_participant_icp_e8s : opt nat64;
	///     min_direct_participation_icp_e8s : opt nat64;
	///     proposal_reject_cost_e8s : opt nat64;
	///     restricted_countries : opt Countries;
	///     min_icp_e8s : opt nat64;
	///     max_direct_participation_icp_e8s : opt nat64;
	/// };
	struct SnsInitPayload: Codable {
		let url: String?
		let max_dissolve_delay_seconds: UInt64?
		let max_dissolve_delay_bonus_percentage: UInt64?
		let nns_proposal_id: UInt64?
		let neurons_fund_participation: Bool?
		let min_participant_icp_e8s: UInt64?
		let neuron_basket_construction_parameters: NeuronBasketConstructionParameters?
		let fallback_controller_principal_ids: [String]
		let token_symbol: String?
		let final_reward_rate_basis_points: UInt64?
		let max_icp_e8s: UInt64?
		let neuron_minimum_stake_e8s: UInt64?
		let confirmation_text: String?
		let logo: String?
		let name: String?
		let swap_start_timestamp_seconds: UInt64?
		let swap_due_timestamp_seconds: UInt64?
		let initial_voting_period_seconds: UInt64?
		let neuron_minimum_dissolve_delay_to_vote_seconds: UInt64?
		let description: String?
		let max_neuron_age_seconds_for_age_bonus: UInt64?
		let min_participants: UInt64?
		let initial_reward_rate_basis_points: UInt64?
		let wait_for_quiet_deadline_increase_seconds: UInt64?
		let transaction_fee_e8s: UInt64?
		let dapp_canisters: DappCanisters?
		let neurons_fund_participation_constraints: NeuronsFundParticipationConstraints?
		let max_age_bonus_percentage: UInt64?
		let initial_token_distribution: InitialTokenDistribution?
		let reward_rate_transition_duration_seconds: UInt64?
		let token_logo: String?
		let token_name: String?
		let max_participant_icp_e8s: UInt64?
		let min_direct_participation_icp_e8s: UInt64?
		let proposal_reject_cost_e8s: UInt64?
		let restricted_countries: Countries?
		let min_icp_e8s: UInt64?
		let max_direct_participation_icp_e8s: UInt64?
	}
	
	/// type SnsUpgrade = record {
	///     next_version : opt SnsVersion;
	///     current_version : opt SnsVersion;
	/// };
	struct SnsUpgrade: Codable {
		let next_version: SnsVersion?
		let current_version: SnsVersion?
	}
	
	/// type SnsVersion = record {
	///     archive_wasm_hash : blob;
	///     root_wasm_hash : blob;
	///     swap_wasm_hash : blob;
	///     ledger_wasm_hash : blob;
	///     governance_wasm_hash : blob;
	///     index_wasm_hash : blob;
	/// };
	struct SnsVersion: Codable {
		let archive_wasm_hash: Data
		let root_wasm_hash: Data
		let swap_wasm_hash: Data
		let ledger_wasm_hash: Data
		let governance_wasm_hash: Data
		let index_wasm_hash: Data
	}
	
	/// type SnsWasm = record {
	///     wasm : blob;
	///     proposal_id : opt nat64;
	///     canister_type : int32;
	/// };
	struct SnsWasm: Codable {
		let wasm: Data
		let proposal_id: UInt64?
		let canister_type: Int32
	}
	
	/// type SnsWasmCanisterInitPayload = record {
	///     allowed_principals : vec principal;
	///     access_controls_enabled : bool;
	///     sns_subnet_ids : vec principal;
	/// };
	struct SnsWasmCanisterInitPayload: Codable {
		let allowed_principals: [ICPPrincipal]
		let access_controls_enabled: Bool
		let sns_subnet_ids: [ICPPrincipal]
	}
	
	/// type SnsWasmError = record {
	///     message : text;
	/// };
	struct SnsWasmError: Codable {
		let message: String
	}
	
	/// type SwapDistribution = record {
	///     total_e8s : nat64;
	///     initial_swap_amount_e8s : nat64;
	/// };
	struct SwapDistribution: Codable {
		let total_e8s: UInt64
		let initial_swap_amount_e8s: UInt64
	}
	
	/// type TreasuryDistribution = record {
	///     total_e8s : nat64;
	/// };
	struct TreasuryDistribution: Codable {
		let total_e8s: UInt64
	}
	
	/// type UpdateAllowedPrincipalsRequest = record {
	///     added_principals : vec principal;
	///     removed_principals : vec principal;
	/// };
	struct UpdateAllowedPrincipalsRequest: Codable {
		let added_principals: [ICPPrincipal]
		let removed_principals: [ICPPrincipal]
	}
	
	/// type UpdateAllowedPrincipalsResponse = record {
	///     update_allowed_principals_result : opt UpdateAllowedPrincipalsResult;
	/// };
	struct UpdateAllowedPrincipalsResponse: Codable {
		let update_allowed_principals_result: UpdateAllowedPrincipalsResult?
	}
	
	/// type UpdateAllowedPrincipalsResult = variant {
	///     Error : SnsWasmError;
	///     AllowedPrincipals : GetAllowedPrincipalsResponse;
	/// };
	enum UpdateAllowedPrincipalsResult: Codable {
		case Error(SnsWasmError)
		case AllowedPrincipals(GetAllowedPrincipalsResponse)
	
		enum CodingKeys: String, CandidCodingKey {
			case Error
			case AllowedPrincipals
		}
	}
	
	/// type UpdateSnsSubnetListRequest = record {
	///     sns_subnet_ids_to_add : vec principal;
	///     sns_subnet_ids_to_remove : vec principal;
	/// };
	struct UpdateSnsSubnetListRequest: Codable {
		let sns_subnet_ids_to_add: [ICPPrincipal]
		let sns_subnet_ids_to_remove: [ICPPrincipal]
	}
	

	/// service : (SnsWasmCanisterInitPayload) -> {
	///     add_wasm : (AddWasmRequest) -> (AddWasmResponse);
	///     deploy_new_sns : (DeployNewSnsRequest) -> (DeployNewSnsResponse);
	///     get_allowed_principals : (record {}) -> (GetAllowedPrincipalsResponse) query;
	///     get_deployed_sns_by_proposal_id : (GetDeployedSnsByProposalIdRequest) -> (
	///         GetDeployedSnsByProposalIdResponse,
	///     ) query;
	///     get_latest_sns_version_pretty : (null) -> (vec record { text; text }) query;
	///     get_next_sns_version : (GetNextSnsVersionRequest) -> (
	///         GetNextSnsVersionResponse,
	///     ) query;
	///     get_proposal_id_that_added_wasm : (GetProposalIdThatAddedWasmRequest) -> (
	///         GetProposalIdThatAddedWasmResponse,
	///     ) query;
	///     get_sns_subnet_ids : (record {}) -> (GetSnsSubnetIdsResponse) query;
	///     get_wasm : (GetWasmRequest) -> (GetWasmResponse) query;
	///     get_wasm_metadata : (GetWasmMetadataRequest) -> (
	///         GetWasmMetadataResponse,
	///     ) query;
	///     insert_upgrade_path_entries : (InsertUpgradePathEntriesRequest) -> (
	///         InsertUpgradePathEntriesResponse,
	///     );
	///     list_deployed_snses : (record {}) -> (ListDeployedSnsesResponse) query;
	///     list_upgrade_steps : (ListUpgradeStepsRequest) -> (
	///         ListUpgradeStepsResponse,
	///     ) query;
	///     update_allowed_principals : (UpdateAllowedPrincipalsRequest) -> (
	///         UpdateAllowedPrincipalsResponse,
	///     );
	///     update_sns_subnet_list : (UpdateSnsSubnetListRequest) -> (
	///         UpdateSnsSubnetListResponse,
	///     );
	/// }
	class Service: ICPService {
		/// add_wasm : (AddWasmRequest) -> (AddWasmResponse);
		func add_wasm(_ arg0: AddWasmRequest, sender: ICPSigningPrincipal? = nil) async throws -> AddWasmResponse {
			let caller = ICPCall<AddWasmRequest, AddWasmResponse>(canister, "add_wasm")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// deploy_new_sns : (DeployNewSnsRequest) -> (DeployNewSnsResponse);
		func deploy_new_sns(_ arg0: DeployNewSnsRequest, sender: ICPSigningPrincipal? = nil) async throws -> DeployNewSnsResponse {
			let caller = ICPCall<DeployNewSnsRequest, DeployNewSnsResponse>(canister, "deploy_new_sns")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_allowed_principals : (record {}) -> (GetAllowedPrincipalsResponse) query;
		func get_allowed_principals(_ arg0: CandidTuple0, sender: ICPSigningPrincipal? = nil) async throws -> GetAllowedPrincipalsResponse {
			let caller = ICPQuery<CandidTuple0, GetAllowedPrincipalsResponse>(canister, "get_allowed_principals")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_deployed_sns_by_proposal_id : (GetDeployedSnsByProposalIdRequest) -> (
		///         GetDeployedSnsByProposalIdResponse,
		///     ) query;
		func get_deployed_sns_by_proposal_id(_ arg0: GetDeployedSnsByProposalIdRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetDeployedSnsByProposalIdResponse {
			let caller = ICPQuery<GetDeployedSnsByProposalIdRequest, GetDeployedSnsByProposalIdResponse>(canister, "get_deployed_sns_by_proposal_id")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_latest_sns_version_pretty : (null) -> (vec record { text; text }) query;
		func get_latest_sns_version_pretty(_ arg0: CandidTuple0, sender: ICPSigningPrincipal? = nil) async throws -> [CandidTuple2<String, String>] {
			let caller = ICPQuery<CandidTuple0, [CandidTuple2<String, String>]>(canister, "get_latest_sns_version_pretty")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_next_sns_version : (GetNextSnsVersionRequest) -> (
		///         GetNextSnsVersionResponse,
		///     ) query;
		func get_next_sns_version(_ arg0: GetNextSnsVersionRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetNextSnsVersionResponse {
			let caller = ICPQuery<GetNextSnsVersionRequest, GetNextSnsVersionResponse>(canister, "get_next_sns_version")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_proposal_id_that_added_wasm : (GetProposalIdThatAddedWasmRequest) -> (
		///         GetProposalIdThatAddedWasmResponse,
		///     ) query;
		func get_proposal_id_that_added_wasm(_ arg0: GetProposalIdThatAddedWasmRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetProposalIdThatAddedWasmResponse {
			let caller = ICPQuery<GetProposalIdThatAddedWasmRequest, GetProposalIdThatAddedWasmResponse>(canister, "get_proposal_id_that_added_wasm")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_sns_subnet_ids : (record {}) -> (GetSnsSubnetIdsResponse) query;
		func get_sns_subnet_ids(_ arg0: CandidTuple0, sender: ICPSigningPrincipal? = nil) async throws -> GetSnsSubnetIdsResponse {
			let caller = ICPQuery<CandidTuple0, GetSnsSubnetIdsResponse>(canister, "get_sns_subnet_ids")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_wasm : (GetWasmRequest) -> (GetWasmResponse) query;
		func get_wasm(_ arg0: GetWasmRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetWasmResponse {
			let caller = ICPQuery<GetWasmRequest, GetWasmResponse>(canister, "get_wasm")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// get_wasm_metadata : (GetWasmMetadataRequest) -> (
		///         GetWasmMetadataResponse,
		///     ) query;
		func get_wasm_metadata(_ arg0: GetWasmMetadataRequest, sender: ICPSigningPrincipal? = nil) async throws -> GetWasmMetadataResponse {
			let caller = ICPQuery<GetWasmMetadataRequest, GetWasmMetadataResponse>(canister, "get_wasm_metadata")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// insert_upgrade_path_entries : (InsertUpgradePathEntriesRequest) -> (
		///         InsertUpgradePathEntriesResponse,
		///     );
		func insert_upgrade_path_entries(_ arg0: InsertUpgradePathEntriesRequest, sender: ICPSigningPrincipal? = nil) async throws -> InsertUpgradePathEntriesResponse {
			let caller = ICPCall<InsertUpgradePathEntriesRequest, InsertUpgradePathEntriesResponse>(canister, "insert_upgrade_path_entries")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// list_deployed_snses : (record {}) -> (ListDeployedSnsesResponse) query;
		func list_deployed_snses(_ arg0: CandidTuple0, sender: ICPSigningPrincipal? = nil) async throws -> ListDeployedSnsesResponse {
			let caller = ICPQuery<CandidTuple0, ListDeployedSnsesResponse>(canister, "list_deployed_snses")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// list_upgrade_steps : (ListUpgradeStepsRequest) -> (
		///         ListUpgradeStepsResponse,
		///     ) query;
		func list_upgrade_steps(_ arg0: ListUpgradeStepsRequest, sender: ICPSigningPrincipal? = nil) async throws -> ListUpgradeStepsResponse {
			let caller = ICPQuery<ListUpgradeStepsRequest, ListUpgradeStepsResponse>(canister, "list_upgrade_steps")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// update_allowed_principals : (UpdateAllowedPrincipalsRequest) -> (
		///         UpdateAllowedPrincipalsResponse,
		///     );
		func update_allowed_principals(_ arg0: UpdateAllowedPrincipalsRequest, sender: ICPSigningPrincipal? = nil) async throws -> UpdateAllowedPrincipalsResponse {
			let caller = ICPCall<UpdateAllowedPrincipalsRequest, UpdateAllowedPrincipalsResponse>(canister, "update_allowed_principals")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
		/// update_sns_subnet_list : (UpdateSnsSubnetListRequest) -> (
		///         UpdateSnsSubnetListResponse,
		///     );
		func update_sns_subnet_list(_ arg0: UpdateSnsSubnetListRequest, sender: ICPSigningPrincipal? = nil) async throws -> UpdateSnsSubnetListResponse {
			let caller = ICPCall<UpdateSnsSubnetListRequest, UpdateSnsSubnetListResponse>(canister, "update_sns_subnet_list")
			let response = try await caller.callMethod(arg0, client, sender: sender)
			return response
		}
	
	}

}
