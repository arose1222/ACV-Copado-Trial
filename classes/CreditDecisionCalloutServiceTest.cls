/**
 * @description Tests for the Service Class that handle calls to the credit decision process. Currently calls the Salesforce Gateway that calls Line of Credit. 
 * @author Oscar Argueyo
 * @since 06/16/2022
 * @group Capital
 * @see [CSO-660]https://acvauctions.atlassian.net/browse/CSO-660
 */
@istest
public class CreditDecisionCalloutServiceTest {
	
    /**
     * @description Test making post request to Credit Decision Service with Success Response (using Mock Request). 
     */
    @isTest 
    static void testPostCalloutCreditDecisionWithSuccessResponse(){
        Boolean exceptionThrown = false;
        
    	Test.setMock(HttpCalloutMock.class, new CapitalCreditDecisionCalloutMock());
        ACV_Credit_decision__mdt credit_decision_data = CreditDecisionCalloutService.getCreditDecisionCustomMDT();
        JSONGenerator application = JSON.createGenerator(true);
        application.writeStartObject();      
        application.writeFieldName('data');
        application.writeStartObject();
        application.writeEndObject();
        application.writeEndObject();
        application.close();
        try{
			Test.startTest();
            CreditDecisionCalloutService.callCreditDecisionService(application.getAsString(), credit_decision_data.Endpoint_URL__c);
            Test.stopTest();
        }catch (CreditDecisionCalloutException e){
    		exceptionThrown = true;
		}finally{
    		System.assertEquals(false, exceptionThrown, 'No exception should be catch');
		}
    }
    
    /**
     * @description Test making post request to Credit Decision Service with Error Response (using Mock Request). 
     */
    @isTest static void testPostCalloutCreditDecisionWithErrorResponse(){
        Boolean exceptionThrown = false;
        Map<String, String> responseHeaders = new Map<String, String>{'Content-Type' => 'application/json'};
        String body = '';
        Integer code = 400;
        String status = 'Bad Request';
    	
        Test.setMock(HttpCalloutMock.class, new CapitalCreditDecisionCalloutMock(code, status, body, responseHeaders));
        
        ACV_Credit_decision__mdt credit_decision_data = CreditDecisionCalloutService.getCreditDecisionCustomMDT();
        
        JSONGenerator application = JSON.createGenerator(true);
        application.writeStartObject();      
        application.writeFieldName('data');
        application.writeStartObject();
        application.writeEndObject();
        application.writeEndObject();
        application.close();
        
        try{
			Test.startTest();
            CreditDecisionCalloutService.callCreditDecisionService(application.getAsString(), credit_decision_data.Endpoint_URL__c);
            Test.stopTest();
        }catch (CreditDecisionCalloutException e){
    		exceptionThrown = true;
		}
    	System.assertEquals(true, exceptionThrown, 'An exception was thrown');
    }
    
    /**
     * @description Update additional comments field in Opportunity with a given message 
     */
    @isTest 
    static void testCheckLogCreationForSendingSplunk(){
        
        SplunkHelper.Log logCreated = CreditDecisionCalloutService.createLog( SplunkHelper.LOGLEVEL.ERROR, 'Log Created', 'Log Stack Created', ACVUtility.currentLineNumber());
        System.assertEquals('Opportunity', logCreated.sfObject);
    }
    
    /**
     * @description Test for calling the Credit Decision Endpoint (With Mock Class)
     */
    @isTest 
    static void testmakeCallOutResponse(){
        Boolean exceptionThrown = false;
        List <Opportunity> opps = createAccountsWithOpps(1,1);
        if (opps.isEmpty() == false){
            Opportunity opportunity = opps[0];
            Test.setMock(HttpCalloutMock.class, new CapitalCreditDecisionCalloutMock());
            ACV_Credit_decision__mdt creditDecisionData = CreditDecisionCalloutService.getCreditDecisionCustomMDT();
            JSONGenerator application = JSON.createGenerator(true);
            application.writeStartObject();      
            application.writeFieldName('data');
            application.writeStartObject();
            application.writeEndObject();
            application.writeEndObject();
            application.close();
            try{
                Test.startTest();
                CreditDecisionCalloutService.makeCallout(String.valueOf(opportunity.Id));
                Test.stopTest();
            }catch (CreditDecisionCalloutException e){
                exceptionThrown = true;
            }finally{
                System.assertEquals(false, exceptionThrown, 'No exception should be catch');
            }
        }
    	
    }
    
    /**
     * @description Test for updating Opportunity Addional Comments with custom message 
     */
    @isTest 
    static void testUpdateOpportunityAdditionalComments(){
        Boolean opp_founded = False;
        List <Opportunity> opps = createAccountsWithOpps(1,1);
        if (opps.isEmpty() == false){
            Opportunity opportunity = opps[0];
  
	        CreditDecisionCalloutService.updateOpportunityComment(String.valueOf(opportunity.Id), 'Test Message' );
        	
            test.startTest();
        	List <Opportunity> opps_list = [SELECT Id, AdditionalComments__c FROM Opportunity 
                                        WHERE Id= :opportunity.Id];
        
            for (Opportunity oppFounded: opps_list){
                if(oppFounded.AdditionalComments__c == 'Test Message'){
                    opp_founded = True;
                }
            }
        
            System.assertEquals(True,opp_founded);
            test.stopTest();        
        }
    }
	
    /**
	 * @description Test get request body from application, opportunity and principals information call json parser.
     * 
     */
    @isTest 
    static void testGetCreditDecisionRequestBody(){
        test.startTest();
        Application__c application = createApplication(1);
        Principal__c owner = createBusinessOwner(application);
        
        String jsonExpected = '{"data" : {"business" : {'+
            				   '"ref_id" : "'+application.Opportunity__c+'",'+
            				   '"app_id" : "'+application.Id+'",'+
            				   '"name" : "TEST New Experian ACCOUNT - 1",'+
            				   '"taxId" : "",'+
                               '"bank_address" : {'+        
                               '"street" : "Test Bank Address 1234",'+
                               '"city" : "Test Bank City",'+
                               '"state" : "TX",'+
                               '"zip" : "1234567",'+
                               '"phone" : "123456789"'+
                               '},'+
            				   '"business_address" : {}},'+
            				   '"owners":[{'+
            							'"ref_id":"'+owner.Id+'","owner_type":"Individual","owner_title":"Owner",'+
                                        '"first_name":"Test Name Contact","middle_name":"M","last_name":"Test Name LastName",'+
            							'"ssn":"123456789","dob":"2010-10-10","street":"TestAddress1234","state":"OwnerState",'+
                                        '"city":"Owner City","zip_code":"123456","phone":"123456789","ownership":"100"}]'+
                               '}}';
        
        jsonExpected = jsonExpected.trim();
        jsonExpected = jsonExpected.replaceAll('(\\s+)', '');
        
        JSONGenerator jsonRequestBody = CreditDecisionCalloutService.getInputBodyForApplications(application);
        String actualResponse = jsonRequestBody.getAsString();
        actualResponse = actualResponse.trim();
        actualResponse = actualResponse.replaceAll('(\\s+)', '');
        System.assertEquals(jsonExpected, actualResponse, 'Input body for applications');
        test.stopTest();
    }    
	
    /**
     * @description Setup function for opportunity Creation with Account
     */
    public static List<Opportunity> createAccountsWithOpps(Integer numAccts, Integer numOppsPerAcct) {
        List<Account> accts = new List<Account>();
        User owner = TestUtility.createSystemAdministratorUser();
        insert owner;
        for(Integer i=0;i<numAccts;i++) {
            Account a = TestUtility.createAccount('TEST Experian ACCOUNT');
            a.ACV_Capital_Sales_Rep__c = owner.Id;
            a.OwnerId = owner.Id;
            accts.add(a);
        }
        insert accts;
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer j=0;j<numAccts;j++) {
            Account testAccount = accts[j];
            // For each account just inserted, add opportunities
            for (Integer k=0;k<numOppsPerAcct;k++) {
                opps.add(new Opportunity(Name=testAccount.Name + ' Opportunity ' + k,
                                       StageName='New',
                                       CloseDate=System.today().addMonths(1),
                                       OwnerId=owner.Id,
                                       AccountId=testAccount.Id));
            }
        }
        
        insert opps;
        return opps;
    }
    
    /**
     * @description Setup function for application Creation with Account and its Opportunity 
     * 
     */
    public static Application__c createApplication(Integer ref){
        Account testAccount = TestUtility.createAccount('TEST New Experian ACCOUNT');
        User owner = TestUtility.createSystemAdministratorUser();
        insert owner;
        testAccount.ACV_Capital_Sales_Rep__c = owner.Id;
        testAccount.BillingStreet = 'Test Business Street'; 
        testAccount.BillingState = 'TX';
        testAccount.BillingCity = 'Test Business City';
        testAccount.BillingPostalCode = '123456';
        testAccount.Phone = '123456789';
        testAccount.Tax_ID__c = '123456789';
        testAccount.OwnerId = owner.Id;
        insert testAccount;
        
        Opportunity opportunity = new Opportunity(Name=testAccount.Name + ' Opportunity ',
                                       StageName='New',
                                       CloseDate=System.today().addMonths(1),
                                       OwnerId=owner.Id,
                                       AccountId=testAccount.Id);
        insert opportunity;
        Application__c app = new Application__c(
            Name=testAccount.Name + ' - ' +ref,
            Opportunity__c=opportunity.Id,
            Bank_Address__c = 'Test Bank Address 1234', 
            Bank_City__c = 'Test Bank City', 
            Bank_Zip__c = '1234567',  
            Bank_State__c = 'TX', 
            Bank_Phone_Number__c = '123456789',
            OwnerId=owner.Id,
            Account__c=testAccount.Id,
            RecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('ACV_Capital_Application').getRecordTypeId()
        );
        
        insert app;
        return app;
    }
    
    /**
     * @description Setup function for Business Owners (Principal__c) Creation for a Given Application(Application__c) 
     * 
     */
    public static Principal__c createBusinessOwner(Application__c application){
        
        Account account = [SELECT Id FROM Account 
                            WHERE Id= :application.Account__c limit 1];
        
        Contact testContact = TestUtility.createContact(account);
        testContact.MiddleName = 'M';
        insert testContact;
        
        Principal__c appOwner = new Principal__c();
        appOwner.Application__c = application.Id;
        appOwner.Ownership__c = 100;
        appOwner.City__c = 'Owner City';
        appOwner.State__c = 'Owner State';
        appOwner.principalHome_Address__c = 'Test Address 1234';
        appOwner.Owner_Name__c = testContact.Id;
        appOwner.Principal_Date_of_BIrth_c__c = date.newInstance(2010,10,10);
        appOwner.principalPhone__c = '123456789';
        appOwner.Z__c = '123456';
        appOwner.SSN__c = '123456789';
        appOwner.OwnerTitle__c = 'Owner';
        appOwner.Principal_Type__c = 'Individual';
       
        insert appOwner;
        return appOwner;
    }
}