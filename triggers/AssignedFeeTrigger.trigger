trigger AssignedFeeTrigger on Assigned_Fee__c (after insert,after update,before insert,before update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}