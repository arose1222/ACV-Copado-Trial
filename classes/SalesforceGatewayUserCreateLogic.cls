public class SalesforceGatewayUserCreateLogic extends TriggerInterface{
    
    private static boolean calledFromAPI = false;
    // Get AVC User Record Type Id
    private static String acvUserRtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();

    public override void afterInsert(List<SObject> insertList){
        Set<Id> contactIDSet = new Set<Id>();
        if(calledFromAPI){
            return;
        }
        for(Contact c :(List<Contact>)insertList){
            //TODO: use map instead for the afterinsert override to use the keyset
            contactIDSet.add(c.Id);
        }
        List<Contact> newContactList = [SELECT Id, Email, FirstName, MiddleName, LastName, MailingPostalCode, Phone, Id__c, Role__c, RecordTypeId, Identity_Id__c, Contact_Guid__c, Creation_Source__c FROM Contact Where ID in :contactIDSet];
        Map<Id,SalesforceGatewayUserCreate> outboundList = new Map<Id, SalesforceGatewayUserCreate>();
        Map<Id,SalesforceGatewayUserCreate> outboundList2 = new Map<Id, SalesforceGatewayUserCreate>();
        List<LoginHistory> lh = [SELECT Id, SourceIp,Browser FROM LoginHistory WHERE UserId = :UserInfo.getUserId() ORDER BY LoginTime DESC LIMIT 1];
        List<Contact> runningUserContact = [Select Id, Identity_Id__c FROM Contact WHERE email = :UserInfo.getUserEmail() AND RecordTypeId =:acvUserRtId LIMIT 1];
        Integer jobSizeCounter = 1;
        //this list is empty check has a limited usecase, baiscally if we are creating a user in code for tests, or if we are logging into a user from a refreshed sandbox login history will not exist causing failures
        if(!lh.isEmpty()){
            for(Contact c :newContactList){
                if(ACVUtility.recordTypeCheck('ACV_User', 'Contact', c.RecordTypeId) && c.Identity_Id__c == null){
                    if(runningUserContact.size() < 1 || String.isBlank(runningUserContact[0]?.Identity_Id__c)){
                        throw new CustomException('You do not have an active Identity Id, please contact a System Admin for assistance');
                    }
                    String nameConCat = String.isBlank(c.MiddleName) ? c.FirstName+' '+c.LastName : c.firstName+' '+c.middleName+' '+c.lastName;
                    List<String> roleList = new List<String>();
                    if(c.Role__c == 'VCI'){
                        roleList.add('vci');
                    }
                    if(jobSizeCounter == 100){
                        outboundList.put(c.Id, new SalesforceGatewayUserCreate(c.email, '', 
                        nameConCat , c.mailingPostalCode, 
                        c.phone, lh[0].Browser, lh[0].SourceIp, runningUserContact[0]?.Identity_Id__c, c.id__c, roleList, c?.Creation_Source__c, c.Contact_Guid__c));
                    }
                    else{
                        outboundList2.put(c.Id, new SalesforceGatewayUserCreate(c.email, '', 
                        nameConCat, c.mailingPostalCode, 
                        c.phone, lh[0].Browser, lh[0].SourceIp, runningUserContact[0]?.Identity_Id__c, c.id__c, roleList, c?.Creation_Source__c, c.Contact_Guid__c));
                    }
                    
                }
                jobSizeCounter++;
            }
        }
        if(outboundList.size() > 0){
            ID jobID = System.enqueueJob(new SalesforceGatewayCreateUserQueueable(outboundList));
        }
        if(outboundList2.size() > 0){
            ID jobID = System.enqueueJob(new SalesforceGatewayCreateUserQueueable(outboundList2));
        }
    }
    
    public static void disableGatewayLogic(){
        calledFromAPI = true;
    }
    public static void enableGatewayLogic(){
        calledFromAPI = false;
    }
}