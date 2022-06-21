public class ExperianMultisegmentsResponse {

	public class CreditStatus {
		public Integer combinedTradelineCount {get;set;} 
		public Integer combinedAccountBalance {get;set;} 
		public Integer currentDbt {get;set;} 
		public Integer combinedRecentHighCreditAmount {get;set;} 
		public Integer yearsOnFile {get;set;} 
		public Integer inquiryCount {get;set;} 

		public CreditStatus(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'combinedTradelineCount') {
							combinedTradelineCount = parser.getIntegerValue();
						} else if (text == 'combinedAccountBalance') {
							combinedAccountBalance = parser.getIntegerValue();
						} else if (text == 'currentDbt') {
							currentDbt = parser.getIntegerValue();
						} else if (text == 'combinedRecentHighCreditAmount') {
							combinedRecentHighCreditAmount = parser.getIntegerValue();
						} else if (text == 'yearsOnFile') {
							yearsOnFile = parser.getIntegerValue();
						} else if (text == 'inquiryCount') {
							inquiryCount = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditStatus consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ExecutiveInformation {
		public String firstName {get;set;} 
		public String middleName {get;set;} 
		public String lastName {get;set;} 
		public String title {get;set;} 

		public ExecutiveInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'middleName') {
							middleName = parser.getText();
						} else if (text == 'lastName') {
							lastName = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ExecutiveInformation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CollectionsDetail {
		public String accountStatus {get;set;} 
		public String datePlacedForCollection {get;set;} 
		public String dateClosed {get;set;} 
		public Integer amountPlacedForCollection {get;set;} 
		public Integer amountPaid {get;set;} 
		public CollectionAgencyInfo collectionAgencyInfo {get;set;} 

		public CollectionsDetail(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'accountStatus') {
							accountStatus = parser.getText();
						} else if (text == 'datePlacedForCollection') {
							datePlacedForCollection = parser.getText();
						} else if (text == 'dateClosed') {
							dateClosed = parser.getText();
						} else if (text == 'amountPlacedForCollection') {
							amountPlacedForCollection = parser.getIntegerValue();
						} else if (text == 'amountPaid') {
							amountPaid = parser.getIntegerValue();
						} else if (text == 'collectionAgencyInfo') {
							collectionAgencyInfo = new CollectionAgencyInfo(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CollectionsDetail consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BankruptcySummary {
		public Boolean bankruptcyIndicator {get;set;} 
		public Integer bankruptcyCount {get;set;} 

		public BankruptcySummary(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bankruptcyIndicator') {
							bankruptcyIndicator = parser.getBooleanValue();
						} else if (text == 'bankruptcyCount') {
							bankruptcyCount = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'BankruptcySummary consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BusinessFacts {
		public List<SicCodes> sicCodes {get;set;} 
		public List<SicCodes> naicsCodes {get;set;} 
		public Boolean publicIndicator {get;set;} 
		public Boolean nonProfitIndicator {get;set;} 
		public Integer yearsOnFile {get;set;}
        public String stateOfIncorporation {get;set;} 
		public String dateOfIncorporation {get;set;} 
		public String businessType {get;set;} 
		public Integer employeeSize {get;set;} 
		public String employeeSizeCode {get;set;} 
		public Long salesRevenue {get;set;} 
		public String salesSizeCode {get;set;} 
		public Fortune1000 fortune1000 {get;set;} 
		public String corporateLinkageType {get;set;} 
		public List<ExecutiveInformation> executiveInformation {get;set;} 

		public BusinessFacts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'sicCodes') {
							sicCodes = arrayOfSicCodes(parser);
						} else if (text == 'naicsCodes') {
							naicsCodes = arrayOfSicCodes(parser);
						} else if (text == 'publicIndicator') {
							publicIndicator = parser.getBooleanValue();
						} else if (text == 'nonProfitIndicator') {
							nonProfitIndicator = parser.getBooleanValue();
						} else if (text == 'yearsOnFile') {
							yearsOnFile = parser.getIntegerValue();
                        } else if (text == 'stateOfIncorporation') {
							stateOfIncorporation = parser.getText();
						} else if (text == 'dateOfIncorporation') {
							dateOfIncorporation = parser.getText();
						} else if (text == 'businessType') {
							businessType = parser.getText();
						} else if (text == 'employeeSize') {
							employeeSize = parser.getIntegerValue();
						} else if (text == 'employeeSizeCode') {
							employeeSizeCode = parser.getText();
						} else if (text == 'salesRevenue') {
							salesRevenue = parser.getLongValue();
						} else if (text == 'salesSizeCode') {
							salesSizeCode = parser.getText();
						} else if (text == 'fortune1000') {
							fortune1000 = new Fortune1000(parser);
						} else if (text == 'corporateLinkageType') {
							corporateLinkageType = parser.getText();
						} else if (text == 'executiveInformation') {
							executiveInformation = arrayOfExecutiveInformation(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BusinessFacts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Address {
		public String street {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zip {get;set;} 
		public String zipExtension {get;set;} 

		public Address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'street') {
							street = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'zip') {
							zip = parser.getText();
						} else if (text == 'zipExtension') {
							zipExtension = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LegalFilingsCollectionsSummary {
		public Integer legalCount {get;set;} 
		public Integer legalBalance {get;set;} 
		public Integer derogatoryLegalCount {get;set;} 
		public Boolean bankruptcyIndicator {get;set;} 
		public Integer bankruptcyCount {get;set;} 
		public Integer lienCount {get;set;} 
		public Integer lienBalance {get;set;} 
		public Integer judgmentCount {get;set;} 
		public Integer judgmentBalance {get;set;} 
		public Integer uccFilingsCount {get;set;} 
		public Integer uccDerogatoryCount {get;set;} 
		public Integer collectionCount {get;set;} 
		public Integer collectionBalance {get;set;} 

		public LegalFilingsCollectionsSummary(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'legalCount') {
							legalCount = parser.getIntegerValue();
						} else if (text == 'legalBalance') {
							legalBalance = parser.getIntegerValue();
						} else if (text == 'derogatoryLegalCount') {
							derogatoryLegalCount = parser.getIntegerValue();
						} else if (text == 'bankruptcyIndicator') {
							bankruptcyIndicator = parser.getBooleanValue();
						} else if (text == 'bankruptcyCount') {
							bankruptcyCount = parser.getIntegerValue();
						} else if (text == 'lienCount') {
							lienCount = parser.getIntegerValue();
						} else if (text == 'lienBalance') {
							lienBalance = parser.getIntegerValue();
						} else if (text == 'judgmentCount') {
							judgmentCount = parser.getIntegerValue();
						} else if (text == 'judgmentBalance') {
							judgmentBalance = parser.getIntegerValue();
						} else if (text == 'uccFilingsCount') {
							uccFilingsCount = parser.getIntegerValue();
						} else if (text == 'uccDerogatoryCount') {
							uccDerogatoryCount = parser.getIntegerValue();
						} else if (text == 'collectionCount') {
							collectionCount = parser.getIntegerValue();
						} else if (text == 'collectionBalance') {
							collectionBalance = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'LegalFilingsCollectionsSummary consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LienSummary {
		public Integer lienCount {get;set;} 
		public Integer lienBalance {get;set;} 

		public LienSummary(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'lienCount') {
							lienCount = parser.getIntegerValue();
						} else if (text == 'lienBalance') {
							lienBalance = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'LienSummary consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LienDetail {
		public String dateFiled {get;set;} 
		public String legalType {get;set;} 
		public String legalAction {get;set;} 
		public String documentNumber {get;set;} 
		public String filingLocation {get;set;} 
		public String owner {get;set;} 
		public Integer liabilityAmount {get;set;} 

		public LienDetail(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'dateFiled') {
							dateFiled = parser.getText();
						} else if (text == 'legalType') {
							legalType = parser.getText();
						} else if (text == 'legalAction') {
							legalAction = parser.getText();
						} else if (text == 'documentNumber') {
							documentNumber = parser.getText();
						} else if (text == 'filingLocation') {
							filingLocation = parser.getText();
						} else if (text == 'owner') {
							owner = parser.getText();
						} else if (text == 'liabilityAmount') {
							liabilityAmount = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'LienDetail consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class RiskClass {
		public String code {get;set;} 
		public String definition {get;set;} 

		public RiskClass(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'definition') {
							definition = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'RiskClass consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CommercialScore {
		public String modelCode {get;set;} 
		public String modelTitle {get;set;} 
		public String customModelCode {get;set;} 
		public Integer score {get;set;} 
		public Integer percentileRanking {get;set;} 
		public Integer recommendedCreditLimitAmount {get;set;} 
		public RiskClass riskClass {get;set;} 

		public CommercialScore(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'modelCode') {
							modelCode = parser.getText();
						} else if (text == 'modelTitle') {
							modelTitle = parser.getText();
						} else if (text == 'customModelCode') {
							customModelCode = parser.getText();
						} else if (text == 'score') {
							score = parser.getIntegerValue();
						} else if (text == 'percentileRanking') {
							percentileRanking = parser.getIntegerValue();
						} else if (text == 'recommendedCreditLimitAmount') {
							recommendedCreditLimitAmount = parser.getIntegerValue();
						} else if (text == 'riskClass') {
							riskClass = new RiskClass(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CommercialScore consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class FsrScore {
		public String modelCode {get;set;} 
		public String modelTitle {get;set;} 
		public Integer score {get;set;} 
		public Integer percentileRanking {get;set;} 
		public Long recommendedCreditLimitAmount {get;set;} 
		public RiskClass_Z riskClass {get;set;} 

		public FsrScore(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'modelCode') {
							modelCode = parser.getText();
						} else if (text == 'modelTitle') {
							modelTitle = parser.getText();
						} else if (text == 'score') {
							score = parser.getIntegerValue();
						} else if (text == 'percentileRanking') {
							percentileRanking = parser.getIntegerValue();
						} else if (text == 'recommendedCreditLimitAmount') {
							recommendedCreditLimitAmount = parser.getLongValue();
						} else if (text == 'riskClass') {
							riskClass = new RiskClass_Z(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'FsrScore consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BusinessHeader {
		public String bin {get;set;} 
		public String businessName {get;set;} 
		public Address address {get;set;} 
		public String phone {get;set;} 
		public String taxId {get;set;} 
		public String websiteUrl {get;set;} 
		public String legalBusinessName {get;set;} 
		public List<String> dbaNames {get;set;} 
		public Boolean customerDisputeIndicator {get;set;} 

		public BusinessHeader(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bin') {
							bin = parser.getText();
						} else if (text == 'businessName') {
							businessName = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'taxId') {
							taxId = parser.getText();
						} else if (text == 'websiteUrl') {
							websiteUrl = parser.getText();
						} else if (text == 'legalBusinessName') {
							legalBusinessName = parser.getText();
						} else if (text == 'dbaNames') {
							dbaNames = arrayOfString(parser);
						} else if (text == 'customerDisputeIndicator') {
							customerDisputeIndicator = parser.getBooleanValue();
						} else {
							System.debug(LoggingLevel.WARN, 'BusinessHeader consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class RiskClass_Z {
		public Integer code {get;set;} 
		public String definition {get;set;} 

		public RiskClass_Z(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getIntegerValue();
						} else if (text == 'definition') {
							definition = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'RiskClass_Z consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LegalFilingsSummary {
		public Integer legalCount {get;set;} 
		public Integer legalBalance {get;set;} 
		public Integer derogatoryLegalCount {get;set;} 

		public LegalFilingsSummary(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'legalCount') {
							legalCount = parser.getIntegerValue();
						} else if (text == 'legalBalance') {
							legalBalance = parser.getIntegerValue();
						} else if (text == 'derogatoryLegalCount') {
							derogatoryLegalCount = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'LegalFilingsSummary consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Results {
		public BusinessHeader businessHeader {get;set;} 
		public BankruptcySummary bankruptcySummary {get;set;} 
		public List<CollectionsDetail> collectionsDetail {get;set;} 
		public CollectionsSummary collectionsSummary {get;set;} 
		public CreditStatus creditStatus {get;set;} 
		public BusinessFacts businessFacts {get;set;} 
		public LegalFilingsCollectionsSummary legalFilingsCollectionsSummary {get;set;} 
		public LegalFilingsSummary legalFilingsSummary {get;set;} 
		public List<LienDetail> lienDetail {get;set;} 
		public LienSummary lienSummary {get;set;} 
		public CommercialScore commercialScore {get;set;} 
		public List<SicCodes> commercialScoreFactors {get;set;} 
		public List<CommercialScoreTrends> commercialScoreTrends {get;set;} 
		public FsrScore fsrScore {get;set;} 
		public List<SicCodes> fsrScoreFactors {get;set;} 
		public List<CommercialScoreTrends> fsrScoreTrends {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessHeader') {
							businessHeader = new BusinessHeader(parser);
						} else if (text == 'bankruptcySummary') {
							bankruptcySummary = new BankruptcySummary(parser);
						} else if (text == 'collectionsDetail') {
							collectionsDetail = arrayOfCollectionsDetail(parser);
						} else if (text == 'collectionsSummary') {
							collectionsSummary = new CollectionsSummary(parser);
						} else if (text == 'creditStatus') {
							creditStatus = new CreditStatus(parser);
						} else if (text == 'businessFacts') {
							businessFacts = new BusinessFacts(parser);
						} else if (text == 'legalFilingsCollectionsSummary') {
							legalFilingsCollectionsSummary = new LegalFilingsCollectionsSummary(parser);
						} else if (text == 'legalFilingsSummary') {
							legalFilingsSummary = new LegalFilingsSummary(parser);
						} else if (text == 'lienDetail') {
							lienDetail = arrayOfLienDetail(parser);
						} else if (text == 'lienSummary') {
							lienSummary = new LienSummary(parser);
						} else if (text == 'commercialScore') {
							commercialScore = new CommercialScore(parser);
						} else if (text == 'commercialScoreFactors') {
							commercialScoreFactors = arrayOfSicCodes(parser);
						} else if (text == 'commercialScoreTrends') {
							commercialScoreTrends = arrayOfCommercialScoreTrends(parser);
						} else if (text == 'fsrScore') {
							fsrScore = new FsrScore(parser);
						} else if (text == 'fsrScoreFactors') {
							fsrScoreFactors = arrayOfSicCodes(parser);
						} else if (text == 'fsrScoreTrends') {
							fsrScoreTrends = arrayOfCommercialScoreTrends(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Fortune1000 {
		public Integer year {get;set;} 
		public Integer rank {get;set;} 

		public Fortune1000(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'year') {
							year = parser.getIntegerValue();
						} else if (text == 'rank') {
							rank = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Fortune1000 consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class SicCodes {
		public String code {get;set;} 
		public String definition {get;set;} 

		public SicCodes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'definition') {
							definition = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'SicCodes consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CollectionAgencyInfo {
		public String name {get;set;} 
		public String phoneNumber {get;set;} 

		public CollectionAgencyInfo(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'phoneNumber') {
							phoneNumber = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CollectionAgencyInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CommercialScoreTrends {
		public String quarter {get;set;} 
		public Integer score {get;set;} 

		public CommercialScoreTrends(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'quarter') {
							quarter = parser.getText();
						} else if (text == 'score') {
							score = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'CommercialScoreTrends consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String requestId {get;set;} 
	public Boolean success {get;set;} 
	public String comments {get;set;} 
	public Results results {get;set;} 

	public ExperianMultisegmentsResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'requestId') {
						requestId = parser.getText();
					} else if (text == 'success') {
						success = parser.getBooleanValue();
					} else if (text == 'comments') {
						comments = parser.getText();
					} else if (text == 'results') {
						results = new Results(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'ExperianMultisegmentsResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class CollectionsSummary {
		public Integer collectionCount {get;set;} 
		public Integer collectionBalance {get;set;} 

		public CollectionsSummary(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'collectionCount') {
							collectionCount = parser.getIntegerValue();
						} else if (text == 'collectionBalance') {
							collectionBalance = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'CollectionsSummary consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}	
	
	public static ExperianMultisegmentsResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExperianMultisegmentsResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    private static List<ExecutiveInformation> arrayOfExecutiveInformation(System.JSONParser p) {
        List<ExecutiveInformation> res = new List<ExecutiveInformation>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ExecutiveInformation(p));
        }
        return res;
    }

    private static List<LienDetail> arrayOfLienDetail(System.JSONParser p) {
        List<LienDetail> res = new List<LienDetail>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new LienDetail(p));
        }
        return res;
    }

    private static List<CommercialScoreTrends> arrayOfCommercialScoreTrends(System.JSONParser p) {
        List<CommercialScoreTrends> res = new List<CommercialScoreTrends>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CommercialScoreTrends(p));
        }
        return res;
    }

    private static List<SicCodes> arrayOfSicCodes(System.JSONParser p) {
        List<SicCodes> res = new List<SicCodes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new SicCodes(p));
        }
        return res;
    }

    private static List<CollectionsDetail> arrayOfCollectionsDetail(System.JSONParser p) {
        List<CollectionsDetail> res = new List<CollectionsDetail>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CollectionsDetail(p));
        }
        return res;
    }
    
    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }


}