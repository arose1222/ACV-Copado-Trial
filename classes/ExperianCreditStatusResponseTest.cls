@IsTest
public class ExperianCreditStatusResponseTest {
	
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
		'    \"combinedTradelineCount\": 0,'+
		'    \"combinedAccountBalance\": 0,'+
		'    \"currentDbt\": 0,'+
		'    \"combinedRecentHighCreditAmount\": 0,'+
		'    \"yearsOnFile\": 0,'+
		'    \"inquiryCount\": 0'+
		'  }'+
		'}';
		ExperianCreditStatusResponse r = ExperianCreditStatusResponse.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianCreditStatusResponse.MatchingBranchAddress objMatchingBranchAddress = new ExperianCreditStatusResponse.MatchingBranchAddress(System.JSON.createParser(json));
		System.assert(objMatchingBranchAddress != null);
		System.assert(objMatchingBranchAddress.bin == null);
		System.assert(objMatchingBranchAddress.street == null);
		System.assert(objMatchingBranchAddress.city == null);
		System.assert(objMatchingBranchAddress.state == null);
		System.assert(objMatchingBranchAddress.zip == null);
		System.assert(objMatchingBranchAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianCreditStatusResponse.Address objAddress = new ExperianCreditStatusResponse.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.street == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.zip == null);
		System.assert(objAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianCreditStatusResponse.Results objResults = new ExperianCreditStatusResponse.Results(System.JSON.createParser(json));
		System.assert(objResults != null);
		System.assert(objResults.businessHeader == null);
		System.assert(objResults.combinedTradelineCount == null);
		System.assert(objResults.combinedAccountBalance == null);
		System.assert(objResults.currentDbt == null);
		System.assert(objResults.combinedRecentHighCreditAmount == null);
		System.assert(objResults.yearsOnFile == null);
		System.assert(objResults.inquiryCount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianCreditStatusResponse.BusinessHeader objBusinessHeader = new ExperianCreditStatusResponse.BusinessHeader(System.JSON.createParser(json));
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
		ExperianCreditStatusResponse objExperianCreditStatusResponse = new ExperianCreditStatusResponse(System.JSON.createParser(json));
		System.assert(objExperianCreditStatusResponse != null);
		System.assert(objExperianCreditStatusResponse.requestId == null);
		System.assert(objExperianCreditStatusResponse.success == null);
		System.assert(objExperianCreditStatusResponse.comments == null);
		System.assert(objExperianCreditStatusResponse.results == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianCreditStatusResponse.BranchLocation objBranchLocation = new ExperianCreditStatusResponse.BranchLocation(System.JSON.createParser(json));
		System.assert(objBranchLocation != null);
		System.assert(objBranchLocation.bin == null);
		System.assert(objBranchLocation.locationId == null);
	}
}