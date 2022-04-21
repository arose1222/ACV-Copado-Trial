@isTest
global class ExperianLegalFilingsMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    public String body;
    protected Map<String, String> responseHeaders;
    
    public ExperianLegalFilingsMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public ExperianLegalFilingsMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{'+
		'  \"requestId\": \"rrt-08334cf162c05aa6d-b-ea-27897-101009453-1\",'+
		'  \"success\": true,'+
		'  \"results\": {'+
		'    \"businessHeader\": {'+
		'      \"bin\": \"800914632\",'+
		'      \"businessName\": \"CROCKER INDUSTRIES\",'+
		'      \"address\": {'+
		'        \"street\": \"100 MAIN\",'+
		'        \"city\": \"PHOENIX\",'+
		'        \"state\": \"AZ\",'+
		'        \"zip\": \"85032\",'+
		'        \"zipExtension\": null'+
		'      },'+
		'      \"phone\": \"+18887859790\",'+
		'      \"taxId\": null,'+
		'      \"websiteUrl\": null,'+
		'      \"legalBusinessName\": null,'+
		'      \"dbaNames\": null,'+
		'      \"customerDisputeIndicator\": true'+
		'    },'+
		'    \"legalFilingsCollectionsSummary\": {'+
		'      \"legalCount\": 0,'+
		'      \"legalBalance\": 0,'+
		'      \"derogatoryLegalCount\": 0,'+
		'      \"bankruptcyIndicator\": false,'+
		'      \"bankruptcyCount\": 0,'+
		'      \"lienCount\": 0,'+
		'      \"lienBalance\": 0,'+
		'      \"judgmentCount\": 0,'+
		'      \"judgmentBalance\": 0,'+
		'      \"uccFilingsCount\": 0,'+
		'      \"uccDerogatoryCount\": 0,'+
		'      \"collectionCount\": 0,'+
		'      \"collectionBalance\": 0'+
		'    },'+
		'    \"legalFilingsSummary\": {'+
		'      \"legalCount\": 0,'+
		'      \"legalBalance\": 0,'+
		'      \"derogatoryLegalCount\": 0'+
		'    }'+
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