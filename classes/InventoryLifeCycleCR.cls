/**
 * This class holds the Trigger logic for creating Inventory Life Cycles 
 * and updating the CR when a Condition Report is triggered
 * @author James Andre LaCour
 */
public class InventoryLifeCycleCR extends TriggerInterface{
    /****************Class Variables************************/
    /****************Context Methods************************/
    /**
     * logic to run in before insert context.
     * Populates the Inventory Life Cycle field if it already exists
     * @param newList - List of new Condition Reports created
     * @return void
     */
    public override void beforeInsert( List<SObject> newList ){
        Set<Id> acctIdSet = new Set<Id>();
        //In Before Context, formula's aren't populated so we need to get Dealer Id from Account record
        for( Condition_Report__c cr : (List<Condition_Report__c>)newList ){
            acctIdSet.add(cr.Dealership__c);
        }
        //Organize in a map of our Identifier to the Inventory Life Cycle Key we will need
        Map<Id,Account> acctMap = new Map<Id,Account>( [ SELECT Id, Dealership_Id__c FROM Account WHERE Id IN :acctIdSet AND Dealer_Type__c IN :InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values() ] );
        if( acctMap.size() == 0 ) return;
        Map<String,List<Condition_Report__c>> ilcKeyToCrsMap = InventoryLifeCycleHelper.groupIlcKeyToSObjectList(newList, acctMap,'Dealership__c','VIN__c');
        //Run logic to populate field if existing
        InventoryLifeCycleHelper.processCurrentRecordPopulation( ilcKeyToCrsMap, 'Inventory_Life_Cycle__c' );
    }
    /**
     * logic to run in after insert context.
     * Creates Inventory Life Cycle if it doesn't exist and updates the CR with it
     * @param newList - List of new Condition Reports created
     * @return void
     */
    public override void afterInsert( Map<Id, SObject> newMap ){
        List<Condition_Report__c> crsToCreateIlcList = new List<Condition_Report__c>();
        Map<Id,Condition_Report__c> crsToUpdateIlcMap = new Map<Id,Condition_Report__c>();
        //Update - Happens when we have a Inventory Life Cycle already. We update the ILC wit the new CR's values
        //Insert - Happens when an Inventory Life Cycle Record isn't found. We create one and populate the CR with it
        for( Condition_Report__c cr: (List<Condition_Report__c>)newMap.values() ){
            if( !InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values().contains(cr.Dealer_Type__c) || String.isBlank(cr.VIN__c) || String.isBlank(cr.Dealer_Id__c) ){
                continue;
            }
            if( cr.Inventory_Life_Cycle__c == null ){
                crsToCreateIlcList.add(cr);
            }else{
                crsToUpdateIlcMap.put(cr.Id,cr);
            }
        }
        if( crsToCreateIlcList.size() == 0 && crsToUpdateIlcMap.size() == 0 ) return;
        List<Inventory_Life_Cycle__c> ilcsToUpsertList = new List<Inventory_Life_Cycle__c>();
        //Create or Update Inventory Life Cycle Records populated with certain fields (Map found in InventoryLifeCycleHelper.cls)
        List<Inventory_Life_Cycle__c> ilcsToCreateList = InventoryLifeCycleHelper.createNewILCs( crsToCreateIlcList );
        List<Inventory_Life_Cycle__c> ilcsToUpdateList = InventoryLifeCycleHelper.updateExistingILCs( crsToUpdateIlcMap, 'Inventory_Life_Cycle__c', 'CR_Doc_CreateDate__c' );
        ilcsToUpsertList.addAll(ilcsToCreateList);
        ilcsToUpsertList.addAll(ilcsToUpdateList);
        if( ilcsToUpsertList.size() > 0 ) upsert ilcsToUpsertList;
        //On Insert, we need to repopulate the field on CR with the new Inventory Life Cycle
        if( ilcsToCreateList.size() > 0 ){
            Map<String, Inventory_Life_Cycle__c> ilcKeyToIlcMap = InventoryLifeCycleHelper.createILCKeyMap(ilcsToCreateList);
            List<Condition_Report__c> crsToUpdate = new List<Condition_Report__c>();
            for( Condition_Report__c cr : crsToCreateIlcList ){
                String key = InventoryLifeCycleHelper.getKey(cr);
                if( ilcKeyToIlcMap.get( key ) != null ){
                    Condition_Report__c tempCr = new Condition_Report__c();
                    tempCr.Id = cr.Id;
                    tempCr.Inventory_Life_Cycle__c = ilcKeyToIlcMap.get( key ).Id;
                    crsToUpdate.add(tempCr);
                }
            }
            if( crsToUpdate.size() > 0 ) update crsToUpdate;
        }
    }
    /**
     * logic to run in after delete context.
     * If this record was the most recent, reparent the ILC to the new most recent
     * @param oldMap - Map of Condition Reports that were deleted
     * @return void
     */
    public override void afterDelete(Map<Id,SObject> oldMap){
        Set<Id> ilcIds = new Set<Id>();
        //Gather Id's to reparent the Inventory Life Cycle
        for( Condition_Report__c cr: (List<Condition_Report__c>)oldMap.values() ){
            if( cr.Inventory_Life_Cycle__c != null ){
                ilcIds.add(cr.Inventory_Life_Cycle__c);
            }
        }
        if( ilcIds.size() == 0 )return;
        //Created Date determines the next recent
        //Update the ILC with the most recent Condition Report that is Tied to it
        List<Inventory_Life_Cycle__c> ilcsToUpdate = new List<Inventory_Life_Cycle__c>();
        for( Inventory_Life_Cycle__c ilc : [ SELECT Id, Key__c, Most_Recent_Condition_Report__c,
                                                (SELECT Id, Vehicle__c, Dealership__c, Auction__c, VIN__c, Inventory_Life_Cycle__c, Dealer_Id__c
                                                 FROM Condition_Reports__r 
                                                 ORDER BY CreatedDate DESC 
                                                 LIMIT 1) 
                                             FROM Inventory_Life_Cycle__c 
                                             WHERE Id IN :ilcIds AND Archived__c != true ])
        {
            //If this was the most recent that was deleted, the Most Recent Condition Report field will be blanked out
            if( ilc.Condition_Reports__r.size() > 0 && ilc.Most_Recent_Condition_Report__c == null ){
                ilcsToUpdate.addAll( InventoryLifeCycleHelper.updateExistingILCs(new Map<Id,Condition_Report__c>(ilc.Condition_Reports__r), 'Inventory_Life_Cycle__c', 'CR_Doc_CreateDate__c') );
            }
        }
        if(ilcsToUpdate.size() > 0 ){
            update ilcsToUpdate;
        }
    }
}