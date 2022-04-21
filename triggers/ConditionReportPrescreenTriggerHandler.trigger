trigger ConditionReportPrescreenTriggerHandler on Condition_Report_Prescreen__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}