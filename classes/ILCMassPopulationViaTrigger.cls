/**
 * This class holds the Trigger logic for Bulk backfill updates for Inventory
 * Life Cycle Records
 * @author James Andre LaCour
 */
public class ILCMassPopulationViaTrigger extends TriggerInterface{
    /****************Class Variables************************/
    /****************Inner Classes**************************/
    /**
     * A Wrapper Class that holds the Id values that need to be assigned
     * to an Inventory Life Cycle. The goal is for this to hold the Most
     * Recent values
     */
    public class RelatedRecordWrapper{
        Id auctionId;
        Id crId;
        Id woliId;
        Id clientId;
        id vehicleId;
        /**
         * Constructor nulls variables. We check on null to see if its been populuated
         * yet in the logic
         */
        public RelatedRecordWrapper(){
            auctionId = null;
            crId = null;
            woliId = null;
            clientId = null;
            vehicleId = null;
        }
    }
    /****************Context Methods************************/
    /**
     * logic to run in before insert context.
     * Populates the Client, Most Recent Auction, Work Order Line Item, and Condition Report
     * on the Inventory Life Cycle if this is a Mass backfill (meaning checkbox is checked)
     * @param newList - List of new Work Order Line Items created
     * @return void
     */
    public override void beforeInsert( List<SObject> newList ){
        Set<String> dealerIdSet = new Set<String>();
        Set<String> vinSet = new Set<String>();
        List<Inventory_Life_Cycle__c> recordsToProcess = new List<Inventory_Life_Cycle__c>();
        //Update with Most Current needs to be checked and the required values to make the Key__c needs to be on the record
        for( Inventory_Life_Cycle__c ilc : (List<Inventory_Life_Cycle__c>)newList ){
            if( ilc.Update_With_Most_Current__c && String.isNotBlank(ilc.Dealer_Id_Text__c) && String.isNotBlank(ilc.VIN__c) ){
                dealerIdSet.add(ilc.Dealer_Id_Text__c);
                vinSet.add(ilc.VIN__c);
                recordsToProcess.add(ilc);
            }
        }
        if( dealerIdSet.size() == 0 || vinSet.size() == 0 ) return;
        Map<String,RelatedRecordWrapper> keyToWrapMap = new Map<String,RelatedRecordWrapper>(); //Key__C to Wrapper
        //Gathers Auction ordered by most recent CreatedDate. We take the Most recent value to populate with
        for( Auction__c auc : [ SELECT Id, vehicle_id__c, Seller_Dealer_Id__c, Seller_Dealership__c, VIN__c FROM Auction__c WHERE Seller_Dealership__r.Dealership_Id__c IN :dealerIdSet AND VIN__c IN :vinSet ORDER BY CreatedDate DESC ] ){
            String key = InventoryLifeCycleHelper.getKey(auc);
            if( keyToWrapMap.get(key) == null ) keyToWrapMap.put( key, new RelatedRecordWrapper() );
            if( keyToWrapMap.get(key).auctionId == null ){
                keyToWrapMap.get(key).auctionId = auc.Id;
            }
            if( keyToWrapMap.get(key).clientId == null ){
                keyToWrapMap.get(key).clientId = auc.Seller_Dealership__c;
            }
            if( keyToWrapMap.get(key).vehicleId == null ){
                keyToWrapMap.get(key).vehicleId = auc.vehicle_id__c;
            }
        }
        //Gathers Auction ordered by most recent CreatedDate. We take the Most recent value to populate with
        for( Condition_Report__c cr : [ SELECT Id, Vehicle__c, CreatedDate, Dealership__c, VIN__c, Dealer_Id__c FROM Condition_Report__c WHERE Dealership__r.Dealership_Id__c IN :dealerIdSet AND VIN__c IN :vinSet ORDER BY CreatedDate DESC ] ){
            String key = InventoryLifeCycleHelper.getKey(cr);
            if( keyToWrapMap.get(key) == null ) keyToWrapMap.put( key, new RelatedRecordWrapper() );
            if( keyToWrapMap.get(key).crId == null ){
                keyToWrapMap.get(key).crId = cr.Id;
            }
            if( keyToWrapMap.get(key).clientId == null ){
                keyToWrapMap.get(key).clientId = cr.Dealership__c;
            }
            if( keyToWrapMap.get(key).vehicleId == null ){
                keyToWrapMap.get(key).vehicleId = cr.Vehicle__c;
            }
        }
        //Gathers Auction ordered by most recent CreatedDate. We take the Most recent value to populate with
        for( WorkOrderLineItem woli : [ SELECT Id, Vehicle__c, CreatedDate, WorkOrder.AccountId, VIN__c, Dealer_Id__c FROM WorkOrderLineItem WHERE WorkOrder.Account.Dealership_Id__c IN :dealerIdSet AND VIN__c IN :vinSet ORDER BY CreatedDate DESC ] ){
            String key = InventoryLifeCycleHelper.getKey(woli);
            if( keyToWrapMap.get(key) == null ) keyToWrapMap.put( key, new RelatedRecordWrapper() );
            if( keyToWrapMap.get(key).woliId == null ){
                keyToWrapMap.get(key).woliId = woli.Id;
            }
            if( keyToWrapMap.get(key).clientId == null ){
                keyToWrapMap.get(key).clientId = woli.WorkOrder.AccountId;
            }
            if( keyToWrapMap.get(key).vehicleId == null ){
                keyToWrapMap.get(key).vehicleId = woli.Vehicle__c;
            }
        }
        //Updates values on Inventory Life Cycle
        for( Inventory_Life_Cycle__c ilc : recordsToProcess ){
            ilc.Most_Recent_Auction__c = keyToWrapMap.get(ilc.key__c).auctionId;
            ilc.Most_Recent_Condition_Report__c = keyToWrapMap.get(ilc.key__c).crId;
            ilc.Most_Recent_Work_Order_Line_Item__c = keyToWrapMap.get(ilc.key__c).woliId;
            ilc.Client__c = keyToWrapMap.get(ilc.key__c).clientId;
            ilc.Vehicle__c = keyToWrapMap.get(ilc.key__c).vehicleId;
            ilc.Update_With_Most_Current__c = false;                    //Reset Flag just incase in the future this gets added to update logic.
        }
    }
    /**
     * logic to run in after update context.
     * Populates the Inventory Life Cycle field on Auction,
     * Condition Report and Work Order Line Item
     * @param newList - List of new Work Order Line Items created
     * @return void
     */
    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Map<String,Id> keyToILCIdMap = new Map<String,Id>();
        Set<String> dealerIdSet = new Set<String>();
        Set<String> vinSet = new Set<String>();
        //Gathers values to query other objects
        for( Inventory_Life_Cycle__c ilc : (List<Inventory_Life_Cycle__c>)newMap.values() ){
            if( ilc.Update_Lookups_with_Inventory_Life_Cycle__c && !((Inventory_Life_Cycle__c)oldMap.get(ilc.Id)).Update_Lookups_with_Inventory_Life_Cycle__c ){
                keyToILCIdMap.put(ilc.Key__c, ilc.Id);
                dealerIdSet.add(ilc.Dealer_Id__c);
                vinSet.add(ilc.VIN__c);
            }
        }
        if( keyToILCIdMap.values().size() == 0 )return;
        //Queries and sets the ILC on Auction
        List<Auction__c> aucsToUpdate = new List<Auction__c>();
        for( Auction__c auc : [ SELECT Id, Inventory_Life_Cycle__c, Seller_Dealership__r.Dealership_Id__c, VIN__c FROM Auction__c WHERE Seller_Dealership__r.Dealership_Id__c IN :dealerIdSet AND VIN__c IN :vinSet ]){
            String key = auc.Seller_Dealership__r.Dealership_Id__c + auc.VIN__c;
            if( keyToILCIdMap.get(key) != null ){
                auc.Inventory_Life_Cycle__c = keyToILCIdMap.get(key);
                aucsToUpdate.add(auc);
            }
        }
        //Queries and sets the ILC on Condition Report
        List<Condition_Report__c> crsToUpdate = new List<Condition_Report__c>();
        for( Condition_Report__c cr : [ SELECT Id, Inventory_Life_Cycle__c, Dealership__r.Dealership_Id__c, VIN__c FROM Condition_Report__c WHERE Dealership__r.Dealership_Id__c IN :dealerIdSet AND VIN__c IN :vinSet ]){
            String key = cr.Dealership__r.Dealership_Id__c + cr.VIN__c;
            if( keyToILCIdMap.get(key) != null ){
                cr.Inventory_Life_Cycle__c = keyToILCIdMap.get(key);
                crsToUpdate.add(cr);
            }
        }
        //Queries and sets the ILC on Work Order Line Item
        List<WorkOrderLineItem> wolisToUpdate = new List<WorkOrderLineItem>();
        for( WorkOrderLineItem woli : [ SELECT Id, Inventory_Life_Cycle__c, WorkOrder.Account.Dealership_Id__c, VIN__c FROM WorkOrderLineItem WHERE WorkOrder.Account.Dealership_Id__c IN :dealerIdSet AND VIN__c IN :vinSet ]){
            String key = woli.WorkOrder.Account.Dealership_Id__c + woli.VIN__c;
            if( keyToILCIdMap.get(key) != null ){
                woli.Inventory_Life_Cycle__c = keyToILCIdMap.get(key);
                wolisToUpdate.add(woli);
            }
        }
        if(aucsToUpdate.size() > 0) update aucsToUpdate;
        if(crsToUpdate.size() > 0) update crsToUpdate;
        if(wolisToUpdate.size() > 0) update wolisToUpdate;
    }
}