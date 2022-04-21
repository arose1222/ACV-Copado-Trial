@isTest
/**
 * Test class logic for InventoryLifeCycleHelperTest
 * @author James Andre LaCour
 */
public class InventoryLifeCycleHelperTest{
    /****************Class Variables************************/
    public static final Id STANDARD_ACCOUNT_RTID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
    public static final String ACCOUNT_WITH_DEALER_ID_NAME = 'Test Dealership With DealerId';
    public static final String TEST_VIN = '1234abcdVINtest';
    public static final string TEST_DEALER_ID = 'dealerId123';
    /****************Test Setup****************************/
    /**
     * Creates Test Data
     * @return void
     */
    @TestSetup
    public static void createData(){
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
    }
    /****************Test Methods***************************/
    /**
     * Expecting an organized Map of Key to ILC based
     * @return void
     */
    public static testMethod void createILCKeyMap(){
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Key__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, ilc.size(), 'Only 1 Inventory Life Cycle should be created' );
        String key = TEST_DEALER_ID + TEST_VIN;
        Map<String,Inventory_Life_Cycle__c> ilcMap = InventoryLifeCycleHelper.createILCKeyMap( ilc );
        System.assertEquals( 1, ilcMap.size(), 'Map should only have 1 value in it' );
        System.assertEquals( ilcMap.get(key), ilc[0], 'Key value not found' );
    }
    /**
     * Expecting Inventory Life Cycle Records with the
     * updated values via the map and an Id attached
     * @return void
     */
    public static testMethod void updateExistingILCs(){
        List<Condition_Report__c> cr = [ SELECT Id, Dealer_Id__c, Vehicle__c, Dealership__c, Auction__c, VIN__c, Inventory_Life_Cycle__c FROM Condition_Report__c ];
        System.assertEquals( 1, cr.size(), 'Only one Condition Report should be found' );
        List<Inventory_Life_Cycle__c> ilcList = InventoryLifeCycleHelper.updateExistingILCs( new Map<Id,Condition_Report__c>(cr), 'Inventory_Life_Cycle__c','CR_Doc_CreateDate__c' );
        System.assertEquals( 1, ilcList.size(), 'Only one ILC should be returned');
        for( String ilcField : InventoryLifeCycleHelper.CR_FIELD_MAP.keySet() ){
            System.assertEquals( cr[0].get(InventoryLifeCycleHelper.CR_FIELD_MAP.get(ilcField)), ilcList[0].get(ilcField), ilcField + ' did not properly map from ' + InventoryLifeCycleHelper.CR_FIELD_MAP.get(ilcField) );
        }
        System.assertEquals( cr[0].Inventory_Life_Cycle__c, ilcList[0].Id, 'The ILC Id should be attached as we are updating it');
    }
    /**
     * Expecting a list of Inventory Life Cycle Records based
     * on the mappings
     * @return void
     */
    public static testMethod void createNewILCs(){
        List<Condition_Report__c> cr = [ SELECT Id, Dealer_Id__c, Vehicle__c, Dealership__c, Auction__c, VIN__c FROM Condition_Report__c ];
        System.assertEquals( 1, cr.size(), 'Only one Condition Report should be found' );
        List<Inventory_Life_Cycle__c> ilcList = InventoryLifeCycleHelper.createNewILCs( cr );
        System.assertEquals( 1, ilcList.size(), 'Only one ILC should be returned');
        for( String ilcField : InventoryLifeCycleHelper.CR_FIELD_MAP.keySet() ){
            System.assertEquals( cr[0].get(InventoryLifeCycleHelper.CR_FIELD_MAP.get(ilcField)), ilcList[0].get(ilcField), ilcField + ' did not properly map from ' + InventoryLifeCycleHelper.CR_FIELD_MAP.get(ilcField) );
        }
    }
    /**
     * Expecting a single Inventory Life Cycle Record based
     * on the mappings
     * @return void
     */
    public static testMethod void createILC(){
        List<Condition_Report__c> cr = [ SELECT Id, Vehicle__c, Dealer_Id__c, Dealership__c, Auction__c, VIN__c FROM Condition_Report__c ];
        System.assertEquals( 1, cr.size(), 'Only one Condition Report should be found' );
        String key = TEST_DEALER_ID + TEST_VIN;
        Inventory_Life_Cycle__c ilc = InventoryLifeCycleHelper.createILC( cr[0], key );
        for( String ilcField : InventoryLifeCycleHelper.CR_FIELD_MAP.keySet() ){
            System.assertEquals( cr[0].get(InventoryLifeCycleHelper.CR_FIELD_MAP.get(ilcField)), ilc.get(ilcField), ilcField + ' did not properly map from ' + InventoryLifeCycleHelper.CR_FIELD_MAP.get(ilcField) );
        }
    }
    /**
     * Expecting the correct Key returned from the function
     * dependent on what sobject is passed in
     * @return void
     */
    public static testMethod void getKey(){
        String key = TEST_DEALER_ID + TEST_VIN;
        List<Auction__c> auc = [ SELECT Id, Seller_Dealer_Id__c, VIN__c FROM Auction__c ];
        List<Condition_Report__c> cr = [ SELECT Id, VIN__c, Dealer_Id__c FROM Condition_Report__c ];
        List<WorkOrderLineItem> woli = [ SELECT Id, VIN__c, Dealer_Id__C FROM WorkOrderLineItem ];
        List<Inventory_Life_Cycle__c> ilc = [ SELECT Id, Key__c FROM Inventory_Life_Cycle__c ];
        System.assertEquals( 1, auc.size(), 'Only 1 Auction should be created' );
        System.assertEquals( 1, cr.size(), 'Only 1 Condition Report should be created' );
        System.assertEquals( 1, woli.size(), 'Only 1 WorkOrderLineItem should be created' );
        System.assertEquals( 1, ilc.size(), 'Only 1 Inventory Life Cyle should be created' );
        System.assertEquals( key, InventoryLifeCycleHelper.getKey(auc[0]), 'Incorrect Key returned for Auction' );
        System.assertEquals( key, InventoryLifeCycleHelper.getKey(cr[0]), 'Incorrect Key returned for Condition Report' );
        System.assertEquals( key, InventoryLifeCycleHelper.getKey(woli[0]), 'Incorrect Key returned for Work Order Line Item' );
        System.assertEquals( key, InventoryLifeCycleHelper.getKey(ilc[0]), 'Incorrect Key returned for Inventory Life Cycle' );
    }
    /**
     * Expecting the population of the Invetory Life Cycle field
     * on the SObject with the existing ILC
     * @return void
     */
    public static testMethod void processCurrentRecordPopulation(){
        List<Condition_Report__c> crList = [ SELECT Id, Dealership__c, VIN__c, Inventory_Life_Cycle__c FROM Condition_Report__c ];
        System.assertEquals( 1, crList.size(), 'A Condition Report was not found' );
        Id ilcId = crList[0].Inventory_Life_Cycle__c;
        for( Condition_Report__c cr: crList ){
            cr.Inventory_Life_Cycle__c = null;
        }
        update crList;
        Map<Id,Account> acctMap = new Map<Id,Account>( [ SELECT Id, Dealership_Id__c FROM Account ] );
        Map<String,List<SObject>> groupedRecordsMap = InventoryLifeCycleHelper.groupIlcKeyToSObjectList(crList, acctMap, 'Dealership__c', 'VIN__c');
        List<SObject> recordsUpdated = InventoryLifeCycleHelper.processCurrentRecordPopulation(groupedRecordsMap, 'Inventory_Life_Cycle__c' );
        System.assertEquals( 1, recordsUpdated.size(), 'One record should\'ve been updated');
        System.assertEquals( ilcId, recordsUpdated[0].get('Inventory_Life_Cycle__c'), 'Condition Report ILC field should\'ve been populated with the ILC');
    }
    /**
     * Expecting a grouped Map of Key to List of records associated with that key
     * @return void
     */
    public static testMethod void groupIlcKeyToSObjectList(){
        String key = TEST_DEALER_ID + TEST_VIN;
        List<Condition_Report__c> crList = [ SELECT Id, Dealership__c, VIN__c FROM Condition_Report__c ];
        Map<Id,Account> acctMap = new Map<Id,Account>( [ SELECT Id, Dealership_Id__c FROM Account ] );
        Map<String,List<SObject>> groupedRecordsMap = InventoryLifeCycleHelper.groupIlcKeyToSObjectList(crList, acctMap, 'Dealership__c', 'VIN__c');
        System.assertEquals( 1, groupedRecordsMap.size(), 'The map should only have one value' );
        System.assertEquals( 1, groupedRecordsMap.get(key).size(), 'For our key, there should only be one value in the list returned' );
    }
    /**
     * Expecting the correct API name of the ilc most recent field
     * based on what sobj is passed in
     * @return void
     */
    public static testMethod void getMostRecentAPINameField(){
        List<Auction__c> auc = [ SELECT Id, Seller_Dealer_Id__c, VIN__c FROM Auction__c ];
        List<Condition_Report__c> cr = [ SELECT Id, VIN__c, Dealer_Id__c FROM Condition_Report__c ];
        List<WorkOrderLineItem> woli = [ SELECT Id, VIN__c, Dealer_Id__C FROM WorkOrderLineItem ];
        System.assertEquals( 1, auc.size(), 'Only 1 Auction should be created' );
        System.assertEquals( 1, cr.size(), 'Only 1 Condition Report should be created' );
        System.assertEquals( 1, woli.size(), 'Only 1 WorkOrderLineItem should be created' );
        System.assertEquals( 'Most_Recent_Auction__c', InventoryLifeCycleHelper.getMostRecentAPINameField(auc[0]), 'Incorrect Key returned for Auction' );
        System.assertEquals( 'Most_Recent_Condition_Report__c', InventoryLifeCycleHelper.getMostRecentAPINameField(cr[0]), 'Incorrect Key returned for Condition Report' );
        System.assertEquals( 'Most_Recent_Work_Order_Line_Item__c', InventoryLifeCycleHelper.getMostRecentAPINameField(woli[0]), 'Incorrect Key returned for Work Order Line Item' );
    }
}