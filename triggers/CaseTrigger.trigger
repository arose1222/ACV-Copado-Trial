trigger CaseTrigger on Case (after insert,after update,before insert,before update, before delete, after delete, after undelete) {
    New CaseTriggerHandler().run();
    (new TriggerFrameWork()).handle();
}