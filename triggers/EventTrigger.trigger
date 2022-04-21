trigger EventTrigger on Event (before insert, before update, before delete, after insert,after update, after delete) {
    (new TriggerFrameWork()).handle();
}