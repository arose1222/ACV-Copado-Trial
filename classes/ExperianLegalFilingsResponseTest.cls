@IsTest
public class ExperianLegalFilingsResponseTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"requestId\": \"ec55cca0-9342-11e7-bddf-ebd4476c3102\",'+
		'  \"success\": true,'+
		'  \"comments\": \"testing\",'+
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
		'    \"legalFilingsSummary\": {'+
		'      \"legalCount\": 24,'+
		'      \"legalBalance\": 6500,'+
		'      \"derogatoryLegalCount\": 8'+
		'    },'+
		'    \"legalFilingsCollectionsSummary\": {'+
		'      \"legalCount\": 24,'+
		'      \"legalBalance\": 6500,'+
		'      \"derogatoryLegalCount\": 8,'+
		'      \"bankruptcyIndicator\": true,'+
		'      \"bankruptcyCount\": 1,'+
		'      \"lienCount\": 1143,'+
		'      \"lienBalance\": 353,'+
		'      \"judgmentCount\": 5,'+
		'      \"judgmentBalance\": 12500,'+
		'      \"uccFilingsCount\": 11,'+
		'      \"uccDerogatoryCount\": 8,'+
		'      \"collectionCount\": 12,'+
		'      \"collectionBalance\": 55799'+
		'    }'+
		'  }'+
		'}';
		ExperianLegalFilingsResponse r = ExperianLegalFilingsResponse.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse.MatchingBranchAddress objMatchingBranchAddress = new ExperianLegalFilingsResponse.MatchingBranchAddress(System.JSON.createParser(json));
		System.assert(objMatchingBranchAddress != null);
		System.assert(objMatchingBranchAddress.bin == null);
		System.assert(objMatchingBranchAddress.street == null);
		System.assert(objMatchingBranchAddress.city == null);
		System.assert(objMatchingBranchAddress.state == null);
		System.assert(objMatchingBranchAddress.zip == null);
		System.assert(objMatchingBranchAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse.Address objAddress = new ExperianLegalFilingsResponse.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.street == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.zip == null);
		System.assert(objAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse.LegalFilingsSummary objLegalFilingsSummary = new ExperianLegalFilingsResponse.LegalFilingsSummary(System.JSON.createParser(json));
		System.assert(objLegalFilingsSummary != null);
		System.assert(objLegalFilingsSummary.legalCount == null);
		System.assert(objLegalFilingsSummary.legalBalance == null);
		System.assert(objLegalFilingsSummary.derogatoryLegalCount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse.LegalFilingsCollectionsSummary objLegalFilingsCollectionsSummary = new ExperianLegalFilingsResponse.LegalFilingsCollectionsSummary(System.JSON.createParser(json));
		System.assert(objLegalFilingsCollectionsSummary != null);
		System.assert(objLegalFilingsCollectionsSummary.legalCount == null);
		System.assert(objLegalFilingsCollectionsSummary.legalBalance == null);
		System.assert(objLegalFilingsCollectionsSummary.derogatoryLegalCount == null);
		System.assert(objLegalFilingsCollectionsSummary.bankruptcyIndicator == null);
		System.assert(objLegalFilingsCollectionsSummary.bankruptcyCount == null);
		System.assert(objLegalFilingsCollectionsSummary.lienCount == null);
		System.assert(objLegalFilingsCollectionsSummary.lienBalance == null);
		System.assert(objLegalFilingsCollectionsSummary.judgmentCount == null);
		System.assert(objLegalFilingsCollectionsSummary.judgmentBalance == null);
		System.assert(objLegalFilingsCollectionsSummary.uccFilingsCount == null);
		System.assert(objLegalFilingsCollectionsSummary.uccDerogatoryCount == null);
		System.assert(objLegalFilingsCollectionsSummary.collectionCount == null);
		System.assert(objLegalFilingsCollectionsSummary.collectionBalance == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse.Results objResults = new ExperianLegalFilingsResponse.Results(System.JSON.createParser(json));
		System.assert(objResults != null);
		System.assert(objResults.businessHeader == null);
		System.assert(objResults.legalFilingsSummary == null);
		System.assert(objResults.legalFilingsCollectionsSummary == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse.BusinessHeader objBusinessHeader = new ExperianLegalFilingsResponse.BusinessHeader(System.JSON.createParser(json));
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
		ExperianLegalFilingsResponse.BranchLocation objBranchLocation = new ExperianLegalFilingsResponse.BranchLocation(System.JSON.createParser(json));
		System.assert(objBranchLocation != null);
		System.assert(objBranchLocation.bin == null);
		System.assert(objBranchLocation.locationId == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianLegalFilingsResponse objExperianLegalFilingsResponse = new ExperianLegalFilingsResponse(System.JSON.createParser(json));
		System.assert(objExperianLegalFilingsResponse != null);
		System.assert(objExperianLegalFilingsResponse.requestId == null);
		System.assert(objExperianLegalFilingsResponse.success == null);
		System.assert(objExperianLegalFilingsResponse.comments == null);
		System.assert(objExperianLegalFilingsResponse.results == null);
	}
}