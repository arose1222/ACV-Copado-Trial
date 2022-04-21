trigger CreditCheckTrigger on Credits_Checks__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}