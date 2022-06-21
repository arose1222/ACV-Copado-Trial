trigger ContentVersionTrigger on ContentVersion (after insert) {
   (new TriggerFrameWork()).handle();
}