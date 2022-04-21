public class ExperianAuthenticateUser {

	public String issued_at {get;set;} 
	public String expires_in {get;set;} 
	public String token_type {get;set;} 
	public String access_token {get;set;} 
	public String refresh_token {get;set;} 

	public ExperianAuthenticateUser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'issued_at') {
						issued_at = parser.getText();
					} else if (text == 'expires_in') {
						expires_in = parser.getText();
					} else if (text == 'token_type') {
						token_type = parser.getText();
					} else if (text == 'access_token') {
						access_token = parser.getText();
					} else if (text == 'refresh_token') {
						refresh_token = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'ExperianAuthenticateUser consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static ExperianAuthenticateUser parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new ExperianAuthenticateUser(parser);
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
}