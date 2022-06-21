/**
 * This class is the test class for ParticipatingDealershipGroupsRLCont
 * @author James Andre LaCour
 */
@isTest
public class ParticipatingDealershipGroupsRLContTest {
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Fee__c fee = TestUtility.createFee();
        insert fee;
        Private_Lane__c pl = TestUtility.createPrivateLane();
        insert pl;
        Assigned_Fee__c af = TestUtility.createAssignedFee( fee, pl );
        insert af;
        Group__c orgGroup = TestUtility.createGroup( 'Test Dealership Group' );
        insert orgGroup;
        Private_Lane_Access__c pla = TestUtility.createPrivateLaneAccess( pl, orgGroup );
        insert pla;
    }
    /********************Test Methods****************************/
     /**
     * Tests that the intialization of the Page properly passes in the record id and returns the 
     * Private Lane Accesses associated.
     * @return void
     */
    public static testMethod void getPrivateLaneAccessTestWithRecord(){
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c LIMIT 1 ];
        System.assert( !plList.isEmpty(), 'No Private List Found' );
        Test.startTest();
            ParticipatingDealershipGroupsRLCont.ReturnWrapper rw = (ParticipatingDealershipGroupsRLCont.ReturnWrapper)JSON.deserialize( ParticipatingDealershipGroupsRLCont.getPrivateLaneAccess( plList[0]?.Id ), ParticipatingDealershipGroupsRLCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals( false, rw.hasError, 'There should be no error in the Return Wrapper' );
        System.assertEquals( '', rw.message, 'There should be a blank message indicating Success' );
        System.assertEquals( 1, rw.plaList.size(), 'There should be 1 Private Lane Access records found' );
    }
     /**
     * Tests that if no Private Lane ID is passed in, the intialization properly fails
     * @return void
     */
    public static testMethod void getPrivateLaneAccessTestNoRecordId(){
        String blankId = '';
        Test.startTest();
            ParticipatingDealershipGroupsRLCont.ReturnWrapper rw = (ParticipatingDealershipGroupsRLCont.ReturnWrapper)JSON.deserialize( ParticipatingDealershipGroupsRLCont.getPrivateLaneAccess( blankId ), ParticipatingDealershipGroupsRLCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals( true, rw?.hasError, 'There should be an error in the Return Wrapper');
        System.assertEquals('Please contact a Salesforce Admin', rw?.message, 'There should be an error message indicating failure');
        System.assertEquals(0, rw.plaList.size(), 'There should be 0 Private Lane Access records found');
    }
     /**
     * Tests that the deletion of a Private Lane Access properly checks and deletes on the endpoint
     * and then deletes in Salesforce
     * @return void
     */
    public static testMethod void deletePLATestSuccess(){
        List<Private_Lane_Access__c> plaList = [ SELECT Id FROM Private_Lane_Access__c LIMIT 1 ];
        System.assert( !plaList.isEmpty(), 'No Private List Access\'s Found' );
        Test.setMock( HttpCalloutMock.class, new MockCalloutDeleteSuccess() );
        Test.startTest();
            ParticipatingDealershipGroupsRLCont.ReturnWrapper rw = (ParticipatingDealershipGroupsRLCont.ReturnWrapper)JSON.deserialize( ParticipatingDealershipGroupsRLCont.deletePLA( plaList[0]?.Id ), ParticipatingDealershipGroupsRLCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals( false, rw?.hasError, 'We should have no error as it was a successful deletion' );
        System.assertEquals( '', rw?.message, 'There should be a blank message indicating Success' );
        System.assertEquals( 0, rw.plaList.size(), 'There should be 0 Private Lane Access records found as thats only used in intiailization');
        Id plaId = plaList[0]?.Id;
        List<Private_Lane_Access__c> plaListCheck = [ SELECT Id FROM Private_Lane_Access__c WHERE Id = :plaId ];
        System.assertEquals( 0, plaListCheck.size(), 'There should be no record as we delete the record out the system on success' );
    }
     /**
     * Tests that the failure of a deletion from the endpoint does not affect the record in Salesforce.
     * @return void
     */
    public static testMethod void deletePLATestFailure(){
        List<Private_Lane_Access__c> plaList = [ SELECT Id FROM Private_Lane_Access__c LIMIT 1 ];
        System.assert( !plaList.isEmpty(), 'No Private List Access\'s Found' );
        Test.setMock( HttpCalloutMock.class, new MockCalloutDeleteFailure() );
        Test.startTest();
            ParticipatingDealershipGroupsRLCont.ReturnWrapper rw = (ParticipatingDealershipGroupsRLCont.ReturnWrapper)JSON.deserialize( ParticipatingDealershipGroupsRLCont.deletePLA( plaList[0]?.Id ), ParticipatingDealershipGroupsRLCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals( true, rw?.hasError, 'We should have an error as it the endpoint mocked a failure' );
        System.assertEquals( 'Test Error', rw?.message, 'There should be a blank message indicating Success' );
        System.assertEquals( 0, rw.plaList.size(), 'There should be 0 Private Lane Access records found as thats only used in intiailization');
        Id plaId = plaList[0]?.Id;
        List<Private_Lane_Access__c> plaListCheck = [ SELECT Id FROM Private_Lane_Access__c WHERE Id = :plaId ];
        System.assertEquals( 1, plaListCheck.size(), 'There should be a record as we don\'t delete on failure' );
    }
     /**
     * Tests the helper method to create a Log works properly
     * @return void
     */
    public static testMethod void createLogTest(){
        SplunkHelper.LOGLEVEL logLevel = SplunkHelper.LOGLEVEL.INFO;
        String message = 'Test Log Message';
        String stackTrace = 'Test Stack Trace';
        Integer lineNumber = 11;
        String recordId = UserInfo.getUserId();
        Test.startTest();
            SplunkHelper.Log log = ParticipatingDealershipGroupsRLCont.createLog( loglevel, message, stackTrace, lineNumber, recordId );
        Test.stopTest();
        System.assertEquals( logLevel, log?.logLevel );
        System.assertEquals( message, log?.message );
        System.assertEquals( stackTrace, log?.stackTrace );
        System.assertEquals( recordId , log?.sfRecordId );
        System.assertEquals( 'Private Lane', log?.sfObject );
        System.assertEquals( 'v1', log?.version );
        System.assertEquals( 'LWC - ParticipatingDealershipGroupRL', log?.componentName );
        System.assertEquals( 'ParticipatingDealershipGroupsRLCont Line #' + String.valueOf(lineNumber), log?.location);
    }
    /********************Mock Callout Class**********************/
    /**
     * Data stucture for mock success callout for Delete
     * @Author James Andre LaCour
     */
    private class MockCalloutDeleteSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }  
    }
    /**
     * Data structure for mock failure callout for Delete
     * @Author James Andre LaCour
     */
    private class MockCalloutDeleteFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            PrivateLaneAccessAPI.DeleteResponse dr = new PrivateLaneAccessAPI.DeleteResponse();
            PrivateLaneAccessAPI.ErrorDetail ed = new PrivateLaneAccessAPI.ErrorDetail();
            ed.type = 'Error';
            ed.msg = 'Test Error';
            ed.loc = new List<String>{'Test Line'};
            dr.detail = new List<PrivateLaneAccessApi.ErrorDetail>{ed};
            HttpResponse res = new HttpResponse();
            res.setStatusCode(422);
            res.setStatus('Error');
            res.setBody(JSON.serialize(dr));
            return res;
        }  
    }
}