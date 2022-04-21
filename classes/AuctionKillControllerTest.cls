/**
 * This class is the test class for the AuctionKillController
 * @author James Andre LaCour
 */
@isTest
public class AuctionKillControllerTest {
    /**
     * Test Email for Contact and User
     */
    public final static String USER_CONTACT_EMAIL = 'AuctionKill@TestUser.test';
    /**
     * Test Acv User Id for Contact and User
     */
    public final static String USER_CONTACT_ACV_ID = '992292';
    /****************Inner Classes*************************/
    private class MockCalloutGood implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            AuctionKillApiResponse akar = new AuctionKillApiResponse();
            akar.data = new AuctionKillApiResponse.Response();
            AuctionKillApiResponse.Data dataSuccess = new AuctionKillApiResponse.Data();
            dataSuccess.message = 'success';
            dataSuccess.auctionid = 123;
            dataSuccess.status = 200;
            akar.data.successes = new List<AuctionKillApiResponse.Data>{dataSuccess};

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(JSON.serialize(akar));
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
        Account acct = TestUtility.createAccount('Test Dealership With DealerId');
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        acct.Dealership_Id__c = 'dealerId123';
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        insert acct;
        Contact con = TestUtility.createContact( acct );
        con.Email = USER_CONTACT_EMAIL;
        con.Id__c = USER_CONTACT_ACV_ID;
        insert con;
        Vehicle__c veh = TestUtility.createVehicle();
        insert veh;
        Auction__c auc = TestUtility.createAuction(acct, con, veh);
        auc.VIN__c = veh.Name;
        auc.Id__c = '123';
        auc.status__c = 'Active';
        insert auc;
        User u = TestUtility.createUser();
        u.Email = USER_CONTACT_EMAIL;
        u.Id__c = USER_CONTACT_ACV_ID;
        insert u;
    }
    /****************Test Methods**************************/
    /**
     * Tests the intialization of the page. Whats passed in is the selected Inventory Life Cycles
     * @return void
     */
    public static testMethod void initTest(){
        List<User> userList = [ SELECT Id, Id__c FROM User WHERE email = :USER_CONTACT_EMAIL LIMIT 1 ];
        System.assert( !userList.isEmpty() );
        //Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id, Most_Recent_Auction__c FROM Inventory_Life_Cycle__c LIMIT 1 ];
        String ilcsSelected = JSON.serialize(ilcs);
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs( userList[0] ){
                response = AuctionKillController.doInit(ilcsSelected);
            }
        Test.stopTest();
        //System Asserts
        AuctionKillController.ReturnWrapper rw = (AuctionKillController.ReturnWrapper)JSON.deserialize(response, AuctionKillController.ReturnWrapper.class);
        System.assertEquals( userList[0].Id__c, rw.runningUser.Id__c, 'The running user isn\'t correct' );
        System.assertEquals( 1, rw.eligibleAuctions.size(), 'There should be 1 eligible Inventory Life Cycle found' );
        System.assertEquals( 1, rw.activeOpenSections.size(), 'There should be 1 item in the Active Open Sections set' );
        System.assertEquals( 'Auctions', rw.activeOpenSections[0], 'The Active Open Sections set should contain Auctions' );
        System.assertEquals( 'Successful', rw.successMessage, 'Should be a successful message.' );
    }
    /**
     * On intiailzation of page, if a car that was selected is in the Vehicle Sold status, it should not be eligible
     * @return void
     */
    public static testMethod void vehicleSoldInitTest(){
        List<User> userList = [ SELECT Id, Id__c FROM User WHERE email = :USER_CONTACT_EMAIL LIMIT 1 ];
        System.assert( !userList.isEmpty() );
        //Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id, Most_Recent_Auction__c FROM Inventory_Life_Cycle__c LIMIT 1 ];
        List<Auction__c> aucList = [ SELECT Id, Status__c FROM Auction__c WHERE Id = :ilcs[0].Most_Recent_Auction__c ];
        for( Auction__c auc : aucList ){
            auc.Status__c = 'ended_accepted';
        }
        update aucList;
        String ilcsSelected = JSON.serialize(ilcs);
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs( userList[0] ){
                response = AuctionKillController.doInit(ilcsSelected);
            }
        Test.stopTest();
        //System Asserts
        AuctionKillController.ReturnWrapper rw = (AuctionKillController.ReturnWrapper)JSON.deserialize(response, AuctionKillController.ReturnWrapper.class);
        System.assertEquals( userList[0].Id__c, rw.runningUser.Id__c, 'The running user isn\'t correct' );
        System.assertEquals( 1, rw.invalidILCList.size(), 'There should be 1 invalid auction found') ;
        System.assertEquals( 1, rw.activeOpenSections.size(), 'There should be 1 item in the Active Open Sections set' );
        System.assertEquals( 'ILCS', rw.activeOpenSections[0], 'The Active Open Sections set should contain ILCS' );
        System.assertEquals( 'Sorry, none of the selected records have an eligible Auction to end.', rw.errorMessage, 'Should be an error message.' );
    }
    /**
     * On intiailzation of page, if a car that was selected is in the Vehicle Unsold status, it should not be eligible
     * @return void
     */
    public static testMethod void vehicleUnsoldInitTest(){
        List<User> userList = [ SELECT Id, Id__c FROM User WHERE email = :USER_CONTACT_EMAIL LIMIT 1 ];
        System.assert( !userList.isEmpty() );
        //Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id,Most_Recent_Auction__c FROM Inventory_Life_Cycle__c LIMIT 1 ];
        List<Auction__c> aucList = [ SELECT Id, Status__c FROM Auction__c WHERE Id = :ilcs[0].Most_Recent_Auction__c ];
        for( Auction__c auc : aucList ){
            auc.Status__c = 'ended_killed';
        }
        update aucList;
        String ilcsSelected = JSON.serialize(ilcs);
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs( userList[0] ){
                response = AuctionKillController.doInit(ilcsSelected);
            }
        Test.stopTest();
        //System Asserts
        AuctionKillController.ReturnWrapper rw = (AuctionKillController.ReturnWrapper)JSON.deserialize(response, AuctionKillController.ReturnWrapper.class);
        System.assertEquals( userList[0].Id__c, rw.runningUser.Id__c, 'The running user isn\'t correct' );
        System.assertEquals( 1, rw.invalidILCList.size(), 'There should be 1 invalid auction found' );
        System.assertEquals( 1, rw.activeOpenSections.size(), 'There should be 1 item in the Active Open Sections set' );
        System.assertEquals( 'ILCS', rw.activeOpenSections[0], 'The Active Open Sections set should contain ILCS' );
        System.assertEquals( 'Sorry, none of the selected records have an eligible Auction to end.', rw.errorMessage, 'Should be an error message.' );
    }
    /**
     * On intiailzation of page, if a car that was selected is in the Scheduling To {insert suffix} status, it should not be eligible
     * @return void
     */
    public static testMethod void schedulingInitTest(){
        List<User> userList = [ SELECT Id, Id__c FROM User WHERE email = :USER_CONTACT_EMAIL LIMIT 1 ];
        System.assert( !userList.isEmpty() );
        //Gather Data
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id FROM Inventory_Life_Cycle__c LIMIT 1 ];
        ilcs[0].Processing_Status__c = RunListSendController.SCHEDULING_TO_RUNLIST_STATUS;
        update ilcs;
        String ilcsSelected = JSON.serialize(ilcs);
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs( userList[0] ){
                response = AuctionKillController.doInit(ilcsSelected);
            }
        Test.stopTest();
        //System Asserts
        AuctionKillController.ReturnWrapper rw = (AuctionKillController.ReturnWrapper)JSON.deserialize(response, AuctionKillController.ReturnWrapper.class);
        System.assertEquals( userList[0].Id__c, rw.runningUser.Id__c, 'The running user isn\'t correct' );
        System.assertEquals( 1, rw.invalidILCList.size(), 'There should be 1 invalid Inventory Life Cycle found' );
        System.assertEquals( 1, rw.activeOpenSections.size(), 'There should be 1 item in the Active Open Sections set' );
        System.assertEquals( 'ILCS', rw.activeOpenSections[0], 'The Active Open Sections set should contain ILCS' );
    }
    /**
     * Tests the submission of the kill auction button.
     * Should have the Auction status updated to indicate it has been killed
     * @return void
     */
    public static testMethod void submitTest(){
        List<User> userList = [ SELECT Id, Id__c FROM User WHERE email = :USER_CONTACT_EMAIL LIMIT 1 ];
        System.assert( !userList.isEmpty() );
        //Gather Data
        Test.setMock(HttpCalloutMock.class, new MockCalloutGood());
        List<Auction__c> auc = [ SELECT Id, Id__c, Status__c FROM Auction__c LIMIT 1 ];
        String dataSubmitWrapperJSON = '{"auctions":[{"yearMakeModelTrim":null,"vin":"TestVIN","status":null,"reservePrice":null,"name":"testAuction","idUrl":"/' + auc[0].Id + '","id":"' + auc[0].Id + '","auctionId":"' + auc[0].Id__c + '"}],"currentUser":{"attributes":{"type":"User","url":"/services/data/v49.0/sobjects/User/0050a00000HKCGqAAP"},"Id":"0050a00000HKCGqAAP","Id__c":"9427","Email":"testEmail@test.com"},"notes":"testKill"}';
        //Send to Controller
        Test.startTest();
            String response = '';
            System.runAs( userList[0] ){
                response = AuctionKillController.submitKillAuction(dataSubmitWrapperJSON);
            }
        Test.stopTest();
        //System Asserts
        auc = [ SELECT Id, status__c FROM Auction__c WHERE Id = :auc[0].Id ];
        AuctionKillController.ReturnWrapper rw = (AuctionKillController.ReturnWrapper)JSON.deserialize(response, AuctionKillController.ReturnWrapper.class);
        System.assertEquals(AuctionKillAPI.AUCTION_KILL_STATUS, auc[0].status__c);
    }
    /**
     * Tests the constructor for the VF pages which handles the passign in of records
     * selected via the list view
     * @return void
     */
    public static testMethod void vfExtensionConstructorTest(){
        //Gather Data
        Test.setCurrentPage(Page.AuctionKillWrapper);
        List<Inventory_Life_Cycle__c> ilcs = [ SELECT Id FROM Inventory_Life_Cycle__c LIMIT 1 ];
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(ilcs);
        std.setSelected(ilcs);
        //Send to Controller
        Test.startTest();
            AuctionKillController akc = new AuctionKillController(std);
        Test.stopTest();
        //System Asserts
        System.assertEquals(ilcs, akc.selectedRecords, 'The wrong records were selected');
        System.assertEquals(JSON.serialize(ilcs), akc.selectedRecordsJSON, 'The wrong records were JSON Serialized');
    }
}