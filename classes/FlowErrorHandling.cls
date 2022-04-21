public class FlowErrorHandling {
    
    @InvocableMethod 
    public static void ErrorCreate(List<String> inputList){

        logToSplunk(inputList);

    }
    public static void logToSplunk(List<String> inputString){
        List<SplunkHelper.logWrapper> logWrapperList = new List<SplunkHelper.logWrapper>();
        System.debug(inputString);
        for(String logString : inputString){
            List<String> splitLogString = logString.split('%:%');
            SplunkHelper.logWrapper lw = new SplunkHelper.logWrapper();

            SplunkHelper.Log log = new SplunkHelper.log();
            log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.ENTERPRISE_APPS};
            log.sfObject = 'FlowGeneratedError';
            log.version = 'v1';
            log.componentName = splitLogString[0];
            log.location = 'FlowGeneratedError';
            log.message =  splitLogString[1];
            log.stackTrace = 'FlowGeneratedError';
            log.logLevel = SplunkHelper.LOGLEVEL.ERROR;
            log.setContext(SplunkHelper.CONTEXT_TYPE.FLOW);
            lw.l = log;
            logWrapperList.add(lw);
            }
        SplunkHelper.processBulkLog(logWrapperList);    
    }
}