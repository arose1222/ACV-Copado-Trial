@IsTest
public class ExperianAuthenticateUserTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
		ExperianAuthenticateUser r = ExperianAuthenticateUser.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		ExperianAuthenticateUser objExperianAuthenticateUser = new ExperianAuthenticateUser(System.JSON.createParser(json));
		System.assert(objExperianAuthenticateUser != null);
		System.assert(objExperianAuthenticateUser.issued_at == null);
		System.assert(objExperianAuthenticateUser.expires_in == null);
		System.assert(objExperianAuthenticateUser.token_type == null);
		System.assert(objExperianAuthenticateUser.access_token == null);
		System.assert(objExperianAuthenticateUser.refresh_token == null);
	}
}