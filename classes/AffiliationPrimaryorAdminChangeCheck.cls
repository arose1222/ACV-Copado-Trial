public with sharing class AffiliationPrimaryorAdminChangeCheck extends TriggerInterface {

    public static Boolean validationEnabled = true;
    

    public override void afterUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Id standardAccountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();


        Map<Id, Affiliation__c> newAffMap = (Map<Id, Affiliation__c>)newMap;
        Map<Id, Affiliation__c> oldAffMap = (Map<Id, Affiliation__c>)oldMap;

        Map<id,Affiliation__c> affMap = new Map<Id, Affiliation__c>([Select id, Account__c, Account__r.RecordTypeId From Affiliation__c Where id IN: newAffMap.keyset()]);

        for (Affiliation__c a : newAffMap.values()) {
            if(affMap.get(a.id).Account__r.RecordTypeId == standardAccountRecordId){
                String fieldFlag;
                if(a.Active__c == FALSE && oldAffMap.get(a.id).Active__c == TRUE){
                    fieldFlag = 'Both';
                }
                else if (a.Primary_Contact__c == FALSE && oldAffMap.get(a.id).Primary_Contact__c == TRUE) {
                    fieldFlag = 'Primary';
                }
                else if(a.Type__c != 'admin' && oldAffMap.get(a.id).Type__c == 'admin') {
                    if((a.Primary_Contact__c == FALSE && oldAffMap.get(a.id).Primary_Contact__c == TRUE)) {
                        fieldFlag = 'Both';
                    }
                    else{
                        fieldFlag = 'Admin';
                    }
                }
                if(validationEnabled && !OrganizationPrimaryandAdminCheck.OrganizationAffiliationPrimaryandAdminCheck(a.Account__c, a.id, fieldFlag)){
                    a.adderror('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation');
                }
            }
        }
    }
    public override void beforeDelete(Map<Id, sObject> oldMap){

        Id standardAccountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        Map<Id, Affiliation__c> oldAffMap = (Map<Id, Affiliation__c>)oldMap;

        Map<id,Affiliation__c> affMap = new Map<Id, Affiliation__c>([Select id, Account__c, Account__r.RecordTypeId From Affiliation__c Where id IN: oldAffMap.keyset()]);
        
        for (Affiliation__c a : oldAffMap.values()) {
            if (validationEnabled && affMap.get(a.id).Account__r.RecordTypeId == standardAccountRecordId && (a.Primary_Contact__c == True || a.Type__c == 'admin')) {
                Boolean AdminPrimExist = OrganizationPrimaryandAdminCheck.OrganizationAffiliationPrimaryandAdminCheck(a.Account__c, a.id, 'Both');
                if(AdminPrimExist == FALSE){
                    a.adderror('Please ensure the associated Account to this Affiliation has an Active Primary Contact and Admin set before updated this Affiliation');
                }
            }
        }
    }
}