public with sharing class DealerDocUpdateEmailFieldsOnExpiration extends TriggerInterface {
    public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, Dealer_Docs__c> oldDocMap = (Map<Id, Dealer_Docs__c>)oldMap;
        Map<Id, Dealer_Docs__c> newDocMap = (Map<Id, Dealer_Docs__c>)newMap;
        Map<Id, Dealer_Docs__c> docsToUpdate = new Map<Id, Dealer_Docs__c>();
        Set<Id> ISTTMPCids = new Set<Id>();
        Set<Id> ISTTMids = new Set<Id>();

        for (Dealer_Docs__c d : newDocMap.values()) {
            if (oldDocMap.get(d.Id).Review_Status__c != 'Requires BDR' && d.Review_Status__c == 'Requires BDR') {
                ISTTMids.add(d.Account__c);
                docsToUpdate.put(d.Account__c, d);
            }
            else if (oldDocMap.get(d.Id).Reminder_Email_Sent__c != d.Reminder_Email_Sent__c || oldDocMap.get(d.Id).Thirty_Day_Reminder_Email_Sent__c != d.Thirty_Day_Reminder_Email_Sent__c || oldDocMap.get(d.Id).Forty_Five_Day_Reminder_Email_Sent__c != d.Forty_Five_Day_Reminder_Email_Sent__c) {
                ISTTMPCids.add(d.Account__c);
                docsToUpdate.put(d.Account__c, d);
            } //these fields are usually only changed from false to true and not the other way around (workflow will only fire if they are set to true)
        }

        if (!ISTTMids.isEmpty()) {
            getISTandTM(ISTTMids, docsToUpdate);
        }

        if (!ISTTMPCids.isEmpty()) {
            getISTandTMandPrimaryContact(ISTTMPCids, docsToUpdate);
        }
    }

    public static void getISTandTM(Set<Id> accIds, Map<Id, Dealer_Docs__c> docsToUpdate) {
        List<Account> accList = [SELECT Id, IST_Account_Owner__r.Email, Owner.Email FROM Account WHERE Id IN :accIds];
        for (Account a : accList) {
            if (docsToUpdate.get(a.Id) != null) {
                docsToUpdate.get(a.Id).IST_Account_Manager_Email__c = a.IST_Account_Owner__r.Email;
                docsToUpdate.get(a.Id).TM_Email__c = a.Owner.Email;
            }
        }
    }

    public static void getISTandTMandPrimaryContact(Set<Id> accIds, Map<Id, Dealer_Docs__c> docsToUpdate) {
        List<Account> accList = [SELECT Id, IST_Account_Owner__r.Email, Owner.Email, Primary_Contact__r.Email FROM Account WHERE Id IN :accIds];
        for (Account a : accList) {
            if (docsToUpdate.get(a.Id) != null) {
                docsToUpdate.get(a.Id).IST_Account_Manager_Email__c = a.IST_Account_Owner__r.Email;
                docsToUpdate.get(a.Id).TM_Email__c = a.Owner.Email;
                docsToUpdate.get(a.Id).Primary_Contact_Email__c = a.Primary_Contact__r.Email;
            }
        }
    }
}