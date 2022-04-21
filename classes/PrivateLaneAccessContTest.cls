/**
 * This class is the test class for PrivateLaneAccessCont
 * @author James Andre LaCour
 */
@isTest
public class PrivateLaneAccessContTest {
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
    @TestSetup
    public static void makeData(){
        Fee__c fee = TestUtility.createFee();
        insert fee;
        Private_Lane__c pl = TestUtility.createPrivateLane();
        insert pl;
        Assigned_Fee__c af = TestUtility.createAssignedFee( fee, pl );
        insert af;
        Group__c orgGroup = TestUtility.createGroup( 'Test Dealership Group' );
        insert orgGroup;
    }
    /********************Test Methods****************************/
     /**
     * Test whether the submit of a Private Lane Access properly hits the endpoint
     * and inserts/updates into the system. Here we do an insert so one should be created
     * @return void
     */
    public static testMethod void submitSuccessTest(){
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c ];
        List<Group__c> grpList = [ SELECT Id FROM Group__c ];
        Boolean buyingPower = false;
        Boolean sellingPower = false;
        String fieldsJson = '{"Organization_Group__c":"' + grpList[0].Id + '","Selling_Power__c":' + sellingPower + ',"Private_Lane__c":"'+ plList[0].Id + '","Buying_Power__c":' + buyingPower + '}';
        Test.setMock( HttpCalloutMock.class, new MockCalloutSetSuccess() );
        Test.startTest();
            PrivateLaneAccessCont.DataWrapper dw = (PrivateLaneAccessCont.DataWrapper)JSON.deserialize( PrivateLaneAccessCont.submit( fieldsJson ), PrivateLaneAccessCont.DataWrapper.class );
        Test.stopTest();
        System.assertEquals( 200 , dw.statusCode );
        System.assertEquals( 'Success', dw.statusMessage );
        List<Private_Lane_Access__c> plaList = [ SELECT Id, Private_Lane__c, Organization_Group__c, Buying_Power__c, Selling_Power__c FROM Private_Lane_Access__c ];
        System.assertEquals( 1, plaList.size() );
        System.assertEquals( plList[0].Id, plaList[0].Private_Lane__c );
        System.assertEquals( grpList[0].Id, plaList[0].Organization_Group__c );
        System.assertEquals( buyingPower, plaList[0].Buying_Power__c );
        System.assertEquals( sellingPower, plaList[0].Selling_Power__c );
    }
    /**
     * Test whether the submit of a Private Lane Access properly hits the endpoint
     * but fails. Nothing should be created in the system for this test
     * @return void
     */
    public static testMethod void submitFailedTest(){
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c ];
        List<Group__c> grpList = [ SELECT Id FROM Group__c ];
        Boolean buyingPower = false;
        Boolean sellingPower = false;
        String fieldsJson = '{"Organization_Group__c":"' + grpList[0].Id + '","Selling_Power__c":' + sellingPower + ',"Private_Lane__c":"'+ plList[0].Id + '","Buying_Power__c":' + buyingPower + '}';
        Test.setMock( HttpCalloutMock.class, new MockCalloutSetFailure() );
        Test.startTest();
            PrivateLaneAccessCont.DataWrapper dw = (PrivateLaneAccessCont.DataWrapper)JSON.deserialize( PrivateLaneAccessCont.submit( fieldsJson ), PrivateLaneAccessCont.DataWrapper.class );
        Test.stopTest();
        System.assertEquals( 422 , dw.statusCode );
        System.assertEquals( 'Test Error', dw.statusMessage );
        List<Private_Lane_Access__c> plaList = [ SELECT Id, Private_Lane__c, Organization_Group__c, Buying_Power__c, Selling_Power__c FROM Private_Lane_Access__c ];
        System.assertEquals( 0, plaList.size() );
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
    /********************Mock Callout Class**********************/
    /**
     * Data stucture for mock success callout for Set
     * @Author James Andre LaCour
     */
    private class MockCalloutSetSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }  
    }
    /**
     * Data structure for mock failure callout for Set
     * @Author James Andre LaCour
     */
    private class MockCalloutSetFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            PrivateLaneAccessAPI.SetResponse dr = new PrivateLaneAccessAPI.SetResponse();
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