@isTest
global class ExperianBusinessSearchMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    
    public ExperianBusinessSearchMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public ExperianBusinessSearchMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{'+
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
        
        this.responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
    }
    
    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}