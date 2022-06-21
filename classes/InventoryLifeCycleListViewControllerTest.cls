/**
 * This holds the tests for the Inventory Life Cycle View Controller
 * @author James Andre LaCour
 */
@isTest
public class InventoryLifeCycleListViewControllerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        String testVin = '321TestVin';
        Account acct = TestUtility.createAccount('Account Test');
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.get('Commercial');
        acct.Dealership_ID__c = '123';
        insert acct;
        Vehicle__c veh = TestUtility.createVehicle();
        veh.vin__c = testVin;
        insert veh;
        Condition_Report__c cr = TestUtility.createCr(veh);
        cr.VIN__c = testVin;
        cr.Dealership__c = acct.Id;
        insert cr;
        Contact con = TestUtility.createContact(acct);
        insert con;
        Auction__c auc = TestUtility.createAuction(acct, con, veh);
        auc.VIN__c = testVin;
        auc.Condition_Report_ID__c = cr.Id;
        auc.Seller_Dealership__c = acct.Id;
        auc.Blue_Light__c = true;
        auc.Yellow_Light__c = true;
        auc.Green_Light__c = true;
        auc.start_time__c = DateTime.Now();
        insert auc;
        Filter_Manager__c fm = new Filter_Manager__c();
        fm.Name = 'Test123';
        fm.Visibility__c = 'Private';
        fm.Filter_Items_JSON__c = '{"objectFields":[{"value":"False","operator":"Equals","label":"Archived","key":"Archived__cEqualsfalse","isActive":true,"field":"Archived__c","canDelete":false},{"value":"Test","operator":"Contains","label":"Client","key":"Client__r.NameContainsTest","isActive":true,"field":"Client__r.Name","canDelete":true}],"logicFields":[{"value":"All","operator":"Equals","label":"Cars to Show","key":"AllOrMyCarsequalsMy","isActive":true,"field":"AllOrMyCars","canDelete":false},{"value":"Blue","operator":"Equals","label":"Auction Lights","key":"Auction_Lights_Concatenation__cEqualsBlue","isActive":true,"field":"Auction_Lights_Concatenation__c","canDelete":true},{"value":"TODAY","operator":"Equals","label":"Last Modified Date","key":"TODAYEqualsLastModifiedDate","isActive":true,"field":"LastModifiedDate","canDelete":true},{"value":"TODAY","operator":"Equals","label":"Auction Start","key":"TODAYEqualsAuction_Start_Datetime__c","isActive":true,"field":"Auction_Start_Datetime__c","canDelete":true}]}';
        fm.RecordTypeId = FilterManagerSidebarController.FILTER_RT_ID;
        fm.Table_Component_Name__c = 'Inventory Life Cycle Table';
        insert fm;
        Filter_Manager__c fmAssignment = new Filter_Manager__c();
        fmAssignment.Filter__c = fm.Id;
        fmAssignment.RecordTypeId = FilterManagerSidebarController.ASSIGNMENT_RT_ID;
        fmAssignment.Pinned__c = true;
        insert fmAssignment;
    }
    @IsTest
    static void doInitTest(){
        Test.startTest();
            InventoryLifeCycleListViewController.DataWrapper dw = (InventoryLifeCycleListViewController.DataWrapper)JSON.deserialize(InventoryLifeCycleListViewController.doInit(), InventoryLifeCycleListViewController.DataWrapper.class);
        Test.stopTest();
        System.assertEquals(1, dw.allIlcRows.size(), '1 record should be found');
    }
    @IsTest
    static void doInitNoFilterTest(){
        Filter_Manager__c fm = [ SELECT Id, Pinned__c FROM Filter_Manager__c WHERE RecordTypeId = :FilterManagerSidebarController.ASSIGNMENT_RT_ID LIMIT 1 ];
        fm.Pinned__c = false;
        update fm;
        Test.startTest();
            InventoryLifeCycleListViewController.DataWrapper dw = (InventoryLifeCycleListViewController.DataWrapper)JSON.deserialize(InventoryLifeCycleListViewController.doInit(), InventoryLifeCycleListViewController.DataWrapper.class);
        Test.stopTest();
        System.assertEquals(0, dw.allIlcRows.size(), '0 record should be found');
    }
    @IsTest
    static void getUpdatedDataTest(){
        List<Filter_Manager__c> fmList = [ SELECT Id FROM Filter_Manager__c WHERE Name = 'Test123' LIMIT 1 ];
        System.assertEquals( 1,fmList.size() );
        String filterIdJson = JSON.serialize(fmList[0].Id);
        Test.startTest();
            InventoryLifeCycleListViewController.DataWrapper dw = (InventoryLifeCycleListViewController.DataWrapper)JSON.deserialize(InventoryLifeCycleListViewController.getUpdatedData(filterIdJson), InventoryLifeCycleListViewController.DataWrapper.class);
        Test.stopTest();
        System.assertEquals(1, dw.allIlcRows.size(), '1 record should be found');
    }
}