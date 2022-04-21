/**
 * This class holds the Trigger logic for creating Inventory Life Cycles 
 * and updating the CR when an Auction is triggered
 * @author James Andre LaCour
 */
public class InventoryLifeCycleAuction extends TriggerInterface{
    /****************Class Variables************************/
    /****************Context Methods************************/
    /**
     * logic to run in before insert context.
     * Populates the Inventory Life Cycle field if it already exists
     * @param newList - List of new Auctions created
     * @return void
     */
    public override void beforeInsert( List<SObject> newList ){
        Set<Id> acctIdSet = new Set<Id>();
        //In Before Context, formula's aren't populated so we need to get Dealer Id from Account record (Seller Dealership)
        for( Auction__c auc : (List<Auction__c>)newList ){
            acctIdSet.add(auc.Seller_Dealership__c);
        }
        //Organize in a map of our Identifier to the Inventory Life Cycle Key we will need
        Map<Id,Account> acctMap = new Map<Id,Account>( [ SELECT Id, Dealership_Id__c FROM Account WHERE Id IN :acctIdSet AND Dealer_Type__c IN :InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values() ] );
        if( acctMap.size() == 0 ) return;
        Map<String,List<Auction__c>> ilcKeyToAucMap = InventoryLifeCycleHelper.groupIlcKeyToSObjectList(newList, acctMap,'Seller_Dealership__c','VIN__c');
        //Run logic to populate field if existing
        InventoryLifeCycleHelper.processCurrentRecordPopulation( ilcKeyToAucMap, 'Inventory_Life_Cycle__c' );
    }
    /**
     * logic to run in after insert context.
     * Creates Inventory Life Cycle if it doesn't exist and updates the Auction with it
     * @param newList - List of new Auctions created
     * @return void
     */
    public override void afterInsert(Map<Id, SObject> newMap){
        List<Auction__c> aucsToCreateIlcList = new List<Auction__c>();
        Map<Id,Auction__c> aucsToUpdateIlcMap = new Map<Id,Auction__c>();
        //Update - Happens when we have a Inventory Life Cycle already. We update the ILC wit the new Auction's values
        //Insert - Happens when an Inventory Life Cycle Record isn'twill  found. We create one and populate the Auction with it
        for( Auction__c auc: (List<Auction__c>)newMap.values() ){
            if( !InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.keyset().contains(auc.Dealer_Type__c) || String.isBlank(auc.VIN__c) || String.isBlank(auc.Seller_Dealer_ID__c) ){
                continue;
            }
            if( auc.Inventory_Life_Cycle__c == null ){
                aucsToCreateIlcList.add(auc);
            }else{
                aucsToUpdateIlcMap.put(auc.Id,auc);
            }
        }
        if( aucsToCreateIlcList.size() == 0 && aucsToUpdateIlcMap.size() == 0 ) return;
        List<Inventory_Life_Cycle__c> ilcsToUpsertList = new List<Inventory_Life_Cycle__c>();
        //Create or Update Inventory Life Cycle Records populated with certain fields (Map found in InventoryLifeCycleHelper.cls)
        List<Inventory_Life_Cycle__c> ilcsToCreateList = InventoryLifeCycleHelper.createNewILCs( aucsToCreateIlcList );
        List<Inventory_Life_Cycle__c> ilcsToUpdateList = InventoryLifeCycleHelper.updateExistingILCs( aucsToUpdateIlcMap, 'Inventory_Life_Cycle__c', 'start_time__c' );
        ilcsToUpsertList.addAll(ilcsToCreateList);
        ilcsToUpsertList.addAll(ilcsToUpdateList);
        if( ilcsToUpsertList.size() > 0 ) upsert ilcsToUpsertList;
        //On Insert, we need to repopulate the field on Auction with the new Inventory Life Cycle
        if( ilcsToCreateList.size() > 0 ){
            Map<String, Inventory_Life_Cycle__c> ilcKeyToIlcMap = InventoryLifeCycleHelper.createILCKeyMap(ilcsToCreateList);
            List<Auction__c> auctionsToUpdate = new List<Auction__c>();
            for( Auction__c auc : aucsToCreateIlcList ){
                String key = InventoryLifeCycleHelper.getKey(auc);
                if( ilcKeyToIlcMap.get( key ) != null ){
                    Auction__c tempAuc = new Auction__c();
                    tempAuc.Id = auc.Id;
                    tempAuc.Inventory_Life_Cycle__c = ilcKeyToIlcMap.get( key ).Id;
                    auctionsToUpdate.add(tempAuc);
                }
            }
            if( auctionsToUpdate.size() > 0 ) update auctionsToUpdate;
        }
    }
    /**
     * logic to run in after delete context.
     * If this record was the most recent, reparent the ILC to the new most recent
     * @param oldMap - Map of Auctions that were deleted
     * @return void
     */
    public override void afterDelete(Map<Id,SObject> oldMap){
        Set<Id> ilcIds = new Set<Id>();
        //Gather Id's to reparent the Inventory Life Cycle
        for( Auction__c auc: (List<Auction__c>)oldMap.values() ){
            if( auc.Inventory_Life_Cycle__c != null ){
                ilcIds.add(auc.Inventory_Life_Cycle__c);
            }
        }
        if( ilcIds.size() == 0 )return;
        //Created Date determines the next recent
        //Update the ILC with the most recent Auction that is Tied to it
        List<Inventory_Life_Cycle__c> ilcsToUpdate = new List<Inventory_Life_Cycle__c>();
        for( Inventory_Life_Cycle__c ilc : [ SELECT Id, Key__c, Most_Recent_Auction__c,
                                                (SELECT Id, Seller_Dealer_ID__c, Condition_Report_ID__c, VIN__c, Dealer_Id__c, Inventory_Life_Cycle__c,
                                                    Seller_Dealership__c, vehicle_id__c
                                                 FROM Auctions__r 
                                                 ORDER BY CreatedDate DESC 
                                                 LIMIT 1) 
                                             FROM Inventory_Life_Cycle__c 
                                             WHERE Id IN :ilcIds AND Archived__c != true ])
        {
            //If this was the most recent that was deleted, the Most Recent Condition Report field will be blanked out
            if( ilc.Auctions__r.size() > 0 && ilc.Most_Recent_Auction__c == null ){
                ilcsToUpdate.addAll( InventoryLifeCycleHelper.updateExistingILCs(new Map<Id,Auction__c>(ilc.Auctions__r), 'Inventory_Life_Cycle__c', 'start_time__c') );
            }
        }
        if(ilcsToUpdate.size() > 0 ){
            update ilcsToUpdate;
        }
    }
}