public class SplunkHelper {
    
    public enum CONTEXT_TYPE { BATCH, INTEGRATION, LWC, APEX_TRIGGER, APEX_CODE, FLOW }
    public enum LOGLEVEL { PERFORMANCE, DEBUG, INFO, WARN, ERROR, FATAL }
    public enum DOMAIN { ENTERPRISE_APPS, SALES, POST_TRANSACTION, CONDITION_REPORT, SUPPLY, DEMAND, MARKETPLACE, CAPITAL, MYACV, EMPLOYEE_BUSINESS_SYSTEMS, CUSTOMER_CHURN_PREVENTION, SECURITY, INSPECTION_PLATFORM, OFF_LEASE_PLATFORM, SCHEDULING_PLATFORM, INSPECTOR_DISPATCH, PRIVATE_AUCTIONS }
    public enum INTEGRATION_DIRECTION { INBOUND, OUTBOUND }

    public class Log {
        public String version;
        public LOGLEVEL logLevel;
        public String location;
        public String message;
        public String stackTrace;
        public String sfRecordId;
        public String componentName;
        public String sfObject;
        public Set<DOMAIN> domainSet; // Set of Domains

        private String contextType; // Don't set

        // Only use to overwrite standard enum. Do not use for Batch/Integration/LWC
        public void setContext( SplunkHelper.CONTEXT_TYPE contextEnum ) {
            this.contextType = contextEnum.name();
        }

        // Need for Engine Class
        public String getContext() {
            return this.contextType;
        }
    }

    public class logWrapper{
        public Log l;
        public SplunkEngine.SFDetails sfDetails;
        public SplunkEngine.LogData logData;
    }

    ////////// STANDARD LOG METHODS //////////

    // Future method for standard log
    public static void buildAndProcessLog( Log info ) {
        if(System.isBatch() || System.isFuture()){
            SplunkJobQueueable splunkJob = new SplunkJobQueueable();
            splunkJob.setLog(JSON.serialize( info ));
            System.enqueueJob(splunkJob);
        }
        else{
            SplunkEngine.processFutureLog( JSON.serialize( info ) );
        }
    }

    // Non-Future method for standard log
    public static void processLog( Log info ) {
        info.contextType = String.isBlank( info.contextType ) ? CONTEXT_TYPE.APEX_CODE.name() : info.contextType;
        SplunkEngine.StandardLog logRec = SplunkEngine.createLogStruct( info );
        SplunkEngine.postLog(  new List<SplunkEngine.StandardLog> {logRec} );
    }

    public static void processBulkLog( List<logWrapper> infoList ) {
        List<SplunkEngine.StandardLog> convertedLogList = new List<SplunkEngine.StandardLog>();
        for(logWrapper info :infoList){
            info.l.contextType = String.isBlank( info.l.contextType ) ? CONTEXT_TYPE.APEX_CODE.name() : info.l.contextType;
            convertedLogList.add(SplunkEngine.createLogStruct( info.l, info.logData, info.sfDetails ));
        }
        if(System.isBatch() || System.isFuture()){
            SplunkJobQueueable splunkJob = new SplunkJobQueueable();
            splunkJob.setBulkLog(JSON.serialize(convertedLogList ));
            System.enqueueJob(splunkJob);
        }
        else{
            SplunkEngine.processFutureBulkLog( JSON.serialize(convertedLogList ));
        }
    }
    
    public static void processNonFutureBulkLog( List<logWrapper> infoList ) {
        List<SplunkEngine.StandardLog> convertedLogList = new List<SplunkEngine.StandardLog>();
        for(logWrapper info :infoList){
            info.l.contextType = String.isBlank( info.l.contextType ) ? CONTEXT_TYPE.APEX_CODE.name() : info.l.contextType;
            convertedLogList.add(SplunkEngine.createLogStruct( info.l, info.logData, info.sfDetails ));
        }
        SplunkEngine.processBulkLog( JSON.serialize(convertedLogList ));
    }

    // Future method for logs with bulk results
    public static void buildAndProcessLog( Log info, List<SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet ) {
        if(System.isBatch() || System.isFuture()){  
            SplunkJobQueueable splunkJob = new SplunkJobQueueable();
            splunkJob.setLogWithBulkRecords(JSON.serialize( info ), JSON.serialize( failedSfIdLst ), JSON.serialize( savedSFIdSet ));
            System.enqueueJob(splunkJob);
        }
        else{
            SplunkEngine.processFutureLogwithBulkRecords( JSON.serialize( info ), JSON.serialize( failedSfIdLst ), JSON.serialize( savedSFIdSet ) );
        }
    }

    // Non-Future method for logs with bulk results
    public static void processLog( Log info, List<SFErrorRecord> failedSfIdLst, Set<String> savedSFIdLst ) {
        info.contextType = String.isBlank( info.contextType ) ? CONTEXT_TYPE.APEX_CODE.name() : info.contextType;
        SplunkEngine.StandardLog logRec = SplunkEngine.createLogStruct( info );
        logRec.details.sfDetails = new SplunkEngine.sfDetails();
        logRec.details.sfDetails.sfFailedRecords = failedSfIdLst;
        logRec.details.sfDetails.sfSuccessfulRecords = savedSFIdLst;

        SplunkEngine.postLog( new List<SplunkEngine.StandardLog> {logRec} );
    }

    ////////// INTEGRATION LOG METHODS //////////

    // Future method for standard logs
    public static void buildAndProcessIntegrationLog( Log info, HTTPRequest req, HTTPResponse res, INTEGRATION_DIRECTION direction ) {
        if(System.isBatch() || System.isFuture()){
            //queueable version
            SplunkJobQueueable splunkJob = new SplunkJobQueueable();
            splunkJob.setIntegrationLog(JSON.serialize( SplunkEngine.buildIntegrationLog( info, req, res, direction ) ));
            System.enqueueJob(splunkJob);
        }
        else{
            SplunkEngine.processFutureIntegrationLog( JSON.serialize( SplunkEngine.buildIntegrationLog( info, req, res, direction ) ) );
        }
    }

    // Non-Future method for standard logs
    public static void processIntegrationLog( Log info, HTTPRequest req, HTTPResponse res, INTEGRATION_DIRECTION direction ) {
        SplunkEngine.postLog( new List<SplunkEngine.StandardLog> {SplunkEngine.buildIntegrationLog( info, req, res, direction )} );
    }

    // Future method for logs with bulk results
    public static void buildAndProcessIntegrationLog( Log info, HTTPRequest req, HTTPResponse res, INTEGRATION_DIRECTION direction, List<SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet ) {
        if(System.isBatch() || System.isFuture()){
            SplunkJobQueueable splunkJob = new SplunkJobQueueable();
            splunkJob.setIntegrationLog(JSON.serialize( SplunkEngine.buildIntegrationLog( info, req, res, direction, failedSfIdLst, savedSFIdSet ) ));
            System.enqueueJob(splunkJob);
        }
        else{
            SplunkEngine.processFutureIntegrationLog( JSON.serialize( SplunkEngine.buildIntegrationLog( info, req, res, direction, failedSfIdLst, savedSFIdSet ) ) );
        }
    }

    // Non-Future method for logs with bulk results
    public static void processIntegrationLog( Log info, HTTPRequest req, HTTPResponse res, INTEGRATION_DIRECTION direction, List<SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet ) {
        SplunkEngine.postLog( new List<SplunkEngine.StandardLog> {SplunkEngine.buildIntegrationLog( info, req, res, direction, failedSfIdLst, savedSFIdSet )} );
    }

    ////////// BATCH LOG METHODS //////////

    public static void processBatchLog( Log info, List<SFErrorRecord> failedSfIdLst, Set<String> savedSFIdLst ) {
        SplunkEngine.StandardLog batchRec = SplunkEngine.createLogStruct( info );

        batchRec.details.sfDetails = new SplunkEngine.sfDetails();
        batchRec.details.contextType = CONTEXT_TYPE.BATCH.name();
        batchRec.details.sfDetails.sfFailedRecords = failedSfIdLst;
        batchRec.details.sfDetails.sfSuccessfulRecords = savedSFIdLst;

        SplunkEngine.postLog( new List<SplunkEngine.StandardLog> {batchRec} );
    }

    ////////// VISUAL COMPONENTS LOG METHODS //////////

    // Non-Future method for standard logs
    public static void processVisualComponentLog( Log info, String userInput, String jsEvent ) {
        SplunkEngine.postLog( new List<SplunkEngine.StandardLog> {SplunkEngine.buildVisualComponentLog( info, userInput, jsEvent )} );
    }

    // Non-Future method for logs with bulk results
    public static void processVisualComponentLog( Log info, String userInput, String jsEvent, List<SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet ) {
        SplunkEngine.postLog( new List<SplunkEngine.StandardLog> {SplunkEngine.buildVisualComponentLog( info, userInput, jsEvent, failedSfIdLst, savedSFIdSet )} );
    }

    public class SFErrorRecord {
        public String jsonStruct;
        public String errorMessage;

        public SFErrorRecord(){}

        public SFErrorRecord( Object rec, String errorMessage ) {
            this.jsonStruct = JSON.serialize( rec );
            this.errorMessage = errorMessage;
        }

        public SFErrorRecord( String jsonString, String errorMessage ) {
            this.jsonStruct = jsonString;
            this.errorMessage = errorMessage;
        }
    }
    ////////// LWC LOG METHODS //////////

    @AuraEnabled
    public static void processJSON(String logInfoJSON){
        processLog((SplunkHelper.Log)JSON.deserialize(logInfoJSON, SplunkHelper.Log.class));
    }
}