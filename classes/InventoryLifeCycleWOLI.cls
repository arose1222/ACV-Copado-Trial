/**
 * This class holds the Trigger logic for creating Inventory Life Cycles and 
 * updating Work Order Line Items when a WOLI is triggerd.
 * @author James Andre LaCour
 */
public class InventoryLifeCycleWOLI extends TriggerInterface{
    /****************Class Variables************************/
    /****************Context Methods************************/
    /**
     * logic to run in before insert context.
     * Populates the Inventory Life Cycle field if it already exists
     * @param newList - List of new Work Order Line Items created
     * @return void
     */
    public override void beforeInsert( List<SObject> newList ){
        Set<Id> woIdSet = new Set<Id>();
        //In Before Context, formula's aren't populated so we need to get Dealer Id from Account record
        for( WorkOrderLineItem woli : (List<WorkOrderLineItem>)newList ){
            woIdSet.add(woli.WorkOrderId);
        }
        //Organize in a map of our Identifier to the Inventory Life Cycle Key we will need
        Map<Id,Account> woIdToAcctMap = new Map<Id,Account>();
        for( WorkOrder wo : [ SELECT Id, AccountId, Account.Dealership_Id__c FROM WorkOrder WHERE Id IN :woIdSet AND Account.Dealer_Type__c IN :InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()] ){
            Account tempAcct = new Account();
            tempAcct.Id = wo.AccountId;
            tempAcct.Dealership_Id__c = wo.Account.Dealership_Id__c;
            woIdToAcctMap.put(wo.Id, tempAcct);
        }
        if (woIdToAcctMap.size() == 0 ) return;
        Map<String,List<WorkOrderLineItem>> ilcKeyToWOLIMap = InventoryLifeCycleHelper.groupIlcKeyToSObjectList(newList, woIdToAcctMap,'WorkOrderId','VIN__c');
        //Run logic to populate field if existing
        InventoryLifeCycleHelper.processCurrentRecordPopulation( ilcKeyToWOLIMap, 'Inventory_Life_Cycle__c' );
    }
    /**
     * logic to run in after insert context.
     * Creates Inventory Life Cycle if it doesn't exist and updates the WOLI with it
     * @param newList - List of new Work Order Line Items created
     * @return void
     */
    public override void afterInsert(Map<Id, SObject> newMap){
        List<WorkOrderLineItem> wolisToCreateIlcList = new List<WorkOrderLineItem>();
        Map<Id,WorkOrderLineItem> wolisToUpdateIlcMap = new Map<Id,WorkOrderLineItem>();
        //Update - Happens when we have a Inventory Life Cycle already. We update the ILC wit the new CR's values
        //Insert - Happens when an Inventory Life Cycle Record isn't found. We create one and populate the CR with it
        for( WorkOrderLineItem woli: (List<WorkOrderLineItem>)newMap.values() ){
            if( !InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values().contains(woli.Dealer_Type__c) || String.isBlank(woli.VIN__c) || String.isBlank(woli.Dealer_Id__c) ){
                continue;
            }
            if( woli.Inventory_Life_Cycle__c == null ){
                wolisToCreateIlcList.add(woli);
            }else{
                wolisToUpdateIlcMap.put(woli.Id,woli);
            }
        }
        if( wolisToCreateIlcList.size() == 0 && wolisToUpdateIlcMap.size() == 0 ) return;
        List<Inventory_Life_Cycle__c> ilcsToUpsertList = new List<Inventory_Life_Cycle__c>();
        //Create Inventory Life Cycle Records populated with certain fields (Map found in InventoryLifeCycleHelper.cls)
        List<Inventory_Life_Cycle__c> ilcsToCreateList = InventoryLifeCycleHelper.createNewILCs( wolisToCreateIlcList );
        List<Inventory_Life_Cycle__c> ilcsToUpdateList = InventoryLifeCycleHelper.updateExistingILCs( wolisToUpdateIlcMap, 'Inventory_Life_Cycle__c', 'CreatedDate' );
        ilcsToUpsertList.addAll(ilcsToCreateList);
        ilcsToUpsertList.addAll(ilcsToUpdateList);
        if( ilcsToUpsertList.size() > 0 ) upsert ilcsToUpsertList;
        //On Insert, we need to repopulate the field on WOLI with the new Inventory Life Cycle
        if( ilcsToCreateList.size() > 0 ){
            Map<String, Inventory_Life_Cycle__c> ilcKeyToIlcMap = InventoryLifeCycleHelper.createILCKeyMap(ilcsToCreateList);
            List<WorkOrderLineItem> wolisToUpdate = new List<WorkOrderLineItem>();
            for( WorkOrderLineItem woli : wolisToCreateIlcList ){
                String key = InventoryLifeCycleHelper.getKey(woli);
                if( ilcKeyToIlcMap.get( key ) != null ){
                    WorkOrderLineItem tempWoli = new WorkOrderLineItem();
                    tempWoli.Id = woli.Id;
                    tempWoli.Inventory_Life_Cycle__c = ilcKeyToIlcMap.get( key ).Id;
                    wolisToUpdate.add(tempWoli);
                }
            }
            if( wolisToUpdate.size() > 0 ) update wolisToUpdate;
        }
    }
    /**
     * logic to run in after delete context.
     * If this record was the most recent, reparent the ILC to the new most recent
     * @param oldMap - Map of WorkOrderLineItems that were deleted
     * @return void
     */
    public override void afterDelete(Map<Id,SObject> oldMap){
        Set<Id> ilcIds = new Set<Id>();
        //Gather Id's to reparent the Inventory Life Cycle
        for( WorkOrderLineItem woli: (List<WorkOrderLineItem>)oldMap.values() ){
            if( woli.Inventory_Life_Cycle__c != null ){
                ilcIds.add(woli.Inventory_Life_Cycle__c);
            }
        }
        if( ilcIds.size() == 0 )return;
        //Created Date determines the next recent
        //Update the ILC with the most recent Work Order Line Item that is Tied to it
        List<Inventory_Life_Cycle__c> ilcsToUpdate = new List<Inventory_Life_Cycle__c>();
        for( Inventory_Life_Cycle__c ilc : [ SELECT Id, Key__c, Most_Recent_Work_Order_Line_Item__c,
                                                (SELECT Id, Dealer_Salesforce_Id__c, Vehicle__c, VIN__c, Dealer_Id__c, Inventory_Life_Cycle__c 
                                                 FROM Work_Order_Line_Items__r 
                                                 ORDER BY CreatedDate DESC 
                                                 LIMIT 1) 
                                             FROM Inventory_Life_Cycle__c 
                                             WHERE Id IN :ilcIds AND Archived__c != true ])
        {
            //If this was the most recent that was deleted, the Most Recent Condition Report field will be blanked out
            if( ilc.Work_Order_Line_Items__r.size() > 0 && ilc.Most_Recent_Work_Order_Line_Item__c == null ){
                ilcsToUpdate.addAll( InventoryLifeCycleHelper.updateExistingILCs(new Map<Id,WorkOrderLineItem>(ilc.Work_Order_Line_Items__r), 'Inventory_Life_Cycle__c', 'CreatedDate') );
            }
        }
        if(ilcsToUpdate.size() > 0 ){
            update ilcsToUpdate;
        }
    }
}