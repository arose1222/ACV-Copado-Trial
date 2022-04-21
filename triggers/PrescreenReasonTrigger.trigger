trigger PrescreenReasonTrigger on Prescreen_Reason__c (after insert,after update,before insert,before update, after delete, after undelete, before delete) {
    (new TriggerFrameWork()).handle();  
}