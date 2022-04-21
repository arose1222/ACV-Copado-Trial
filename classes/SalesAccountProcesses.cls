public class SalesAccountProcesses {
    public static void runBeforeInsert(List<SobJect> incomingList){
        
    }

    public static void runAfterInsert(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        
    }

    public static void runBeforeUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        updateCaseISTAccountOwnersOnChange((Map<Id,Account>) incomingNewMap, (Map<Id,Account>) incomingOldMap);
    }

    public static void runAfterUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        
    }

    public static void updateCaseISTAccountOwnersOnChange(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        Set<Id> accountIdSet = new Set<Id>();

        for(Account a :newMap.values()){
            if(a.IST_Account_Owner__c != oldMap.get(a.id).IST_Account_Owner__c){
                accountIdSet.add(a.id);
            }
        }

        if(accountIdSet.size() > 0){ 
            User doNotCall = [SELECT Id FROM User WHERE FirstName = 'Do' AND LastName = 'Not Call'];
            List<Case> updatedCases= new List<Case>();
            Map<Id,Customer_Inquiry__c> updatedCIs = new Map<Id,Customer_Inquiry__c>();
            for (Case c : [SELECT Id, AccountId, IST_Account_Owner_Lookup__c, RecordType.DeveloperName, (SELECT Id, OwnerId, Assigned_To__c, CreatedById FROM Related_Cases__r WHERE Account__c IN :accountIdSet AND Status__c != 'Closed') FROM Case WHERE AccountId IN :accountIdSet AND isClosed = false]) {
                if(newMap.get(c.accountId) != null){
                    c.IST_Account_Owner_Lookup__c = newMap.get(c.accountId).IST_Account_Owner__c;
                    if(c.RecordType.DeveloperName == 'Support' && newMap.get(c.AccountId).IST_Account_Owner__c != null && newMap.get(c.AccountId).IST_Account_Owner__c != doNotCall.Id) {
                        c.OwnerId = newMap.get(c.AccountId).IST_Account_Owner__c;
                    }
                    updatedCases.add(c);
                }
                for(Customer_Inquiry__c ci : c.Related_Cases__r) {
                    if(newMap.get(c.AccountId).IST_Account_Owner__c != null && newMap.get(c.AccountId).IST_Account_Owner__c != doNotCall.Id) {
                        ci.OwnerId = newMap.get(c.AccountId).IST_Account_Owner__c;
                        if(ci.Assigned_To__c == ci.CreatedById){
                            ci.Assigned_To__c = newMap.get(c.AccountId).IST_Account_Owner__c;
                        }
                        updatedCIs.put(ci.Id,ci);
                    }
                }
            }

            for (Customer_Inquiry__c ci : [SELECT Id, Ops_Case__r.AccountId, Assigned_To__c FROM Customer_Inquiry__c WHERE Ops_Case__r.AccountId IN :accountIdSet AND Call_Type__c = 'Seller Title Status' AND Status__c != 'Closed' AND ID NOT IN :updatedCIs.keySet()]) {
                if(ci.Assigned_To__c == oldMap.get(ci.Ops_Case__r.AccountId).IST_Account_Owner__c && newMap.get(ci.Ops_Case__r.AccountId).IST_Account_Owner__c != null && newMap.get(ci.Ops_Case__r.AccountId).IST_Account_Owner__c != doNotCall.Id) {
                    ci.Assigned_To__c = newMap.get(ci.Ops_Case__r.AccountId).IST_Account_Owner__c;
                    updatedCIs.put(ci.Id,ci);
                }
            }

            if(updatedCases.size() > 0){
                update updatedCases;
            }
            if(updatedCIs.size() > 0){
                update updatedCIs.values();
            }
        }
    }
}