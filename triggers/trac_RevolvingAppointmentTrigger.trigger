trigger trac_RevolvingAppointmentTrigger on Timeline__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    (new TriggerFrameWork()).handle();
}