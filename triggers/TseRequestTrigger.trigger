trigger TseRequestTrigger on TSE_Request__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}