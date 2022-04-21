public class GroupAffiliationChangeEvent extends TriggerInterface{
   
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 
            Map<Id,Group_Affiliation__c> newGroupAffMap = (Map<Id,Group_Affiliation__c>) incomingNewMap;
            Map<Id,Group_Affiliation__c> oldGroupMap = (Map<Id,Group_Affiliation__c>) incomingOldMap;
            List<Id> idList = New List<Id>();
            List<Group_Affiliation_Event__e> GroupAffiliationEvents = New List<Group_Affiliation_Event__e>();

            //query for ID fields found in associated objects and add to newgroupAffMap
            Map<Id,Group_Affiliation__c> newGroupAff = new Map<Id,Group_Affiliation__c>([Select id, Name, Account__c, Group__c, Account__r.Dealership_ID__c, 
            Group__r.Group_Guid__c, Active__c, Account__r.RecordType.DeveloperName From Group_Affiliation__c Where id in: newGroupAffMap.keySet()]);
                
            for(Group_Affiliation__c GroupAffRec : newGroupAff.values()) {
                //Only publish Platform Event if associated Account is Standard
                if(GroupAffRec.Account__r.RecordType.DeveloperName == 'Standard'){
                    //trigger where GroupAffiliation active field has been flipped to False will trigger remove-group-affiliation event
                    if(oldGroupMap.get(GroupAffRec.id).Active__c == True && 
                        GroupAffRec.Active__c == False ){
                                    
                    
                    // Create an instance of the event and store it in the Group_Affiliation_Event__e variable 
                        GroupAffiliationEvents.add(new Group_Affiliation_Event__e(
                        Organization_Group_Id__c=GroupAffRec.Group__r.Group_Guid__c,
                        Active__c=GroupAffRec.Active__c, 
                        Organization_Id__c=GroupAffRec.Account__r.Dealership_ID__c,
                        Group_Salesforce_Id__c=GroupAffRec.Group__c,
                        Account_Salesforce_Id__c=GroupAffRec.Account__c,
                        event_type__c = 'remove-group-affiliation'));
                        idList.add(GroupAffRec.Id);
                    }
                    //trigger where GroupAffiliation active field has been flipped to False will trigger add-group-affiliation event
                    if(oldGroupMap.get(GroupAffRec.id).Active__c == False && 
                        GroupAffRec.Active__c == True){
                    
                    // Create an instance of the event and store it in the Group_Affiliation_Event__e variable 
                        GroupAffiliationEvents.add(new Group_Affiliation_Event__e(
                        Organization_Group_Id__c=GroupAffRec.Group__r.Group_Guid__c,
                        Active__c=GroupAffRec.Active__c, 
                        Organization_Id__c=GroupAffRec.Account__r.Dealership_ID__c,
                        Group_Salesforce_Id__c=GroupAffRec.Group__c,
                        Account_Salesforce_Id__c=GroupAffRec.Account__c,
                        event_type__c = 'add-group-affiliation'));
                        idList.add(GroupAffRec.Id);
                    
                    }
            }   
            }     
            //If the Event variable is NOT empty then fire the Publisher 
            if(!GroupAffiliationEvents.isempty()){
                groupaffiliationpublisher(GroupAffiliationEvents, idList);
            }
            
    }    

    public override void afterInsert(Map<Id,SObject> incomingMap){ 
        Map<Id,Group_Affiliation__c> newGroupAffMap = (Map<Id,Group_Affiliation__c>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Group_Affiliation_Event__e> GroupAffiliationEvents = New List<Group_Affiliation_Event__e>();

        Salesforce_Setting__mdt createdDateDelay = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Created Time in Minutes Delay' ];
        Salesforce_Setting__mdt delayInSeconds = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Platform Event Publish Delay in Seconds' ];

        //query for ID fields found in associated objects and add to newgroupAffMap
        Map<Id,Group_Affiliation__c> newGroupAff = new Map<Id,Group_Affiliation__c>([Select id, Name, Account__c, Group__c, Account__r.Dealership_ID__c, 
        Group__r.Group_Guid__c, Active__c, Account__r.RecordType.DeveloperName, Account__r.CreatedDate, Group__r.CreatedDate From Group_Affiliation__c Where id in: newGroupAffMap.keySet()]);

        for(Group_Affiliation__c GroupAffRec : newGroupAff.values()) {
            Datetime start = System.Now().addSeconds(Integer.valueOf(delayInSeconds.Value__c));
            if(newGroupAff.get(GroupAffRec.id).Account__r.CreatedDate < System.Now().addMinutes(Integer.valueOf(createdDateDelay.Value__c)) || 
            newGroupAff.get(GroupAffRec.id).Group__r.CreatedDate < System.Now().addMinutes(Integer.valueOf(createdDateDelay.Value__c))){
                ACVUtility.delay(Integer.valueOf(delayInSeconds.Value__c));
                System.debug('Delay successful');
            }
            //Only publish Platform Event if associated Account is Standard and Active Flag is True for created Group Affiliation 
            if(GroupAffRec.Active__c == True && GroupAffRec.Account__r.RecordType.DeveloperName == 'Standard'){
                
                // Create an instance of the event and store it in the Group_Affiliation_Event__e variable 
                GroupAffiliationEvents.add(new Group_Affiliation_Event__e(
                Organization_Group_Id__c=GroupAffRec.Group__r.Group_Guid__c,
                Active__c=GroupAffRec.Active__c, 
                Organization_Id__c=GroupAffRec.Account__r.Dealership_ID__c,
                Group_Salesforce_Id__c=GroupAffRec.Group__c,
                Account_Salesforce_Id__c=GroupAffRec.Account__c,
                event_type__c = 'add-group-affiliation'));
                idList.add(GroupAffRec.Id);

            // if(GroupAffRec.Active__c == False)
                
            //     GroupAffiliationEvents.add(new Group_Affiliation_Event__e(
            //     Organization_Group_Id__c=GroupAffRec.Group__r.Group_Guid__c,
            //     Active__c=GroupAffRec.Active__c, 
            //     Organization_Id__c=GroupAffRec.Account__r.Dealership_ID__c,
            //     Group_Salesforce_Id__c=GroupAffRec.Group__c,
            //     Account_Salesforce_Id__c=GroupAffRec.Account__c,
            //     event_type__c = 'remove-group-affiliation'));
            //     idList.add(GroupAffRec.Id);

            }
        //If the Event variable is NOT empty then fire the Publisher 
        }
        if(!GroupAffiliationEvents.isempty()){
            groupaffiliationpublisher(GroupAffiliationEvents, idList);
        }
        
    }


    public static void groupaffiliationpublisher(List<Group_Affiliation_Event__e> GroupAffiliationEvents, List<Id> idList){ 
        // Call method to publish list of Group Affiliation events
        system.debug(GroupAffiliationEvents);
        system.debug(idList);
        system.debug(GroupAffiliationEvents.size());       
        List<Database.SaveResult> results = EventBus.publish(GroupAffiliationEvents);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Group Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){	
            Database.SaveResult Result = results[i];
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = 'Group_Affiliation_Event__e';
            integrationObj.Integration_Name__c = 'GroupAffiliationChangeEvent';
            integrationObj.recordId__c = string.valueof(idlist[i]);
            integrationObj.Request_Message__c = String.valueof(GroupAffiliationEvents[i]);
            
            if (!result.isSuccess()) {
                if(result.getErrors().size() > 0){
                    integrationObj.Status_Code__c = 400;
                    integrationObj.Status_Message__c = String.valueof(result.getErrors());
                }
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