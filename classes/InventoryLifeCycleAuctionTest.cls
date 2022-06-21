@isTest
/**
 * This is the Test class for the Trigger InventoryLifeCycleAuction
 * @author James Andre LaCour
 */
public class InventoryLifeCycleAuctionTest{
    /****************Class Variables************************/
    public static final Id STANDARD_ACCOUNT_RTID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
    public static final String ACCOUNT_WITH_DEALER_ID_NAME = 'Test Dealership With DealerId';
    public static final String ACCOUNT_WITHOUT_DEALER_ID_NAME = 'Test Dealership without DealerId';
    /****************Test Setup****************************/
    /**
     * Creates Test Data
     * @return void
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account acct = new Account();
        acct.Name = ACCOUNT_WITH_DEALER_ID_NAME;
        acct.RecordTypeId = STANDARD_ACCOUNT_RTID;
        acct.Dealership_Id__c = 'dealerId123';
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        acct.Legal_Name__c = ACCOUNT_WITH_DEALER_ID_NAME;
        Account acct2 = new Account();
        acct2.Name = ACCOUNT_WITHOUT_DEALER_ID_NAME;
        acct2.RecordTypeId = STANDARD_ACCOUNT_RTID;
        acct2.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        List<Account> acctsToInsert = new List<Account>{acct,acct2};
        insert acctsToInsert;
    }
    /****************Test Methods***************************/
    /**
     * Expecting Successful Creation of Inventory Life Cycle
     * @return void
     */
    public static testMethod void successfulCreation(){
        //Gather Data
        List<Account> acct = [ SELECT Id, Dealership_Id__c FROM Account WHERE Name = :ACCOUNT_WITH_DEALER_ID_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size(), 'No Account Found from Creation' );
        String vin = '1234abcdVINTest';
        //Create Data
        Test.startTest();
            Auction__c auc = new Auction__c();
            auc.Seller_Dealership__c = acct[0].Id;
            auc.VIN__c = vin;
            insert auc;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Auction__c, Most_Recent_Auction__r.Inventory_Life_Cycle__c, VIN__c, Client__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only one Inventory Life Cycle record should be created' );
        System.assertEquals( vin, ilcToCheck[0].VIN__c, 'VIN value was not correctly populated on the Inventory Life Cycle Record' );
        System.assertEquals( auc.Id, ilcToCheck[0].Most_Recent_Auction__c, 'Most Recent Auction should be populated with auc created in test' );
        System.assertEquals( acct[0].Id, ilcToCheck[0].Client__c, 'Client should be populated with Account created in testSetup' );
        System.assertEquals( ilcToCheck[0].Id, ilcToCheck[0].Most_Recent_Auction__r.Inventory_Life_Cycle__c, 'Inventory Life Cycle value should be created with ILC created from logic' );
    }
    /**
     * Expecting No Inventory Life Cycle because VIN Code is not populated
     * @return void
     */
    public static testMethod void noVinCode(){
        //Gather Data
        List<Account> acct = [ SELECT Id, Dealership_Id__c FROM Account WHERE Name = :ACCOUNT_WITH_DEALER_ID_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size(), 'No Account Found from Creation' );
        //Create Data
        Test.startTest();
            Auction__c auc = new Auction__c();
            auc.Seller_Dealership__c = acct[0].Id;
            insert auc;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Auction__c, Most_Recent_Auction__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 0, ilcToCheck.size(), 'No Inventory Life Cycle record should be created' );
    }
    /**
     * Expecting no Inventory Life Cycle because the Dealer Id on Account isn't populated
     * @return void
     */
    public static testMethod void noDealerId(){
        //Gather Data
        List<Account> acct = [ SELECT Id, Dealership_Id__c FROM Account WHERE Name = :ACCOUNT_WITHOUT_DEALER_ID_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size(), 'No Account Found from Creation' );
        String vin = '1234abcdVINTest';
        //Create Data
        Test.startTest();
            Auction__c auc = new Auction__c();
            auc.Seller_Dealership__c = acct[0].Id;
            auc.VIN__c = vin;
            insert auc;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Auction__c, Most_Recent_Auction__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 0, ilcToCheck.size(), 'No Inventory Life Cycle record should be created' );
    }
    /**
     * Expecting that the Inventory Life Cycle record is reparented to the next 
     * newest Auction due to the current one being deleated
     * @return void
     */
    public static testMethod void deletionReparent(){
        //Gather Data
        List<Account> acct = [ SELECT Id, Dealership_Id__c FROM Account WHERE Name = :ACCOUNT_WITH_DEALER_ID_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size(), 'No Account Found from Creation' );
        String vin = '1234abcdVINTest';
        Auction__c auc = new Auction__c();
        auc.Seller_Dealership__c = acct[0].Id;
        auc.VIN__c = vin;
        insert auc;
        //Create Data
        Test.startTest();
            Auction__c newAuc = new Auction__c();
            newAuc.Seller_Dealership__c = acct[0].Id;
            newAuc.VIN__c = vin;
            newAuc.name = 'Second Auc';
            insert newAuc;
            List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Auction__c, Most_Recent_Auction__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
            System.assertEquals( 1, ilcToCheck.size(), 'Only 1 Inventory Life Cycle should be created' );
            System.assertEquals( newAuc.Id, ilcToCheck[0].Most_Recent_Auction__c, 'Most Recent Auction should be attached to the new Auc' );
            delete newAuc;
        Test.stopTest();
        //System Asserts
        ilcToCheck = [ SELECT Id, Most_Recent_Auction__c, Most_Recent_Auction__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only 1 Inventory Life Cycle should be created' );
        System.assertEquals( auc.Id, ilcToCheck[0].Most_Recent_Auction__c, 'Most Recent Auction should be attached to the old Auc after new one was deleted' );
    }
    /**
     * Test for a bug where theres already an ILC created and multiple Auctions's
     * come in at the same time
     * @return void
     */
    public static testMethod void multipleAucSameKeyAlreadyCreatedILC(){
        //Gather Data
        List<Account> acct = [ SELECT Id, Dealership_Id__c FROM Account WHERE Name = :ACCOUNT_WITH_DEALER_ID_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size(), 'No Account Found from Creation' );
        String vin = '1234abcdVINTest';
        String dealerId = 'dealerId123';
        Inventory_Life_Cycle__c ilc = new Inventory_Life_Cycle__c();
        ilc.key__c = dealerID + vin;
        ilc.Client__c = acct[0].Id;
        insert ilc;
        //Create Data
        Test.startTest();
            Auction__c auc1 = new Auction__c();
            auc1.Seller_Dealership__c = acct[0].Id;
            auc1.VIN__c = vin;
            auc1.start_time__c = Datetime.Now();
            Auction__c auc2 = new Auction__c();
            auc2.Seller_Dealership__c = acct[0].Id;
            auc2.VIN__c = vin;
            auc2.start_time__c = Datetime.now().addDays(1);
            insert new List<Auction__c>{auc1,auc2};
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Auction__c, Most_Recent_Auction__r.Inventory_Life_Cycle__c, VIN__c, Client__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only one Inventory Life Cycle record should be created' );
        System.assertEquals( vin, ilcToCheck[0].VIN__c, 'VIN value was not correctly populated on the Inventory Life Cycle Record' );
        System.assertEquals( auc2.Id, ilcToCheck[0].Most_Recent_Auction__c, 'Most Recent Auction should be populated with CR created in test' );
        System.assertEquals( acct[0].Id, ilcToCheck[0].Client__c, 'Client should be populated with Account created in testSetup' );
        System.assertEquals( ilcToCheck[0].Id, ilcToCheck[0].Most_Recent_Auction__r.Inventory_Life_Cycle__c, 'Inventory Life Cycle value should be created with ILC created from logic' );
    }
}