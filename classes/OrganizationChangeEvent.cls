global class OrganizationChangeEvent extends TriggerInterface{
    //TODO: get rid of integration results

    @testvisible
    public static boolean CauseFailure = false;

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();


    global override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 

        Map<Id,Account> newOrgMap = (Map<Id,Account>) incomingNewMap;
        Map<Id,Account> oldOrgMap = (Map<Id,Account>) incomingOldMap;
        List<Id> idList = New List<Id>();
        List<Organization_Event__e> OrganizationEvents = New List<Organization_Event__e>();
            
            for(Account OrgRec : newOrgMap.values()) {
                //trigger where Active flag is flipped AND Inactive sub status has not been changed    
                if(OrgRec.RecordTypeId == orgRecordTypeId &&
                OrgRec.Dealership_Id__c != null &&
                oldOrgMap.get(OrgRec.id).Inactive_Sub_Status__c == null &&
                OrgRec.Inactive_Sub_Status__c == null &&
                oldOrgMap.get(OrgRec.id).Active__c == false &&
                OrgRec.Active__c == true 
                ){
                // Create an instance of the event and store it in the Organization_Event__e variable 
                OrganizationEvents.add(new Organization_Event__e(    
                    Organization_Id__c = OrgRec.Dealership_Id__c,
                    Organization_Guid__c = OrgRec.Organization_Guid__c,
                    Changed_By_SF_User_Id__c = OrgRec.LastModifiedById,
                    Changed_By_Username__c = UserInfo.getUserEmail(),
                    event_type__c = 'organization-activated'));
                    idList.add(OrgRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!OrganizationEvents.isempty()){
                organizationpublisher(OrganizationEvents, idList);
            }         
    }   

    global static void organizationRegisteredEvent(List<SObject> incomingList){

        List<Account> orgList = (List<Account>) incomingList;
        List<Id> idList = New List<Id>();
        List<Organization_Event__e> OrganizationEvents = New List<Organization_Event__e>();

        for(Account OrgRec : [Select id, Dealership_Id__c, Organization_Guid__c, LastModifiedBy.Email From Account Where Id in :orgList] ){
            // Create an instance of the event and store it in the Organization_Event__e variable 
            OrganizationEvents.add(new Organization_Event__e(    
                Organization_Id__c = OrgRec.Dealership_Id__c,
                Organization_Guid__c = OrgRec.Organization_Guid__c,
                Changed_By_SF_User_Id__c = OrgRec.LastModifiedById,
                Changed_By_Username__c = OrgRec.LastModifiedBy.Email,
                event_type__c = 'registration-complete'));
                idList.add(OrgRec.Id);
              
        }
        //If the Event variable is NOT empty then fire the Publisher 
        if(!OrganizationEvents.isempty()){
            organizationpublisher(OrganizationEvents, idList);
        }       
    }

    public static void organizationpublisher(List<Organization_Event__e> OrganizationEvents, List<Id> idList){ 
        // Call method to publish list of Contact events       
        List<Database.SaveResult> results = EventBus.publish(OrganizationEvents);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Contact Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){
            Database.SaveResult Result = results[i];	
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = 'Organization_Event__e';
            integrationObj.Integration_Name__c = 'OrganizationChangeEvent';
            integrationObj.recordId__c = string.valueof(idlist[i]);
            integrationObj.Request_Message__c = String.valueof(OrganizationEvents[i]);

            if (!result.isSuccess() || CauseFailure) {
                if(result.getErrors().size() > 0 || CauseFailure)
                        IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                        'OrganizationChangeEvent: Organization Event failed to publish to event bus', 
                        SplunkHelper.LOGLEVEL.ERROR, 'OrganizationChangeEvent', 
                        'Organization Event failed to publish to event bus', 
                        'Organization');
            }
            else{
                integrationObj.Status_Code__c = 200;
                integrationObj.Status_Message__c = String.valueof(result);          
            }
            integrationList.add(integrationObj);
        }   
        if (integrationList.size() > 0){
            insert integrationList;
        }           
    }   
}