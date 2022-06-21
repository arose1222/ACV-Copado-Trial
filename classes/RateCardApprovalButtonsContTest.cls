/**
 * Test Class for Rate Card Approval Buttons Cont
 * @author James Andre LaCour
 * @since May 6th, 2021
 */
@isTest
public class RateCardApprovalButtonsContTest {
    /**
     * Creates Test Data
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        User testUser = TestUtility.createUser();
        testUser.email = 'testingonetwothree@test.test';
        testUser.Id__c = '1234';
        User testUser2 = TestUtility.createUser();
        testUser2.Email = 'noPermissionUser@test.test';
        insert new List<User>{testUser, testUser2};
        addUserToQueue(testUser.Id);
    }
    /**
     * Test that a true is only returned when you have access to the Queue
     * To be an approver
     */
    public static testMethod void checkApprovalPermissionsTest(){
        createTestData();
        List<Rate_Card__c> rcList = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals(1, rcList.size());
        sendToApproval( rcList[0].Id );
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        Test.startTest();
        Boolean hasAccess = false;
            System.runAs(testUser){
                hasAccess = RateCardApprovalButtonsCont.checkApprovalPermissions(rcList[0].Id);
            }
            System.assertEquals( true, hasAccess );
            testUser = [ SELECT Id FROM User WHERE Email = 'noPermissionUser@test.test' LIMIT 1 ];
            System.runAs(testUser){
                hasAccess = RateCardApprovalButtonsCont.checkApprovalPermissions(rcList[0].Id);
            }
        Test.stopTest();
        System.assertEquals(false, hasAccess);
    }
    /**
     * Does a full success test of Approve
     */
    
    public static testMethod void approveSuccessTest(){
        createTestData();
        List<Rate_Card__c> rcList = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals( 1, rcList.size() );
        System.assertEquals( true, sendToApproval(rcList[0].Id).isSuccess() );
        String testComments = 'Test Comment';
        Test.setMock( HttpCalloutMock.class, new MockCalloutApproveSuccess() );
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        Test.startTest();
            RateCardApprovalButtonsCont.ReturnWrapper rw = null;
            System.runAs(testUser){
                rw = (RateCardApprovalButtonsCont.ReturnWrapper)JSON.deserialize( RateCardApprovalButtonsCont.approve( testComments, rcList[0].Id ), RateCardApprovalButtonsCont.ReturnWrapper.class );
            }
        Test.stoptest();
        System.assertEquals( false, rw.hasError );
        System.assertEquals( '', rw.message );
        rcList = [ SELECT Id, Approval_Status__c FROM Rate_Card__c WHERE Id = :rcList[0].Id LIMIT 1 ];
        System.assertEquals( 'Published', rcList[0].Approval_Status__c );
    }
    
    /**
     * Test the response when reaching out to the API fails
     */
    public static testMethod void approveRateCardApiFailedTest(){
        createTestData();
        List<Rate_Card__c> rcList = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals( 1, rcList.size() );
        System.assertEquals( true, sendToApproval(rcList[0].Id).isSuccess() );
        String testComments = 'Test Comment';
        Test.setMock( HttpCalloutMock.class, new MockCalloutApproveRateCardApiFails() );
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        Test.startTest();
            RateCardApprovalButtonsCont.ReturnWrapper rw = null;
            System.runAs(testUser){
                rw = (RateCardApprovalButtonsCont.ReturnWrapper)JSON.deserialize( RateCardApprovalButtonsCont.approve( testComments, rcList[0].Id ), RateCardApprovalButtonsCont.ReturnWrapper.class );
            }
        Test.stoptest();
        System.assertEquals( true, rw.hasError );
        System.assertEquals( 'There was an issue when processing this request. A Salesforce Admin has been notified.', rw.message );
        rcList = [ SELECT Id, Approval_Status__c FROM Rate_Card__c WHERE Id = :rcList[0].Id LIMIT 1 ];
        System.assertEquals( 'In Review', rcList[0].Approval_Status__c );
    }
    /**
     * This test the Validation for Rate Card Fees method
     */
    
    public static testMethod void validateRateCardFeesTest(){
        Rate_Card_Fee__c rc1 = TestUtility.createRateCardFee( 1, 100 );
        Rate_Card_Fee__c rc2 = TestUtility.createRateCardFee( 5, 500 );
        Rate_Card_Fee__c rc3 = TestUtility.createRateCardFee( 5, 50 );
        Rate_Card_Fee__c rc4 = TestUtility.createRateCardFee( 1, 200 );
        List<Rate_Card_Fee__c> passingValidationFees = new List<Rate_Card_Fee__c>{rc1, rc2};
        List<Rate_Card_Fee__c> noRateCardFees = new List<Rate_Card_Fee__c>();
        List<Rate_Card_Fee__c> no1dollarFeeChargeFees = new List<Rate_Card_Fee__c>{rc2};
        List<Rate_Card_Fee__c> feeChargedTooLowFees = new List<Rate_Card_Fee__c>{rc1, rc3};
        List<Rate_Card_Fee__c> duplicateFees = new List<Rate_Card_Fee__c>{rc1, rc4};
        Test.startTest();
            String errorMessage = RateCardApprovalButtonsCont.validateRateCardFees(passingValidationFees);
            System.assert( String.isBlank(errorMessage), errorMessage );
            errorMessage = RateCardApprovalButtonsCont.validateRateCardFees(noRateCardFees);
            System.assert( errorMessage == 'There are no Rate Card Fees attached to the Rate Card', errorMessage );
            errorMessage = RateCardApprovalButtonsCont.validateRateCardFees(no1dollarFeeChargeFees);
            System.assert(  errorMessage == 'At least one rate card must have a Price Minimum of $1', errorMessage );
            errorMessage = RateCardApprovalButtonsCont.validateRateCardFees(feeChargedTooLowFees);
            System.assert(  errorMessage.startsWithIgnoreCase('The Fee Chagred for Price Minimum $'), errorMessage );
            errorMessage = RateCardApprovalButtonsCont.validateRateCardFees(duplicateFees);
            System.assert(  errorMessage.startsWithIgnoreCase('There is a duplicate Price Minimum for the Price Minimum $'), errorMessage );
        Test.stopTest();
    }
    /**
     * Test the rejection method
     */
    
    public static testMethod void rejectTest(){
        createTestData();
        List<Rate_Card__c> rcList = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals( 1, rcList.size() );
        System.assertEquals( true, sendToApproval(rcList[0].Id).isSuccess() );
        String testComments = 'Test Comment';
        Test.startTest();
            RateCardApprovalButtonsCont.ReturnWrapper rw = (RateCardApprovalButtonsCont.ReturnWrapper)JSON.deserialize( RateCardApprovalButtonsCont.reject( testComments, rcList[0].Id ), RateCardApprovalButtonsCont.ReturnWrapper.class );
        Test.stoptest();
        System.assertEquals( false, rw.hasError );
        System.assertEquals( '', rw.message );
        rcList = [ SELECT Id, Approval_Status__c FROM Rate_Card__c WHERE Id = :rcList[0].Id LIMIT 1 ];
        System.assertEquals( 'Draft', rcList[0].Approval_Status__c );
    }
    /**
     * Test the helper method of submitting the action of approve/reject
     */
    
    public static testMethod void createApprovalProcessSubmissionTest(){
        createTestData();
        List<Rate_Card__c> rcList = [ SELECT Id FROM Rate_Card__c LIMIT 1 ];
        System.assertEquals( 1, rcList.size() );
        System.assertEquals( true, sendToApproval(rcList[0].Id).isSuccess() );
        String testComments = 'Test Comment';
        String testActionType = 'Approve';
        Test.startTest();
            Approval.ProcessWorkitemRequest pwr = RateCardApprovalButtonsCont.createApprovalProcessSubmission( testComments, rcList[0].Id, testActionType );
        Test.stopTest();
        System.assertEquals( testActionType, pwr.getAction() );
        System.assertEquals( testComments, pwr.getComments() );
    }
    /**
     * Tests the helper method to create a Log works properly
     */
    
    public static testMethod void createLogTest(){
        SplunkHelper.LOGLEVEL logLevel = SplunkHelper.LOGLEVEL.INFO;
        String message = 'Test Log Message';
        String stackTrace = 'Test Stack Trace';
        Integer lineNumber = 11;
        String recordId = UserInfo.getUserId();
        Test.startTest();
            SplunkHelper.Log log = PrivateLaneAccessCont.createLog( loglevel, message, stackTrace, lineNumber, recordId );
        Test.stopTest();
        System.assertEquals( logLevel, log?.logLevel );
        System.assertEquals( message, log?.message );
        System.assertEquals( stackTrace, log?.stackTrace );
        System.assertEquals( recordId , log?.sfRecordId );
        System.assertEquals( 'Private Lane', log?.sfObject );
        System.assertEquals( 'v1', log?.version );
        System.assertEquals( 'LWC - PrivateLaneAccessLayout', log?.componentName );
        System.assertEquals( 'PrivateLaneAccessCont Line #' + String.valueOf(lineNumber), log?.location);
    }
  
    /**
     * Helper Test method for adding a user to the Queue
     * @param userId salesforce user id
     */
    public static void addUserToQueue( Id userId ){
        Group rateCardApproverGroup = [ SELECT Id FROM Group WHERE DeveloperName = :RateCardApprovalButtonsCont.RATE_CARD_APPROVER_QUEUE_DEVELOPER_NAME LIMIT 1 ];
        GroupMember gm = new GroupMember();
        gm.UserOrGroupId = userId;
        gm.GroupId = rateCardApproverGroup.Id;
        insert gm;
    }
    /**
     * Helper Test method for setting up a Rate Card in the Approval Process
     * @param recordId 
     * @return  `Approval.ProcessResult` the result of the Approval
     */
    public static Approval.ProcessResult sendToApproval( String recordId ){
        Approval.ProcessSubmitRequest item = new Approval.ProcessSubmitRequest();
        item.setObjectID(recordId);
        item.setProcessDefinitionNameOrId('Rate_Card');
        return Approval.Process(item);
    }
    /**
     * Create Test Data to avoid MIXED_Dml
     */
    public static void createTestData(){
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        System.runAs(testUser){
            Rate_Card__c rc = TestUtility.createRateCard();
            rc.Approval_Status__c = 'In Review';
            insert rc;
            Rate_Card_Fee__c rcf = TestUtility.createRateCardFee(rc, 1, 100);
            insert rcf;
        }

        Account acct = TestUtility.createAccount();
        insert acct;
        Contact c = TestUtility.createContact(acct);
        c.Email = 'testingonetwothree@test.test';
        c.Id__c = '1234';
        insert c;       
        
    }
    /**
     * Data stucture for mock success callout for approve endpoint
     * @Author James Andre LaCour
     */
    private class MockCalloutApproveSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            if( req.getEndpoint().endsWith(RateCardApi.PUBLISH_RATE_CARD_ENDPOINT_SUFFIX) ){
                res.setStatusCode(201);
                res.setStatus('OK');
                RateCardApi.PublishRateCardResponse responseBody = new RateCardApi.PublishRateCardResponse();
                responseBody.data = new RateCardApi.ResponseData();
                responseBody.data.id = 1234;
                res.setBody( JSON.serialize(responseBody) );
            }else if( req.getEndpoint().contains('splunkcloud') ){
                res.setStatusCode(200);
                res.setStatus('OK');
            }else{
                res.setStatusCode(200);
                res.setStatus('OK');
                res.setBody( '{"jwtToken":"test token"}' );
            }
            return res;
        }  
    }
    /**
     * Data stucture for mock failed api callout for approve endpoint
     * @Author James Andre LaCour
     */
    private class MockCalloutApproveRateCardApiFails implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            if( req.getEndpoint().endsWith(RateCardApi.PUBLISH_RATE_CARD_ENDPOINT_SUFFIX) ){
                res.setStatusCode(403);
                res.setStatus('ERROR');
                res.setBody( '{"errors":[{"detail":"the lowest price point must be 1"}]}' );
            }else if( req.getEndpoint().contains('splunkcloud') ){
                res.setStatusCode(200);
                res.setStatus('OK');
            }else{
                res.setStatusCode(200);
                res.setStatus('OK');
                res.setBody( '{"jwtToken":"test token"}' );
            }
            return res;
        }  
    }
}