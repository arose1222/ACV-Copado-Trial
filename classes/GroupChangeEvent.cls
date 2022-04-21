public class GroupChangeEvent extends TriggerInterface{
   
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 
        Map<Id,Group__c> newGroupMap = (Map<Id,Group__c>) incomingNewMap;
        Map<Id,Group__c> oldGroupMap = (Map<Id,Group__c>) incomingOldMap;
        List<Id> idList = New List<Id>();
        List<Organization_Group__e> GroupEvents = New List<Organization_Group__e>();
            
            for(Group__c GroupRec : newGroupMap.values()) {
                //trigger where Group fields active or name have been updated    
                if(oldGroupMap.get(GroupRec.id).Name != GroupRec.Name || 
                    GroupRec.Active__c != oldGroupMap.get(GroupRec.Id).Active__c ||
                    GroupRec.Disable_Bid_Visibility__c != oldGroupMap.get(GroupRec.Id).Disable_Bid_Visibility__c 
                ){
                // Create an instance of the event and store it in the Organization_Group__e variable 
                    GroupEvents.add(new Organization_Group__e(
                    Organization_Group_Id__c=Grouprec.Group_Guid__c,
                    Active__c=Grouprec.Active__c, 
                    Group_Name__c=GroupRec.Name,
                    Group_Salesforce_Id__c=Grouprec.id,
                    Disable_Bid_Visibility__c=GroupRec.Disable_Bid_Visibility__c,
                    event_type__c = 'update-organization-group'));
                    idList.add(Grouprec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!GroupEvents.isempty()){
                grouppublisher(GroupEvents, idList);
            }         
    }   
    

    public override void afterInsert(Map<Id,SObject> incomingMap){ 
        Map<Id,Group__c> newGroup = (Map<Id,Group__c>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Group__e> GroupEvents = New List<Organization_Group__e>();
            
            //trigger anytime a Group is Created
            for(Group__c GroupRec : newGroup.values()) {
                // Create an instance of the event and store it in the Organization_Group__e variable 
                    GroupEvents.add(new Organization_Group__e(
                    Organization_Group_Id__c=GroupRec.Group_Guid__c,
                    Active__c=GroupRec.Active__c, 
                    Group_Name__c=GroupRec.Name,
                    Group_Salesforce_Id__c=GroupRec.id,
                    Disable_Bid_Visibility__c=GroupRec.Disable_Bid_Visibility__c,
                    event_type__c = 'create-organization-group'));
                    idList.add(GroupRec.Id);
                
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!GroupEvents.isempty()){
                grouppublisher(GroupEvents, idList);
            }
    }
    public static void grouppublisher(List<Organization_Group__e> GroupEvents, List<Id> idList){ 
        // Call method to publish list of Group events       
        List<Database.SaveResult> results = EventBus.publish(GroupEvents);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Group Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){
            Database.SaveResult Result = results[i];	
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = 'Organization_Group__e';
            integrationObj.Integration_Name__c = 'OrganizationGroupChangeEvent';
            integrationObj.recordId__c = string.valueof(idlist[i]);
            integrationObj.Request_Message__c = String.valueof(GroupEvents[i]);

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