@isTest
global class ExperianBusinessScoreMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    public String body;
    protected Map<String, String> responseHeaders;
    
    public ExperianBusinessScoreMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public ExperianBusinessScoreMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{'+
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