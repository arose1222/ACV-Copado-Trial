trigger TriggerEventHandler on Trigger_Event__e ( after insert ) {
    (new TriggerFrameWork()).handle();
}