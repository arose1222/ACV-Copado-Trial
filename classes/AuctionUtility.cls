public class AuctionUtility {

    public static void afterUpdateLogic(Map<Id,Auction__c> auctionMap,Map<Id,Auction__c> auctionMapOld){

        //Tried running this as a before update, got issues from the Case Utility needing Auctions to have the updated information so items were reverted back
        Map<Id,Case> caseUpdateMap = new Map<Id,Case>();
        caseUpdateMap = updateCasesOnVinChange(auctionMap,auctionMapOld, caseUpdateMap);
        caseUpdateMap = updateCasesOnBuyerChange(auctionMap,auctionMapOld,caseUpdateMap);
        caseUpdateMap = updateCasesOnSellerChange(auctionMap,auctionMapOld,caseUpdateMap);
        caseUpdateMap = updateCasesWithNewFieldData(auctionMap,auctionMapOld,caseUpdateMap);
        caseUpdateMap = updateCasesForTitlesEndpoint(auctionMap,auctionMapOld,caseUpdateMap);

        if(caseUpdateMap.values().size() > 0){
            CaseTransportationProcesses.beforeUpdateToggle(false);
            update caseUpdateMap.values();
        }
    } 

    public static Map<id,Case> updateCasesOnSellerChange(Map<Id,Auction__c> auctionMap,Map<Id,Auction__c> auctionMapOld, Map<Id,Case> caseMap){
        Map<Id, Auction__c> auctionsWithNewSeller = new Map<Id, Auction__c>();
        Id unwindRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        for(Auction__c a :auctionMap.values()){
            if(auctionMapOld.get(a.id).Seller_Dealership__c != a.Seller_Dealership__c || auctionMapOld.get(a.id).Seller__c != a.Seller__c){
                auctionsWithNewSeller.put(a.id,a);
            }
        }
        if(auctionsWithNewSeller.size() > 0){
            for (Case c : [SELECT id, auction_number__c, vehicle__c,Release_Datetime__c, Release_Available__c, accountId,contactId,Seller_Dealership__c,Seller_Contact__c FROM case WHERE recordTypeId != :unwindRTID AND auction_number__c in :auctionsWithNewSeller.keySet()]) {
                if(caseMap.get(c.id) != null){
                    caseMap.get(c.id).Seller_Dealership__c = auctionsWithNewSeller.get(c.auction_number__c).Seller_Dealership__c;
                    caseMap.get(c.id).Seller_Contact__c = auctionsWithNewSeller.get(c.auction_number__c).seller__c;
                }
                else{
                    c.Seller_Dealership__c = auctionsWithNewSeller.get(c.auction_number__c).Seller_Dealership__c;
                    c.Seller_Contact__c = auctionsWithNewSeller.get(c.auction_number__c).seller__c;
                    caseMap.put(c.id, c);
                }
            }
        }
        return caseMap;
    }

    public static Map<id,Case> updateCasesOnBuyerChange(Map<Id,Auction__c> auctionMap,Map<Id,Auction__c> auctionMapOld, Map<Id,Case> caseMap){
        Map<Id, Auction__c> auctionsWithNewBuyer = new Map<Id, Auction__c>();
        Id unwindRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        for(Auction__c a :auctionMap.values()){
            if(auctionMapOld.get(a.id).buyer_dealership__c != a.buyer_dealership__c || auctionMapOld.get(a.id).Buyer_Contact__c != a.Buyer_Contact__c){
                auctionsWithNewBuyer.put(a.id,a);
            }
        }
        if(auctionMapOld.size() > 0){
            for (Case c : [SELECT id, auction_number__c, vehicle__c,Release_Datetime__c, Release_Available__c, accountId,contactId,Seller_Dealership__c,Seller_Contact__c FROM case WHERE recordTypeId != :unwindRTID AND auction_number__c in :auctionsWithNewBuyer.keySet()]) {
                if(caseMap.get(c.id) != null){
                    caseMap.get(c.id).accountId = auctionsWithNewBuyer.get(c.auction_number__c).buyer_dealership__c;
                    caseMap.get(c.id).contactId = auctionsWithNewBuyer.get(c.auction_number__c).Buyer_Contact__c;
                }
                else{
                    c.accountId = auctionsWithNewBuyer.get(c.auction_number__c).buyer_dealership__c;
                    c.contactId = auctionsWithNewBuyer.get(c.auction_number__c).Buyer_Contact__c;
                    caseMap.put(c.id, c);
                }
            }
        }
        return caseMap;
    }
    
    public static Map<id,Case> updateCasesOnVinChange(Map<Id,Auction__c> auctionMap,Map<Id,Auction__c> auctionMapOld, Map<Id,Case> caseMap){
        Map<Id, Auction__c> auctionsWithNewVIN = new Map<Id, Auction__c>();
        Id unwindRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        for(Auction__c a :auctionMap.values()){
            if(auctionMapOld.get(a.id).vehicle_id__c != a.vehicle_id__c){
                auctionsWithNewVIN.put(a.id,a);
            }
        }
        if(auctionsWithNewVIN.size() > 0){
            for (Case c : [SELECT id, auction_number__c, vehicle__c,Release_Datetime__c, Release_Available__c, accountId,contactId,Seller_Dealership__c,Seller_Contact__c FROM case WHERE recordTypeId != :unwindRTID AND auction_number__c in :auctionsWithNewVIN.keySet()]) {
                if(caseMap.get(c.id) != null){
                    caseMap.get(c.id).vehicle__c = auctionsWithNewVIN.get(c.auction_number__c).vehicle_id__c;
                }
                else{
                    c.vehicle__c = auctionsWithNewVIN.get(c.auction_number__c).vehicle_id__c;
                    caseMap.put(c.id, c);
                }
            }
        }
        return caseMap;
    }

    public static map<Id,Case> updateCasesWithNewFieldData(Map<Id,Auction__c> auctionMap, Map<Id,Auction__c> auctionMapOld, Map<Id,Case> caseMap){
        Map<Id,Auction__c> auctionsWithNewData = new Map<Id, Auction__c>();
        Id ArbRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Id TransportRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Id unwindRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        for(Auction__c a :auctionMap.values()){
            if(auctionMapOld.get(a.id).Release_Available__c != a.Release_Available__c || auctionMapOld.get(a.id).Release_DateTime__c != a.Release_DateTime__c || auctionMapOld.get(a.id).ACV_inop__c != a.ACV_inop__c){
                auctionsWithNewData.put(a.id,a);
            }
        }
        if(auctionsWithNewData.size() > 0){
            for (Case c : [SELECT id, auction_number__c, Release_Datetime__c, Release_Available__c, vehicle__c, accountId,contactId,Seller_Dealership__c,Seller_Contact__c, inop__c FROM case WHERE (recordTypeId = :TransportRTID OR recordTypeId = :ArbRTID) AND recordTypeId != :unwindRTID AND auction_number__c in :auctionsWithNewData.keySet() AND isClosed = FALSE]) {
                if(caseMap.get(c.id) != null){
                    caseMap.get(c.id).vehicle__c = auctionsWithNewData.get(c.auction_number__c).vehicle_id__c;
                }
                else{
                    c.Release_Datetime__c = auctionsWithNewData.get(c.auction_number__c).Release_DateTime__c;
                    c.Release_Available__c = auctionsWithNewData.get(c.auction_number__c).Release_Available__c;
                    c.inop__c = auctionsWithNewData.get(c.auction_number__c).ACV_inop__c;
                    caseMap.put(c.id, c);
                }
            }
        }
        return caseMap;
    }

    public static Map<Id,Case> updateCasesForTitlesEndpoint(Map<Id,Auction__c> auctionMap, Map<Id,Auction__c> auctionMapOld, Map<Id,Case> caseMap){
        Set<Id> auctionIdSet = new Set<Id>();
        Id titlesRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        for(Auction__c a : auctionMap.values()){
            if(auctionMapOld.get(a.Id).seller_payment_method__c != a.seller_payment_method__c || auctionMapOld.get(a.Id).seller_payment_tracking_number__c != a.seller_payment_tracking_number__c || auctionMapOld.get(a.Id).seller_payment_date__c != a.seller_payment_date__c){
                auctionIdSet.add(a.Id);
            }
        }
        auctionIdSet.remove(null);

        if(!auctionIdSet.isEmpty()){
            Set<Id> recordTypeSet = new Set<Id>();
            recordTypeSet.add( Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId() );recordTypeSet.add( Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dealer_Compliance').getRecordTypeId() );

            for (Case c : [SELECT Id, Seller_Payment_Tracking_Number__c, Seller_Payment_Method__c, Auction_Number__c FROM Case WHERE Auction_Number__c IN :auctionIdSet AND RecordTypeId NOT IN :recordTypeSet ]){
                if(caseMap.get(c.Id) == null){
                    c.Seller_Payment_Method__c = auctionMap.get(c.Auction_Number__c).Seller_Payment_Method__c;
                    c.Seller_Payment_Tracking_Number__c = auctionMap.get(c.Auction_Number__c).Seller_Payment_Tracking_Number__c;
                    caseMap.put(c.Id, c);
                } else {
                    caseMap.get(c.Id).Seller_Payment_Method__c = auctionMap.get(c.Auction_Number__c).Seller_Payment_Method__c;
                    caseMap.get(c.Id).Seller_Payment_Tracking_Number__c = auctionMap.get(c.Auction_Number__c).Seller_Payment_Tracking_Number__c;
                }
            }
        }
        return caseMap;
    }
}