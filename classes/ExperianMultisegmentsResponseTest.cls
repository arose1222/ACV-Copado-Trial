@IsTest
public class ExperianMultisegmentsResponseTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
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
		ExperianMultisegmentsResponse r = ExperianMultisegmentsResponse.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.CreditStatus objCreditStatus = new ExperianMultisegmentsResponse.CreditStatus(System.JSON.createParser(json));
		System.assert(objCreditStatus != null);
		System.assert(objCreditStatus.combinedTradelineCount == null);
		System.assert(objCreditStatus.combinedAccountBalance == null);
		System.assert(objCreditStatus.currentDbt == null);
		System.assert(objCreditStatus.combinedRecentHighCreditAmount == null);
		System.assert(objCreditStatus.yearsOnFile == null);
		System.assert(objCreditStatus.inquiryCount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.ExecutiveInformation objExecutiveInformation = new ExperianMultisegmentsResponse.ExecutiveInformation(System.JSON.createParser(json));
		System.assert(objExecutiveInformation != null);
		System.assert(objExecutiveInformation.firstName == null);
		System.assert(objExecutiveInformation.middleName == null);
		System.assert(objExecutiveInformation.lastName == null);
		System.assert(objExecutiveInformation.title == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.CollectionsDetail objCollectionsDetail = new ExperianMultisegmentsResponse.CollectionsDetail(System.JSON.createParser(json));
		System.assert(objCollectionsDetail != null);
		System.assert(objCollectionsDetail.accountStatus == null);
		System.assert(objCollectionsDetail.datePlacedForCollection == null);
		System.assert(objCollectionsDetail.dateClosed == null);
		System.assert(objCollectionsDetail.amountPlacedForCollection == null);
		System.assert(objCollectionsDetail.amountPaid == null);
		System.assert(objCollectionsDetail.collectionAgencyInfo == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.BankruptcySummary objBankruptcySummary = new ExperianMultisegmentsResponse.BankruptcySummary(System.JSON.createParser(json));
		System.assert(objBankruptcySummary != null);
		System.assert(objBankruptcySummary.bankruptcyIndicator == null);
		System.assert(objBankruptcySummary.bankruptcyCount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.BusinessFacts objBusinessFacts = new ExperianMultisegmentsResponse.BusinessFacts(System.JSON.createParser(json));
		System.assert(objBusinessFacts != null);
		System.assert(objBusinessFacts.sicCodes == null);
		System.assert(objBusinessFacts.naicsCodes == null);
		System.assert(objBusinessFacts.publicIndicator == null);
		System.assert(objBusinessFacts.nonProfitIndicator == null);
		System.assert(objBusinessFacts.yearsOnFile == null);
		System.assert(objBusinessFacts.dateOfIncorporation == null);
		System.assert(objBusinessFacts.businessType == null);
		System.assert(objBusinessFacts.employeeSize == null);
		System.assert(objBusinessFacts.employeeSizeCode == null);
		System.assert(objBusinessFacts.salesRevenue == null);
		System.assert(objBusinessFacts.salesSizeCode == null);
		System.assert(objBusinessFacts.fortune1000 == null);
		System.assert(objBusinessFacts.corporateLinkageType == null);
		System.assert(objBusinessFacts.executiveInformation == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.Address objAddress = new ExperianMultisegmentsResponse.Address(System.JSON.createParser(json));
		System.assert(objAddress != null);
		System.assert(objAddress.street == null);
		System.assert(objAddress.city == null);
		System.assert(objAddress.state == null);
		System.assert(objAddress.zip == null);
		System.assert(objAddress.zipExtension == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.LegalFilingsCollectionsSummary objLegalFilingsCollectionsSummary = new ExperianMultisegmentsResponse.LegalFilingsCollectionsSummary(System.JSON.createParser(json));
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
		ExperianMultisegmentsResponse.LienSummary objLienSummary = new ExperianMultisegmentsResponse.LienSummary(System.JSON.createParser(json));
		System.assert(objLienSummary != null);
		System.assert(objLienSummary.lienCount == null);
		System.assert(objLienSummary.lienBalance == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.LienDetail objLienDetail = new ExperianMultisegmentsResponse.LienDetail(System.JSON.createParser(json));
		System.assert(objLienDetail != null);
		System.assert(objLienDetail.dateFiled == null);
		System.assert(objLienDetail.legalType == null);
		System.assert(objLienDetail.legalAction == null);
		System.assert(objLienDetail.documentNumber == null);
		System.assert(objLienDetail.filingLocation == null);
		System.assert(objLienDetail.owner == null);
		System.assert(objLienDetail.liabilityAmount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.RiskClass objRiskClass = new ExperianMultisegmentsResponse.RiskClass(System.JSON.createParser(json));
		System.assert(objRiskClass != null);
		System.assert(objRiskClass.code == null);
		System.assert(objRiskClass.definition == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.CommercialScore objCommercialScore = new ExperianMultisegmentsResponse.CommercialScore(System.JSON.createParser(json));
		System.assert(objCommercialScore != null);
		System.assert(objCommercialScore.modelCode == null);
		System.assert(objCommercialScore.modelTitle == null);
		System.assert(objCommercialScore.customModelCode == null);
		System.assert(objCommercialScore.score == null);
		System.assert(objCommercialScore.percentileRanking == null);
		System.assert(objCommercialScore.recommendedCreditLimitAmount == null);
		System.assert(objCommercialScore.riskClass == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.FsrScore objFsrScore = new ExperianMultisegmentsResponse.FsrScore(System.JSON.createParser(json));
		System.assert(objFsrScore != null);
		System.assert(objFsrScore.modelCode == null);
		System.assert(objFsrScore.modelTitle == null);
		System.assert(objFsrScore.score == null);
		System.assert(objFsrScore.percentileRanking == null);
		System.assert(objFsrScore.recommendedCreditLimitAmount == null);
		System.assert(objFsrScore.riskClass == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.BusinessHeader objBusinessHeader = new ExperianMultisegmentsResponse.BusinessHeader(System.JSON.createParser(json));
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

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.RiskClass_Z objRiskClass_Z = new ExperianMultisegmentsResponse.RiskClass_Z(System.JSON.createParser(json));
		System.assert(objRiskClass_Z != null);
		System.assert(objRiskClass_Z.code == null);
		System.assert(objRiskClass_Z.definition == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.LegalFilingsSummary objLegalFilingsSummary = new ExperianMultisegmentsResponse.LegalFilingsSummary(System.JSON.createParser(json));
		System.assert(objLegalFilingsSummary != null);
		System.assert(objLegalFilingsSummary.legalCount == null);
		System.assert(objLegalFilingsSummary.legalBalance == null);
		System.assert(objLegalFilingsSummary.derogatoryLegalCount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.Results objResults = new ExperianMultisegmentsResponse.Results(System.JSON.createParser(json));
		System.assert(objResults != null);
		System.assert(objResults.businessHeader == null);
		System.assert(objResults.bankruptcySummary == null);
		System.assert(objResults.collectionsDetail == null);
		System.assert(objResults.collectionsSummary == null);
		System.assert(objResults.creditStatus == null);
		System.assert(objResults.businessFacts == null);
		System.assert(objResults.legalFilingsCollectionsSummary == null);
		System.assert(objResults.legalFilingsSummary == null);
		System.assert(objResults.lienDetail == null);
		System.assert(objResults.lienSummary == null);
		System.assert(objResults.commercialScore == null);
		System.assert(objResults.commercialScoreFactors == null);
		System.assert(objResults.commercialScoreTrends == null);
		System.assert(objResults.fsrScore == null);
		System.assert(objResults.fsrScoreFactors == null);
		System.assert(objResults.fsrScoreTrends == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.Fortune1000 objFortune1000 = new ExperianMultisegmentsResponse.Fortune1000(System.JSON.createParser(json));
		System.assert(objFortune1000 != null);
		System.assert(objFortune1000.year == null);
		System.assert(objFortune1000.rank == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.SicCodes objSicCodes = new ExperianMultisegmentsResponse.SicCodes(System.JSON.createParser(json));
		System.assert(objSicCodes != null);
		System.assert(objSicCodes.code == null);
		System.assert(objSicCodes.definition == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.CollectionAgencyInfo objCollectionAgencyInfo = new ExperianMultisegmentsResponse.CollectionAgencyInfo(System.JSON.createParser(json));
		System.assert(objCollectionAgencyInfo != null);
		System.assert(objCollectionAgencyInfo.name == null);
		System.assert(objCollectionAgencyInfo.phoneNumber == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.CommercialScoreTrends objCommercialScoreTrends = new ExperianMultisegmentsResponse.CommercialScoreTrends(System.JSON.createParser(json));
		System.assert(objCommercialScoreTrends != null);
		System.assert(objCommercialScoreTrends.quarter == null);
		System.assert(objCommercialScoreTrends.score == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse objExperianMultisegmentsResponse = new ExperianMultisegmentsResponse(System.JSON.createParser(json));
		System.assert(objExperianMultisegmentsResponse != null);
		System.assert(objExperianMultisegmentsResponse.requestId == null);
		System.assert(objExperianMultisegmentsResponse.success == null);
		System.assert(objExperianMultisegmentsResponse.comments == null);
		System.assert(objExperianMultisegmentsResponse.results == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianMultisegmentsResponse.CollectionsSummary objCollectionsSummary = new ExperianMultisegmentsResponse.CollectionsSummary(System.JSON.createParser(json));
		System.assert(objCollectionsSummary != null);
		System.assert(objCollectionsSummary.collectionCount == null);
		System.assert(objCollectionsSummary.collectionBalance == null);
	}
}