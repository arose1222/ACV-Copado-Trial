trigger ProgramTrigger on Program__c (after update, before update) {
    (new TriggerFrameWork()).handle();
}