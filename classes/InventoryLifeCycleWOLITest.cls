@isTest
/**
 * This is the Test class for the Trigger InventoryLifeCycleWOLI
 * @author James Andre LaCour
 */
public class InventoryLifeCycleWOLITest{
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
        List<Account> acctsToInsert = New List<Account>();

        Account acct = TestUtility.createAccount();
        acct.Name = ACCOUNT_WITH_DEALER_ID_NAME;
        acct.RecordTypeId = STANDARD_ACCOUNT_RTID;
        acct.Dealership_Id__c = 'dealerId123';
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        acct.Legal_Name__c = ACCOUNT_WITH_DEALER_ID_NAME;
        acctsToInsert.add(acct);

        Account acct2 = TestUtility.createAccount();
        acct2.Name = ACCOUNT_WITHOUT_DEALER_ID_NAME;
        acct2.RecordTypeId = STANDARD_ACCOUNT_RTID;
        acct2.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        acct2.Legal_Name__c = ACCOUNT_WITHOUT_DEALER_ID_NAME;
        acctsToInsert.add(acct2);

        insert acctsToInsert;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo' , '14209' );

        WorkType wt = [SELECT Id, Work_Type_Unique_ID__c, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        
        List<WorkOrder> wosToInsert = new List<WorkOrder>();
        
        WorkOrder wo = new WorkOrder(AccountId = acctsToInsert[0].id, status = 'New', WorkTypeId = wt.id);
        wosToInsert.add(wo);

        WorkOrder wo2 = new WorkOrder(AccountId = acctsToInsert[1].id, status = 'New', WorkTypeId = wt.id);
        wosToInsert.add(wo2);

        insert wosToInsert;
    }
    /****************Test Methods***************************/
    /**
     * Expecting Successful Creation of Inventory Life Cycle
     * @return void
     */
    public static testMethod void successfulCreation(){
        //Gather Data
        List<WorkOrder> wo = [ SELECT Id, AccountId, WorkTypeId FROM WorkOrder WHERE Account.Name = :ACCOUNT_WITH_DEALER_ID_NAME ];
        System.assertEquals( 1, wo.size(), 'No Work Order Found from Creation' );
        String vin = '1234abcdVINTest';
        //Create Data
        Test.startTest();
            WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.WorkOrderId = wo[0].Id;
            woli.VIN__c = vin;
            woli.Duration = 30.0;
            woli.DurationType = 'Minutes';
            woli.WorkTypeId = wo[0].WorkTypeId;
            insert woli;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, VIN__c, Client__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only one Inventory Life Cycle record should be created' );
        System.assertEquals( vin, ilcToCheck[0].VIN__c, 'VIN value was not correctly populated on the Inventory Life Cycle Record' );
        System.assertEquals( woli.Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__c, 'Most Recent Work Order Line Item should be populated with Work ORder Line ITem created in test' );
        System.assertEquals( wo[0].AccountId, ilcToCheck[0].Client__c, 'Client should be populated with Account created in testSetup' );
        System.assertEquals( ilcToCheck[0].Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, 'Inventory Life Cycle value should be created with ILC created from logic' );
    }
    /**
     * Expecting No Inventory Life Cycle because VIN Code is not populated
     * @return void
     */
    public static testMethod void noVinCode(){
        //Gather Data
        List<WorkOrder> wo = [ SELECT Id, AccountId, WorkTypeId FROM WorkOrder WHERE Account.Name = :ACCOUNT_WITH_DEALER_ID_NAME ];
        System.assertEquals( 1, wo.size(), 'No Work Order Found from Creation' );
        //Create Data
        Test.startTest();
            WorkOrderLineItem woli = new WorkOrderLineItem();
            woli.WorkOrderId = wo[0].Id;
            woli.Duration = 30.0;
            woli.DurationType = 'Minutes';
            woli.WorkTypeId = wo[0].WorkTypeId;
            insert woli;
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 0, ilcToCheck.size(), 'No Inventory Life Cycle record should be created' );
    }
    /**
     * Expecting no Inventory Life Cycle because the Dealer Id on Account isn't populated
     * @return void
     */
    //  Bill Removed as part of SOT
    // public static testMethod void noDealerId(){
    //     //Gather Data
    //     List<WorkOrder> wo = [ SELECT Id, AccountId FROM WorkOrder WHERE Account.Name = :ACCOUNT_WITHOUT_DEALER_ID_NAME ];
    //     System.assertEquals( 1, wo.size(), 'No Work Order Found from Creation' );
    //     String vin = '1234abcdVINTest';
    //     //Create Data
    //     Test.startTest();
    //         WorkOrderLineItem woli = new WorkOrderLineItem();
    //         woli.WorkOrderId = wo[0].Id;
    //         woli.VIN__c = vin;
    //         woli.Duration = 30.0;
    //         woli.DurationType = 'Minutes';
    //         insert woli;
    //     Test.stopTest();
    //     //System Asserts
    //     List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
    //     System.assertEquals( 0, ilcToCheck.size(), 'No Inventory Life Cycle record should be created' );
    // }
    /**
     * Expecting that the Inventory Life Cycle record is reparented to the next 
     * newest Work Order Line Item due to the current one being deleated
     * @return void
     */
    public static testMethod void deletionReparent(){
        //Gather Data
        List<WorkOrder> wo = [ SELECT Id, AccountId, WorkTypeId FROM WorkOrder WHERE Account.Name = :ACCOUNT_WITH_DEALER_ID_NAME ];
        System.assertEquals( 1, wo.size(), 'No Work Order Found from Creation' );
        String vin = '1234abcdVINTest';
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = wo[0].Id;
        woli.VIN__c = vin;
        woli.Duration = 30.0;
        woli.DurationType = 'Minutes';
        woli.WorkTypeId = wo[0].WorkTypeId;
        insert woli;
        //Create Data
        Test.startTest();
            WorkOrderLineItem newWOLI = new WorkOrderLineItem();
            newWOLI.WorkOrderId = wo[0].Id;
            newWOLI.VIN__c = vin;
            newWoli.Duration = 30.0;
            newWoli.DurationType = 'Minutes';
            newWoli.WorkTypeId = wo[0].WorkTypeId;
            insert newWOLI;
            List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
            System.assertEquals( 1, ilcToCheck.size(), 'Only 1 Inventory Life Cycle should be created' );
            System.assertEquals( newWOLI.Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__c, 'Most Recent Work_Order_Line_Item should be attached to the new Work Order Line Item' );
            delete newWOLI;
        Test.stopTest();
        //System Asserts
        ilcToCheck = [ SELECT Id, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, VIN__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only 1 Inventory Life Cycle should be created' );
        System.assertEquals( woli.Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__c, 'Most Recent Work_Order_Line_Item should be attached to the old Work Order Line Item after new one was deleted' );
    }
     /**
     * Test for a bug where theres already an ILC created and multiple WOLI's
     * come in at the same time
     * @return void
     */
    public static testMethod void multipleWOLISameKeyAlreadyCreatedILC(){
        //Gather Data
        List<WorkOrder> wo = [ SELECT Id, AccountId, WorkTypeId FROM WorkOrder WHERE Account.Name = :ACCOUNT_WITH_DEALER_ID_NAME ];
        System.assertEquals( 1, wo.size(), 'No Work Order Found from Creation' );
        String vin = '1234abcdVINTest';
        String dealerId = 'dealerId123';
        Inventory_Life_Cycle__c ilc = new Inventory_Life_Cycle__c();
        ilc.key__c = dealerID + vin;
        ilc.Client__c = wo[0].AccountId;
        insert ilc;
        //Create Data
        Test.startTest();
            WorkOrderLineItem woli1 = new WorkOrderLineItem();
            woli1.WorkOrderId = wo[0].Id;
            woli1.VIN__c = vin;
            woli1.Duration = 30.0;
            woli1.DurationType = 'Minutes';
            woli1.WorkTypeId = wo[0].WorkTypeId;
            WorkOrderLineItem woli2 = new WorkOrderLineItem();
            woli2.WorkOrderId = wo[0].Id;
            woli2.VIN__c = vin;
            woli2.Duration = 30.0;
            woli2.DurationType = 'Minutes';
            woli2.WorkTypeId = wo[0].WorkTypeId;
            insert new List<WorkOrderLineItem>{woli1,woli2};
        Test.stopTest();
        //System Asserts
        List<Inventory_Life_Cycle__c> ilcToCheck = [ SELECT Id, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, VIN__c, Client__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilcToCheck.size(), 'Only one Inventory Life Cycle record should be created' );
        System.assertEquals( vin, ilcToCheck[0].VIN__c, 'VIN value was not correctly populated on the Inventory Life Cycle Record' );
        System.assertEquals( woli2.Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__c, 'Most Recent Work Order Line Item should be populated with CR created in test' );
        System.assertEquals( wo[0].AccountId, ilcToCheck[0].Client__c, 'Client should be populated with Account created in testSetup' );
        System.assertEquals( ilcToCheck[0].Id, ilcToCheck[0].Most_Recent_Work_Order_Line_Item__r.Inventory_Life_Cycle__c, 'Inventory Life Cycle value should be created with ILC created from logic' );
    }
}