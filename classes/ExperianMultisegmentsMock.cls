@isTest
global class ExperianMultisegmentsMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    public String body;
    protected Map<String, String> responseHeaders;
    
    public ExperianMultisegmentsMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public ExperianMultisegmentsMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{'+
		'  \"requestId\": \"rrt-066d21a2774f00545-c-ea-28578-34293122-1\",'+
		'  \"success\": true,'+
		'  \"comments\": \"abcde12345\",'+
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
		'      \"dbaNames\": ['+
		'        \"EXPERIAN CONSUMER DIRECT\"'+
		'      ],'+
		'      \"customerDisputeIndicator\": false'+
		'    },'+
		'    \"bankruptcySummary\": {'+
		'      \"bankruptcyIndicator\": false,'+
		'      \"bankruptcyCount\": 0'+
		'    },'+
		'    \"collectionsDetail\": ['+
		'      {'+
		'        \"accountStatus\": \"Open Account\",'+
		'        \"datePlacedForCollection\": \"2019-12-01\",'+
		'        \"dateClosed\": null,'+
		'        \"amountPlacedForCollection\": 267,'+
		'        \"amountPaid\": 0,'+
		'        \"collectionAgencyInfo\": {'+
		'          \"name\": \"ASSOCIATED CREDIT SERVICES\",'+
		'          \"phoneNumber\": \"+18005316500\"'+
		'        }'+
		'      },'+
		'      {'+
		'        \"accountStatus\": \"Open Account\",'+
		'        \"datePlacedForCollection\": \"2019-12-01\",'+
		'        \"dateClosed\": null,'+
		'        \"amountPlacedForCollection\": 575,'+
		'        \"amountPaid\": 0,'+
		'        \"collectionAgencyInfo\": {'+
		'          \"name\": \"ASSOCIATED CREDIT SERVICES\",'+
		'          \"phoneNumber\": \"+18005316500\"'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"collectionsSummary\": {'+
		'      \"collectionCount\": 2,'+
		'      \"collectionBalance\": 842'+
		'    },'+
		'    \"creditStatus\": {'+
		'      \"combinedTradelineCount\": 17,'+
		'      \"combinedAccountBalance\": 152500,'+
		'      \"currentDbt\": 8,'+
		'      \"combinedRecentHighCreditAmount\": 803700,'+
		'      \"yearsOnFile\": 45,'+
		'      \"inquiryCount\": 451'+
		'    },'+
		'    \"businessFacts\": {'+
		'      \"sicCodes\": ['+
		'        {'+
		'          \"code\": \"7323\",'+
		'          \"definition\": \"CREDIT REPORTING SERVICES\"'+
		'        },'+
		'        {'+
		'          \"code\": \"7299\",'+
		'          \"definition\": \"PERSONAL SERVICES, MISC, NEC\"'+
		'        },'+
		'        {'+
		'          \"code\": \"8742\",'+
		'          \"definition\": \"MANAGEMENT CONSULTING SERVICES\"'+
		'        }'+
		'      ],'+
		'      \"naicsCodes\": ['+
		'        {'+
		'          \"code\": \"561450\",'+
		'          \"definition\": \"Credit Bureaus\"'+
		'        },'+
		'        {'+
		'          \"code\": \"812990\",'+
		'          \"definition\": \"All Other Personal Services\"'+
		'        },'+
		'        {'+
		'          \"code\": \"541610\",'+
		'          \"definition\": \"Management Consulting Services\"'+
		'        }'+
		'      ],'+
		'      \"publicIndicator\": false,'+
		'      \"nonProfitIndicator\": false,'+
		'      \"yearsOnFile\": 45,'+
		'      \"dateOfIncorporation\": null,'+
		'      \"businessType\": \"Corporation\",'+
		'      \"employeeSize\": null,'+
		'      \"employeeSizeCode\": null,'+
		'      \"salesRevenue\": null,'+
		'      \"salesSizeCode\": null,'+
		'      \"fortune1000\": {'+
		'        \"year\": null,'+
		'        \"rank\": null'+
		'      },'+
		'      \"corporateLinkageType\": \"Headquarters/Parent\",'+
		'      \"executiveInformation\": ['+
		'        {'+
		'          \"firstName\": \"CRAIG\",'+
		'          \"middleName\": null,'+
		'          \"lastName\": \"BOUNDY\",'+
		'          \"title\": \"CEO\"'+
		'        }'+
		'      ]'+
		'    },'+
		'    \"legalFilingsCollectionsSummary\": {'+
		'      \"legalCount\": 99,'+
		'      \"legalBalance\": 1132011,'+
		'      \"derogatoryLegalCount\": 15,'+
		'      \"bankruptcyIndicator\": false,'+
		'      \"bankruptcyCount\": 0,'+
		'      \"lienCount\": 10,'+
		'      \"lienBalance\": 1118862,'+
		'      \"judgmentCount\": 5,'+
		'      \"judgmentBalance\": 13149,'+
		'      \"uccFilingsCount\": 26,'+
		'      \"uccDerogatoryCount\": 9,'+
		'      \"collectionCount\": 2,'+
		'      \"collectionBalance\": 842'+
		'    },'+
		'    \"legalFilingsSummary\": {'+
		'      \"legalCount\": 99,'+
		'      \"legalBalance\": 1132011,'+
		'      \"derogatoryLegalCount\": 15'+
		'    },'+
		'    \"lienDetail\": ['+
		'      {'+
		'        \"dateFiled\": \"2021-06-06\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"2017021043\",'+
		'        \"filingLocation\": \"KENNEBEC REGISTRY\",'+
		'        \"owner\": \"STATE OF MAINE\",'+
		'        \"liabilityAmount\": 436'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2021-02-05\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"RELEASED\",'+
		'        \"documentNumber\": \"GD16024282\",'+
		'        \"filingLocation\": \"ALLEGHENY COUNTY CVL CT\",'+
		'        \"owner\": \"STATE OF PENNSYLVANIA\",'+
		'        \"liabilityAmount\": 35243'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2020-09-15\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"GD16024282\",'+
		'        \"filingLocation\": \"ALLEGHENY COUNTY CVL CT\",'+
		'        \"owner\": \"STATE OF PENNSYLVANIA\",'+
		'        \"liabilityAmount\": 35243'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2020-12-01\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"RELEASED\",'+
		'        \"documentNumber\": \"GD16019336\",'+
		'        \"filingLocation\": \"ALLEGHENY COUNTY CVL CT\",'+
		'        \"owner\": \"STATE OF PENNSYLVANIA\",'+
		'        \"liabilityAmount\": 31662'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2020-07-12\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"GD16019336\",'+
		'        \"filingLocation\": \"ALLEGHENY COUNTY CVL CT\",'+
		'        \"owner\": \"STATE OF PENNSYLVANIA\",'+
		'        \"liabilityAmount\": 31662'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2019-08-09\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"RELEASED\",'+
		'        \"documentNumber\": \"GD14019329\",'+
		'        \"filingLocation\": \"ALLEGHENY COUNTY CVL CT\",'+
		'        \"owner\": \"STATE OF PENNSYLVANIA\",'+
		'        \"liabilityAmount\": 1048330'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2018-07-20\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"GD14019329\",'+
		'        \"filingLocation\": \"ALLEGHENY COUNTY CVL CT\",'+
		'        \"owner\": \"STATE OF PENNSYLVANIA\",'+
		'        \"liabilityAmount\": 1048330'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2018-11-05\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"2015000055890\",'+
		'        \"filingLocation\": \"ORANGE COUNTY RECORDERS\",'+
		'        \"owner\": \"STATE OF CALIFORNIA\",'+
		'        \"liabilityAmount\": 50'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2018-09-05\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"RELEASED\",'+
		'        \"documentNumber\": \"10257128\",'+
		'        \"filingLocation\": \"MARION CNTY CIRCUIT/SUPERIOR/MUNICIPAL C\",'+
		'        \"owner\": \"STATE OF INDIANA\",'+
		'        \"liabilityAmount\": 212'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2018-09-02\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"2014000518290\",'+
		'        \"filingLocation\": \"ORANGE COUNTY RECORDERS\",'+
		'        \"owner\": \"STATE OF CALIFORNIA\",'+
		'        \"liabilityAmount\": 1315'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2016-08-27\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"E025403789W0025\",'+
		'        \"filingLocation\": \"ALBANY COUNTY CLERK\",'+
		'        \"owner\": \"STATE OF NEW YORK\",'+
		'        \"liabilityAmount\": 204'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2016-08-27\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"2012T15358\",'+
		'        \"filingLocation\": \"ONONDAGA COUNTY CLERKS OFFICE\",'+
		'        \"owner\": \"STATE OF NEW YORK\",'+
		'        \"liabilityAmount\": 433'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2016-03-13\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"2012T07732\",'+
		'        \"filingLocation\": \"ONONDAGA COUNTY CLERKS OFFICE\",'+
		'        \"owner\": \"STATE OF NEW YORK\",'+
		'        \"liabilityAmount\": 668'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2016-03-01\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"RELEASED\",'+
		'        \"documentNumber\": \"08998897\",'+
		'        \"filingLocation\": \"MARION CNTY CIRCUIT/SUPERIOR/MUNICIPAL C\",'+
		'        \"owner\": \"STATE OF INDIANA\",'+
		'        \"liabilityAmount\": 521'+
		'      },'+
		'      {'+
		'        \"dateFiled\": \"2016-02-09\",'+
		'        \"legalType\": \"STATE TAX\",'+
		'        \"legalAction\": \"LIEN\",'+
		'        \"documentNumber\": \"08998897\",'+
		'        \"filingLocation\": \"MARION CNTY CIRCUIT/SUPERIOR/MUNICIPAL C\",'+
		'        \"owner\": \"STATE OF INDIANA\",'+
		'        \"liabilityAmount\": 521'+
		'      }'+
		'    ],'+
		'    \"lienSummary\": {'+
		'      \"lienCount\": 10,'+
		'      \"lienBalance\": 1118862'+
		'    },'+
		'    \"commercialScore\": {'+
		'      \"modelCode\": \"000254\",'+
		'      \"modelTitle\": \"INTELLISCORE PLUS V3 ML\",'+
		'      \"customModelCode\": \"01\",'+
		'      \"score\": 300,'+
		'      \"percentileRanking\": 1,'+
		'      \"recommendedCreditLimitAmount\": 289500,'+
		'      \"riskClass\": {'+
		'        \"code\": null,'+
		'        \"definition\": \"HIGH RISK\"'+
		'      }'+
		'    },'+
		'    \"commercialScoreFactors\": ['+
		'      {'+
		'        \"code\": \"000031\",'+
		'        \"definition\": \"COMMERCIAL TRADES 30+ DAYS DELINQUENT IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000074\",'+
		'        \"definition\": \"NUMBER OF COMM TRADES WITH SEVERE DELINQUENCY IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000109\",'+
		'        \"definition\": \"TOT NBR OF COMMERCIAL TRADES WITH DELINQUENCY IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000077\",'+
		'        \"definition\": \"NUMBER OF DELINQUENT COMMERCIAL TRADES IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000067\",'+
		'        \"definition\": \"NUMBER OF COMMERCIAL INQUIRES IS HIGH\"'+
		'      }'+
		'    ],'+
		'    \"commercialScoreTrends\": ['+
		'      {'+
		'        \"quarter\": \"Oct-Dec\",'+
		'        \"score\": 300'+
		'      },'+
		'      {'+
		'        \"quarter\": \"Jul-Sep\",'+
		'        \"score\": 300'+
		'      },'+
		'      {'+
		'        \"quarter\": \"Apr-Jun\",'+
		'        \"score\": 300'+
		'      },'+
		'      {'+
		'        \"quarter\": \"Jan-Mar\",'+
		'        \"score\": 300'+
		'      }'+
		'    ],'+
		'    \"fsrScore\": {'+
		'      \"modelCode\": \"000253\",'+
		'      \"modelTitle\": \"FINANCIAL STABILITY RISK SCORE V2 ML\",'+
		'      \"score\": 476,'+
		'      \"percentileRanking\": 1,'+
		'      \"recommendedCreditLimitAmount\": null,'+
		'      \"riskClass\": {'+
		'        \"code\": 5,'+
		'        \"definition\": \"HIGH RISK\"'+
		'      }'+
		'    },'+
		'    \"fsrScoreFactors\": ['+
		'      {'+
		'        \"code\": \"000038\",'+
		'        \"definition\": \"DBT OF COMMERCIAL TRADES IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000069\",'+
		'        \"definition\": \"PCT OF COMMERCIAL TRADES SEVERELY DELINQUENT IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000005\",'+
		'        \"definition\": \"AMOUNT OF COMMERCIAL LEGAL FILLINGS IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000065\",'+
		'        \"definition\": \"NUMBER OF UCC FILINGS IS TOO HIGH\"'+
		'      },'+
		'      {'+
		'        \"code\": \"000047\",'+
		'        \"definition\": \"NUMBER OF COMMERCIAL INQUIRES IS HIGH\"'+
		'      }'+
		'    ],'+
		'    \"fsrScoreTrends\": ['+
		'      {'+
		'        \"quarter\": \"Oct-Dec\",'+
		'        \"score\": 555'+
		'      },'+
		'      {'+
		'        \"quarter\": \"Jul-Sep\",'+
		'        \"score\": 430'+
		'      },'+
		'      {'+
		'        \"quarter\": \"Apr-Jun\",'+
		'        \"score\": 476'+
		'      },'+
		'      {'+
		'        \"quarter\": \"Jan-Mar\",'+
		'        \"score\": 461'+
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