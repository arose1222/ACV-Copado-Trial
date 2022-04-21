public class CaseUnwindProcesses {
    private static boolean beforeInsertProcessed = false;
    private static boolean afterInsertProcessed = false;
    private static boolean beforeUpdateProcessed = false;
    private static boolean afterUpdateProcessed = false;

    public static void beforeInsert(List<Case> newCaseList){
        if(beforeInsertProcessed == false){
            List<Case> filteredList = filter(newCaseList);

            if(filteredList.size() > 0){
                beforeInsertProcessed = true;
                updatePickupFields(filteredList);
            }
        } else{
            System.debug('Recursion on Before Insert on Unwind Cases blocked. Use CaseUnwindProcesses.beforeInsertToggle() to step in.');
        }        
    }

    public static void afterInsert(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(afterInsertProcessed == false){
            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                afterInsertProcessed = true;
                unwindStatusChange((Map<Id,Case>)newcaseMap);
                System.debug('After Insert processes for Unwind Cases executed');
            }
        } else{
            System.debug('Recursion on After Insert on Unwind Cases blocked. Use CaseUnwindProcesses.afterInsertToggle() to step in.');
        }
    }

    public static void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(beforeUpdateProcessed == false){
            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                beforeUpdateProcessed = true;
                updatePickupFields((Map<Id,Case>)newCaseMap, (Map<Id,Case>)oldCaseMap);
                unwindRequestIsRejected((Map<Id,Case>)newCaseMap, (Map<Id,Case>)oldCaseMap);
                System.debug('Before Update processes for Unwind Cases executed.'); 
            }
        } else{
            System.debug('Recursion on Before Update on Unwind Cases blocked. Use CaseUnwindProcesses.beforeUpdateToggle() to step in.');
        }
    }

    public static void afterUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(afterUpdateProcessed == false){
            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                afterUpdateProcessed = true;
                unwindStatusChange((Map<Id,Case>)newcaseMap);
                System.debug('After Update processes for Unwind Cases executed');
            }
        } else{
            System.debug('Recursion on Before Update on Unwind Cases blocked. Use CaseUnwindProcesses.afterUpdateToggle() to step in.');
        }
    }

    /**
     * unwindStatusChange 
     *  GIVEN Case is an Unwind
     *  WHEN Case status is changed to 'Unwound'
     *  THEN Update Auction status to 'Ended Unwound'
     *
     * @param  newcaseMap 
     */
    public static void unwindStatusChange (Map<Id, Case> newcaseMap ){
        Set<Id> auctionIdSet = new Set<Id>();
        for(Case c :newcasemap.values()){
            if(c.status == 'Unwound'){
                auctionIdSet.add(c.Auction_Number__c);
            }
        }
        auctionidset.remove(null);

        if(auctionIDset == null){
            return;
        }

        Map<Id,Auction__c> auctionMap = new Map<Id,Auction__c>([Select id, status__c from auction__C where id in :auctionIdSet]);

        for(Id caseId :newcaseMap.keyset()){ 
            if(newcasemap.get(caseId).auction_number__c != null && auctionmap.get(newcasemap.get(caseId).auction_number__C) != null){
                auctionmap.get(newcasemap.get(caseId).auction_number__C).status__c = 'ended_unwound'; 
            }
        }

        if(auctionmap.values().size() >0){
            update auctionmap.values();  
        }
    }

    /**
     * updatePickupFields
     *   GIVEN A Case is an Unwind
     *   AND the Case Vehicle Location is set to 'Buyer' OR 'Seller' OR is changed
     *   AND Auction Number on the Case is set
     *   AND the Seller Dealership on the related Auction is not null
     *   AND the Buyer Dealership on the related Auction is not null
     *   THEN update the Pickup info on the case to match 
     *      the Buyer Dealership Billing Address for 'Buyer'
     *   WHEN Vehicle Location is set to 'Buyer'
     *      the Seller Dealership Billing Address for 'Seller'
     *   WHEN Vehicle Location is set to 'Seller'
     *      to null for any other value 
     *   
     * @param  newCaseMap
     */

    // Before Update
    public static void updatePickupFields(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Case> caseList = new List<Case>();
        Set<Id> auctionIdSet = new Set<Id>();
        Map<Id,Id> auc2acc = new Map<Id,Id>();

        for(Case c : newCaseMap.values()){
            if(c.Vehicle_Location__c != oldCaseMap.get(c.Id).Vehicle_Location__c && c.Auction_Number__c != null){
                caseList.add(c);
                auctionIdSet.add(c.Auction_Number__c);
            }
        }
        
        Map<Id,Auction__c> auctionMap = new Map<Id,Auction__c>([SELECT Id, Buyer_Dealership__c, Seller_Dealership__C FROM Auction__c WHERE Id IN :auctionIdSet]);

        for(Case c : caseList){
            if(c.Vehicle_Location__c == 'Buyer' && auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c != null && auctionMap.get(c.Auction_Number__c).Seller_Dealership__C != null){
                auc2acc.put(c.Auction_Number__c,auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c);
            } else if(c.Vehicle_Location__c == 'Seller' && auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c != null && auctionMap.get(c.Auction_Number__c).Seller_Dealership__C != null){
                auc2acc.put(c.Auction_Number__c,auctionMap.get(c.Auction_Number__c).Seller_Dealership__c);
            } 

        }

        Map<Id,Account> accMap = new Map<Id,Account>([SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Territory_Name__c FROM Account WHERE Id IN :auc2acc.values()]);

        for(Case c : caseList){
            if(auc2acc.get(c.Auction_Number__c) != null){
                c.Pickup_Address__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingStreet;
                c.Default_Pickup_City__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingCity;
                c.Default_Pickup_Postal_Code__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingPostalCode;
                c.Default_Pickup_State__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingState;
                c.Default_Pickup_Country__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingCountry;
                c.Vehicle_Location_Territory__c = accMap.get(auc2acc.get(c.Auction_Number__c)).Territory_Name__c;
            } else{
                c.Pickup_Address__c = null;
                c.Default_Pickup_City__c = null;
                c.Default_Pickup_Postal_Code__c = null;
                c.Default_Pickup_State__c = null;
                c.Default_Pickup_Country__c = null;
            }
        }
    }

    //Before Insert
    public static void updatePickupFields(List<Case> newCaseList){
        List<Case> caseList = new List<Case>();
        Set<Id> auctionIdSet = new Set<Id>();
        Map<Id,Id> auc2acc = new Map<Id,Id>();

        for(Case c : newCaseList){
            if((c.Vehicle_Location__c == 'Buyer' || c.Vehicle_Location__c == 'Seller') && (c.Auction_Number__c != null)){
                caseList.add(c);
                auctionIdSet.add(c.Auction_Number__c);
            }
        }
        
        Map<Id,Auction__c> auctionMap = new Map<Id,Auction__c>([SELECT Id, Buyer_Dealership__c, Seller_Dealership__C FROM Auction__c WHERE Id IN :auctionIdSet]);

        for(Case c : caseList){
            if(c.Vehicle_Location__c == 'Buyer' && auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c != null && auctionMap.get(c.Auction_Number__c).Seller_Dealership__C != null){
                auc2acc.put(c.Auction_Number__c,auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c);
            } else if(c.Vehicle_Location__c == 'Seller' && auctionMap.get(c.Auction_Number__c).Buyer_Dealership__c != null && auctionMap.get(c.Auction_Number__c).Seller_Dealership__C != null){
                auc2acc.put(c.Auction_Number__c,auctionMap.get(c.Auction_Number__c).Seller_Dealership__c);
            } 

        }

        Map<Id,Account> accMap = new Map<Id,Account>([SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Territory_Name__c FROM Account WHERE Id IN :auc2acc.values()]);

        for(Case c : caseList){
            if(auc2acc.get(c.Auction_Number__c) != null){
                c.Pickup_Address__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingStreet;
                c.Default_Pickup_City__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingCity;
                c.Default_Pickup_Postal_Code__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingPostalCode;
                c.Default_Pickup_State__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingState;
                c.Default_Pickup_Country__c = accMap.get(auc2acc.get(c.Auction_Number__c)).BillingCountry;
                c.Vehicle_Location_Territory__c = accMap.get(auc2acc.get(c.Auction_Number__c)).Territory_Name__c;
            } 
        }
    }

    public static void unwindRequestIsRejected(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        List<Case> caseList = new List<Case>();
        Set<Id> auctionIdSet = new Set<Id>();
        for(Case c : newCaseMap.values()){
            System.Debug('New Unwind Status: ' + c.Status);
            System.Debug('Old Unwind Status: ' + oldCaseMap.get(c.Id).Status);
            if(c.Status != oldCaseMap.get(c.Id).Status && c.Status == 'Closed (Not Approved)'){
                caseList.add(c);
                auctionIdSet.add(c.Auction_Number__c);
            }
        }
        auctionIdSet.remove(null);

        if(auctionIdSet.isEmpty()){
            return;
        }
        
        //Construct a Map that uses Auction Number as the key to get related Titles Case
        Id titleRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        List<Case> titlesList = [SELECT Auction_Number__c, Status FROM Case WHERE RecordTypeId = :titleRecordType AND Auction_Number__c IN :auctionIdSet];
        Map<Id,Case> titlesMap = new Map<Id,Case>();
        
        for(Case t : titlesList){
            titlesMap.put(t.Auction_Number__c,t);
        }

        for(Case c : caseList){
            if(titlesMap.get(c.Auction_Number__c) != null){
                titlesMap.get(c.Auction_Number__c).Status = c.Unwind_Title_Status__c;
            }
        }

        update titlesMap.values();

    }
    public static Map<Id,Case> filter(Map<Id,Case> newCaseMap){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        Map<Id,Case> filteredMap = new Map<Id,Case>();

        for(Case c : newCaseMap.values()){
            if(c.RecordTypeId == arbRecordType){
                filteredMap.put(c.Id,c);
            }
        }

        return filteredMap;
    }

    public static List<Case> filter(List<Case> newCaseList){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        List<Case> filteredList = new List<Case>();

        for(Case c : newCaseList){
            if(c.RecordTypeId == arbRecordType){
                filteredList.add(c);
            }
        }

        return filteredList;
    }
    public static void beforeInsertToggle(){
        beforeInsertProcessed = !beforeInsertProcessed;
    }
    public static void beforeInsertToggle(Boolean foo){
        beforeInsertProcessed = foo;
    }

    public static void afterInsertToggle(){
        afterInsertProcessed = !afterInsertProcessed;
    }
    public static void afterInsertToggle(Boolean foo){
        afterInsertProcessed = foo;
    }

    public static void beforeUpdateToggle(){
        beforeUpdateProcessed = !beforeUpdateProcessed;
    }
    public static void beforeUpdateToggle(Boolean foo){
        beforeUpdateProcessed = foo;
    }

    public static void afterUpdateToggle(){
        afterUpdateProcessed = !afterUpdateProcessed;
    }
    public static void afterUpdateToggle(Boolean foo){
        afterUpdateProcessed = foo;
    }
}