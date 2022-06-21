@istest
public class ExperianCalloutServiceTest {
    
    @isTest static void testCreateExperianBussinessInformationForValidAccount(){
        Account acc = TestUtility.createAccount('Experian');
        acc.BillingCity = 'Costa Mesa';
        acc.BillingState = 'CA';
        acc.BillingStreet = '475 ANTON BLVD';
        acc.BillingPostalCode = '92626';
        acc.Phone = '9495673800';
        insert acc;
    
        ExperianBusinessFactsMock business_facts_mock = new ExperianBusinessFactsMock();
        ExperianBusinessFactsResponse business_facts = (ExperianBusinessFactsResponse)JSON.deserializeStrict(business_facts_mock.body, ExperianBusinessFactsResponse.class);
        
        ExperianCreditStatusMock credit_status_mock = new ExperianCreditStatusMock();
        ExperianCreditStatusResponse credit_status = (ExperianCreditStatusResponse)JSON.deserializeStrict(credit_status_mock.body, ExperianCreditStatusResponse.class);
        
        ExperianLegalFilingsMock legal_filings_mock = new ExperianLegalFilingsMock();
        ExperianLegalFilingsResponse legal_filings = (ExperianLegalFilingsResponse)JSON.deserializeStrict(legal_filings_mock.body, ExperianLegalFilingsResponse.class);
        
        ExperianBusinessScoreMock score_mock = new ExperianBusinessScoreMock();
        ExperianScoreResponse score = (ExperianScoreResponse)JSON.deserializeStrict(score_mock.body, ExperianScoreResponse.class);
		
        Test.startTest();
		ExperianCalloutService.createExperianBussinessInformationRecord(acc, business_facts, legal_filings, credit_status,score);
        List <EXPRN__Exp_Business_Info__c> exp_business_info_list = [SELECT Id, EXPRN__Account_Name__c 
                                                                FROM EXPRN__Exp_Business_Info__c 
                                                                WHERE EXPRN__Account_Name__c = :acc.Id];
        Test.stopTest();
        System.assertEquals(1,exp_business_info_list.size());             
    }
	
    @isTest static void testCreateExperianBussinessInformationForValidAccountWithMultisegments(){
        Account acc = TestUtility.createAccount('Experian');
        acc.BillingCity = 'Costa Mesa';
        acc.BillingState = 'CA';
        acc.BillingStreet = '475 ANTON BLVD';
        acc.BillingPostalCode = '92626';
        acc.Phone = '9495673800';
        insert acc;
    
        ExperianMultisegmentsMock multisegments_mock = new ExperianMultisegmentsMock();
        ExperianMultisegmentsResponse multisegments = (ExperianMultisegmentsResponse)JSON.deserializeStrict(multisegments_mock.body, ExperianMultisegmentsResponse.class);
		
        Test.startTest();
		ExperianCalloutService.createExperianBussinessInformationRecord(acc, multisegments);
        List <EXPRN__Exp_Business_Info__c> exp_business_info_list = [SELECT Id, EXPRN__Account_Name__c 
                                                                FROM EXPRN__Exp_Business_Info__c 
                                                                WHERE EXPRN__Account_Name__c = :acc.Id];
        Test.stopTest();
        System.assertEquals(1,exp_business_info_list.size());             
    }
   
	static testMethod void testPostCalloutLoginFromExperian(){
    	Test.setMock(HttpCalloutMock.class, new ExperianBusinessLoginMock());  
        ExperianAuthenticateUser auth_credentials = ExperianCalloutService.login();
    }
    
    @isTest static void testPostCalloutSearchAccountNotFoundedInExperian(){
        Account acc = TestUtility.createAccount('TEST ACCOUNT Experian');
		acc.Tax_ID__c= '123456789';
        insert acc;
        
    	Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        ExperianCalloutService.mockResponseBody = '{"errors": [{"fault": {"faultstring": "Unexpected EOF at target","detail": {"errorcode": "messaging.adaptors.http.flow.UnexpectedEOFAtTarget"}}}]}';
        ExperianCalloutService.mockResponseCode = 400;
        Boolean exceptionThrown = false;
        ExperianCalloutService.mockResponseStatus = 'Bad Request';

        Test.startTest();
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        
        try{
            String bin_code = ExperianCalloutService.getBinAccount(acc, auth_credentials);     
	    }catch (Exception e){
    
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(true, exceptionThrown, 'Expected an exception to be thrown, but there was no exception');
		} 
        Test.stopTest();	
    }
    
    @isTest static void testPostCalloutSearchAccountInExperianWithSuccessResponse(){
        Account acc = TestUtility.createAccount('TEST ACCOUNT Experian');
        acc.Tax_ID__c= '123456789';
        insert acc;
    
        Test.setMock(HttpCalloutMock.class, new ExperianBusinessSearchMock());
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        Test.startTest();
        String bin_code = ExperianCalloutService.getBinAccount(acc, auth_credentials);
        Test.stopTest();
        System.assertEquals('800914632', bin_code);
        
    }
    
    static testMethod void testPostCalloutGetBusinessFactsWithSuccessResponse(){
        String bin_code = 'TEST_BIN_CODE';
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        Test.setMock(HttpCalloutMock.class, new ExperianBusinessFactsMock());
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        
        ExperianBusinessFactsResponse business_facts = ExperianCalloutService.getBusinessFacts(bin_code, auth_credentials);	
    }
    
    @isTest static void testPostCalloutGetBusinessFactsWithFailedResponse(){
        String bin_code = 'TEST_BIN_CODE';
        Boolean exceptionThrown = false;
    	Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"errors": [{"fault": {"faultstring": "Unexpected EOF at target","detail": {"errorcode": "messaging.adaptors.http.flow.UnexpectedEOFAtTarget"}}}]}';
        Integer code = 400;
        String status = 'Bad Request';
        Test.setMock(HttpCalloutMock.class, New ExperianBusinessFactsMock(code, status, body, responseHeaders));

        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        try{
    	    ExperianBusinessFactsResponse business_facts = ExperianCalloutService.getBusinessFacts(bin_code, auth_credentials);	
	    }catch (Exception e){
    
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(true, exceptionThrown, 'Expected an exception to be thrown, but there was no exception');
		}   
    }
    
    static testMethod void testPostCalloutGetLegalFilingsWithSuccessResponse(){
        String bin_code = 'TEST_BIN_CODE';
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
    
        Test.setMock(HttpCalloutMock.class, new ExperianLegalFilingsMock());
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        
		ExperianLegalFilingsResponse legal_filings = ExperianCalloutService.getLegalFilings(bin_code, auth_credentials);	
    }
    
    @isTest static void testPostCalloutGetLegalFilingsWithFailedResponse(){
        String bin_code = 'TEST_BIN_CODE';
        Boolean exceptionThrown = false;
    	Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"errors": [{"fault": {"faultstring": "Unexpected EOF at target","detail": {"errorcode": "messaging.adaptors.http.flow.UnexpectedEOFAtTarget"}}}]}';
        Integer code = 400;
        String status = 'Bad Request';
        Test.setMock(HttpCalloutMock.class, New ExperianCreditStatusMock(code, status, body, responseHeaders));

        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        try{
    	    ExperianLegalFilingsResponse legal_filings = ExperianCalloutService.getLegalFilings(bin_code, auth_credentials);	
	    }catch (Exception e){
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(true, exceptionThrown, 'Expected an exception to be thrown, but there was no exception');
		}   
    }

    static testMethod void testPostCalloutGetCreditStatusWithSuccessResponse(){
        String bin_code = 'TEST_BIN_CODE';
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        Test.setMock(HttpCalloutMock.class, new ExperianCreditStatusMock());
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        
		ExperianCreditStatusResponse credit_status = ExperianCalloutService.getCreditStatus(bin_code, auth_credentials);        	
    }
    
    @isTest static void testPostCalloutGetCreditStatusWithFailedResponse(){
        String bin_code = 'TEST_BIN_CODE';
        Boolean exceptionThrown = false;
    	Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"errors": [{"fault": {"faultstring": "Unexpected EOF at target","detail": {"errorcode": "messaging.adaptors.http.flow.UnexpectedEOFAtTarget"}}}]}';
        Integer code = 400;
        String status = 'Bad Request';
        Test.setMock(HttpCalloutMock.class, New ExperianCreditStatusMock(code, status, body, responseHeaders));

        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        try{
			ExperianCreditStatusResponse credit_status = ExperianCalloutService.getCreditStatus(bin_code, auth_credentials);
        }catch (Exception e){
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(true, exceptionThrown, 'Expected an exception to be thrown, but there was no exception');
		}   
    }
    
    static testMethod void testPostCalloutGetBusinessScoreWithSuccessResponse(){
        String bin_code = 'TEST_BIN_CODE';
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        Test.setMock(HttpCalloutMock.class, new ExperianBusinessScoreMock());
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        
		ExperianScoreResponse business_score = ExperianCalloutService.getBusinessScore(bin_code, auth_credentials);        	
    }
    
    @isTest static void testPostCalloutGetBusinessScoreWithFailedResponse(){
        String bin_code = 'TEST_BIN_CODE';
        Boolean exceptionThrown = false;
    	Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"errors": [{"fault": {"faultstring": "Unexpected EOF at target","detail": {"errorcode": "messaging.adaptors.http.flow.UnexpectedEOFAtTarget"}}}]}';
        Integer code = 400;
        String status = 'Bad Request';
        Test.setMock(HttpCalloutMock.class, New ExperianBusinessScoreMock(code, status, body, responseHeaders));

        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        try{
			ExperianScoreResponse business_score = ExperianCalloutService.getBusinessScore(bin_code, auth_credentials);
        }catch (Exception e){
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(true, exceptionThrown, 'Expected an exception to be thrown, but there was no exception');
		}   
    }

    @isTest static void testMakeExperianCallForAccount(){
        Boolean exceptionThrown = false;
        Account acc = TestUtility.createAccount('TEST ACCOUNT');
        acc.Name = 'Experian';
        acc.BillingCity = 'Costa Mesa';
        acc.BillingState = 'CA';
        acc.BillingStreet = '475 ANTON BLVD';
        acc.BillingPostalCode = '92626';
        acc.Phone = '9495673800';
        insert acc;
        try{
			Test.startTest();
            ExperianCalloutService.makeCallout(acc.Id);
            Test.stopTest();
        }catch (Exception e){
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(false, exceptionThrown, 'No exception should be catch');
		}
    }    
    
    static testMethod void testCheckLogCreationForSendingSplunk(){
        
        SplunkHelper.Log log_created= ExperianCalloutService.createLog( SplunkHelper.LOGLEVEL.ERROR, 'Log Created', 'Log Stack Created', ACVUtility.currentLineNumber());
        system.assertEquals('Account', log_created.sfObject);
    }
    
    static testMethod void testPostCalloutGetMultisegmentsWithSuccessResponse(){
        String bin_code = 'TEST_BIN_CODE';
        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
    
        Test.setMock(HttpCalloutMock.class, new ExperianMultisegmentsMock());
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        
		ExperianMultisegmentsResponse multisegments = ExperianCalloutService.getMultisegmentsResponse(bin_code, auth_credentials);
    }
    
    @isTest static void testPostCalloutGetMultisegmentsWithFailedResponse(){
        String bin_code = 'TEST_BIN_CODE';
        Boolean exceptionThrown = false;
    	Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '{"errors": [{"fault": {"faultstring": "Unexpected EOF at target","detail": {"errorcode": "messaging.adaptors.http.flow.UnexpectedEOFAtTarget"}}}]}';
        Integer code = 400;
        String status = 'Bad Request';
        Test.setMock(HttpCalloutMock.class, New ExperianMultisegmentsMock(code, status, body, responseHeaders));

        String json_credentials = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(json_credentials, ExperianAuthenticateUser.class);
        try{
    	    ExperianMultisegmentsResponse multisegments = ExperianCalloutService.getMultisegmentsResponse(bin_code, auth_credentials);	
	    }catch (Exception e){
    		exceptionThrown = true;
		}finally{
    		system.assertEquals(true, exceptionThrown, 'Expected an exception to be thrown, but there was no exception');
		}   
    }

    
}