@isTest
global class ExperianCreditStatusMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    public String body;
    protected Map<String, String> responseHeaders;
    
    public ExperianCreditStatusMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public ExperianCreditStatusMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{'+
		'  \"requestId\": \"rrt-007dde08211a705db-c-ea-2269-102851751-1\",'+
		'  \"success\": true,'+
		'  \"results\": {'+
		'    \"businessHeader\": {'+
		'      \"bin\": \"796744203\",'+
		'      \"businessName\": \"EXPERIAN INFORMATION SOLUTIONS, INC\",'+
		'      \"address\": {'+
		'        \"street\": \"475 ANTON BLVD\",'+
		'        \"city\": \"COSTA MESA\",'+
		'        \"state\": \"CA\",'+
		'        \"zip\": \"92626\",'+
		'        \"zipExtension\": \"7037\"'+
		'      },'+
		'      \"phone\": \"+17148307000\",'+
		'      \"taxId\": \"133015410\",'+
		'      \"websiteUrl\": \"http://www.experian.com\",'+
		'      \"legalBusinessName\": \"EXPERIAN INFORMATION SOLUTIONS, INC.\",'+
		'      \"dbaNames\": null,'+
		'      \"customerDisputeIndicator\": false'+
		'    },'+
		'    \"combinedTradelineCount\": 17,'+
		'    \"combinedAccountBalance\": 152500,'+
		'    \"currentDbt\": 8,'+
		'    \"combinedRecentHighCreditAmount\": 803700,'+
		'    \"yearsOnFile\": 45,'+
		'    \"inquiryCount\": 451'+
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