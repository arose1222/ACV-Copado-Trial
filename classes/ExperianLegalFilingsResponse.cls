public class ExperianLegalFilingsResponse {

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
	
	public class Results {
		public BusinessHeader businessHeader {get;set;} 
		public LegalFilingsSummary legalFilingsSummary {get;set;} 
		public LegalFilingsCollectionsSummary legalFilingsCollectionsSummary {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessHeader') {
							businessHeader = new BusinessHeader(parser);
						} else if (text == 'legalFilingsSummary') {
							legalFilingsSummary = new LegalFilingsSummary(parser);
						} else if (text == 'legalFilingsCollectionsSummary') {
							legalFilingsCollectionsSummary = new LegalFilingsCollectionsSummary(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
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
	
	public String requestId {get;set;} 
	public Boolean success {get;set;} 
	public String comments {get;set;} 
	public Results results {get;set;} 

	public ExperianLegalFilingsResponse(JSONParser parser) {
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
						System.debug(LoggingLevel.WARN, 'ExperianLegalFilingsResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static ExperianLegalFilingsResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExperianLegalFilingsResponse(parser);
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
}