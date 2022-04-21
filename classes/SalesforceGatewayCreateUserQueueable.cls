public class SalesforceGatewayCreateUserQueueable implements Queueable, Database.AllowsCallouts{

    @TestVisible public Map<Id,SalesforceGatewayUserCreate> data = new Map<Id,SalesforceGatewayUserCreate>();
    private Integer retryCount = 0;
    private final string endpointURL = '/api/v1/user';

    @TestVisible static Boolean makeCallout = true; 

    public SalesforceGatewayCreateUserQueueable(Map<Id,SalesforceGatewayUserCreate> input){
        data = input;
    }

    public SalesforceGatewayCreateUserQueueable(Map<Id,SalesforceGatewayUserCreate> input, Integer attemptNumber){
        data = input;
        retryCount = attemptNumber;
    }

    public void execute(QueueableContext context){
        runCalloutLogic();
    }

    public void runCalloutLogic(){
        List<Contact> updateList = new List<Contact>();
        Map<Id,SalesforceGatewayUserCreate> failedRecords = new Map<Id,SalesforceGatewayUserCreate>();
        Map<Id, Contact> contactInfo= new Map<Id, Contact>([Select Id, Lead_Convert_Status__C, AccountId From Contact where Id in :data.keySet()]);
        List<Id> outboundList = new List<Id>();
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
            if(res.getStatusCode() == 200){
                SalesforceGatewayUserResponse sfgur = (SalesforceGatewayUserResponse)JSON.deserializeStrict(res.getBody(), SalesforceGatewayUserResponse.class);
                updateList.add(new Contact(Id=i, Identity_Id__c = sfgur.identity_user_id));

                if(contactInfo.containsKey(i) && contactInfo.get(i).Lead_Convert_Status__c=='Converting')           
                {                    
                    outboundList.add(i);
                }
              
                                
            }
            else{
                failedRecords.put(i,data.get(i));
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber());
            }
        }
        if(updateList.size()>0){
            try{
                update updateList;

                if(outboundList.size() > 0 && !Test.isRunningTest()){
                  
                    ID jobID = System.enqueueJob(new SalesforceGatewayValidateEulaQueueable(outboundList));
                }

            }
            catch(Exception e){
           
                for(Contact c :updateList){
                    failedRecords.put(c.Id, data.get(c.Id));
                }
                outboundList.clear();
            }
        }

        if(failedRecords.size() > 0 && retryCount <= 3){
            retryCount += 1;
            Id jobId;
            if(makeCallout){
                jobID = System.enqueueJob(new SalesforceGatewayCreateUserQueueable(failedRecords, retryCount));
                sendLog(SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber(),'Failure Detected, Retry Attempt #'+retryCount,'SalesforceGatewayCreateUserQueueable.Execute',jobID);
            } 
        }
        else if(retryCount == 4){

            List<Account> accList = new List<Account>();
           
            for(Id i : failedRecords.keySet()){
                if( contactInfo.get(i).Lead_Convert_Status__c == 'Converting' )
                {
                    Account acc= new Account(Id= contactInfo.get(i).AccountId, Lead_Convert_Status__C= 'Identity Id Endpoint Failed');
                    accList.add(acc);
                }
            }

            update accList;

            sendLog(SplunkHelper.LOGLEVEL.FATAL, ACVUtility.currentLineNumber(),'Retry has exeeded 3 attempts','SalesforceGatewayCreateUserQueueable.Execute',UserInfo.getUserId());
        }
    }

    public static void sendHTTPLog(HttpRequest req, HttpResponse res, SplunkHelper.LOGLEVEL logLevel, Integer lineNumber){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'SalesforceGatewayCreateUserQueueable:' + lineNumber;
        infoLog.message = res.getStatus();
        infoLog.stackTrace = 'SalesforceGatewayCreateUserQueueable.execute: '+lineNumber;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'SalesforceGatewayCreateUserQueueable';
        infoLog.sfObject = 'Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }

    public static void sendLog(SplunkHelper.LOGLEVEL logLevel, Integer lineNumber, String Message, String StackTrace, String recordId){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'SalesforceGatewayCreateUserQueueable:' + lineNumber;
        infoLog.message = Message;
        infoLog.stackTrace = StackTrace+ ' '+lineNumber;
        infoLog.sfRecordId = String.isBlank(recordId) ? '' : recordId;
        infoLog.componentName = 'SalesforceGatewayCreateUserQueueable';
        infoLog.sfObject = 'Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES};
        SplunkHelper.buildandProcessLog( infoLog );
    }
}