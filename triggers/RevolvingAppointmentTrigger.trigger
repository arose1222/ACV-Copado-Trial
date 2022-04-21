trigger RevolvingAppointmentTrigger on Timeline__c (before insert, before update) {
    (new TriggerFrameWork()).handle();
}