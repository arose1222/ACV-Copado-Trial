@IsTest
public class ExperianBusinessSearchResponseTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"requestId\": \"ec55cca0-9342-11e7-bddf-ebd4476c3102\",'+
		'  \"responseMessage\": \"Your search did not match any records. Suggestions try adding optional fields like street address and phone to your search, check your spelling, and remember, the absence of a match can be valuable information.\",'+
		'  \"comments\": \"my_guid_for_tracking\",'+
		'  \"success\": true,'+
		'  \"results\": ['+
		'    {'+
		'      \"bin\": \"800914632\",'+
		'      \"reliabilityCode\": 91.02,'+
		'      \"businessName\": \"EXPERIAN\",'+
		'      \"phone\": \"+17148307000\",'+
		'      \"address\": {'+
		'        \"street\": \"535 ANTON BLVD\",'+
		'        \"city\": \"Costa Mesa\",'+
		'        \"state\": \"CA\",'+
		'        \"zip\": \"92626\",'+
		'        \"zipExtension\": \"9262\"'+
		'      },'+
		'      \"numberOfTradelines\": 62,'+
		'      \"financialStatementIndicator\": true,'+
		'      \"keyFactsIndicator\": true,'+
		'      \"inquiryIndicator\": true,'+
		'      \"bankDataIndicator\": true,'+
		'      \"governmentDataIndicator\": true,'+
		'      \"executiveSummaryIndicator\": true,'+
		'      \"uccIndicator\": true,'+
		'      \"matchingNameAndAddress\": {'+
		'        \"businessName\": \"EXPERIAN\",'+
		'        \"address\": {'+
		'          \"street\": \"535 ANTON BLVD\",'+
		'          \"city\": \"Costa Mesa\",'+
		'          \"state\": \"CA\",'+
		'          \"zip\": \"92626\",'+
		'          \"zipExtension\": \"9262\"'+
		'        }'+
		'      },'+
		'      \"businessGeocode\": {'+
		'        \"latitudeLongitudeLevel\": \"Roof Top Level\",'+
		'        \"latitude\": 33.690764,'+
		'        \"longitude\": -117.873551,'+
		'        \"msaCode\": \"5945\",'+
		'        \"censusBlkGrpCode\": \"2\",'+
		'        \"censusTractCode\": \"063907\",'+
		'        \"cottageIndicator\": true,'+
		'        \"congressionalDistrictCode\": \"48\",'+
		'        \"dateLastReported\": \"01/01/1977\"'+
		'      }'+
		'    }'+
		'  ]'+
		'}';
		ExperianBusinessSearchResponse r = ExperianBusinessSearchResponse.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessSearchResponse.MatchingNameAndAddress objMatchingNameAndAddress = new ExperianBusinessSearchResponse.MatchingNameAndAddress(System.JSON.createParser(json));
		System.assert(objMatchingNameAndAddress != null);
		System.assert(objMatchingNameAndAddress.businessName == null);
		System.assert(objMatchingNameAndAddress.address == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessSearchResponse.Address objAddress = new ExperianBusinessSearchResponse.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.street == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.zip == null);
		System.assert(objAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessSearchResponse.Results objResults = new ExperianBusinessSearchResponse.Results(System.JSON.createParser(json));
		System.assert(objResults != null);
		System.assert(objResults.bin == null);
		System.assert(objResults.reliabilityCode == null);
		System.assert(objResults.businessName == null);
		System.assert(objResults.phone == null);
		System.assert(objResults.address == null);
		System.assert(objResults.numberOfTradelines == null);
		System.assert(objResults.financialStatementIndicator == null);
		System.assert(objResults.keyFactsIndicator == null);
		System.assert(objResults.inquiryIndicator == null);
		System.assert(objResults.bankDataIndicator == null);
		System.assert(objResults.governmentDataIndicator == null);
		System.assert(objResults.executiveSummaryIndicator == null);
		System.assert(objResults.uccIndicator == null);
		System.assert(objResults.matchingNameAndAddress == null);
		System.assert(objResults.businessGeocode == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessSearchResponse objExperianBusinessSearchResponse = new ExperianBusinessSearchResponse(System.JSON.createParser(json));
		System.assert(objExperianBusinessSearchResponse != null);
		System.assert(objExperianBusinessSearchResponse.requestId == null);
		System.assert(objExperianBusinessSearchResponse.responseMessage == null);
		System.assert(objExperianBusinessSearchResponse.comments == null);
		System.assert(objExperianBusinessSearchResponse.success == null);
		System.assert(objExperianBusinessSearchResponse.results == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessSearchResponse.BusinessGeocode objBusinessGeocode = new ExperianBusinessSearchResponse.BusinessGeocode(System.JSON.createParser(json));
		System.assert(objBusinessGeocode != null);
		System.assert(objBusinessGeocode.latitudeLongitudeLevel == null);
		System.assert(objBusinessGeocode.latitude == null);
		System.assert(objBusinessGeocode.longitude == null);
		System.assert(objBusinessGeocode.msaCode == null);
		System.assert(objBusinessGeocode.censusBlkGrpCode == null);
		System.assert(objBusinessGeocode.censusTractCode == null);
		System.assert(objBusinessGeocode.cottageIndicator == null);
		System.assert(objBusinessGeocode.congressionalDistrictCode == null);
		System.assert(objBusinessGeocode.dateLastReported == null);
	}
}