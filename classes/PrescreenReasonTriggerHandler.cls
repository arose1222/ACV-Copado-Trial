public with sharing class PrescreenReasonTriggerHandler extends TriggerInterface{

    public override void afterInsert(Map<Id, SObject> newMap) {
        PrescreenReasonProcesses.assignPrescreenToQueue((Map<Id, Prescreen_Reason__c>) newMap);
    }

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        PrescreenReasonProcesses.assignPrescreenToQueue((Map<Id, Prescreen_Reason__c>) newMap);
	}
    
    public override void afterDelete(Map<Id, SObject> oldMap) {
        PrescreenReasonProcesses.assignPrescreenToQueue((Map<Id, Prescreen_Reason__c>) oldMap);
	}

}