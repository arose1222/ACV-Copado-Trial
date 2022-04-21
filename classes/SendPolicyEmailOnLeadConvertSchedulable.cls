/**
 * Schedulable class to send policy email upon custom lead conversion with a delay.
 * @author Jyothsna P
 * @since 4/16/21
 */
public class SendPolicyEmailOnLeadConvertSchedulable implements Schedulable {

    public static final String ACV_AUCTIONS_POLICY_EMAIL_NAME = 'ACV Auctions Policy Information';

    @TestVisible public List<Id> data = new List<Id>();
    // Accepts list of Contact Id
    public SendPolicyEmailOnLeadConvertSchedulable(List<Id> input){
        data = input;
    }

    public void execute(SchedulableContext context){
        sendEmail();
    }

    public void sendEmail(){
        List<EmailTemplate> et = [ SELECT Id, Name FROM EmailTemplate WHERE Name = :ACV_AUCTIONS_POLICY_EMAIL_NAME LIMIT  1];
        List<Contact> cList = [ SELECT Id, IST_Account_Manager_Email__c FROM Contact WHERE Id in :data];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'dealeronboarding@acvauctions.com' ];
       
        // Looping through the contact list
        for( Contact c : cList){                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(et[0].Id);
                email.setReplyTo(c.IST_Account_Manager_Email__c); 
                email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
                email.setTargetObjectId(c.Id);
                emailList.add(email);
            }
            String conRecordIdList= string.join(data, ',');
            try{
                if(!Test.isRunningTest() && !emailList.isEmpty())
                {
                    Messaging.sendEmail(emailList);
                }
                sendLog('SendPolicyEmailOnLeadConvertSuccess', '', ACVUtility.currentLineNumber(), conRecordIdList , SplunkHelper.LOGLEVEL.INFO);
            }
            catch( Exception ex ){
                if(!ex.getMessage().contains('NO_MASS_MAIL_PERMISSION')) 
                {
                    sendLog('SendPolicyEmailOnLeadConvertFailed', ex.getStackTraceString(), ACVUtility.currentLineNumber(), conRecordIdList, SplunkHelper.LOGLEVEL.FATAL);
                }
            }
    }

    public static void sendLog( String message, String stackLineMsg, Integer lineNumber, String recordIdList, SplunkHelper.LOGLEVEL logLevel ){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.componentName = 'SendPolicyEmailOnLeadConvertSchedulable';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        infoLog.location = 'SendPolicyEmailOnLeadConvertSchedulable:'+lineNumber;
        infoLog.logLevel = logLevel;
        infoLog.message = message;
        infoLog.sfObject = 'Contact';
        infoLog.sfRecordId = recordIdList;
        infoLog.stackTrace = stackLineMsg;
        infoLog.version = 'v1';
        infoLog.setContext(SplunkHelper.CONTEXT_TYPE.APEX_TRIGGER);
        SplunkHelper.buildAndProcessLog(infoLog);
    }

}