/*
    This class contains logic to make a callout to send an external endpoint to send welcome email. This will called from LeadConversion.cls
*/
public class SalesforceGatewaySendEmailQueueable implements Queueable, Database.AllowsCallouts{

    private final string endpointURL = '/api/v1/user/welcome';
    @TestVisible public List<String> data = new List<String>();
    
    public SalesforceGatewaySendEmailQueueable(List<String> input){
        data = input;
    }

    public void execute(QueueableContext context){
        runCalloutLogic();
    }

    public void runCalloutLogic(){
        
        //Get login history and Identity Id of running user
        List<LoginHistory> lh = [SELECT Id, SourceIp,Browser FROM LoginHistory WHERE UserId = :UserInfo.getUserId() ORDER BY LoginTime DESC LIMIT 1];
        List<Contact> runningUserContact = [Select Id, Email, Identity_Id__c FROM Contact WHERE email = :UserInfo.getUserEmail() LIMIT 1];
        
        if(runningUserContact.size() < 1 || String.isBlank(runningUserContact[0]?.Identity_Id__c)){
            throw new CustomException('You do not have an active Identity Id, please contact a System Admin for assistance');
        }

        if(!lh.isEmpty() && data.size()>0){
            for(String i :data){
                SalesforceGatewaySendEmail emailRequest= new SalesforceGatewaySendEmail(i, lh[0].Browser, lh[0].SourceIp, runningUserContact[0].Identity_Id__c);
            
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                Http h = new Http();
                req.setMethod('POST');
                req.setEndpoint( 'callout:Salesforce_Gateway' + endpointURL );
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', '{!$Credential.Password}');
                req.setTimeout(120000);
                req.setBody(JSON.serialize(emailRequest));
                try{
                    res = h.send(req);
                }
                catch(Exception e){
                    sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.FATAL, ACVUtility.currentLineNumber());
                    continue;
                }
                // If status code is 200, no need to anything.
                if(res.getStatusCode() != 200){
                    sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.FATAL, ACVUtility.currentLineNumber());
                }
            }
        }
    }

    public static void sendHTTPLog(HttpRequest req, HttpResponse res, SplunkHelper.LOGLEVEL logLevel, Integer lineNumber){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'SalesforceGatewaySendWelcomeEmailQueueable:' + lineNumber;
        infoLog.message = res.getStatus();
        infoLog.stackTrace = 'SalesforceGatewaySendWelcomeEmailQueueable.execute: '+lineNumber;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'SalesforceGatewaySendWelcomeEmailQueueable';
        infoLog.sfObject = 'Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
    }

}