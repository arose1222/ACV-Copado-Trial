public with sharing class RevAppOwnerHandlerBlankUpdate extends TriggerInterface {

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        Map<Id, Timeline__c> newRevAppMap = (Map<Id, Timeline__c>) newMap;
        Map<Id, Timeline__c> oldRevAppMap = (Map<Id, Timeline__c>) oldMap;
        
        List<Timeline__c> revAppOwnerUpdateList = RevolvingAppointmentOwnerHandler.makeResourceOwner(newRevAppMap.values());
    }
}