global class VerifyAsyncJobsBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    
    private static final Integer LINE_NUMBER = ACVUtility.currentLineNumber();
    private static final String CLASS_NAME = 'VerifyAsyncJobsBatch';
    global Set<String> checkAsyncJobNameSet {
        get {
            if ( checkAsyncJobNameSet == null ) {
                checkAsyncJobNameSet = new Set<String>();
                for ( Async_Job_Verification__mdt recordData : [ SELECT Label FROM Async_Job_Verification__mdt WHERE Active__c = TRUE ] ) {
                    checkAsyncJobNameSet.add( recordData.Label );
                }
            }
            return checkAsyncJobNameSet;
        }
        set;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if ( !checkAsyncJobNameSet.isEmpty() ) {
            Date dateRange = Date.today().addDays( -1 );
            query =  'SELECT ApexClassId, ApexClass.Name, MethodName, NumberOfErrors, TotalJobItems, Status';
            query += ' FROM AsyncApexJob';
            query += ' WHERE ApexClassId != null';
            query += ' AND ApexClass.Name IN :checkAsyncJobNameSet';
            query += ' AND CompletedDate >= :dateRange';
        }
        // return
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        // scheduling
        Database.executeBatch(new VerifyAsyncJobsBatch(), 1);
    }

    global void execute(Database.BatchableContext bc, List<AsyncApexJob> scope){
        //batch process
        for ( AsyncApexJob job : scope ) {
            String jobName = job.ApexClass.Name;
            if ( checkAsyncJobNameSet.contains( jobName ) ) {
                LogData returnData;
                if ( job.Status == 'Completed' && ( job.NumberOfErrors == 0 || job.NumberOfErrors == null ) ) {
                    returnData = buildLog( jobName, FALSE, job );
                } else {
                    returnData = buildLog( jobName, TRUE, job );
                }
                checkAsyncJobNameSet.remove( jobName );
                SplunkHelper.processLog( returnData.log, returnData.errorReturnLst, returnData.successfulIdSet );
            }
        }
    }

    public static LogData buildLog( String jobName, Boolean isError, AsyncApexJob jobData ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet

        infoLog.logLevel = !isError ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR; 
        infoLog.location = CLASS_NAME + ':' + LINE_NUMBER;
        infoLog.message = !isError ? jobName + ' ran without issue to report' : jobName + ' had some issues processing, seeing the results for specifics';
        infoLog.stackTrace = CLASS_NAME + ':' + LINE_NUMBER; 
        infoLog.componentName = jobName;
        infoLog.sfObject = 'AsyncApexJob';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.INSPECTOR_DISPATCH };
        if ( jobData != null ) { infoLog.sfRecordId = jobData.Id; }

        List<SplunkHelper.SFErrorRecord> errorReturnLst = new List<SplunkHelper.SFErrorRecord>();
        Set<String> successfulIdSet = new Set<String>();
        if ( isError && jobData != null ) { errorReturnLst.add( new SplunkHelper.SFErrorRecord( jobData, 'The job ran with issues, please be aware' ) ); } 
        else if ( !isError && jobData != null ) { successfulIdSet.add( jobData.Id ); }

        return new LogData( infoLog, successfulIdSet, errorReturnLst );
    }

    global void finish(Database.BatchableContext bc) {
        // The callouts are always done in execute
        List<SplunkHelper.logWrapper> bulkLogLst = new List<SplunkHelper.logWrapper>();
        if ( !checkAsyncJobNameSet.isEmpty() ) {
            for ( String jobName : checkAsyncJobNameSet ) {
                LogData buildALog = buildLog( jobName, TRUE, new AsyncApexJob( Id = bc.getJobId() ) );

                SplunkHelper.logWrapper tempWrapper = new SplunkHelper.logWrapper();
                tempWrapper.l = buildALog.log;

                bulkLogLst.add( tempWrapper );
            }
            SplunkHelper.processNonFutureBulkLog( bulkLogLst );
        }
    }

    private class LogData {
        public SplunkHelper.Log log;
        public Set<String> successfulIdSet;
        public List<SplunkHelper.SFErrorRecord> errorReturnLst;

        public LogData( SplunkHelper.Log log, Set<String> successfulIdSet, List<SplunkHelper.SFErrorRecord> errorReturnLst ) {
            this.log = log;
            this.successfulIdSet = successfulIdSet;
            this.errorReturnLst = errorReturnLst;
        }
    }
}