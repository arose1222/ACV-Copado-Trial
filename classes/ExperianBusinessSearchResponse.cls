public class ExperianBusinessSearchResponse {

	public class MatchingNameAndAddress {
		public String businessName {get;set;} 
		public Address address {get;set;} 

		public MatchingNameAndAddress(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessName') {
							businessName = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'MatchingNameAndAddress consuming unrecognized property: '+text);
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
	
	public class Results {
		public String bin {get;set;} 
		public Double reliabilityCode {get;set;} 
		public String businessName {get;set;} 
		public String phone {get;set;} 
		public Address address {get;set;} 
		public Integer numberOfTradelines {get;set;} 
		public Boolean financialStatementIndicator {get;set;} 
		public Boolean keyFactsIndicator {get;set;} 
		public Boolean inquiryIndicator {get;set;} 
		public Boolean bankDataIndicator {get;set;} 
		public Boolean governmentDataIndicator {get;set;} 
		public Boolean executiveSummaryIndicator {get;set;} 
		public Boolean uccIndicator {get;set;} 
		public MatchingNameAndAddress matchingNameAndAddress {get;set;} 
		public BusinessGeocode businessGeocode {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bin') {
							bin = parser.getText();
						} else if (text == 'reliabilityCode') {
							reliabilityCode = parser.getDoubleValue();
						} else if (text == 'businessName') {
							businessName = parser.getText();
						} else if (text == 'phone') {
							phone = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'numberOfTradelines') {
							numberOfTradelines = parser.getIntegerValue();
						} else if (text == 'financialStatementIndicator') {
							financialStatementIndicator = parser.getBooleanValue();
						} else if (text == 'keyFactsIndicator') {
							keyFactsIndicator = parser.getBooleanValue();
						} else if (text == 'inquiryIndicator') {
							inquiryIndicator = parser.getBooleanValue();
						} else if (text == 'bankDataIndicator') {
							bankDataIndicator = parser.getBooleanValue();
						} else if (text == 'governmentDataIndicator') {
							governmentDataIndicator = parser.getBooleanValue();
						} else if (text == 'executiveSummaryIndicator') {
							executiveSummaryIndicator = parser.getBooleanValue();
						} else if (text == 'uccIndicator') {
							uccIndicator = parser.getBooleanValue();
						} else if (text == 'matchingNameAndAddress') {
							matchingNameAndAddress = new MatchingNameAndAddress(parser);
						} else if (text == 'businessGeocode') {
							businessGeocode = new BusinessGeocode(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String requestId {get;set;} 
	public String responseMessage {get;set;} 
	public String comments {get;set;} 
	public Boolean success {get;set;} 
	public List<Results> results {get;set;} 

	public ExperianBusinessSearchResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'requestId') {
						requestId = parser.getText();
					} else if (text == 'responseMessage') {
						responseMessage = parser.getText();
					} else if (text == 'comments') {
						comments = parser.getText();
					} else if (text == 'success') {
						success = parser.getBooleanValue();
					} else if (text == 'results') {
						results = arrayOfResults(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'ExperianBusinessSearchResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class BusinessGeocode {
		public String latitudeLongitudeLevel {get;set;} 
		public Double latitude {get;set;} 
		public Double longitude {get;set;} 
		public String msaCode {get;set;} 
		public String censusBlkGrpCode {get;set;} 
		public String censusTractCode {get;set;} 
		public Boolean cottageIndicator {get;set;} 
		public String congressionalDistrictCode {get;set;} 
		public String dateLastReported {get;set;} 

		public BusinessGeocode(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'latitudeLongitudeLevel') {
							latitudeLongitudeLevel = parser.getText();
						} else if (text == 'latitude') {
							latitude = parser.getDoubleValue();
						} else if (text == 'longitude') {
							longitude = parser.getDoubleValue();
						} else if (text == 'msaCode') {
							msaCode = parser.getText();
						} else if (text == 'censusBlkGrpCode') {
							censusBlkGrpCode = parser.getText();
						} else if (text == 'censusTractCode') {
							censusTractCode = parser.getText();
						} else if (text == 'cottageIndicator') {
							cottageIndicator = parser.getBooleanValue();
						} else if (text == 'congressionalDistrictCode') {
							congressionalDistrictCode = parser.getText();
						} else if (text == 'dateLastReported') {
							dateLastReported = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'BusinessGeocode consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static ExperianBusinessSearchResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExperianBusinessSearchResponse(parser);
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
	

    private static List<Results> arrayOfResults(System.JSONParser p) {
        List<Results> res = new List<Results>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Results(p));
        }
        return res;
    }
}