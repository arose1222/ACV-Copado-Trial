public without sharing class DealerDocInfoAccountPopulation extends TriggerInterface {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    public override void afterInsert(Map<Id, sObject> newMap) {
        Map<Id, Dealer_Docs__c> newDocMap = (Map<Id, Dealer_Docs__c>)newMap;
        Map<Id, Account> acctMap = new Map<Id, Account>();

        for (Dealer_Docs__c d : newDocMap.values()) {
            if (d.Compliant__c == true) {
                acctMap = mapUpdate(acctMap, d, d.RecordTypeId);
            }
        }
        update acctMap.values();
    }

    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, Dealer_Docs__c> newDocMap = (Map<Id, Dealer_Docs__c>)newMap;
        Map<Id, Dealer_Docs__c> oldDocMap = (Map<Id, Dealer_Docs__c>)oldMap;
        Map<Id, Account> acctMap = new Map<Id, Account>();

        for (Dealer_Docs__c d : newDocMap.values()) {
            if (d.Compliant__c == true && oldDocMap.get(d.Id).Compliant__c == false) {
                acctMap = mapUpdate(acctMap, d, d.RecordTypeId);
            }
            else if (((d.License_Number__c != oldDocMap.get(d.Id).License_Number__c) && d.License_Number__c != null) || ((d.Permit_Resale_Number__c != oldDocMap.get(d.Id).Permit_Resale_Number__c) && d.Permit_Resale_Number__c != null)
                || d.S3_Link__c!=oldDocMap.get(d.Id).S3_Link__c) {
                acctMap = mapUpdate(acctMap, d, d.RecordTypeId);
            }
        }
        update acctMap.values();
    }

    public static Map<Id, Account> mapUpdate(Map<Id, Account> acctMap, Dealer_Docs__c d, Id recordTypeId) {
        if (recordTypeId == licenseId) {
            if (acctMap.get(d.Account__c) == null) {
                Account a = new Account(Id = d.Account__c, License_Number__c = d.License_Number__c, License_S3_Link__c= d.S3_Link__c);
                acctMap.put(d.Account__c, a);
            }
            else {
                acctMap.get(d.Account__c).License_Number__c = d.License_Number__c;
                acctMap.get(d.Account__c).License_S3_Link__c= d.S3_Link__c;
            }
        }
        else if (recordTypeId == resaleId) {
            if (acctMap.get(d.Account__c) == null) {
                Account a = new Account(Id = d.Account__c, Permit_Resale_Number__c = d.Permit_Resale_Number__c, Permit_Resale_S3_Link__c= d.S3_Link__c);
                acctMap.put(d.Account__c, a);
            }
            else {
                acctMap.get(d.Account__c).Permit_Resale_Number__c = d.Permit_Resale_Number__c;
                acctMap.get(d.Account__c).Permit_Resale_S3_Link__c= d.S3_Link__c;
            }
        }
        return acctMap;
    }
}