trigger TimelineTrigger on Timeline__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    //add all keywords
    (new TriggerFrameWork()).handle();
}