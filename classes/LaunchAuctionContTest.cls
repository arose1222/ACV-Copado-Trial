@isTest
public class LaunchAuctionContTest {
    /****************Test Setup****************************/
    /**
     * Creates Test data for each test method
     * @return void
     */
    @TestSetup
    public static void makeData(){
        List<Profile> pList = [ SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1 ]; 
        // User u = new User(Alias = 'testSys', Email='systemAdmin@testorg.com', 
        //     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        //     LocaleSidKey='en_US', ProfileId = pList[0].Id, Id__c = '991155', isActive = true,
        //     TimeZoneSidKey='America/Los_Angeles', UserName='systemAdmin@testorg.com');
        User u = TestUtility.createSystemAdministratorUser();
        u.Id__c = '991155';
        u.Email='systemAdmin@testorg.com';
        u.Username = 'systemAdmin@testorg.com';
        insert u;
        Account acct = TestUtility.createAccount('Test Dealership With DealerId');
        acct.Dealership_Id__c = 'dealerId123';
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        acct.OwnerId = u.Id;
        insert acct;
        Contact c = TestUtility.createContact(acct);
        c.Id__c = '991155';
        c.Email='systemAdmin@testorg.com';
        c.OwnerId = u.Id;
        insert c;
        Affiliation__c aff = new Affiliation__c();
        aff.Active__c = true;
        aff.Account__c = acct.Id;
        aff.Contact__c = c.Id;
        insert aff;
        Vehicle__c veh = TestUtility.createVehicle();
        veh.Name = 'TestVIN';
        insert veh;
        Condition_Report__c cr = TestUtility.createCr(veh);
        cr.Dealership__c = acct.Id;
        cr.VIN__c = 'TestVIN';
        cr.Floor_Price__c = 5000;
        cr.name = '123';
        cr.ACV_Saved_Auction_Id__c = '123';
        Condition_Report__c crFail = TestUtility.createCr(veh);
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
     * Test the intialization of Launch Auction modal
     * @return void
     */
    public static testMethod void intializeTest(){
        // Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id FROM Inventory_Life_Cycle__c ];
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        String ilcsSelected = JSON.serialize(ilcs);
        // Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = LaunchAuctionCont.intialize(ilcsSelected);
            }
        Test.stopTest();
        // System Asserts
        LaunchAuctionCont.DataWrapper dw = (LaunchAuctionCont.DataWrapper)JSON.deserialize(response, LaunchAuctionCont.DataWrapper.class);
        System.assertEquals(1, dw.launchOptionsList[0].eligibleList.size(), 'There should be 1 eligible Condition Report found for Auction');
        System.assertEquals(1, dw.launchOptionsList[0].ineligibleList.size(), 'There should be 1 invalid Condition Report found for Ineligible');
        System.assertEquals(1, dw.launchOptionsList.size(), 'There should be 1 Launch Option');
        System.assertEquals(200, dw.statusCode, 'Should be a successful code.');
    }
    /**
     * Tests the submission of launchAuction subtmit button
     * Should have the Inventory Life Cycle status updated to AuctionLaunchExt.SCHEDULING_PREFIX + LaunchToLiveAPI.LIVE_LAUNCHING_STATUS_SUFFIX
     * @return void
     */
    public static testMethod void launchLiveTest(){
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutGood());
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id, Client__c, Client__r.Name, Lights__c, Most_Recent_Auction__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.City,
                                                          Most_Recent_Work_Order_Line_Item__r.WorkOrderId, Odometer__c, Reserve__c, Status__c, Stock_Number__c, Auction_Lights_Concatenation__c,
                                                          Year_Make_Model_Trim__c, VIN__c, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.State,
                                                          Most_Recent_Condition_Report__c, Vehicle__r.Year_Make_Model_Trim__c, Vehicle__c FROM Inventory_Life_Cycle__c ];
        InventoryLifeCycleListViewController.InventoryRow ir = new InventoryLifeCycleListViewController.InventoryRow(ilcs[0]);
        LaunchAuctionCont.InventoryRowLaunch irl = (LaunchAuctionCont.InventoryRowLaunch)JSON.deserialize(JSON.serialize(ir), LaunchAuctionCont.InventoryRowLaunch.class);
        irl.startDateTime = '2020-10-20 12:30:00.000Z';
        String ilcsSelected = JSON.serialize(new List<LaunchAuctionCont.InventoryRowLaunch>{irl});
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = LaunchAuctionCont.launchAuction(ilcsSelected, 'Live');
            }
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Status__c FROM Inventory_Life_Cycle__c ];
        LaunchAuctionCont.DataWrapper dw = (LaunchAuctionCont.DataWrapper)JSON.deserialize(response, LaunchAuctionCont.DataWrapper.class);
        System.assertEquals(AuctionLaunchExt.SCHEDULING_PREFIX + LaunchToLiveAPI.LIVE_LAUNCHING_STATUS_SUFFIX, ilc[0].Status__c, 'Status should be Scheduled for Live');
        System.assertEquals(200, dw.statusCode, 'Should be a successful code.');
    }
    /**
     * Tests the submission of launchAuction subtmit button with a negative Callout Response
     * @return void
     */
    public static testMethod void launchAuctionNegativeBadCalloutTest(){
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutBad());
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id, Client__c, Client__r.Name, Lights__c, Most_Recent_Auction__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.City,
                                                          Most_Recent_Work_Order_Line_Item__r.WorkOrderId, Odometer__c, Reserve__c, Status__c, Stock_Number__c, Auction_Lights_Concatenation__c,
                                                          Year_Make_Model_Trim__c, VIN__c, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.State,
                                                          Most_Recent_Condition_Report__c, Vehicle__r.Year_Make_Model_Trim__c, Vehicle__c FROM Inventory_Life_Cycle__c ];
        InventoryLifeCycleListViewController.InventoryRow ir = new InventoryLifeCycleListViewController.InventoryRow(ilcs[0]);
        LaunchAuctionCont.InventoryRowLaunch irl = (LaunchAuctionCont.InventoryRowLaunch)JSON.deserialize(JSON.serialize(ir), LaunchAuctionCont.InventoryRowLaunch.class);
        irl.startDateTime = '2020-10-20 12:30:00.000Z';
        String ilcsSelected = JSON.serialize(new List<LaunchAuctionCont.InventoryRowLaunch>{irl});
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = LaunchAuctionCont.launchAuction(ilcsSelected, 'Live');
            }
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Status__c FROM Inventory_Life_Cycle__c ];
        LaunchAuctionCont.DataWrapper dw = (LaunchAuctionCont.DataWrapper)JSON.deserialize(response, LaunchAuctionCont.DataWrapper.class);
        System.assertNotEquals(AuctionLaunchExt.SCHEDULING_PREFIX + LaunchToLiveAPI.LIVE_LAUNCHING_STATUS_SUFFIX, ilc[0].Status__c, 'Status should not be Scheduled for Live');
        System.assertEquals(400, dw.statusCode, 'Should be an error code.');
    }
    /**
     * Tests the submission of LaunchAuction subtmit button with a negative Callout Response
     * @return void
     */
    public static testMethod void launchAuctionNegativeFailedToScheduleTest(){
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutMixed());
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id, Client__c, Client__r.Name, Lights__c, Most_Recent_Auction__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.City,
                                                          Most_Recent_Work_Order_Line_Item__r.WorkOrderId, Odometer__c, Reserve__c, Status__c, Stock_Number__c, Auction_Lights_Concatenation__c,
                                                          Year_Make_Model_Trim__c, VIN__c, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.State,
                                                          Most_Recent_Condition_Report__c, Vehicle__r.Year_Make_Model_Trim__c, Vehicle__c FROM Inventory_Life_Cycle__c ];
        InventoryLifeCycleListViewController.InventoryRow ir = new InventoryLifeCycleListViewController.InventoryRow(ilcs[0]);
        LaunchAuctionCont.InventoryRowLaunch irl = (LaunchAuctionCont.InventoryRowLaunch)JSON.deserialize(JSON.serialize(ir), LaunchAuctionCont.InventoryRowLaunch.class);
        irl.startDateTime = '2020-10-20 12:30:00.000Z';
        String ilcsSelected = JSON.serialize(new List<LaunchAuctionCont.InventoryRowLaunch>{irl});
        List<User> u = [ SELECT Id FROM User WHERE Username = 'systemAdmin@testorg.com' LIMIT 1];
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs(u[0]){
                response = LaunchAuctionCont.launchAuction(ilcsSelected, 'Live');
            }
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Status__c FROM Inventory_Life_Cycle__c ];
        LaunchAuctionCont.DataWrapper dw = (LaunchAuctionCont.DataWrapper)JSON.deserialize(response, LaunchAuctionCont.DataWrapper.class);
        System.assertNotEquals(AuctionLaunchExt.SCHEDULING_PREFIX + LaunchToLiveAPI.LIVE_LAUNCHING_STATUS_SUFFIX, ilc[0].Status__c, 'Status should not be Scheduled for Live');
        System.assertEquals(202, dw.statusCode, 'Should be a mixed code.');
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
                log = LaunchAuctionCont.createLog(SplunkHelper.LOGLEVEL.FATAL, 'testMessage', 'Test Stack trace', 1, 'Test Record Id');
            }
        Test.stopTest();
        //System Asserts
        System.assertEquals(log.logLevel, SplunkHelper.LOGLEVEL.FATAL, 'Wrong loglevel');
        System.assertEquals(log.message, 'testMessage', 'Wrong Message');
        System.assertEquals(log.stackTrace, 'Test Stack trace', 'Wrong Stack Trace');
        System.assertEquals(log.location, 'LaunchAuctionCont Line #1', 'Wrong location');
        System.assertEquals(log.sfRecordId, 'Test Record Id', 'Wrong Salesforce Record Id');
        System.assertEquals(log.sfObject, 'Inventory Life Cycle', 'Wrong Salesforce Object');
        System.assertEquals(log.version, 'v1', 'Wrong Version');
        System.assertEquals(log.componentName, 'LWC - Launch Auction Modal', 'Wrong Component Name');
        System.assertEquals(log.domainSet, new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SUPPLY}, 'Wrong Domain');
    }
    /****************Inner Classes*************************/
    private class MockCalloutGood implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            LaunchToLiveAPI.LiveResponse rlsRes = new LaunchToLiveAPI.LiveResponse();
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
            LaunchToLiveAPI.LiveResponse rlsRes = new LaunchToLiveAPI.LiveResponse();
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
            LaunchToLiveAPI.LiveResponse rlsRes = new LaunchToLiveAPI.LiveResponse();
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
}