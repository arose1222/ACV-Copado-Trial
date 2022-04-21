public class TitlesCaseProcesses {

    public static void runBeforeInsert(List<SobJect> incomingList){
        stampAddressInfoOnCase(incomingList);
    }

    public static void runBeforeUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        stampAddressInfoOnCase(incomingNewMap.values());
        //updateStatusOnAuction(incomingNewMap,incomingOldMap);
    }
    
    public static void stampAddressInfoOnCase(List<SobJect> incomingList){
        List<Case> caseList = (List<Case>)incomingList;
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        List<Id> dealershipIdList = new List<Id>();
        for(case c : caseList){
            if(c.AccountId != null && c.RecordTypeId == titlesRecordType){
                dealershipIdList.add(c.AccountId);
            }
        }

        Map<id,Account> dealerMap = new Map<Id, Account>([Select Id, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone from Account where id in :dealershipIdList]);

        for(case c :caseList){
            if(c.AccountId != null && dealerMap.get(c.AccountId) != null){
                if(c.Default_Delivery_Address__c == null){
                    c.Default_Delivery_Address__c = dealerMap.get(c.AccountId).BillingStreet;
                }
                if(c.Default_Delivery_City__c == null){
                    c.Default_Delivery_City__c = dealerMap.get(c.AccountId).BillingCity;
                }
                if(c.Default_Delivery_Country__c == null){
                    c.Default_Delivery_Country__c = dealerMap.get(c.AccountId).BillingCountry;
                }
                if(c.Default_Delivery_Postal_Code__c == null){
                    c.Default_Delivery_Postal_Code__c = dealerMap.get(c.AccountId).BillingPostalCode;
                }
                if(c.Default_Delivery_State__c == null){
                    c.Default_Delivery_State__c = dealerMap.get(c.AccountId).BillingState;
                }
            }
        }
    }

    /*public static void updateStatusOnAuction(Map<Id,Sobject> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        Map<Id,Case> newMap = (Map<Id,Case>)incomingNewMap;
        Map<Id,Case> oldMap = (Map<Id,Case>)incomingOldMap;
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();

        List<Auction__c> auctionUpdateList = new List<Auction__c>();
        for(Case c :newMap.values()){
            if(c.RecordTypeId == titlesRecordType && c.Auction_Number__c != null && c.status != oldMap.get(c.id).status){
                auctionUpdateList.add(new Auction__c(id = c.Auction_Number__c, Title_Status_1__c = String.valueOf(c.Status)));
            }
        }

        if(auctionUpdateList.size() > 0){
            update auctionUpdateList;
        }
    }*/
}