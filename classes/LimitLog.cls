public without sharing class LimitLog {
    /*
    Currently there is an issue with OrgLimits.getMap() on Salesforces end, There is a permission issue thrown when we try to run it in a test context.
    We will need to update the Test code once there is a fix for the bug. I(Bill) have subscribed to the issue.
    Current Test Coverage is low since we can not get actual records.
    */

    public static void logOrgLimits(){
        Map<String,System.OrgLimit> limitsMap = (!Test.isRunningTest()) ? OrgLimits.getMap() : new Map<String,System.OrgLimit>();
        List<SplunkHelper.logWrapper> wrapperList = new List<SplunkHelper.logWrapper>();
        for(String limitName : limitsMap.keySet()){
            wrapperList.add(generteLogWrapper(limitsMap.get(limitName), limitName));
        }

        if(wrapperList.size() > 0){
            SplunkHelper.processBulkLog(wrapperList);
        }
    }

    public static SplunkHelper.logWrapper generteLogWrapper(System.OrgLimit orgLim, String limitName){
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'LimitLog';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
        log.location = 'LimitLog.generateLogWrapper';
        log.logLevel = SplunkHelper.LOGLEVEL.PERFORMANCE;
        log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log.stackTrace = 'LimitLog.generateLogWrapper: '+ACVUtility.currentLineNumber();
        log.version = '1.0';

        SplunkEngine.LogData data = new SplunkEngine.LogData();
        data.name = limitName;
        data.currentValue = String.valueOf(orgLim.getValue());
        data.maximumValue = String.valueOf(orgLim.getLimit());
        String finalPercent = Integer.ValueOf(data.maximumValue) > 0 ? String.valueOf((Double.ValueOf(data.currentValue)/Double.ValueOf(data.maximumValue))*100) : '0';

        data.percentUsed = finalPercent;
        data.type = 'Org Limit';
        
        
        SplunkHelper.logWrapper lw = new SplunkHelper.logWrapper();
        lw.l = log;
        lw.logData = data;

        return lw;
    }
}