public class OptimizationRequestFailure extends TriggerInterface {

    List<FSL__Optimization_Request__c> failedOptimizationRequestList = new List<FSL__Optimization_Request__c>();

    public override void afterInsert( List<SObject> newList ) {
        for(FSL__Optimization_Request__c optimizationRequest: (List<FSL__Optimization_Request__c>) newList) {
            if(optimizationRequest.FSL__Status__c == 'Failed') {
                failedOptimizationRequestList.add(optimizationRequest);
            }
        }
        processFailures(failedOptimizationRequestList);
    }

    public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        for(FSL__Optimization_Request__c newOptimizationRequest: (List<FSL__Optimization_Request__c>) newMap.values()) {
            FSL__Optimization_Request__c oldOptimizationRequest = (FSL__Optimization_Request__c) oldMap.get(newOptimizationRequest.Id);
            if(oldOptimizationRequest.FSL__Status__c != newOptimizationRequest.FSL__Status__c && newOptimizationRequest.FSL__Status__c == 'Failed') {
                failedOptimizationRequestList.add(newOptimizationRequest);
            }
        }
        processFailures(failedOptimizationRequestList);
    }

    public static void processFailures(List<FSL__Optimization_Request__c> failedOptimizationRequestList){

        final String LINE_NUMBER = '21';
        List<Integration_Result__c> irLst = new List<Integration_Result__c>();
        String isFutureOrBatch = System.isFuture() ? 'Future' : 'Batch'; // Only gets used in the method for Future/Batch context
        for(FSL__Optimization_Request__c optimizationRequest : failedOptimizationRequestList){
            String message = 'Optimization Request Type: ' + optimizationRequest.FSL__Type__c + '\n' + 'Failure Reason: ' + optimizationRequest.FSL__Failure_Reason__c + '\n' + 'Details: ' + optimizationRequest.FSL__Failure_Details__c;
            if ( !System.isFuture() && !System.isBatch() ) {
                SplunkHelper.Log log = new SplunkHelper.log();
                log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.INSPECTOR_DISPATCH};
                log.sfObject = 'FSL__Optimization_Request__c';
                log.sfRecordId = optimizationRequest.Id;
                log.version = 'v1';
                log.componentName = 'OptimizationRequest';
                log.location = 'OptimizationRequest:' + LINE_NUMBER;
                log.message = message;
                log.stackTrace = 'OptimizationRequest:' + LINE_NUMBER;
                log.logLevel = SplunkHelper.LOGLEVEL.ERROR;
                log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);

                SplunkHelper.buildAndProcessLog(log);
            } else { // Sometimes this logic is hit via Managed Package Batch methods, so we can't use an API directly
                irLst.add( new Integration_Result__c(
                    RecordId__c = optimizationRequest.Id,
                    Integration_Name__c = 'Optimization Request Failure - ' + isFutureOrBatch,
                    SObject_name__c = 'Optimization Request',
                    Integration_Type__c = 'Internal',
                    response_message__c = message
                ) );
            }
        }
        if ( !irLst.isEmpty() ) { insert irLst; }
    }
}