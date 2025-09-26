"""
Unified Dynamic OOPMAX Framework

Everything in one file:
- Reads scenarios from CSV
- Generates all test data dynamically
- Creates and runs tests dynamically
- No hardcoded JSON files needed
"""
import json
import csv
import pytest
from pathlib import Path
from typing import Dict, List, Any, Optional
from unittest.mock import patch
from dataclasses import dataclass

from fastapi.testclient import TestClient

from app.main import app
from app.models.rate_criteria import NegotiatedRate
from app.schemas.benefit_response import BenefitApiResponse
from app.schemas.accumulator_response import AccumulatorResponse


@dataclass
class ScenarioConfig:
    """Configuration for a single OOPMAX scenario."""
    sr_no: str
    scenario_name: str
    is_service_covered: str
    has_limit: str
    has_oopmax_individual: str
    has_oopmax_family: str
    has_deductible_individual: str
    has_deductible_family: str
    cost_share_copay: float
    cost_share_coinsurance: float
    copay_applies_out_of_pocket: str
    coins_applies_out_of_pocket: str
    deductible_applies_out_of_pocket: str
    copay_count_to_deductible_indicator: str
    copay_continue_when_deductible_met_indicator: str
    copay_continue_when_out_of_pocket_max_met_indicator: str
    is_deductible_before_copay: str
    oopmax_i_calculated_value: Optional[float]
    oopmax_f_calculated_value: Optional[float]
    di_calculated_value: Optional[float]
    df_calculated_value: Optional[float]
    limit_calculated_value: Optional[float]
    limit_type: Optional[str]
    num_of_individuals_met: Optional[int]
    num_of_individuals_needed_to_meet: Optional[int]
    service_amount: float
    expected_member_pays: float
    logic: str
    notes: str


class UnifiedDynamicOOPMAXFramework:
    """Unified framework that does everything in one place."""
    
    def __init__(self, csv_file_path: str = "tests/api/oopmax_scenarios.csv"):
        self.csv_file_path = csv_file_path
        self.scenarios = self._load_scenarios_from_csv()
    
    def _load_scenarios_from_csv(self) -> List[ScenarioConfig]:
        """Load scenarios from CSV file."""
        scenarios = []
        
        with open(self.csv_file_path, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                if not row.get('Sr No.'):
                    continue
                    
                scenario = ScenarioConfig(
                    sr_no=row['Sr No.'],
                    scenario_name=row['Scenario'],
                    is_service_covered="Y" if row['isServiceCovered'].lower() == "yes" else "N",
                    has_limit=row['code = "limit"'],
                    has_oopmax_individual=row['code = "OOPMAX" , level="I"'],
                    has_oopmax_family=row['code = "OOPMAX" , level="F"'],
                    has_deductible_individual=row['code = "Deductible" , level="I"'],
                    has_deductible_family=row['code = "Deductible" , level="F"'],
                    cost_share_copay=float(row['costShareCopay']),
                    cost_share_coinsurance=float(row['costShareCoinsurance']),
                    copay_applies_out_of_pocket=row['copayAppliesOutOfPocket'],
                    coins_applies_out_of_pocket=row['coinsAppliesOutOfPocket'],
                    deductible_applies_out_of_pocket=row['deductibleAppliesOutOfPocket'],
                    copay_count_to_deductible_indicator=row['copayCountToDeductibleIndicator'],
                    copay_continue_when_deductible_met_indicator=row['copayContinueWhenDeductibleMetIndicator'],
                    copay_continue_when_out_of_pocket_max_met_indicator=row['copayContinueWhenOutOfPocketMaxMetIndicator'],
                    is_deductible_before_copay=row['isDeductibleBeforeCopay'],
                    oopmax_i_calculated_value=self._parse_none(row['OOPMAXIcalculatedValue']),
                    oopmax_f_calculated_value=self._parse_none(row['OOPMAXFcalculatedValue']),
                    di_calculated_value=self._parse_none(row['DIcalculatedValue']),
                    df_calculated_value=self._parse_none(row['DFcalculatedValue']),
                    limit_calculated_value=self._parse_none(row['LimitcalculatedValue']),
                    limit_type=row['limitType'] if row['limitType'] != 'N/A' else None,
                    num_of_individuals_met=self.row['numOfIndividualsMet'],
                    num_of_individuals_needed_to_meet=self.row['numOfIndividualsNeededToMeet'],
                    service_amount=float(row['ServiceAmount']),
                    expected_member_pays=float(row['Expected Member_Pays']),
                    logic=row['Logic'],
                    notes=row['Notes']
                )
                scenarios.append(scenario)
        
        return scenarios

    def _parse_none(self, value: str):
        """Parse float value, handling N/A and empty strings."""
        if value in ['N/A', '', 'n/a', None]:
            return None
        return value
    
    def _generate_cost_request(self, scenario: ScenarioConfig) -> Dict[str, Any]:
        """Generate cost request JSON dynamically."""
        # Use the same service codes that work for all scenarios to avoid matching issues
        service_code = "21137"
        place_of_service = "22"
        provider_type = "HO"
        specialty_code = ""
        description = ""
        
        return {
            "membershipId": f"5~265646860+10+725+20250101+799047+BA+42",
            "zipCode": "",
            "benefitProductType": "Medical",
            "languageCode": "11",
            "service": {
                "code": service_code,
                "type": "CPT4",
                "description": description,
                "supportingService": {"code": "", "type": ""},
                "modifier": {"modifierCode": ""},
                "diagnosisCode": "",
                "placeOfService": {"code": place_of_service}
            },
            "providerInfo": [
                {
                    "serviceLocation": "0003543634",
                    "providerType": provider_type,
                    "speciality": {"code": specialty_code},
                    "taxIdentificationNumber": "",
                    "taxIdQualifier": "",
                    "providerNetworks": {"networkID": "00387"},
                    "providerIdentificationNumber": "0006170130",
                    "nationalProviderId": "",
                    "providerNetworkParticipation": {"providerTier": ""}
                }
            ]
        }
    
    def _generate_benefit_response(self, scenario: ScenarioConfig) -> Dict[str, Any]:
        """Generate benefit response JSON dynamically."""
        related_accumulators = []
        
        # Add accumulators based on scenario configuration
        if scenario.has_deductible_individual.lower() == "yes":
            related_accumulators.append({
                "code": "Deductible", "level": "Individual", "deductibleCode": "",
                "accumExCode": "L01", "networkIndicatorCode": "I"
            })

        if scenario.has_deductible_family.lower() == "yes":
            related_accumulators.append({
                "code": "Deductible", "level": "Family", "deductibleCode": "",
                "accumExCode": "L04", "networkIndicatorCode": "I"
            })

        if scenario.has_oopmax_individual.lower() == "yes":
            related_accumulators.append({
                "code": "OOPMAX", "level": "Individual", "deductibleCode": "",
                "accumExCode": "L03", "networkIndicatorCode": "I"
            })

        if scenario.has_oopmax_family.lower() == "yes":
            related_accumulators.append({
                "code": "OOPMAX", "level": "Family", "deductibleCode": "",
                "accumExCode": "L04", "networkIndicatorCode": "I"
            })

        if scenario.has_limit.lower() == "yes":
            related_accumulators.append({
                "code": "limit", "level": "Individual", "deductibleCode": "",
                "accumExCode": "L05", "networkIndicatorCode": "I"
            })
        
        # Use the same service codes that work for all scenarios to avoid matching issues
        service_code = "21137"
        place_of_service = "22"
        provider_type = "HO"
        specialty_code = ""
        
        return {
            "serviceInfo": [
                {
                    "serviceCodeInfo": [{"code": service_code, "type": "CPT4", "modifier": {}}],
                    "placeOfService": [{"code": place_of_service}],
                    "providerType": [{"code": provider_type}],
                    "providerSpecialty": [{"code": specialty_code}],
                    "benefit": [
                        {
                            "benefitName": "MEDICAL ANCILLARY",
                            "benefitCode": 1,
                            "isInitialBenefit": "Y",
                            "benefitTier": {"benefitTierName": ""},
                            "networkCategory": "InNetwork",
                            "prerequisites": [{"type": "precert", "isRequired": "N"}],
                            "benefitProvider": "",
                            "serviceProvider": [{}],
                            "coverages": [
                                {
                                    "sequenceNumber": 1,
                                    "benefitDescription": "MEDICAL ANCILLARY",
                                    "costShareCopay": scenario.cost_share_copay,
                                    "costShareCoinsurance": scenario.cost_share_coinsurance,
                                    "copayAppliesOutOfPocket": scenario.copay_applies_out_of_pocket,
                                    "coinsAppliesOutOfPocket": scenario.coins_applies_out_of_pocket,
                                    "deductibleAppliesOutOfPocket": scenario.deductible_applies_out_of_pocket,
                                    "deductibleAppliesOutOfPocketOtherIndicator": "",
                                    "copayCountToDeductibleIndicator": scenario.copay_count_to_deductible_indicator,
                                    "copayContinueWhenDeductibleMetIndicator": scenario.copay_continue_when_deductible_met_indicator,
                                    "copayContinueWhenOutOfPocketMaxMetIndicator": scenario.copay_continue_when_out_of_pocket_max_met_indicator,
                                    "coinsuranceToOutOfPocketOtherIndicator": "",
                                    "copayToOutofPocketOtherIndicator": "",
                                    "isDeductibleBeforeCopay": scenario.is_deductible_before_copay,
                                    "benefitLimitation": "",
                                    "isServiceCovered": scenario.is_service_covered,
                                    "relatedAccumulators": related_accumulators
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    
    def _generate_accumulator_response(self, scenario: ScenarioConfig) -> Dict[str, Any]:
        """Generate accumulator response JSON dynamically."""
        accumulators = []
        
        # Add accumulators based on scenario configuration
        if scenario.has_deductible_individual == "Yes":
            accumulators.append({
                "level": "Individual", "frequency": "Calendar Year", "relationshipToSubscriber": "W",
                "suffix": "799047", "benefitProductType": "Medical", "description": "Deductible",
                "currentValue": "0.00", "limitValue": "1000.00", "code": "Deductible",
                "effectivePeriod": {"datetimeBegin": "2025-01-01", "datetimeEnd": "2025-12-31"},
                "calculatedValue": scenario.di_calculated_value,
                "savingsLevel": "In Network", "networkIndicator": "InNetwork",
                "accumExCode": "L01", "networkIndicatorCode": "I"
            })
        
        if scenario.has_deductible_family == "Yes":
            accumulators.append({
                "level": "Family", "frequency": "Calendar Year", "relationshipToSubscriber": "W",
                "suffix": "799047", "benefitProductType": "Medical", "description": "Deductible",
                "currentValue": "0.00", "limitValue": "2000.00", "code": "Deductible",
                "effectivePeriod": {"datetimeBegin": "2025-01-01", "datetimeEnd": "2025-12-31"},
                "calculatedValue": scenario.df_calculated_value ,
                "savingsLevel": "In Network", "networkIndicator": "InNetwork",
                "accumExCode": "L04", "networkIndicatorCode": "I"
            })
        
        if scenario.has_oopmax_individual == "Yes":
            accumulators.append({
                "level": "Individual", "frequency": "Calendar Year", "relationshipToSubscriber": "W",
                "suffix": "799047", "benefitProductType": "Medical", "description": "OOPMAX",
                "currentValue": "0.00", "limitValue": "3000.00", "code": "OOPMAX",
                "effectivePeriod": {"datetimeBegin": "2025-01-01", "datetimeEnd": "2025-12-31"},
                "calculatedValue": scenario.oopmax_i_calculated_value or 0.0,
                "savingsLevel": "In Network", "networkIndicator": "InNetwork",
                "accumExCode": "L03", "networkIndicatorCode": "I"
            })
        
        if scenario.has_oopmax_family == "Yes":
            accumulators.append({
                "level": "Family", "frequency": "Calendar Year", "relationshipToSubscriber": "W",
                "suffix": "799047", "benefitProductType": "Medical", "description": "OOPMAX",
                "currentValue": "0.00", "limitValue": "9000.00", "code": "OOPMAX",
                "effectivePeriod": {"datetimeBegin": "2025-01-01", "datetimeEnd": "2025-12-31"},
                "calculatedValue": scenario.oopmax_f_calculated_value,
                "savingsLevel": "In Network", "networkIndicator": "InNetwork",
                "accumExCode": "L04", "networkIndicatorCode": "I"
            })
        
        if scenario.has_limit == "Yes":
            limit_accumulator = {
                "level": "Individual", "frequency": "Calendar Year", "relationshipToSubscriber": "W",
                "suffix": "799047", "benefitProductType": "Medical", "description": "limit",
                "currentValue": "0.00", "limitValue": "100.00", "code": "limit",
                "effectivePeriod": {"datetimeBegin": "2025-01-01", "datetimeEnd": "2025-12-31"},
                "calculatedValue": scenario.limit_calculated_value,
                "savingsLevel": "In Network", "networkIndicator": "InNetwork",
                "accumExCode": "L05", "networkIndicatorCode": "I"
            }
            
            if scenario.limit_type:
                limit_accumulator["limitType"] = scenario.limit_type
            
            accumulators.append(limit_accumulator)
        
        return {
            "readAccumulatorsResponse": {
                "memberships": {
                    "dependents": [
                        {
                            "privacyRestriction": "false",
                            "membershipIdentifier": {
                                "idSource": "5",
                                "idValue": "265646860+10+725+20250101+799047+BA+42",
                                "idType": "memberships",
                                "resourceId": "5~265646860+10+725+20250101+799047+BA+42"
                            },
                            "accumulators": accumulators
                        }
                    ]
                }
            }
        }
    
    
    def _make_api_call(self, cost_request_data: Dict[str, Any], scenario: ScenarioConfig) -> Dict[str, Any]:
        """Make API call with mocked services and return response."""
        from unittest.mock import patch
        from app.models.rate_criteria import NegotiatedRate
        from app.schemas.benefit_response import BenefitApiResponse
        from app.schemas.accumulator_response import AccumulatorResponse

        cost_request = self._generate_cost_request(scenario)

        # Generate mock data
        benefit_response = self._generate_benefit_response(scenario)
        accumulator_response = self._generate_accumulator_response(scenario)
        
        # Build mock services
        benefit_api_response = BenefitApiResponse(**benefit_response)
        accumulator_api_response = AccumulatorResponse(**accumulator_response)

        # Mock external services
        with patch('app.services.impl.benefit_service_impl.BenefitServiceImpl.get_benefit') as mock_benefit, \
             patch('app.services.impl.accumulator_service_impl.AccumulatorServiceImpl.get_accumulator') as mock_accumulator, \
             patch('app.repository.impl.cost_estimator_repository_impl.CostEstimatorRepositoryImpl.get_rate') as mock_rate, \
             patch('app.core.session_manager.SessionManager.get_token') as mock_token:
            
            # Configure mocks
            mock_token.return_value = "mock_token"
            mock_benefit.return_value = benefit_api_response
            mock_accumulator.return_value = accumulator_response
            mock_rate.return_value = NegotiatedRate(
                paymentMethod="AMT",
                rate=scenario.service_amount,
                rateType="AMOUNT",
                isRateFound=True,
                isProviderInfoFound=True,
            )
            
            # Make API call
            client = TestClient(app)
            headers = {
                "Content-Type": "application/json",
                "x-global-transaction-id": f"oopmax-{scenario.sr_no}",
                "x-clientrefid": f"oopmax-client-{scenario.sr_no}",
            }
        
        response = client.post("/costestimator/v1/rate", json=cost_request, headers=headers)

        self.save_generated_data(scenario, cost_request, benefit_api_response, accumulator_api_response, response.json())

        if response.status_code != 200:
            raise AssertionError(f"API call failed with status {response.status_code}: {response.text}")
        
        return response.json()
    
    
    def _validate_scenario_response(self, response: Dict[str, Any], scenario: ScenarioConfig):
        """Validate API response against scenario expectations."""
        # Extract response info
        info_list = response["costEstimateResponse"]["costEstimateResponseInfo"]
        assert len(info_list) == 1, f"Expected 1 response info, got {len(info_list)}"
        info = info_list[0]
        
        # Validate basic coverage
        assert info["coverage"]["isServiceCovered"] == scenario.is_service_covered 
        assert info["coverage"]["costShareCopay"] == scenario.cost_share_copay
        assert info["coverage"]["costShareCoinsurance"] == scenario.cost_share_coinsurance
        assert info["cost"]["inNetworkCosts"] == scenario.service_amount
        
        # Validate accumulators presence
        accumulators = info.get("accumulators", [])
        codes = {(a["accumulator"]["code"], a["accumulator"]["level"]) for a in accumulators}
        
        # Check if OOPMAX is met (member pays 0) - if so, OOPMAX accumulators won't be in response
        oopmax_met = scenario.expected_member_pays == 0.0 and scenario.has_oopmax_individual == "Yes" or scenario.has_oopmax_family == "Yes"
        
        if scenario.has_deductible_individual == "Yes":
            assert ("Deductible", "Individual") in codes, "Deductible Individual should be present"
        if scenario.has_deductible_family == "Yes":
            assert ("Deductible", "Family") in codes, "Deductible Family should be present"
        if scenario.has_oopmax_individual == "Yes" and not oopmax_met:
            assert ("OOPMAX", "Individual") in codes, "OOPMAX Individual should be present"
        if scenario.has_oopmax_family == "Yes" and not oopmax_met:
            assert ("OOPMAX", "Family") in codes, "OOPMAX Family should be present"
        if scenario.has_limit == "Yes":
            assert ("limit", "Individual") in codes, "Limit Individual should be present"
        
        # Validate calculated values
        for a in accumulators:
            code = a["accumulator"]["code"].lower()
            level = a["accumulator"]["level"].lower()
            calculated_value = a["accumulator"]["calculatedValue"]
            
            if code == "deductible" and level == "individual" and scenario.di_calculated_value is not None:
                assert calculated_value == scenario.di_calculated_value, f"Deductible Individual calculatedValue should be {scenario.di_calculated_value}, got {calculated_value}"
            elif code == "deductible" and level == "family" and scenario.df_calculated_value is not None:
                assert calculated_value == scenario.df_calculated_value, f"Deductible Family calculatedValue should be {scenario.df_calculated_value}, got {calculated_value}"
            elif code == "oop max" and level == "individual" and scenario.oopmax_i_calculated_value is not None:
                assert calculated_value == scenario.oopmax_i_calculated_value, f"OOPMAX Individual calculatedValue should be {scenario.oopmax_i_calculated_value}, got {calculated_value}"
            elif code == "oop max" and level == "family" and scenario.oopmax_f_calculated_value is not None:
                assert calculated_value == scenario.oopmax_f_calculated_value, f"OOPMAX Family calculatedValue should be {scenario.oopmax_f_calculated_value}, got {calculated_value}"
            elif code == "limit" and level == "individual" and scenario.limit_calculated_value is not None:
                assert calculated_value == scenario.limit_calculated_value, f"Limit Individual calculatedValue should be {scenario.limit_calculated_value}, got {calculated_value}"
        
        # Validate health claim line
        health_claim_line = info.get("healthClaimLine", {})
        assert health_claim_line.get("amountResponsibility") == scenario.expected_member_pays, f"Expected member pays {scenario.expected_member_pays}, got {health_claim_line.get('amountResponsibility')}"
        
        print(f"\nScenario {scenario.sr_no}: {scenario.scenario_name}")
        print(f"   Expected Member Pays: {scenario.expected_member_pays}")
        print(f"   Actual Member Pays: {health_claim_line.get('amountResponsibility')}")
        print(f"   Logic: {scenario.logic}")
    
    def run_scenario_test(self, scenario: ScenarioConfig):
        """Run a single scenario test."""
        # Make API call
        response = self._make_api_call(scenario)

        # Validate response
        self._validate_scenario_response(response, scenario)

    def save_generated_data(self, scenario: ScenarioConfig, cost_request, benefit_response, accumulator_response, cost_response, output_dir: str = "tests/generated_oopmax_data"):
        """Save generated test data to JSON files (optional)."""
        
        # Create output directory
        output_path = Path(output_dir) / f"scenario_{scenario.sr_no.replace('.', '_')}"
        output_path.mkdir(parents=True, exist_ok=True)
        
        # Save individual files
        with open(output_path / "cost_request.json", 'w') as f:
            json.dump(cost_request, f, indent=2)
        
        with open(output_path / "benefit_response.json", 'w') as f:
            json.dump(benefit_response, f, indent=2)
        
        with open(output_path / "accumulator_response.json", 'w') as f:
            json.dump(accumulator_response, f, indent=2)
        
        with open(output_path / "cost_response.json", 'w') as f:
            json.dump(cost_response, f, indent=2)
        
        print(f"Generated test data saved to: {output_path}")
        return cost_request, benefit_response, accumulator_response, cost_response


# Initialize framework
framework = UnifiedDynamicOOPMAXFramework()


# Generate test functions dynamically
def create_test_function(scenario: ScenarioConfig):
    """Create a test function for a scenario."""
    def test_function():
        framework.run_scenario_test(scenario)
    
    # Set function name and docstring
    test_function.__name__ = f"test_scenario_{scenario.sr_no.replace('.', '_')}_{scenario.scenario_name.lower().replace(' ', '_').replace(',', '').replace('(', '').replace(')', '')}"
    test_function.__doc__ = f"Test Scenario {scenario.sr_no}: {scenario.scenario_name}"
    
    return test_function


# Dynamically create test functions for all scenarios
for scenario in framework.scenarios:
    test_func = create_test_function(scenario)
    # Add the test function to the current module
    globals()[test_func.__name__] = test_func


# Utility functions
def generate_all_test_data():
    """Generate test data for all scenarios from CSV."""
    print("Generating test data for all OOPMAX scenarios from CSV...")
    
    for scenario in framework.scenarios:
        print(f"\nProcessing Scenario {scenario.sr_no}: {scenario.scenario_name}")
        print(f"   Expected Member Pays: {scenario.expected_member_pays}")
        print(f"   Service Amount: {scenario.service_amount}")
        print(f"   Logic: {scenario.logic}")
        
        # Generate and save test data
        framework.save_generated_data(scenario)
        
        print(f"Generated: cost_request.json, benefit_response.json, accumulator_response.json, cost_response.json")


def run_all_scenarios():
    """Run all OOPMAX scenarios dynamically from CSV."""
    print("Running all OOPMAX scenarios dynamically from CSV...")
    
    for scenario in framework.scenarios:
        print(f"\nRunning Scenario {scenario.sr_no}: {scenario.scenario_name}")
        framework.run_scenario_test(scenario)
        print(f"Scenario {scenario.sr_no} passed!")


# Test functions
@pytest.mark.asyncio
async def test_generate_all_scenarios():
    """Generate test data for all scenarios from CSV."""
    generate_all_test_data()


@pytest.mark.asyncio
async def test_all_oopmax_scenarios_unified():
    """Run all OOPMAX scenarios dynamically from CSV."""
    run_all_scenarios()


# Individual scenario tests are automatically created above
# You can run them individually or all together
