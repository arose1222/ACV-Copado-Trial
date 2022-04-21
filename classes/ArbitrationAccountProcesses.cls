public class ArbitrationAccountProcesses {
    
    public static void runBeforeInsert(List<SobJect> incomingList){
        
    }

    public static void runAfterInsert(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        
    }

    public static void runBeforeUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        updateCaseBuyerAssuranceOnChange((Map<Id,Account>) incomingNewMap, (Map<Id,Account>) incomingOldMap);
    }

    public static void runAfterUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        
    }

    public static void updateCaseBuyerAssuranceOnChange(Map<Id,Account> newMap, Map<Id,Account> oldMap){

        Set<Id> accountIdSet = new Set<Id>();
        for(Account a :newMap.values()){
            if(a.Buyer_s_Assurance_Exceptions__c != oldMap.get(a.id).Buyer_s_Assurance_Exceptions__c){
                accountIdSet.add(a.id);
            }
        }

        if(accountIdSet.size() > 0){
            List<Case> updatedCases= new List<Case>();
            Id arbRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
            for (Case c : [SELECT id, accountId, Buyer_s_Assurance_Exceptions__c FROM case WHERE recordTypeId = :arbRecordTypeId AND accountId in :accountIdSet]) {
                if(newMap.get(c.accountId) != null && c.Buyer_s_Assurance_Exceptions__c != newMap.get(c.accountId).Buyer_s_Assurance_Exceptions__c){
                    c.Buyer_s_Assurance_Exceptions__c = newMap.get(c.accountId).Buyer_s_Assurance_Exceptions__c;
                    updatedCases.add(c);
                }
            }
            if(updatedCases.size() > 0){
                update updatedCases;
            }
        }
    }
}