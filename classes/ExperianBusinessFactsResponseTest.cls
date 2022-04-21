@IsTest
public class ExperianBusinessFactsResponseTest {
	
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
		'    \"sicCodes\": ['+
		'      {'+
		'        \"code\": \"7323\",'+
		'        \"definition\": \"CREDIT REPORTING SERVICES\"'+
		'      }'+
		'    ],'+
		'    \"naicsCodes\": ['+
		'      {'+
		'        \"code\": \"561450\",'+
		'        \"definition\": \"Credit Bureaus\"'+
		'      }'+
		'    ],'+
		'    \"publicIndicator\": true,'+
		'    \"tickerSymbol\": \"EXP\",'+
		'    \"stockExchange\": \"Experian Consumer Direct, Inc.\",'+
		'    \"nonProfitIndicator\": true,'+
		'    \"yearsOnFile\": 21,'+
		'    \"stateOfIncorporation\": \"MA\",'+
		'    \"dateOfIncorporation\": \"01/01/1996\",'+
		'    \"businessType\": \"Corporation\",'+
		'    \"employeeSize\": 13456,'+
		'    \"employeeSizeCode\": \"A\",'+
		'    \"salesRevenue\": 130311000,'+
		'    \"salesSizeCode\": \"B\",'+
		'    \"fortune1000\": {'+
		'      \"year\": 0,'+
		'      \"rank\": 0'+
		'    },'+
		'    \"corporateLinkageType\": \"Headquarters/Parent\",'+
		'    \"executiveInformation\": ['+
		'      {'+
		'        \"firstName\": \"Mike\",'+
		'        \"middleName\": \"J\",'+
		'        \"lastName\": \"Dean\",'+
		'        \"title\": \"President\"'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		ExperianBusinessFactsResponse r = ExperianBusinessFactsResponse.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.ExecutiveInformation objExecutiveInformation = new ExperianBusinessFactsResponse.ExecutiveInformation(System.JSON.createParser(json));
		System.assert(objExecutiveInformation != null);
		System.assert(objExecutiveInformation.firstName == null);
		System.assert(objExecutiveInformation.middleName == null);
		System.assert(objExecutiveInformation.lastName == null);
		System.assert(objExecutiveInformation.title == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.MatchingBranchAddress objMatchingBranchAddress = new ExperianBusinessFactsResponse.MatchingBranchAddress(System.JSON.createParser(json));
		System.assert(objMatchingBranchAddress != null);
		System.assert(objMatchingBranchAddress.bin == null);
		System.assert(objMatchingBranchAddress.street == null);
		System.assert(objMatchingBranchAddress.city == null);
		System.assert(objMatchingBranchAddress.state == null);
		System.assert(objMatchingBranchAddress.zip == null);
		System.assert(objMatchingBranchAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse objExperianBusinessFactsResponse = new ExperianBusinessFactsResponse(System.JSON.createParser(json));
		System.assert(objExperianBusinessFactsResponse != null);
		System.assert(objExperianBusinessFactsResponse.requestId == null);
		System.assert(objExperianBusinessFactsResponse.success == null);
		System.assert(objExperianBusinessFactsResponse.comments == null);
		System.assert(objExperianBusinessFactsResponse.results == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.Address objAddress = new ExperianBusinessFactsResponse.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.street == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.zip == null);
		System.assert(objAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.Results objResults = new ExperianBusinessFactsResponse.Results(System.JSON.createParser(json));
		System.assert(objResults != null);
		System.assert(objResults.businessHeader == null);
		System.assert(objResults.sicCodes == null);
		System.assert(objResults.naicsCodes == null);
		System.assert(objResults.publicIndicator == null);
		System.assert(objResults.tickerSymbol == null);
		System.assert(objResults.stockExchange == null);
		System.assert(objResults.nonProfitIndicator == null);
		System.assert(objResults.yearsOnFile == null);
		System.assert(objResults.stateOfIncorporation == null);
		System.assert(objResults.dateOfIncorporation == null);
		System.assert(objResults.businessType == null);
		System.assert(objResults.employeeSize == null);
		System.assert(objResults.employeeSizeCode == null);
		System.assert(objResults.salesRevenue == null);
		System.assert(objResults.salesSizeCode == null);
		System.assert(objResults.fortune1000 == null);
		System.assert(objResults.corporateLinkageType == null);
		System.assert(objResults.executiveInformation == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.Fortune1000 objFortune1000 = new ExperianBusinessFactsResponse.Fortune1000(System.JSON.createParser(json));
		System.assert(objFortune1000 != null);
		System.assert(objFortune1000.year == null);
		System.assert(objFortune1000.rank == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.SicCodes objSicCodes = new ExperianBusinessFactsResponse.SicCodes(System.JSON.createParser(json));
		System.assert(objSicCodes != null);
		System.assert(objSicCodes.code == null);
		System.assert(objSicCodes.definition == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianBusinessFactsResponse.BusinessHeader objBusinessHeader = new ExperianBusinessFactsResponse.BusinessHeader(System.JSON.createParser(json));
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
		ExperianBusinessFactsResponse.BranchLocation objBranchLocation = new ExperianBusinessFactsResponse.BranchLocation(System.JSON.createParser(json));
		System.assert(objBranchLocation != null);
		System.assert(objBranchLocation.bin == null);
		System.assert(objBranchLocation.locationId == null);
	}
    
    static testMethod void testParse2() {
        String json = '{\"requestId\":\"rrt-0a2ee6ffd98db449b-d-ea-22770-11192458-3\",\"success\":true,\"results\":{\"businessHeader\":{\"bin\":\"701502218\",\"businessName\":\"US POSTAL SERVICE\",\"address\":{\"street\":\"60 SUGARLOAF ST\",\"city\":\"S DEERFIELD\",\"state\":\"MA\",\"zip\":\"01373\",\"zipExtension\":\"1100\"},\"phone\":\"+1202268293056015\",\"websiteUrl\":\"www.usps.com\",\"legalBusinessName\":null,\"dbaNames\":[\"MISSION CREEK POSTAL CENTER\",\"EXECUTIVE OFFICE SERVICES\",\"USPO - THE GALLERIA\",\"USP ST. LOUIS CBO\",\"USPS P&D\",\"POSTAL PLUS BUSINESS CENTER\",\"PINE MOUNTAIN POSTAL STATION\",\"OLD TOWN AUBURN ANTIQUES\",\"UNITED STATES POSTAL SERVICE INTRACOASTAL CPU\",\"POSTMASTER\"],\"customerDisputeIndicator\":false},\"sicCodes\":[{\"code\":\"4311\",\"definition\":\"U S POSTAL SERVICE\"}],\"naicsCodes\":[{\"code\":\"491110\",\"definition\":\"Postal Service\"}],\"publicIndicator\":false,\"nonProfitIndicator\":false,\"yearsOnFile\":45,\"stateOfIncorporation\":\"NC\",\"dateOfIncorporation\":\"2007-07-20\",\"businessType\":\"Limited Liability Company (LLC)\",\"employeeSize\":null,\"employeeSizeCode\":null,\"salesRevenue\":71400000000,\"salesSizeCode\":\"K\",\"fortune1000\":{\"year\":null,\"rank\":null},\"corporateLinkageType\":\"Headquarters/Parent\",\"executiveInformation\":[{\"firstName\":\"STATE\",\"middleName\":\"OF\",\"lastName\":\"OREGON\",\"title\":\"UCC DEBTOR\"},{\"firstName\":\"STATE\",\"middleName\":\"OF\",\"lastName\":\"MN\",\"title\":\"UCC DEBTOR\"},{\"firstName\":\"STATE\",\"middleName\":\"OF\",\"lastName\":\"IDAHO\",\"title\":\"UCC DEBTOR\"}]}}';
        ExperianBusinessFactsResponse r = ExperianBusinessFactsResponse.parse(json);
		System.assert(r != null);
	}
}