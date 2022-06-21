@isTest
/**
 * Test class logic for ILCMassPopulationViaTrigger
 * @author James Andre LaCour
 */
public class ILCMassPopulationViaTriggerTest{
    /****************Class Variables************************/
    public static final Id STANDARD_ACCOUNT_RTID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
    public static final String ACCOUNT_WITH_DEALER_ID_NAME = 'Test Dealership With DealerId';
    public static final String TEST_VIN = '1234abcdVINtest';
    public static final string TEST_DEALER_ID = 'dealerId123';
    /****************Test Setup****************************/
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Account> accountList = New List<Account>();
        Account acct = TestUtility.createAccount();
        acct.Name = ACCOUNT_WITH_DEALER_ID_NAME;
        acct.RecordTypeId = STANDARD_ACCOUNT_RTID;
        acct.Dealership_Id__c = TEST_DEALER_ID;
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        acct.Legal_Name__c = ACCOUNT_WITH_DEALER_ID_NAME;

        accountList.add(acct);
        insert accountList;
        
        Vehicle__c v = new Vehicle__c();
        v.VIN__c = TEST_VIN;
        insert v;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo' , '14209' );

        WorkType wt = [SELECT Id, Work_Type_Unique_ID__c, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];

        WorkOrder wo = new WorkOrder (AccountId = accountList[0].id, status = 'New', WorkTypeId = wt.id);
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkTypeId = wt.Id;
        woli.WorkOrderId = wo.Id;
        woli.VIN__c = TEST_VIN;
        woli.Vehicle__c = v.Id;
        woli.Duration = 30.0;
        woli.DurationType = 'Minutes';
        insert woli;

        Condition_Report__c cr = new Condition_Report__c();
        cr.Dealership__c = acct.Id;
        cr.VIN__c = TEST_VIN;
        cr.Vehicle__c = v.Id;
        insert cr;

        Auction__c auc = new Auction__c();
        auc.Seller_Dealership__c = acct.Id;
        auc.VIN__c = TEST_VIN;
        auc.Condition_Report_ID__c = cr.Id;
        auc.Vehicle_id__c = v.Id;
        insert auc;

        cr.Auction__c = auc.Id;
        update cr;

        //The goal is to simulate already having the other records in the system but with no Inventory Life Cycle records
        List<Inventory_Life_Cycle__c> ilcToDelete = [ SELECT Id FROM Inventory_Life_Cycle__c ];
        if( ilcToDelete.size() > 0 ) delete ilcToDelete;
    }
    /****************Test Methods***************************/
    /**
     * Test that when the Update With Most Current checkbox is checked on Insert
     * it will populate all the lookup fields on Inventory Life Cycle
     * @return void
     */
    public static testMethod void updateWithMostCurrentTest(){
        //Gather data
        List<Account> acct = [ SELECT Id FROM Account ];
        List<Condition_Report__c> cr = [ SELECT Id FROM Condition_Report__c ];
        List<Auction__c> auc = [ SELECT Id FROM Auction__c ];
        List<WorkOrderLineItem> woli = [ SELECT Id FROM WorkOrderLineItem ];
        List<Vehicle__c> veh = [ SELECT Id FROM Vehicle__c ];
        //Test insert
        Test.startTest();
            Inventory_Life_Cycle__c ilc = new Inventory_Life_Cycle__c();
            ilc.key__c = TEST_DEALER_ID + TEST_VIN;
            ilc.Update_With_Most_Current__c = true;
            ilc.Dealer_Id_Text__c = TEST_DEALER_ID;
            ilc.VIN__c = TEST_VIN;
            insert ilc;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Vehicle__c, Client__c, Most_Recent_Auction__c, Most_Recent_Condition_Report__c, Most_Recent_Work_Order_Line_Item__c, Update_With_Most_Current__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals(1, ilcToCheck.size(), 'Only one Inventory Life Cycle should have been created');
        System.assertEquals(acct[0].Id, ilcToCheck[0].Client__c, 'The incorrect Client was attached to the Inventory Life Cycle Record');
        System.assertEquals(veh[0].Id, ilcToCheck[0].Vehicle__c, 'The incorrect Vehicle was attached to the Inventory Life Cycle Record');
        System.assertEquals(auc[0].Id, ilcToCheck[0].Most_Recent_Auction__c, 'The incorrect Auction was attached to the Inventory Life Cycle Record');
        System.assertEquals(woli[0].Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__c, 'The incorrect Work Order Line Item was attached to the Inventory Life Cycle Record');
        System.assertEquals(cr[0].Id, ilcToCheck[0].Most_Recent_Condition_Report__c, 'The incorrect Condition Report was attached to the Inventory Life Cycle Record');
        System.assertEquals(false, ilcToCheck[0].Update_With_Most_Current__c, 'The flag should have been reset to false');
    }
    /**
     * Test that when the Update_Lookups_with_Inventory_Life_Cycle__c checkbox is checked on Update
     * it will populate all the Inventory Life Cycle fields on the other records
     * @return void
     */
    public static testMethod void updateLookupsTest(){
        //Test Update
        Test.startTest();
            Inventory_Life_Cycle__c ilc = new Inventory_Life_Cycle__c();
            ilc.key__c = TEST_DEALER_ID + TEST_VIN;
            ilc.Update_With_Most_Current__c = true;
            ilc.Dealer_Id_Text__c = TEST_DEALER_ID;
            ilc.VIN__c = TEST_VIN;
            insert ilc;
            
            ilc.Update_Lookups_with_Inventory_Life_Cycle__c = true;
            update ilc;
        Test.stopTest();
        List<Condition_Report__c> cr = [ SELECT Id, Inventory_Life_Cycle__c FROM Condition_Report__c ];
        List<Auction__c> auc = [ SELECT Id, Inventory_Life_Cycle__c FROM Auction__c ];
        List<WorkOrderLineItem> woli = [ SELECT Id, Inventory_Life_Cycle__c FROM WorkOrderLineItem ];
        //System Asserts
        System.assertEquals(ilc.Id, auc[0].Inventory_Life_Cycle__c, 'The Auction was attached to the incorrect Inventory Life Cycle Record');
        System.assertEquals(ilc.Id, woli[0].Inventory_Life_Cycle__c, 'The Work Order Line Item was attached to the incorrect Inventory Life Cycle Record');
        System.assertEquals(ilc.Id, cr[0].Inventory_Life_Cycle__c, 'The Condition Report was attached to the incorrect Inventory Life Cycle Record');
    }
}