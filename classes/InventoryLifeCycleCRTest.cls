@isTest
/**
 * This is the Test class for the Trigger InventoryLifeCycleCR
 * @author James Andre LaCour
 */
public class InventoryLifeCycleCRTest{
    /****************Class Variables************************/
    public static final Id STANDARD_ACCOUNT_RTID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
    public static final String ACCOUNT_WITH_DEALER_ID_NAME = 'Test Dealership With DealerId';
    public static final String ACCOUNT_WITHOUT_DEALER_ID_NAME = 'Test Dealership without DealerId';
    /****************Test Setup****************************/
    /**
     * Creates Test Data
     * @return void
     */
    @testSetup
    public static void createData(){
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
            Condition_Report__c cr = new Condition_Report__c();
            cr.Dealership__c = acct[0].Id;
            cr.VIN__c = vin;
            insert cr;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Condition_Report__c, Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, VIN__c, Client__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only one Inventory Life Cycle record should be created' );
        System.assertEquals( vin, ilcToCheck[0].VIN__c, 'VIN value was not correctly populated on the Inventory Life Cycle Record' );
        System.assertEquals( cr.Id, ilcToCheck[0].Most_Recent_Condition_Report__c, 'Most Recent Condition Report should be populated with CR created in test' );
        System.assertEquals( acct[0].Id, ilcToCheck[0].Client__c, 'Client should be populated with Account created in testSetup' );
        System.assertEquals( ilcToCheck[0].Id, ilcToCheck[0].Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, 'Inventory Life Cycle value should be created with ILC created from logic' );
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
            Condition_Report__c cr = new Condition_Report__c();
            cr.Dealership__c = acct[0].Id;
            insert cr;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Condition_Report__c, Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
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
            Condition_Report__c cr = new Condition_Report__c();
            cr.Dealership__c = acct[0].Id;
            cr.VIN__c = vin;
            insert cr;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Condition_Report__c, Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 0, ilcToCheck.size(), 'No Inventory Life Cycle record should be created' );
    }
    /**
     * Expecting that the Inventory Life Cycle record is reparented to the next 
     * newest Condition Report due to the current one being deleated
     * @return void
     */
    public static testMethod void deletionReparent(){
        //Gather Data
        List<Account> acct = [ SELECT Id, Dealership_Id__c FROM Account WHERE Name = :ACCOUNT_WITH_DEALER_ID_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size(), 'No Account Found from Creation' );
        String vin = '1234abcdVINTest';
        Condition_Report__c cr = new Condition_Report__c();
        cr.Dealership__c = acct[0].Id;
        cr.VIN__c = vin;
        insert cr;
        //Create Data
        Test.startTest();
            Condition_Report__c newCR = new Condition_Report__c();
            newCR.Dealership__c = acct[0].Id;
            newCR.VIN__c = vin;
            newCR.name = 'Second CR';
            insert newCR;
            List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Condition_Report__c, Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
            System.assertEquals( 1, ilcToCheck.size(), 'Only 1 Inventory Life Cycle should be created' );
            System.assertEquals( newCr.Id, ilcToCheck[0].Most_Recent_Condition_Report__c, 'Most Recent Condition Report should be attached to the new CR' );
            delete newCR;
        Test.stopTest();
        //System Asserts
        ilcToCheck = [ SELECT Id, Most_Recent_Condition_Report__c, Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only 1 Inventory Life Cycle should be created' );
        System.assertEquals( cr.Id, ilcToCheck[0].Most_Recent_Condition_Report__c, 'Most Recent Condition Report should be attached to the old CR after new one was deleted' );
    }
    /**
     * Test for a bug where theres already an ILC created and multiple CR's
     * come in at the same time
     * @return void
     */
    public static testMethod void multipleCRSameKeyAlreadyCreatedILC(){
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
            Condition_Report__c cr1 = new Condition_Report__c();
            cr1.Dealership__c = acct[0].Id;
            cr1.VIN__c = vin;
            cr1.CR_Doc_CreateDate__c = Datetime.Now();
            Condition_Report__c cr2 = new Condition_Report__c();
            cr2.Dealership__c = acct[0].Id;
            cr2.VIN__c = vin;
            cr2.CR_Doc_CreateDate__C = Datetime.Now().addDays(1);
            insert new List<Condition_Report__c>{cr1,cr2};
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Condition_Report__c, Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, VIN__c, Client__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only one Inventory Life Cycle record should be created' );
        System.assertEquals( vin, ilcToCheck[0].VIN__c, 'VIN value was not correctly populated on the Inventory Life Cycle Record' );
        System.assertEquals( cr2.Id, ilcToCheck[0].Most_Recent_Condition_Report__c, 'Most Recent Condition Report should be populated with CR created in test' );
        System.assertEquals( acct[0].Id, ilcToCheck[0].Client__c, 'Client should be populated with Account created in testSetup' );
        System.assertEquals( ilcToCheck[0].Id, ilcToCheck[0].Most_Recent_Condition_Report__r.Inventory_Life_Cycle__c, 'Inventory Life Cycle value should be created with ILC created from logic' );
    }
}