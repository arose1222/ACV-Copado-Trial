public class ExperianScoreResponse {

	public class MatchingBranchAddress {
		public String bin {get;set;} 
		public String street {get;set;} 
		public String city {get;set;} 
		public String state {get;set;} 
		public String zip {get;set;} 
		public String zipExtension {get;set;} 

		public MatchingBranchAddress(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bin') {
							bin = parser.getText();
						} else if (text == 'street') {
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
							System.debug(LoggingLevel.WARN, 'MatchingBranchAddress consuming unrecognized property: '+text);
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

	public ExperianScoreResponse(JSONParser parser) {
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
						System.debug(LoggingLevel.WARN, 'ExperianScoreResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class CollectionScore {
		public String modelCode {get;set;} 
		public String modelTitle {get;set;} 
		public Integer score {get;set;} 
		public Integer percentileRanking {get;set;} 
		public RiskClass riskClass {get;set;} 

		public CollectionScore(JSONParser parser) {
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
						} else if (text == 'riskClass') {
							riskClass = new RiskClass(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CollectionScore consuming unrecognized property: '+text);
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
	
	public class RiskClass {
		public Integer code {get;set;} 
		public String definition {get;set;} 

		public RiskClass(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getIntegerValue();
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
	
	public class Results {
		public BusinessHeader businessHeader {get;set;} 
		public CommercialScore commercialScore {get;set;} 
		public List<CommercialScoreFactors> commercialScoreFactors {get;set;} 
		public List<CommercialScoreTrends> commercialScoreTrends {get;set;} 
		public FsrScore fsrScore {get;set;} 
		public List<CommercialScoreFactors> fsrScoreFactors {get;set;} 
		public List<CommercialScoreTrends> fsrScoreTrends {get;set;} 
		public CollectionScore collectionScore {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessHeader') {
							businessHeader = new BusinessHeader(parser);
						} else if (text == 'commercialScore') {
							commercialScore = new CommercialScore(parser);
						} else if (text == 'commercialScoreFactors') {
							commercialScoreFactors = arrayOfCommercialScoreFactors(parser);
						} else if (text == 'commercialScoreTrends') {
							commercialScoreTrends = arrayOfCommercialScoreTrends(parser);
						} else if (text == 'fsrScore') {
							fsrScore = new FsrScore(parser);
						} else if (text == 'fsrScoreFactors') {
							fsrScoreFactors = arrayOfCommercialScoreFactors(parser);
						} else if (text == 'fsrScoreTrends') {
							fsrScoreTrends = arrayOfCommercialScoreTrends(parser);
						} else if (text == 'collectionScore') {
							collectionScore = new CollectionScore(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CommercialScoreFactors {
		public String code {get;set;} 
		public String definition {get;set;} 

		public CommercialScoreFactors(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'definition') {
							definition = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CommercialScoreFactors consuming unrecognized property: '+text);
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
		public Integer recommendedCreditLimitAmount {get;set;} 
		public RiskClass riskClass {get;set;} 

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
							recommendedCreditLimitAmount = parser.getIntegerValue();
						} else if (text == 'riskClass') {
							riskClass = new RiskClass(parser);
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
		public Boolean foreignCountry {get;set;} 
		public Boolean corporateLinkageIndicator {get;set;} 
		public MatchingBranchAddress matchingBranchAddress {get;set;} 
		public BranchLocation branchLocation {get;set;} 

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
						} else if (text == 'foreignCountry') {
							foreignCountry = parser.getBooleanValue();
						} else if (text == 'corporateLinkageIndicator') {
							corporateLinkageIndicator = parser.getBooleanValue();
						} else if (text == 'matchingBranchAddress') {
							matchingBranchAddress = new MatchingBranchAddress(parser);
						} else if (text == 'branchLocation') {
							branchLocation = new BranchLocation(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BusinessHeader consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BranchLocation {
		public String bin {get;set;} 
		public String locationId {get;set;} 

		public BranchLocation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bin') {
							bin = parser.getText();
						} else if (text == 'locationId') {
							locationId = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'BranchLocation consuming unrecognized property: '+text);
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
	
	
	public static ExperianScoreResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExperianScoreResponse(parser);
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
	






    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
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






    private static List<CommercialScoreFactors> arrayOfCommercialScoreFactors(System.JSONParser p) {
        List<CommercialScoreFactors> res = new List<CommercialScoreFactors>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CommercialScoreFactors(p));
        }
        return res;
    }


}