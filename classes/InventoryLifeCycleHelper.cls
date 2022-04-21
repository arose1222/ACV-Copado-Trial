/**
 * This class holds Logic Pertaiing to Inventory Life Cycle Object. The functions in here
 * are called from multiple classes so that every class is referencing the same logic
 * @author James Andre LaCour
 */
public class InventoryLifeCycleHelper{
    /****************Class Variables************************/
    //Temporarily we only will have this run on Commercial, Franchise, and Independent - ACV Certified Accounts
    public static final Map<String, String> DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS = new Map<String,String>{'Franchise' => '1', 'Independent - ACV Certified' => '4', 'Commercial' => '5'};
    //Maps to populate Inventory Life Cycle dependent on what record triggered it
    @TestVisible private static final Map<String,String> WOLI_FIELD_MAP = new Map<String,String>{ 
        'Most_Recent_Work_Order_Line_Item__c' => 'Id',
        'Client__c'                           => 'Dealer_Salesforce_Id__c',
        'Vehicle__c'                          => 'Vehicle__c',
        'VIN__c'                              => 'VIN__c'
    };
    @TestVisible private static final Map<String,String> CR_FIELD_MAP = new Map<String,String>{
        'Most_Recent_Condition_Report__c'     => 'Id',
        'Vehicle__c'                          => 'Vehicle__c',
        'Client__c'                           => 'Dealership__c',
        'Most_Recent_Auction__c'              => 'Auction__c',
        'VIN__c'                              => 'VIN__c'
    };
    @TestVisible private static final Map<String,String> AUCTION_FIELD_MAP = new Map<String,String>{
        'Most_Recent_Auction__c'              => 'Id',
        'Most_Recent_Condition_Report__C'     => 'Condition_Report_ID__c',
        'Client__c'                           => 'Seller_Dealership__c',
        'VIN__c'                              => 'VIN__c',
        'Vehicle__c'                          => 'vehicle_id__c',
        'Processing_Status__c'                => ''
    };
    private static final Map<Schema.SObjectType, Map<String, String>> sobjTypeToFieldMap = new Map<Schema.SObjectType, Map<String,String>>{
        Schema.WorkOrderLineItem.getSObjectType()   => WOLI_FIELD_MAP,
        Schema.Condition_Report__c.getSObjectType() => CR_FIELD_MAP,
        Schema.Auction__c.getSObjectType()          => AUCTION_FIELD_MAP
    };
    /****************Helper Methods*************************/
    /**
     * Creates Inventory Life Cycle Map based on the List passed in
     * @param newList - List of ILC's that will be grouped into a Map
     * @return Map<String,Inventory_Life_Cycle> - a Map of ILC Key to the ILC record
     */
    public static Map<String,Inventory_Life_Cycle__c> createILCKeyMap( List<Inventory_Life_Cycle__c> ilcsToCreateList ){
        Map<String, Inventory_Life_Cycle__c> ilcKeyToIlcMap = new Map<String, Inventory_Life_Cycle__c>();
        for( Inventory_Life_Cycle__c ilc : ilcsToCreateList ){
            ilcKeyToIlcMap.put( InventoryLifeCycleHelper.getKey(ilc), ilc );
        }
        return ilcKeyToIlcMap;
    }
    /**
     * Updates existing Inventory Life Cycle's based on Source Records passed in
     * @param mapToUpdateFrom - Map of Source object to update the new ILC from
     * @param fieldNameOfILC - String of field on source object to get the ILC Id from
     * @param compareField - a DateTime field we use to determine Most Recent
     * @return List<Inventory_Life_Cycle__c> - a List of ILC's updated by the field mappings
     */
    public static List<Inventory_Life_Cycle__c> updateExistingILCs( Map<Id,SObject> mapToUpdateFrom, String fieldNameOfILC, String compareField ){
        Map<Id,Inventory_Life_Cycle__C> ilcsToReturnMap = new Map<Id,Inventory_Life_Cycle__c>();
        if( mapToUpdateFrom.size() > 0 ){
            String mostRecentField = getMostRecentAPINameField( mapToUpdateFrom.values()[0] );
            for( SObject sobj : mapToUpdateFrom.values() ){ //If we already have one more recent, then no need to update
                if( ilcsToReturnMap.get((Id)sobj.get(fieldNameOfILC)) != null  && mapToUpdateFrom.get( (Id)ilcsToReturnMap.get((Id)sobj.get(fieldNameOfILC)).get(mostRecentField) ) != null && 
                    (Datetime)mapToUpdateFrom.get( (Id)ilcsToReturnMap.get((Id)sobj.get(fieldNameOfILC)).get(mostRecentField) ).get(compareField) > (Datetime)sobj.get(compareField) ){
                    continue;
                }
                Inventory_Life_Cycle__c ilc = createILC( sobj, getKey(sobj) );
                ilc.Id = (Id)sobj.get(fieldNameOfILC);
                ilcsToReturnMap.put(ilc.Id,ilc);
            }
        }
        return ilcsToReturnMap.values();
    }
    /**
     * Creates Inventory Life Cycle based on the Source Records passed in
     * @param newList - List of Source object to create the new ILC from
     * @return List<Inventory_Life_Cycle__c - a List of ILC's updated by the field mappings
     */
    public static List<Inventory_Life_Cycle__c> createNewILCs( List<SObject> listToCreateFrom ){
        Map<String,Inventory_Life_Cycle__C> ilcsToReturnMap = new Map<String,Inventory_Life_Cycle__c>();
        for( SObject sobj : listToCreateFrom ){
            String key = getKey(sobj);
            if( ilcsToReturnMap.get(key) != null ){ //If one exists for the key, don't need to create another
                continue;
            }
            ilcsToReturnMap.put( key, createILC( sobj, key ) );
        }
        return ilcsToReturnMap.values();
    }
    /**
     * Creates Inventory Life Cycle based on the Source Record passed in
     * @param sobj - source object to map
     * @param key - the key of Dealer Id + Vin to assign
     * @return Inventory_Life_Cycle__c - an Inventory Life Cycle record mapped with its correct fields
     */
    public static Inventory_Life_Cycle__c createILC( SObject sobj, String key ){
        Inventory_Life_Cycle__c ilc = new Inventory_Life_Cycle__c();
        ilc.Key__c = key;
        Map<String, String> fieldMap = sobjTypeToFieldMap.get( sobj.getSObjectType() );
        for( String targetObjectField : fieldMap.keySet() ){
            //Tries to put the field value in. If its not a valid field, it puts the hard coded value in
            try{
                if( sobj.get(fieldMap.get(targetObjectField)) != null ){
                    ilc.put( targetObjectField, sobj.get( fieldMap.get(targetObjectField) ) );
                }
            }catch(Exception ex){
                ilc.put( targetObjectField, fieldMap.get(targetObjectField) );
            }
        }
        return ilc;
    }
    /**
     * Returns the ILC Key for whatever source object is passed in
     * @param sobj - source object to get key from
     * @return String - key of ILC
     */
    public static String getKey(SObject sobj){
        switch on sobj{
            when Inventory_Life_Cycle__c ilc{
                return ilc.Key__c;
            }
            when WorkOrderLineItem woli{
                if( String.isNotBlank(woli.Dealer_Id__c) && String.isNotBlank(woli.Vin__c) ){
                    return woli.Dealer_Id__c + woli.VIN__c;    
                }
            }
            when Auction__c auc{
                if( String.isNotBlank(auc.VIN__c) && String.isNotBlank(auc.Seller_Dealer_ID__c) ){
                    return auc.Seller_Dealer_ID__c + auc.VIN__c;
                }
            }
            when Condition_Report__c cr{
                if( String.isNotBlank(cr.Dealer_Id__c) && String.isNotBlank(cr.VIN__c) ){
                    return cr.Dealer_Id__c + cr.VIN__c;
                }
            }
        }
        return null;
    }
    /**
     * Returns the ILC Key for whatever source object is passed in
     * @param sobj - source object to get key from
     * @return String - key of ILC
     */
    public static List<SObject> processCurrentRecordPopulation( Map<String, List<SObject>> ilcKeyToSObjectMap, String lookupFieldToPopulate ){
        List<SObject> recordsToUpdate = new List<SObject>();
        //Populate Lookup field if one exists
        for( Inventory_Life_Cycle__c ilc : [SELECT Id, Key__c 
                                            FROM Inventory_Life_Cycle__c 
                                            WHERE Key__c IN :ilcKeyToSObjectMap.keySet() AND Archived__c != true ] 
        ){
            if( ilcKeyToSObjectMap.get(ilc.Key__c) == null ) continue;
            for( SObject sobj : ilcKeyToSObjectMap.get(ilc.Key__c) ){
                sobj.put(lookupFieldToPopulate, ilc.Id);
                recordsToUpdate.add(sobj);
            }
        }
        return recordsToUpdate;
    }
    /**
     * Returns the ILC Key for whatever source object is passed in
     * @param recordsToProcess - list of source records to group by ILC
     * @param sourceIdentifierToAccountMap - Map of Account Id to Acocunt
     * @param sourceIdentifierAccount - field on source object that is the Account Id we need
     * @param sourceIdentifierVin - field on source object that references the VIN
     * @return Map<String,List<SObject>> - an organized map of ILC Key to a List of Source Records it applies to
     */
    public static Map<String,List<SObject>> groupIlcKeyToSObjectList( List<SObject> recordsToProcess, Map<Id,Account> sourceIdentifierToAccountMap ,String sourceIdentifierAccount,String sourceIdentifierVin ){
        Map<String,List<SObject>> ilcKeyToSObjectListMap = new Map<String,List<SObject>>();
        for( SObject sobj : recordsToProcess ){
            // Only process records with a valid Key. Key should be Dealer Id on the Dealership + Vehicle VIN
            if( sourceIdentifierToAccountMap.get((Id)sobj.get(sourceIdentifierAccount)) == null || 
                sourceIdentifierToAccountMap.get((Id)sobj.get(sourceIdentifierAccount)).Dealership_Id__c == null || 
                String.isBlank((String)sobj.get(sourceIdentifierVin)) )
            {
                continue;
            }
            if( ilcKeyToSObjectListMap.get(sourceIdentifierToAccountMap.get((Id)sobj.get(sourceIdentifierAccount)).Dealership_Id__c + (String)sobj.get(sourceIdentifierVin)) == null ){
                ilcKeyToSObjectListMap.put(sourceIdentifierToAccountMap.get((Id)sobj.get(sourceIdentifierAccount)).Dealership_Id__c + (String)sobj.get(sourceIdentifierVin), new List<SObject>() );
            }
            ilcKeyToSObjectListMap.get(sourceIdentifierToAccountMap.get((Id)sobj.get(sourceIdentifierAccount)).Dealership_Id__c + (String)sobj.get(sourceIdentifierVin)).add(sobj);
        }
        return ilcKeyToSObjectListMap;
    }
    /**
     * Returns most recent field API name on the ILC based on the Source object
     * @param sobj - source object to get key from
     * @return String - API name of Most recent field
     */
    public static String getMostRecentAPINameField( SObject sobj ){
        String mostRecentField = '';
        switch on sobj{
            when WorkOrderLineItem woli{
                mostRecentField = 'Most_Recent_Work_Order_Line_Item__c';
            }
            when Auction__c auc{
                mostRecentField = 'Most_Recent_Auction__c';
            }
            when Condition_Report__c cr{
                mostRecentField = 'Most_Recent_Condition_Report__c';
            }
        }
        return mostRecentField;
    }
}