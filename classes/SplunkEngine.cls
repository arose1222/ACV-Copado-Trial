public class SplunkEngine{
    
    private static final String SF = 'Salesforce';

    ////////// STANDARD LOG METHODS //////////

    @Future(callout=true)
    public static void processFutureLog( String jsonPayload ) {
        processLog(jsonPayload);
    }

    public static void processLog(String jsonPayload){
        SplunkHelper.processLog( 
            (SplunkHelper.Log) JSON.deserialize( jsonPayload, SplunkHelper.Log.class ) 
        );
    }



    @Future(callout=true)
    public static void processFutureLogwithBulkRecords( String jsonPayload, String failedLstPayload, String savedSetPayload ) {
        processLogWithBulkRecords(jsonPayload, failedLstPayload, savedSetPayload);
    }

    public static void processLogWithBulkRecords(string jsonPayload, string failedLstPayload, String savedSetPayload){
        SplunkHelper.processLog( 
            (SplunkHelper.Log) JSON.deserialize( jsonPayload, SplunkHelper.Log.class ), 
            (List<SplunkHelper.SFErrorRecord>) JSON.deserialize( failedLstPayLoad, List<SplunkHelper.SFErrorRecord>.class ), 
            (Set<String>) JSON.deserialize( savedSetPayload, Set<String>.class ) 
        );
    }

    @Future(callout=true)
    public static void processFutureBulkLog(String jsonPayload){
        processBulkLog(jsonPayload);
    }

    public static void processBulkLog(String jsonPayload){
        postLog( (List<StandardLog>) JSON.deserialize(jsonPayload, List<StandardLog>.class) );
    }

    ////////// INTEGRATION LOG METHODS //////////

    public static StandardLog buildIntegrationLog( SplunkHelper.Log info, HTTPRequest req, HTTPResponse res, SplunkHelper.INTEGRATION_DIRECTION direction ) {
        return buildIntegrationLog( info, req, res, direction, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
    }

    public static StandardLog buildIntegrationLog( SplunkHelper.Log info, HTTPRequest req, HTTPResponse res, SplunkHelper.INTEGRATION_DIRECTION direction, List<SplunkHelper.SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet ) {
        StandardLog intRec = createLogStruct( info );
        
        intRec.details.contextType = SplunkHelper.CONTEXT_TYPE.INTEGRATION.name();
        intRec.responseCode = res.getStatusCode();
        intRec.requestVerb = req.getMethod();
        intRec.requestUrl = req.getEndpoint();

        intRec.details.sfDetails = new sfDetails();
        intRec.details.sfDetails.requestBody = req.getBody();
        intRec.details.sfDetails.responseBody = res.getBody();
        intRec.details.sfDetails.statusMessage = res.getStatus();
        intRec.details.sfDetails.integrationType = direction.name();

        intRec.details.sfDetails.sfFailedRecords = failedSfIdLst;
        intRec.details.sfDetails.sfSuccessfulRecords = savedSFIdSet;

        return intRec;
    }

    @Future(callout=true)
    public static void processFutureIntegrationLog( String jsonPayload ) {
        processIntegrationLog(jsonPayload);
    }

    public static void processIntegrationLog(String jsonPayload){
        StandardLog info = (StandardLog) JSON.deserialize( jsonPayload, StandardLog.class );
        postLog( new List<StandardLog> {info} );
    }

    ////////// VISUAL COMPONENTS LOG METHODS //////////

    public static StandardLog buildVisualComponentLog( SplunkHelper.Log info, String userInput, String jsEvent ) {
        return buildVisualComponentLog( info, userInput, jsEvent, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
    }

    public static StandardLog buildVisualComponentLog( SplunkHelper.Log info, String userInput, String jsEvent, List<SplunkHelper.SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet ) {
        StandardLog visualRec = createLogStruct( info );

        visualRec.details.contextType = SplunkHelper.CONTEXT_TYPE.LWC.name();

        visualRec.details.sfDetails = new sfDetails();
        visualRec.details.sfDetails.userInput = userInput;
        visualRec.details.sfDetails.jsEvent = jsEvent;

        visualRec.details.sfDetails.sfFailedRecords = failedSfIdLst;
        visualRec.details.sfDetails.sfSuccessfulRecords = savedSFIdSet;

        return visualRec;
    }

    ////////// BACK-END LOG METHODS //////////

    public static StandardLog createLogStruct(SPlunkHelper.Log info, LogData data, SFDetails details){
        
        StandardLog log = createLogSTruct(info);

        if(data != null){
            log.details.sfDetails.log = data;
        }

        if(details != null){
            if(details.integrationType != null){
                log.details.sfDetails.integrationType = details.integrationType;
            }
            if(String.isNotEmpty(details.jsEvent)){
                log.details.sfDetails.jsEvent = details.jsEvent;
            }
            if(details.log != null){
                log.details.sfDetails.log = details.log;
            }
            if(String.isNotEmpty(details.requestBody)){
                log.details.sfDetails.requestBody = details.requestBody;
            }
            if(String.isNotEmpty(details.responseBody)){
                log.details.sfDetails.responseBody = details.responseBody;
            }
            if( details.sfFailedRecords != null && !details.sfFailedRecords.isEmpty()){
                log.details.sfDetails.sfFailedRecords = details.sfFailedRecords;
            }
            if( details.sfSuccessfulRecords != null &&!details.sfSuccessfulRecords.isEmpty()){
                log.details.sfDetails.sfSuccessfulRecords = details.sfSuccessfulRecords;
            }
            if(String.isNotEmpty(details.statusMessage)){
                log.details.sfDetails.statusMessage = details.statusMessage;
            }
            if(String.isNotEmpty(details.userInput)){
                log.details.sfDetails.userInput = details.userInput;
            }
        }

        return log;
    }

    public static StandardLog createLogStruct(SplunkHelper.Log info, LogData data){
        StandardLog log = createLogStruct(info);
        log.details.sfDetails.log = data;
        return log;
    }

    public static StandardLog createLogStruct( SplunkHelper.Log info ) {
        StandardLog logRec = new StandardLog();
        logRec.app = SF;
        logRec.version = info.version;
        logRec.traceId = ACVUtility.NewGuid();
        logRec.logLevel = info.logLevel.name();
        logRec.location = info.location;
        logRec.message = info.message;
        
        logRec.stackTrace = info.stackTrace.split( '\n' );
        DateTime now = Datetime.now();
        logRec.timestamp = now.yearGmt() + '-' + now.monthGmt() + '-' + now.dayGmt() + 'T' + now.hourGmt() + ':' + now.minuteGmt() + ':' + now.secondGmt() + '.' + now.millisecondGmt() + 'Z';
        
        logRec.details = new Details();
        logRec.details.sfUserId = UserInfo.getUserId();
        logRec.details.sfRecordId = info.sfRecordId;
        logRec.details.sfObject = info.sfObject;
        logRec.details.contextType = info.getContext();
        logRec.details.componentName = info.componentName;
        logRec.details.environment = ACVUtility.getEnvironmentName();
        for ( SplunkHelper.DOMAIN domainRec : info.domainSet ) {
            logRec.details.domain = String.isBlank( logRec.details.domain ) ? domainRec.name() + ',' : logRec.details.domain + domainRec.name() + ',';
        }
        logRec.details.domain = !info.domainSet.isEmpty() ? logRec.details.domain.substring( 0, logRec.details.domain.length() - 1 ): logRec.details.domain;

        logRec.details.sfDetails = new sfDetails();
        logRec.details.sfDetails.sfFailedRecords = new List<SplunkHelper.SFErrorRecord>();
        logRec.details.sfDetails.sfSuccessfulRecords = new Set<String>();

        return logRec;
    }

    // public static void postLog( StandardLog logStructRec ) {
    //     HTTP h = new HTTP();
    //     HTTPRequest request = new HTTPRequest();

    //     request.setMethod( 'POST' );
    //     request.setEndpoint( 'callout:Splunk/services/collector/event' );
    //     request.setHeader( 'Authorization', '{!$Credential.Password}' );
    //     request.setHeader( 'Content-Type', 'application/json' );

    //     String body = JSON.serialize( logStructRec );

    //     SplunkEvent requestEvent = new SplunkEvent();
    //     requestEvent.sourcetype = SF;
    //     requestEvent.event = body;

    //     body = JSON.serialize( requestEvent );

    //     request.setBody( body );
    //     HTTPResponse response; 

    //     try {
    //         response = h.send( request ); 
    //     } catch ( exception e ) {
    //         response = new HTTPResponse();
    //         response.setStatusCode( 500 );
    //         response.setBody( e.getStackTraceString() );
    //         response.setStatus( e.getMessage() );
    //     }

    //     if ( response.getStatusCode() == null || ( response.getStatusCode() != null && ( response.getStatusCode() >= 300 || response.getStatusCode() < 200 ) ) ) {
    //         insert new ACVAPIHelper.Result( request, response, 'Splunk Integration', Id.valueOf( logStructRec.details.sfRecordId ) ).toIR();
    //     }
    // }

    public static void postLog( List<StandardLog> logStructRec ) {
        HTTP h = new HTTP();
        HTTPRequest request = new HTTPRequest();

        request.setMethod( 'POST' );
        request.setEndpoint( 'callout:Splunk/services/collector/event' );
        request.setHeader( 'Authorization', '{!$Credential.Password}' );
        request.setHeader( 'Content-Type', 'application/json' );
        List<SplunkEvent> eventList = new List<SplunkEvent>();
        String body;

        for(StandardLog sl :logStructRec){
            SplunkEvent requestEvent = new SplunkEvent();
            requestEvent.sourcetype = SF;
            requestEvent.event = JSON.serialize(sl);
            if(body == null){
                body = JSON.serialize(requestEvent);
            }
            else{
                body += JSON.serialize(requestEvent);
            }
        }
        request.setBody( body );
        HTTPResponse response; 

        try {
            response = h.send( request ); 
        } catch ( exception e ) {
            response = new HTTPResponse();
            response.setStatusCode( 500 );
            response.setBody( e.getStackTraceString() );
            response.setStatus( e.getMessage() );
        }

        if ( response.getStatusCode() == null || ( response.getStatusCode() != null && ( response.getStatusCode() >= 300 || response.getStatusCode() < 200 ) ) ) {
            insert new ACVAPIHelper.Result( request, response, 'Splunk Integration', Id.valueOf( logStructRec[0].details.sfRecordId ) ).toIR();
        }
    }

    

    public class SplunkEvent {
        public String sourcetype;
        public String event;
    }

    

    public class StandardLog {
        public String app;
        public String version;
        public String traceId; // uuid v4
        //public Kubernetes kubernetes;
        public String logLevel;
        public String location;
        public String message;
        public String durationMs;
        public Integer responseCode;
        public String requestRoute;
        public String requestPath;
        public String requestVerb;
        public String requestUrl;
        public List<String> stackTrace;
        public String timestamp;
        
        public Details details;
    }

    public class Details {
		public String sfUserId;
		public String sfRecordId;
		public String sfObject;
		public String contextType;
        public String componentName;
        public String domain;
        public String environment;
		public SFDetails sfDetails;
	}

	public class SFDetails {
        // Should only Set one group, never multiple
        
        // Integration
        public String integrationType;
        public String requestBody;
        public String responseBody;
        public String statusMessage;

        // Batch
        public List<SplunkHelper.SFErrorRecord> sfFailedRecords;
        public Set<String> sfSuccessfulRecords;

        // Visual Component
        public String userInput; // Should be user provided JSON
        public String jsEvent;

        //Logging Data
        public LogData log;
    }

    public class LogData{
        public String name;
        public String currentValue;
        public String maximumValue;
        public String percentUsed;
        public String type;
    }
	/*public class Kubernetes {
		public String provider;
		public String cluster;
		public String region;
		public String namespace;
		public String podId;
		public String containerName;
    }*/
}