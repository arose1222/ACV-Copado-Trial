/**
 * This class is the test class for the RunListSendController
 * @author James Andre LaCour
 */
@isTest
public class RunListSendControllerTest {
     /****************Inner Classes*************************/
     private class MockCalloutGood implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            RunListAPI.RunListResponse rlsRes = new RunListAPI.RunListResponse();
            rlsRes.data = new AuctionLaunchExt.Response();
            AuctionLaunchExt.ResponseData dataSuccess = new AuctionLaunchExt.ResponseData();
            dataSuccess.message = 'success';
            dataSuccess.saved_auction_id = 123;
            dataSuccess.status = 200;
            rlsRes.data.successes = new List<AuctionLaunchExt.ResponseData>{dataSuccess};

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(JSON.serialize(rlsRes));
            return res;
        }
    }
    private class MockCalloutBad implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            RunListAPI.RunListResponse rlsRes = new RunListAPI.RunListResponse();
            rlsRes.detail = 'Failed Response';

            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('ERROR');
            res.setBody(JSON.serialize(rlsRes));
            return res;
        }
    }
    private class MockCalloutMixed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            RunListAPI.RunListResponse rlsRes = new RunListAPI.RunListResponse();
            rlsRes.data = new AuctionLaunchExt.Response();
            AuctionLaunchExt.ResponseData dataErrors = new AuctionLaunchExt.ResponseData();
            dataErrors.message = 'Faield to Schedule';
            dataErrors.saved_auction_id = 123;
            dataErrors.status = 400;
            rlsRes.data.errors = new List<AuctionLaunchExt.ResponseData>{dataErrors};

            HttpResponse res = new HttpResponse();
            res.setStatusCode(202);
            res.setStatus('OK');
            res.setBody(JSON.serialize(rlsRes));
            return res;
        }
    }
    /****************Test Setup****************************/
    /**
     * Creates Test data for each test method
     * @return void
     */
    @TestSetup
    public static void makeData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        Id acvUserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        User u = TestUtility.createUser();
        // u = new User(Alias = 'testSys', Email='systemAdmin@testorg.com', 
        //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        //     LocaleSidKey='en_US', Id__c = '991155', isActive = true,
        //     TimeZoneSidKey='America/Los_Angeles', UserName='systemAdmin@testorg.com',
        u.Id__c = '991155';
        u.UserName = 'systemAdmin@testorg.com';
        insert u;
        Account acct = TestUtility.createAccount('Test Dealership With DealerId');
        acct.Dealership_Id__c = 'dealerId123';
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        acct.OwnerId = u.Id;
        insert acct;
        Contact c = new Contact();
        c.FirstName = UserInfo.getFirstName();
        c.LastName = UserInfo.getLastName();
        c.Id__c = '991155';
        c.OwnerId = u.Id;
        c.AccountId = acct.Id;
        c.recordTypeId = acvUserRecordTypeId;
        c.email = 'test@email.com';
        insert c;
        Affiliation__c aff = new Affiliation__c();
        aff.Active__c = true;
        aff.Account__c = acct.Id;
        aff.Contact__c = c.Id;
        aff.type__c = 'rep';
        insert aff;
        Vehicle__c veh = new Vehicle__c( Name = 'TestVIN');
        insert veh;
        Condition_Report__c cr = new Condition_Report__c();
        cr.Dealership__c = acct.Id;
        cr.VIN__c = 'TestVIN';
        cr.Vehicle__c = veh.id;
        cr.Floor_Price__c = 5000;
        cr.name = '123';
        cr.ACV_Saved_Auction_Id__c = '123';
        Condition_Report__c crFail = new Condition_Report__c();
        crFail.Dealership__c = acct.Id;
        crFail.VIN__c = 'TestFailedVIN';
        crFail.Vehicle__c = veh.id;
        crFail.Floor_Price__c = 10;
        crFail.name = '456';
        crFail.ACV_Saved_Auction_Id__c = '';
        insert new List<Condition_Report__c>{cr, crFail};
    }
    /****************Test Methods**************************/
    /**
     * Tests the intialization of the page. Whats passed in is the selected Inventory Life Cycles
     * @return void
     */
    public static testMethod void initTest(){
        //Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id FROM Inventory_Life_Cycle__c ];
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        String ilcsSelected = JSON.serialize(ilcs);
        //Send to Controller
        Test.startTest();
            string response = '';
            System.runAs(u[0]){
                response = RunListSendController.doInit(ilcsSelected);
            }
        Test.stopTest();
        //System Asserts
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(response, RunListSendController.ReturnWrapper.class);
        System.assertEquals(1, rw.eligibleCRs.size(), 'There should be 1 eligible Condition Report found');
        System.assertEquals(1, rw.invalidILCList.size(), 'There should be 1 invalid Condition Report found');
        System.assertEquals(2, rw.activeOpenSections.size(), 'There should be 2 items in the Active Open Sections set: Invalid and CRs');
        System.assertEquals('Successful', rw.successMessage, 'Should be a successful message.');
    }
    /**
     * If an ILC is in the "Scheduling To {insert suffix}" status, it should not be able to be ran
     * @return void
     */
    public static testMethod void schedulingToTest(){
        //Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id FROM Inventory_Life_Cycle__c ];
        for( Inventory_Life_Cycle__c ilc : ilcs ){
            ilc.Processing_Status__c = RunListSendController.SCHEDULING_TO_RUNLIST_STATUS;
        }
        update ilcs;
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        String ilcsSelected = JSON.serialize(ilcs);
        //Send to Controller
        Test.startTest();
            string response = '';
            System.runAs(u[0]){
                response = RunListSendController.doInit(ilcsSelected);
            }
        Test.stopTest();
        //System Asserts
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(response, RunListSendController.ReturnWrapper.class);
        System.assert(rw.eligibleCRs == null, 'There should be 0 eligible Condition Report found');
        System.assertEquals(2, rw.invalidILCList.size(), 'There should be 2 invalid Condition Report found');
        System.assertEquals(1, rw.activeOpenSections.size(), 'There should be 1 item in the Active Open Sections set: Invalid ');
    }
    /**
     * Tests the submission of Send to Run List subtmit button
     * Should have the Inventory Life Cycle status updated to RunListSendController.SCHEDULING_TO_RUNLIST_STATUS
     * @return void
     */
    public static testMethod void submitTest(){
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutGood());
        List<Condition_Report__c> cr = [ SELECT Id, ACV_Saved_Auction_Id__c, Inventory_Life_Cycle__c FROM Condition_Report__c LIMIT 1 ];
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        String dataSubmitWrapperJSON = '{"crs":[{"yearMakeModelTrim":null,"vin":null,"savedAuctionId":"123","reservePrice":5000,"ilcId":"' + cr[0].Inventory_Life_Cycle__c + '","idUrl":"/' + cr[0].Id + '","id":"' + cr[0].Id + '"}]}';
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = RunListSendController.submitSendToRunList(dataSubmitWrapperJSON);
            }
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Status__c FROM Inventory_Life_Cycle__c ];
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(response, RunListSendController.ReturnWrapper.class);
        System.assertEquals(RunListSendController.SCHEDULING_TO_RUNLIST_STATUS, ilc[0].Status__c, 'Status should be Scheduled for Run List');
    }
    /**
     * Tests the submission of Send to Run List subtmit button with a negative Callout Response
     * @return void
     */
    public static testMethod void submitNegativeBadCalloutTest(){
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutBad());
        List<Condition_Report__c> cr = [ SELECT Id, ACV_Saved_Auction_Id__c, Inventory_Life_Cycle__c FROM Condition_Report__c LIMIT 1 ];
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        String dataSubmitWrapperJSON = '{"crs":[{"yearMakeModelTrim":null,"vin":null,"savedAuctionId":"123","reservePrice":5000,"ilcId":"' + cr[0].Inventory_Life_Cycle__c + '","idUrl":"/' + cr[0].Id + '","id":"' + cr[0].Id + '"}]}';
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = RunListSendController.submitSendToRunList(dataSubmitWrapperJSON);
            }
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Status__c FROM Inventory_Life_Cycle__c ];
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(response, RunListSendController.ReturnWrapper.class);
        System.assertNotEquals(RunListSendController.SCHEDULING_TO_RUNLIST_STATUS, ilc[0].Status__c, 'Status should not be Scheduled for Run List');
    }
    /**
     * Tests the submission of Send to Run List subtmit button with a negative Callout Response
     * @return void
     */
    public static testMethod void submitNegativeFailedToScheduleTest(){
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutMixed());
        List<Condition_Report__c> cr = [ SELECT Id, ACV_Saved_Auction_Id__c, Inventory_Life_Cycle__c FROM Condition_Report__c LIMIT 1 ];
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        String dataSubmitWrapperJSON = '{"crs":[{"yearMakeModelTrim":null,"vin":null,"savedAuctionId":"123","reservePrice":5000,"ilcId":"' + cr[0].Inventory_Life_Cycle__c + '","idUrl":"/' + cr[0].Id + '","id":"' + cr[0].Id + '"}]}';
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = RunListSendController.submitSendToRunList(dataSubmitWrapperJSON);
            }
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Status__c FROM Inventory_Life_Cycle__c ];
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(response, RunListSendController.ReturnWrapper.class);
        System.assertNotEquals(RunListSendController.SCHEDULING_TO_RUNLIST_STATUS, ilc[0].Status__c, 'Status should not be Scheduled for Run List');
    }
    /**
     * Tests the constructor for the VF pages which handles the passign in of records
     * selected via the list view
     * @return void
     */
    public static testMethod void vfExtensionConstructorTest(){
        //Gather Data
        Test.setCurrentPage(Page.RunListSendWrapper);
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id FROM Inventory_Life_Cycle__c LIMIT 1 ];
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(ilcs);
        std.setSelected(ilcs);
        //Send to Controller
        Test.startTest();
            RunListSendController rlsCont;
            System.runAs(u[0]){
                rlsCont = new RunListSendController(std);
            }
        Test.stopTest();
        //System Asserts
        System.assertEquals(ilcs, rlsCont.selectedRecords, 'The wrong records were selected');
        System.assertEquals(JSON.serialize(ilcs), rlsCont.selectedRecordsJSON, 'The wrong records were JSON Serialized');
    }
    /**
     * Tests the creation of the SplunkLog that will be sent to the 
     * Splunk server on failures
     * @return void
     */
    public static testMethod void createSplunkLogTest(){
        //Gather Data
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        //Send to Controller
        Test.startTest();
            SplunkHelper.log log;
            System.runAs(u[0]){
                log = RunListSendController.createLog(SplunkHelper.LOGLEVEL.FATAL, 'testMessage', 'Test Stack trace', 1, 'Test Record Id');
            }
        Test.stopTest();
        //System Asserts
        System.assertEquals(log.logLevel, SplunkHelper.LOGLEVEL.FATAL, 'Wrong loglevel');
        System.assertEquals(log.message, 'testMessage', 'Wrong Message');
        System.assertEquals(log.stackTrace, 'Test Stack trace', 'Wrong Stack Trace');
        System.assertEquals(log.location, 'RunListSendController Line #1', 'Wrong location');
        System.assertEquals(log.sfRecordId, 'Test Record Id', 'Wrong Salesforce Record Id');
        System.assertEquals(log.sfObject, 'Inventory Life Cycle', 'Wrong Salesforce Object');
        System.assertEquals(log.version, 'v1', 'Wrong Version');
        System.assertEquals(log.componentName, 'LWC - Send to Run List', 'Wrong Component Name');
        System.assertEquals(log.domainSet, new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SUPPLY}, 'Wrong Domain');
    }
}