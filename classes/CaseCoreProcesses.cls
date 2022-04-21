public class CaseCoreProcesses {
    private static Map<Id, String> triggeredCases = new Map<Id, String>();
    
    private static List<Case> getUnTriggeredCases(List<Case> checkCasesIfTriggered)	{
        List<Case> unTriggeredCases = new List<Case>();
        for(Case c : checkCasesIfTriggered)	{
            String tc = triggeredCases.get(c.Id);
            if(tc == null)	{
                /* Map is used for constant lookup time. 
                 * A single letter ('y' in this case) is used as a value to keep the memory footprint small.
                 * There is no other significance of the letter 'y' here.
                 */
                triggeredCases.put(c.Id, 'y');
                unTriggeredCases.add(c);
            }
        }
        
        return unTriggeredCases;
    }
    
    /*
     * @description This recussive trigger is reset after every trancsaction (like insert/update/etc operations).
     * Sometimes, we want to reset the recussive trigger within a transaction (e.g. a Unit Test where each test method is run within a single transaction).
     */
    public static void reset()	{
        triggeredCases = new Map<Id, String>();
    }
    
    public static void beforeInsert(List<Case> newCaseList){
        List<Case> newCasesNotTriggeredYet = getUnTriggeredCases(newCaseList);
        if(newCasesNotTriggeredYet.size() > 0)	{
            populateISTAccountOnCase(newCasesNotTriggeredYet);
            stampAuctionFields(newCasesNotTriggeredYet);
            stampVehicleFields(newCasesNotTriggeredYet, null);
            stampPrimarySellerContact(newCasesNotTriggeredYet);
    	}
    }

    public static void afterInsert(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    }

    public static void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        List<Case> newCasesNotTriggeredYet = getUnTriggeredCases((List<Case>)newCaseMap.values());
        if(newCasesNotTriggeredYet.size() > 0)	{
            Map<Id, Case> newCasesNotTriggeredYetMap = new Map<Id, Case>();
            for(Case c : newCasesNotTriggeredYet)	{
                newCasesNotTriggeredYetMap.put(c.Id, c);
            }
            changeCaseOwnertoTakeCaseId(newCasesNotTriggeredYetMap, (Map<Id,Case>)oldcasemap);
            stampAuctionFields(newCasesNotTriggeredYet);
            stampVehicleFields(newCasesNotTriggeredYet, (Map<Id,Case>)oldCaseMap);
        }
    }

    public static void afterUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
    }

    /**
     * populateISTAccountOnCase
     *   GIVEN a Case with null AccountId
     *   AND Case status does not equal 'Closed'
     *   AND Case status does not equal 'Denial Pending's
     *   WHEN Case is inserted
     *   THEN Set IST Account Owner Lookup on case to IST_Account of related Account 
     *
     * @param  newcaseList 
     */
    public static void populateISTAccountOnCase (List<Case> newCaseList ){
        Set<Id> accountIdset = new Set<Id>();
        for(Case c :newCaseList){    
            accountIDSet.add(c.AccountId);
        }
        // Remove null values to prevent SOQL errors
        accountIdset.remove(null);

        if(accountIdset == null){
            return;
        }

        Map<Id,Account> accountMap = new Map<Id,Account> ([SELECT Id, IST_Account_Owner__C 
                                                           FROM Account 
                                                           WHERE Id IN :accountIDSet ]);
        
        for(Case c :newCaseList){
            //The if statement prevents errors with attempting to dereference a null value/object
            if(c.Status != null && c.accountid != null && c.Status != 'Closed' && c.Status != 'Denial Pending' && 
               accountMap.get(c.accountid).ist_account_owner__C != null){
                    c.IST_Account_Owner_Lookup__c = accountMap.get(c.AccountId).IST_Account_Owner__c;
            }
        }
    
    }

    /**
     * changeCaseOwnertoTakeCaseId 
     *   GIVEN Take Case Id is changed on a Case
     *   AND Take Case Id is not chagned to null
     *   AND the OwnerId starts with '00G'
     *   WHEN a Case is updated
     *   THEN a update the OwnerId to equal the Take Case Id
     *
     * @param  newCaseMap newCaseMap description
     * @param  oldcasemap oldcasemap description
     */
    public static void changeCaseOwnertoTakeCaseId(Map<Id, Case> newCaseMap, Map<Id, Case> oldcasemap){
        List<Case> caseList = new List<Case>();
        for(Case c : newCaseMap.values()){
            if(c.Take_Case_Id__c != null && c.Take_Case_Id__c != oldcasemap.get(c.Id).Take_Case_Id__c && ((String)c.OwnerId).startsWith('00G')){
                caseList.add(c);
            }
        }

        if(caseList.size() == 0){
            return;
        }

        for(Case c : caseList){
            c.Status = 'Working';
            c.OwnerId = c.Take_Case_Id__c;
        }
    }

    /**
     * stampPrimarySellerContact 
     *  GIVEN A Case has a Seller Dealership associated to it
     *  WHEN a Case inserted
     *  THEN Stamp the Seller Dealership's Primary Contact on Case
     *
     * @param  newCaseList
     */
    public static void stampPrimarySellerContact( List<Case> newCaseList ) {
        Set<Id> acctIdSet = new Set<Id>();
        for ( Case caseRec : newCaseList ) {
            if ( caseRec.Seller_Dealership__c != null ) {
                acctIdSet.add( caseRec.Seller_Dealership__c );
            }
        }

        if ( acctIdSet != null && !acctIdSet.isEmpty() ) {
            Map<Id, Account> sellerAcctMap = new Map<Id, Account>( [ SELECT Id, Primary_Contact__c FROM Account WHERE Id IN :acctIdSet ] );
        
            for ( Case caseRec : newCaseList ) {
                if ( sellerAcctMap.get( caseRec.Seller_Dealership__c ) != null ) {
                    caseRec.Seller_Contact__c = sellerAcctMap.get( caseRec.Seller_Dealership__c ).Primary_Contact__c;
                }
            }
        }
    }

    /**
     * stampAuctionFields 
     *  GIVEN A Case has a Auction associated to it
     *  AND the Auction has Buyer Dealership associated to it
     *  WHEN a Case is updated or inserted
     *  THEN Stamp all of the Auction info onto the Case
     *
     * @param  newCaseMap 
     */
    public static void stampAuctionFields(List<Case> newCaseList){
        List<Case> caseList = new List<Case>();
        Set<Id> auctionIdSet = new Set<Id>();
        for(Case c :newCaseList){
            if(c.Auction_Number__c != null){
                auctionIdSet.add(c.Auction_Number__c);
                caseList.add(c);
            }
        }
        auctionIdSet.remove(null);

        if(auctionIdSet.isEmpty()){
            return;
        }

        //Get all related Auctions into map
        Map<Id,Auction__c> auctionMap = new Map<Id,Auction__c>([SELECT Id,Release_Available__c,Release_DateTime__c,Release_Pickup_Phrase__c, Buyer_Dealership__c, Seller_Dealership__c, Seller__c, Buyer_Contact__c, vehicle_id__c 
                                                                FROM Auction__c 
                                                                WHERE Id IN :auctionIdSet]);

        //Update the fields on Case that are null
        for(Case c : caseList){
            if(auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c != null){
                if(c.AccountId == null){
                    c.AccountId = auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c;
                }
                if(c.ContactId == null){
                    c.ContactId = auctionMap.get(c.Auction_Number__c).Buyer_Contact__c;
                }
                if(c.Seller_Dealership__c == null){
                    c.Seller_Dealership__c = auctionMap.get(c.Auction_Number__c).Seller_Dealership__c;
                }
                if(c.Seller_Contact__c == null){
                    c.Seller_Contact__c = auctionMap.get(c.Auction_Number__c).Seller__c;    
                }
                if(c.Vehicle__c == null){
                    c.Vehicle__c = auctionMap.get(c.Auction_Number__c).vehicle_id__c;
                }
                if(c.Release_Pickup_Phrase__c == null){
                    c.Release_Pickup_Phrase__c = auctionMap.get(c.Auction_Number__c).Release_Pickup_Phrase__c;
                }
                if(!c.Release_Available__c){
                    c.Release_Available__c = auctionMap.get(c.Auction_Number__c).Release_Available__c;
                }
                if(c.Release_DateTime__c == null){
                    c.Release_DateTime__c = auctionMap.get(c.Auction_Number__c).Release_DateTime__c;
                }
            }
        }
    }

    public static void stampVehicleFields(List<Case> newCaseList, Map<Id,Case> oldCaseMap){
        List<Case> caseList = new List<Case>();
        Set<Id> vehicleIdSet = new Set<Id>();
        for(Case c :newCaseList){
            if(c.Vehicle__c != null){
                vehicleIdSet.add(c.Vehicle__c);
                caseList.add(c);
            }
        }
        vehicleIdSet.remove(null);

        if(vehicleIdSet.isEmpty()){
            return;
        }
        //Get all related vehicles
        Map<Id,Vehicle__c> vehicleMap = new Map<Id,Vehicle__c>([SELECT Id, Make__c, trim__c, style__c, Model__c, Vin__c, Year__c 
                                                                FROM Vehicle__c 
                                                                WHERE id IN :vehicleIdSet]);
        
        for(Case c : caseList){
            //before update
            if(oldCaseMap != null && oldCaseMap.get(c.Id) != null && c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c){
                if((c.Vehicle_Make__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).Make__c != null){
                c.Vehicle_Make__c = vehicleMap.get(c.Vehicle__c).Make__c;
                }
                if((c.Vehicle_Model__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).Model__c != null){
                    c.Vehicle_Model__c = vehicleMap.get(c.Vehicle__c).Model__c;
                }
                if((c.Vehicle_Year__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).Year__c != null){
                    c.Vehicle_Year__c = vehicleMap.get(c.Vehicle__c).Year__c;
                }
                if((c.Vehicle_VIN__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).Vin__c != null){
                    c.Vehicle_VIN__c = vehicleMap.get(c.Vehicle__c).Vin__c;
                }
                if((c.Vehicle_VIN_Last_6__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).Vin__c != null){
                    c.Vehicle_VIN_Last_6__c = vehicleMap.get(c.Vehicle__c).Vin__c.right(6);
                }
                //vehicle_trim__c, vehicle_style__c, 
                if((c.vehicle_trim__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).trim__c != null){
                    c.vehicle_trim__c = vehicleMap.get(c.Vehicle__c).trim__c;
                }
                if((c.vehicle_style__c == null || c.Vehicle__c != oldCaseMap.get(c.Id).Vehicle__c) && vehicleMap.get(c.Vehicle__c).style__c != null){
                    c.vehicle_style__c = vehicleMap.get(c.Vehicle__c).style__c;
                }
            }
            //before insert
            else{
                if(c.Vehicle_Make__c == null && vehicleMap.get(c.Vehicle__c).Make__c != null){
                    c.Vehicle_Make__c = vehicleMap.get(c.Vehicle__c).Make__c;
                }
                if(c.Vehicle_Model__c == null && vehicleMap.get(c.Vehicle__c).Model__c != null){
                    c.Vehicle_Model__c = vehicleMap.get(c.Vehicle__c).Model__c;
                }
                if(c.Vehicle_Year__c == null && vehicleMap.get(c.Vehicle__c).Year__c != null){
                    c.Vehicle_Year__c = vehicleMap.get(c.Vehicle__c).Year__c;
                }
                if(c.Vehicle_VIN__c == null && vehicleMap.get(c.Vehicle__c).Vin__c != null){
                    c.Vehicle_VIN__c = vehicleMap.get(c.Vehicle__c).Vin__c;
                }
                if(c.Vehicle_VIN_Last_6__c == null && vehicleMap.get(c.Vehicle__c).Vin__c != null){
                    c.Vehicle_VIN_Last_6__c = vehicleMap.get(c.Vehicle__c).Vin__c.right(6);
                }
                if(c.vehicle_trim__c == null && vehicleMap.get(c.Vehicle__c).trim__c != null){
                    c.vehicle_trim__c = vehicleMap.get(c.Vehicle__c).trim__c.right(6);
                }
                if(c.vehicle_style__c == null && vehicleMap.get(c.Vehicle__c).style__c != null){
                    c.vehicle_style__c = vehicleMap.get(c.Vehicle__c).style__c;
                }       
            }
        }
    }
}