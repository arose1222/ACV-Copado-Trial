public class SalesforceGatewayUpdateUserQeueable implements Queueable, Database.AllowsCallouts{
    @TestVisible public Map<Id,usernameUpdate> data = new Map<Id,usernameUpdate>();
    private Integer retryCount = 0;
    private final string endpointURL = '/api/v1/identity/username';

    @TestVisible static Boolean makeCallout = true; 

    public SalesforceGatewayUpdateUserQeueable(Map<Id,usernameUpdate> input){
        data = input;
    }

    public SalesforceGatewayUpdateUserQeueable(Map<Id,usernameUpdate> input, Integer attemptNumber){
        data = input;
        retryCount = attemptNumber;
    }

    public void execute(QueueableContext context){
        runCalloutLogic();
    }

    public void runCalloutLogic(){
        Map<Id,usernameUpdate> failedRecords = new Map<Id,usernameUpdate>();
        for(Id i :data.keySet()){
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http h = new Http();
            req.setMethod('POST');
            req.setEndpoint( 'callout:Salesforce_Gateway' + endpointURL );
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', '{!$Credential.Password}');
            req.setTimeout(120000);
            req.setBody(JSON.serialize(data.get(i)));
            try{
                res = h.send(req);
            }
            catch(Exception e){
                failedRecords.put(i,data.get(i));
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber());
                continue;
            }
            if(res.getStatusCode() != 200){
                failedRecords.put(i,data.get(i));
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber());
            }
        }

        if(failedRecords.size() > 0 && retryCount <= 3){
            retryCount += 1;
            if(makeCallout){
                ID jobID = System.enqueueJob(new SalesforceGatewayUpdateUserQeueable(failedRecords, retryCount));
                sendLog(SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber(),'Failure Detected, Retry Attempt #'+retryCount,'SalesforceGatewayUpdateUserQeueable.Execute',jobID);
            }   
        }
        else if(retryCount == 4){
            sendLog(SplunkHelper.LOGLEVEL.FATAL, ACVUtility.currentLineNumber(),'Retry has exeeded 3 attempts','SalesforceGatewayUpdateUserQeueable.Execute',UserInfo.getUserId());
        }
    }

    public static void sendHTTPLog(HttpRequest req, HttpResponse res, SplunkHelper.LOGLEVEL logLevel, Integer lineNumber){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'SalesforceGatewayUpdateUserQeueable:' + lineNumber;
        infoLog.message = res.getStatus();
        infoLog.stackTrace = 'SalesforceGatewayUpdateUserQeueable.execute: '+lineNumber;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'SalesforceGatewayUpdateUserQeueable';
        infoLog.sfObject = 'Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }

    public static void sendLog(SplunkHelper.LOGLEVEL logLevel, Integer lineNumber, String Message, String StackTrace, String recordId){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'SalesforceGatewayUpdateUserQeueable:' + lineNumber;
        infoLog.message = Message;
        infoLog.stackTrace = StackTrace+ ' '+lineNumber;
        infoLog.sfRecordId = recordId;
        infoLog.componentName = 'SalesforceGatewayUpdateUserQeueable';
        infoLog.sfObject = 'Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES};
        SplunkHelper.buildandProcessLog( infoLog );
    }

    public class usernameUpdate{
        public string identity_user_id;
        public string username;
        public string user_agent;
        public string ip_address;
        public string requesting_identity_user_id;

        public usernameUpdate(String iui, String un, String ua, String ipa, String riuid){
            this.identity_user_id = iui;
            this.username = un;
            this.user_agent = ua;
            this.ip_address = ipa;
            this.requesting_identity_user_id = riuid;
        }
    }
}