trigger ProgramEnrollmentTrigger on Program_Enrollment__c (before insert, before update, after update) {

            (new TriggerFrameWork()).handle();
}