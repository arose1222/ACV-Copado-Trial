public class SalesforceGatewayValidateEulaQueueable implements Queueable, Database.AllowsCallouts{

    private final string endpointURL = '/api/v1/eula';
    
    @TestVisible public List<Id> data = new List<Id>();
    @TestVisible static Boolean makeCallout = true; 
    public SalesforceGatewayValidateEulaQueueable(List<Id> input){
        data = input;
    }

    public void execute(QueueableContext context){
        runCalloutLogic();
    }

    public void runCalloutLogic(){
        
        List<Contact> updateList = new List<Contact>();
        Map<Id, Eula_Tos__C> eulaRecords= new Map<Id, Eula_Tos__C>([Select Id, Contact__c, Eula_Id__c, Accepted_Date__c, Contact__r.Identity_Id__c, Contact__r.ID__C,
                                         Contact__r.Account.Organization_Guid__c, Contact__r.AccountId, Contact__r.Email From Eula_Tos__C where Contact__C in :data]);
        
        
        List<Id> failedRecords = new List<Id>();
        List<Id> failedAccRecords = new List<Id>();
        List<Account> accList= new List<Account>();
        List<Contact> conList= new List<Contact>();
        List<String> outboundList= new List<String>();

        for(Eula_Tos__C i :eulaRecords.values()){
            SalesforceGatewayEulaValidate eulaRequest= new SalesforceGatewayEulaValidate(i.Contact__r.Identity_Id__c, i.Contact__r.ID__C, i.Eula_Id__c, 
                                                        i.Contact__r.Account.Organization_Guid__c, i.Accepted_Date__c);
            
            outboundList.add(i.Contact__r.Email);
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http h = new Http();
            req.setMethod('POST');
            req.setEndpoint( 'callout:Salesforce_Gateway' + endpointURL );
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', '{!$Credential.Password}');
            req.setTimeout(120000);
            req.setBody(JSON.serialize(eulaRequest));
            try{
                res = h.send(req);
            }
            catch(Exception e){
                failedRecords.add(i.Contact__c);
                failedAccRecords.add(i.Contact__r.AccountId);
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.FATAL, ACVUtility.currentLineNumber());
                continue;
            }
            if(res.getStatusCode() == 200){
                accList.add(new Account(Id= i.Contact__r.AccountId, Lead_Convert_Status__c= 'Complete'));
                conList.add(new Contact(Id= i.Contact__c, Active__c= true));
            }
            else{
                failedRecords.add(i.Contact__c);
                failedAccRecords.add(i.Contact__r.AccountId);
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.FATAL, ACVUtility.currentLineNumber());
            }
        }
        if(conList.size()>0 || accList.size()>0){
            try{
                 update conList;
                 update accList;
            }
            catch(Exception e){
                for(Contact c :conList){
                    failedRecords.add(c.Id);
                }
                for(Account c :accList){
                    failedAccRecords.add(c.Id);
                }
            }
            
        }

        if(failedRecords.size() > 0){
            List<Account> accFailedList= new List<Account>();
            for(Id i :failedAccRecords){
                Account acc= new Account(Id= i, Lead_Convert_Status__C= 'Eula/Tos Endpoint Failed');
                accFailedList.add(acc);
            }

            update accFailedList;
        }

        if(outboundList.size() > 0 && !Test.isRunningTest()){
            ID jobID= System.enqueueJob(new SalesforceGatewaySendEmailQueueable(outboundList));
        }

    }

    public static void sendHTTPLog(HttpRequest req, HttpResponse res, SplunkHelper.LOGLEVEL logLevel, Integer lineNumber){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'SalesforceGatewayValidateEulaQueueable:' + lineNumber;
        infoLog.message = res.getStatus();
        infoLog.stackTrace = 'SalesforceGatewayValidateEulaQueueable.execute: '+lineNumber;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'SalesforceGatewayValidateEulaQueueable';
        infoLog.sfObject = 'Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
    }

}