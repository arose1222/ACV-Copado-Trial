public class ExperianBusinessFactsResponse {
    
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

	public ExperianBusinessFactsResponse(JSONParser parser) {
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
						System.debug(LoggingLevel.WARN, 'ExperianBusinessFactsResponse consuming unrecognized property: '+text);
						consumeObject(parser);
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
	
	public class Results {
		public BusinessHeader businessHeader {get;set;} 
		public List<SicCodes> sicCodes {get;set;} 
		public List<SicCodes> naicsCodes {get;set;} 
		public Boolean publicIndicator {get;set;} 
		public String tickerSymbol {get;set;} 
		public String stockExchange {get;set;} 
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

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessHeader') {
							businessHeader = new BusinessHeader(parser);
						} else if (text == 'sicCodes') {
							sicCodes = arrayOfSicCodes(parser);
						} else if (text == 'naicsCodes') {
							naicsCodes = arrayOfSicCodes(parser);
						} else if (text == 'publicIndicator') {
							publicIndicator = parser.getBooleanValue();
						} else if (text == 'tickerSymbol') {
							tickerSymbol = parser.getText();
						} else if (text == 'stockExchange') {
							stockExchange = parser.getText();
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
	
	
	public static ExperianBusinessFactsResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExperianBusinessFactsResponse(parser);
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
	



    private static List<SicCodes> arrayOfSicCodes(System.JSONParser p) {
        List<SicCodes> res = new List<SicCodes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new SicCodes(p));
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


    private static List<ExecutiveInformation> arrayOfExecutiveInformation(System.JSONParser p) {
        List<ExecutiveInformation> res = new List<ExecutiveInformation>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ExecutiveInformation(p));
        }
        return res;
    }

}