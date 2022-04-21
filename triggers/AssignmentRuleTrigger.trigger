trigger AssignmentRuleTrigger on maps__AssignmentRule__c ( before insert, before update, after insert, after update, before delete, after delete  ) {
    (new TriggerFrameWork()).handle();
}