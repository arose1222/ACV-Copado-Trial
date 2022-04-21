@isTest
global class ExperianBusinessFactsMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    public String body;
    protected Map<String, String> responseHeaders;
    
    public ExperianBusinessFactsMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public ExperianBusinessFactsMock() {
        this.code = 200;
        this.status = 'OK';
        this.body =  '{'+
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