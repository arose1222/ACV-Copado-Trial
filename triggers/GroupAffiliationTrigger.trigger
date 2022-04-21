trigger GroupAffiliationTrigger on Group_Affiliation__c (after insert, after update, before insert, before update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}