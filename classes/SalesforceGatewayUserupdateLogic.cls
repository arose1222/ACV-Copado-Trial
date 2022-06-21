public class SalesforceGatewayUserupdateLogic extends TriggerInterface{
    
    public override void afterUpdate(Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
        Map<Id,Contact> newConMap = (Map<Id,Contact>) newMap;
        Map<Id,Contact> oldConMap = (Map<Id,Contact>) oldMap;
        Map<Id,SalesforceGatewayUpdateUserQeueable.usernameUpdate> outboundList = new Map<Id, SalesforceGatewayUpdateUserQeueable.usernameUpdate>();
        Map<Id,SalesforceGatewayUpdateUserQeueable.usernameUpdate> outboundList2 = new Map<Id, SalesforceGatewayUpdateUserQeueable.usernameUpdate>();
        List<LoginHistory> lh = [SELECT Id, SourceIp,Browser FROM LoginHistory WHERE UserId = :UserInfo.getUserId() ORDER BY LoginTime DESC LIMIT 1];
        List<Contact> runningUserContact = [Select Id, Identity_Id__c FROM Contact WHERE email = :UserInfo.getUserEmail() LIMIT 1];
        Integer jobSizeCounter = 1;
        //this list is empty check has a limited usecase, basically if we are creating a user in code for tests, or if we are logging into a user from a refreshed sandbox login history will not exist causing failures
        if(!lh.isEmpty()){
            for(Contact c :newConMap.values()){
                if(ACVUtility.recordTypeCheck('ACV_User', 'Contact', c.RecordTypeId) && !String.isBlank(c.Identity_Id__c) && c.email != oldConMap.get(c.id).email){
                    if(runningUserContact.size() < 1 || String.isBlank(runningUserContact[0]?.Identity_Id__c)){
                        throw new CustomException('You do not have an active Identity Id, please contact a System Admin for assistance');
                    }
                    if(jobSizeCounter == 100){
                        outboundList.put(c.Id, new SalesforceGatewayUpdateUserQeueable.usernameUpdate(c.Identity_Id__c, c.email, lh[0].Browser, lh[0].SourceIp, runningUserContact[0].Identity_Id__c));
                    }
                    else{
                        outboundList2.put(c.Id, new SalesforceGatewayUpdateUserQeueable.usernameUpdate(c.Identity_Id__c, c.email, lh[0].Browser, lh[0].SourceIp, runningUserContact[0].Identity_Id__c));
                    }
                }
                jobSizeCounter++;
            }
        }
        if(outboundList.size() > 0){
            ID jobID = System.enqueueJob(new SalesforceGatewayUpdateUserQeueable(outboundList));
        }
        if(outboundList2.size() > 0){
            ID jobID = System.enqueueJob(new SalesforceGatewayUpdateUserQeueable(outboundList2));
        }
    }
}