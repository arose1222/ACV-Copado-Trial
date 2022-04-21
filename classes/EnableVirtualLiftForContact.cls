public class EnableVirtualLiftForContact extends TriggerInterface{
    
    public override void beforeUpdate(Map<Id,SObject> oldmap, Map<Id,SObject> newMap){
        if(System.isFuture()){
            //need this for the event that the callout fails and we update to revert the checkbox, we can not future call from a future call
            return;
        }
        Map<Id,Contact> newConMap = (Map<Id,Contact>)newMap;
        Map<Id,Contact> oldConMap = (Map<Id,Contact>)oldmap;
        List<String> enableList = new List<String>();
        List<String> disableList = new List<String>();

        for(Contact c :newConMap.values()){
            if(c.Virtual_Lift_Enabled__c && oldConMap.get(c.id).Successful_Virtual_Lift_Prescreens__c != c.Successful_Virtual_Lift_Prescreens__c && c.Successful_Virtual_Lift_Prescreens__c >= 10 && oldConMap.get(c.id).Successful_Virtual_Lift_Prescreens__c < 10){
                enableList.add(c.id__c);
            }
            else if(!c.Virtual_Lift_Enabled__c && oldConMap.get(c.id).Virtual_Lift_Enabled__c != c.Virtual_Lift_Enabled__c){
                disableList.add(c.id__c);
            }
        }

        if(enableList.size() > 0){
            enableUser(enableList);
        }
        if(disableList.size() > 0){
            disableUser(disableList);
        }
    }

    @future(callout=true)
    public static void enableUser(List<String> userIdList){
        VirtualLiftAPIHelper vlAPI = new VirtualLiftAPIHelper();
        if(!vlAPI.whiteListUser(userIdList)){
            system.debug(userIdList);
            handleIntegrationError(userIdList,'Enable');
        }
    }

    @future(callout=true)
    public static void disableUser(List<String> userIdList){
        VirtualLiftAPIHelper vlAPI = new VirtualLiftAPIHelper();
        if(!vlAPI.deactivateUser(userIdList)){
            handleIntegrationError(userIdList,'Disable');
        }
    }

    public static void handleIntegrationError(List<String> userIdList, String action){
        List<ChatterUtility.chatterWrapper> chatterList = new List<ChatterUtility.chatterWrapper>();
        List<Contact> contactList = new List<Contact>();
        String wording = '';
        Boolean VLResult = false;
        if(action == 'Enable'){
            wording = 'Was not Able to Enable user for Virtual Lift, Please Try again or contact Support if the issue continues';
        }
        else{
            wording = 'Was not Able to Disable user for Virtual Lift, Please Try again or contact Support if the issue continues';
            VLResult = true;
        }
        for(Contact c:[Select Id, Id__c, Virtual_Lift_Enabled__c from Contact where Id__c in :userIdList]){
            c.Virtual_Lift_Enabled__c = VLResult;
            contactList.add(c);
            chatterList.add(new ChatterUtility.chatterWrapper(c.id, wording,UserInfo.getUserId()));
        }
        if(chatterList.size() > 0){
            //trying  to get around having see all data in my test class, I think it is causing issues with my deployment
            if(!Test.isRunningTest()){ChatterUtility.mentionTextRecordPostBatch(chatterList);}
        }
        if(contactList.size() > 0){
            update contactList;
        }
    }
}