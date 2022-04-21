trigger Condition_Report_Trigger on Condition_Report__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}