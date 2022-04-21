trigger LeadTriggerHandler on Lead (before insert, after insert, before update, after update) {
    (new TriggerFrameWork()).handle();
}