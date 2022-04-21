@IsTest
public class ExperianScoreResponseTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"requestId\": \"ec55cca0-9342-11e7-bddf-ebd4476c3102\",'+
		'  \"success\": true,'+
		'  \"comments\": \"abcde12345\",'+
		'  \"results\": {'+
		'    \"businessHeader\": {'+
		'      \"bin\": \"800914632\",'+
		'      \"businessName\": \"EXPERIAN CONSUMER DIRECT\",'+
		'      \"address\": {'+
		'        \"street\": \"535 ANTON BLVD\",'+
		'        \"city\": \"Costa Mesa\",'+
		'        \"state\": \"CA\",'+
		'        \"zip\": \"92626\",'+
		'        \"zipExtension\": \"1947\"'+
		'      },'+
		'      \"phone\": \"+19495673800\",'+
		'      \"taxId\": \"176970333\",'+
		'      \"websiteUrl\": \"consumerinfo.com\",'+
		'      \"legalBusinessName\": \"EXPERIAN CONSUMER DIRECT\",'+
		'      \"dbaNames\": ['+
		'        \"EXPERIAN CONSUMER DIRECT\"'+
		'      ],'+
		'      \"customerDisputeIndicator\": true,'+
		'      \"foreignCountry\": true,'+
		'      \"corporateLinkageIndicator\": true,'+
		'      \"matchingBranchAddress\": {'+
		'        \"bin\": \"800914632\",'+
		'        \"street\": \"475 ANTON BLVD\",'+
		'        \"city\": \"Costa Mesa\",'+
		'        \"state\": \"CA\",'+
		'        \"zip\": \"92626\",'+
		'        \"zipExtension\": \"1947\"'+
		'      },'+
		'      \"branchLocation\": {'+
		'        \"bin\": \"800914632\",'+
		'        \"locationId\": \"475 ANTON BLVD\"'+
		'      }'+
		'    },'+
		'    \"commercialScore\": {'+
		'      \"modelCode\": \"000254\",'+
		'      \"modelTitle\": \"INTELLISCORE PLUS V3 ML\",'+
		'      \"customModelCode\": \"02\",'+
		'      \"score\": 11,'+
		'      \"percentileRanking\": 10,'+
		'      \"recommendedCreditLimitAmount\": 206400,'+
		'      \"riskClass\": {'+
		'        \"code\": 4,'+
		'        \"definition\": \"MEDIUM TO HIGH RISK\"'+
		'      }'+
		'    },'+
		'    \"commercialScoreFactors\": ['+
		'      {'+
		'        \"code\": \"033\",'+
		'        \"definition\": \"NUMBER OF COMMERCIAL ACCOUNTS THAT ARE CURRENT\"'+
		'      }'+
		'    ],'+
		'    \"commercialScoreTrends\": ['+
		'      {'+
		'        \"quarter\": \"DEC-FEB\",'+
		'        \"score\": 8'+
		'      }'+
		'    ],'+
		'    \"fsrScore\": {'+
		'      \"modelCode\": \"string\",'+
		'      \"modelTitle\": \"string\",'+
		'      \"score\": 0,'+
		'      \"percentileRanking\": 0,'+
		'      \"recommendedCreditLimitAmount\": 206400,'+
		'      \"riskClass\": {'+
		'        \"code\": 1,'+
		'        \"definition\": \"Low Risk\"'+
		'      }'+
		'    },'+
		'    \"fsrScoreFactors\": ['+
		'      {'+
		'        \"code\": \"string\",'+
		'        \"definition\": \"string\"'+
		'      }'+
		'    ],'+
		'    \"fsrScoreTrends\": ['+
		'      {'+
		'        \"quarter\": \"string\",'+
		'        \"score\": 0'+
		'      }'+
		'    ],'+
		'    \"collectionScore\": {'+
		'      \"modelCode\": \"000243\",'+
		'      \"modelTitle\": \"COMMERCIAL RECOVERY SCORE LR\",'+
		'      \"score\": 669,'+
		'      \"percentileRanking\": 99,'+
		'      \"riskClass\": {'+
		'        \"code\": 1,'+
		'        \"definition\": \"HIGH RECOVERY ODDS\"'+
		'      }'+
		'    }'+
		'  }'+
		'}';
		ExperianScoreResponse r = ExperianScoreResponse.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.MatchingBranchAddress objMatchingBranchAddress = new ExperianScoreResponse.MatchingBranchAddress(System.JSON.createParser(json));
		System.assert(objMatchingBranchAddress != null);
		System.assert(objMatchingBranchAddress.bin == null);
		System.assert(objMatchingBranchAddress.street == null);
		System.assert(objMatchingBranchAddress.city == null);
		System.assert(objMatchingBranchAddress.state == null);
		System.assert(objMatchingBranchAddress.zip == null);
		System.assert(objMatchingBranchAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse objExperianScoreResponse = new ExperianScoreResponse(System.JSON.createParser(json));
		System.assert(objExperianScoreResponse != null);
		System.assert(objExperianScoreResponse.requestId == null);
		System.assert(objExperianScoreResponse.success == null);
		System.assert(objExperianScoreResponse.comments == null);
		System.assert(objExperianScoreResponse.results == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.CollectionScore objCollectionScore = new ExperianScoreResponse.CollectionScore(System.JSON.createParser(json));
		System.assert(objCollectionScore != null);
		System.assert(objCollectionScore.modelCode == null);
		System.assert(objCollectionScore.modelTitle == null);
		System.assert(objCollectionScore.score == null);
		System.assert(objCollectionScore.percentileRanking == null);
		System.assert(objCollectionScore.riskClass == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.Address objAddress = new ExperianScoreResponse.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.street == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.zip == null);
		System.assert(objAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.RiskClass objRiskClass = new ExperianScoreResponse.RiskClass(System.JSON.createParser(json));
		System.assert(objRiskClass != null);
		System.assert(objRiskClass.code == null);
		System.assert(objRiskClass.definition == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.CommercialScore objCommercialScore = new ExperianScoreResponse.CommercialScore(System.JSON.createParser(json));
		System.assert(objCommercialScore != null);
		System.assert(objCommercialScore.modelCode == null);
		System.assert(objCommercialScore.modelTitle == null);
		System.assert(objCommercialScore.customModelCode == null);
		System.assert(objCommercialScore.score == null);
		System.assert(objCommercialScore.percentileRanking == null);
		System.assert(objCommercialScore.recommendedCreditLimitAmount == null);
		System.assert(objCommercialScore.riskClass == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.Results objResults = new ExperianScoreResponse.Results(System.JSON.createParser(json));
		System.assert(objResults != null);
		System.assert(objResults.businessHeader == null);
		System.assert(objResults.commercialScore == null);
		System.assert(objResults.commercialScoreFactors == null);
		System.assert(objResults.commercialScoreTrends == null);
		System.assert(objResults.fsrScore == null);
		System.assert(objResults.fsrScoreFactors == null);
		System.assert(objResults.fsrScoreTrends == null);
		System.assert(objResults.collectionScore == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.CommercialScoreFactors objCommercialScoreFactors = new ExperianScoreResponse.CommercialScoreFactors(System.JSON.createParser(json));
		System.assert(objCommercialScoreFactors != null);
		System.assert(objCommercialScoreFactors.code == null);
		System.assert(objCommercialScoreFactors.definition == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.FsrScore objFsrScore = new ExperianScoreResponse.FsrScore(System.JSON.createParser(json));
		System.assert(objFsrScore != null);
		System.assert(objFsrScore.modelCode == null);
		System.assert(objFsrScore.modelTitle == null);
		System.assert(objFsrScore.score == null);
		System.assert(objFsrScore.percentileRanking == null);
		System.assert(objFsrScore.recommendedCreditLimitAmount == null);
		System.assert(objFsrScore.riskClass == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.BusinessHeader objBusinessHeader = new ExperianScoreResponse.BusinessHeader(System.JSON.createParser(json));
		System.assert(objBusinessHeader != null);
		System.assert(objBusinessHeader.bin == null);
		System.assert(objBusinessHeader.businessName == null);
		System.assert(objBusinessHeader.address == null);
		System.assert(objBusinessHeader.phone == null);
		System.assert(objBusinessHeader.taxId == null);
		System.assert(objBusinessHeader.websiteUrl == null);
		System.assert(objBusinessHeader.legalBusinessName == null);
		System.assert(objBusinessHeader.dbaNames == null);
		System.assert(objBusinessHeader.customerDisputeIndicator == null);
		System.assert(objBusinessHeader.foreignCountry == null);
		System.assert(objBusinessHeader.corporateLinkageIndicator == null);
		System.assert(objBusinessHeader.matchingBranchAddress == null);
		System.assert(objBusinessHeader.branchLocation == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.BranchLocation objBranchLocation = new ExperianScoreResponse.BranchLocation(System.JSON.createParser(json));
		System.assert(objBranchLocation != null);
		System.assert(objBranchLocation.bin == null);
		System.assert(objBranchLocation.locationId == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianScoreResponse.CommercialScoreTrends objCommercialScoreTrends = new ExperianScoreResponse.CommercialScoreTrends(System.JSON.createParser(json));
		System.assert(objCommercialScoreTrends != null);
		System.assert(objCommercialScoreTrends.quarter == null);
		System.assert(objCommercialScoreTrends.score == null);
	}
}