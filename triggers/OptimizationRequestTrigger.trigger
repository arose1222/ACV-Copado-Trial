trigger OptimizationRequestTrigger on FSL__Optimization_Request__c (after insert, after update) {
    (new TriggerFrameWork()).handle();
}