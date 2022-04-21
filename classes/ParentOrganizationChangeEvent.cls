public class ParentOrganizationChangeEvent extends TriggerInterface{
   
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 
            Map<Id,Account> newAccMap = (Map<Id,Account>) incomingNewMap;
            Map<Id,Account> oldAccMap = (Map<Id,Account>) incomingOldMap;
            List<Id> idList = New List<Id>();
            List<Parent_Organization_Event__e> ParentOrgEvents = New List<Parent_Organization_Event__e>();

            //query for ID fields found in associated Accounts and add to newAccMap
            Map<Id,Account> newAcc = new Map<Id,Account>([Select id, Dealership_Id__c, ParentId, Parent.Dealership_Id__c, RecordType.DeveloperName, 
            Parent.RecordType.DeveloperName From Account Where id in: newAccMap.keySet()]);
                
            for(Account AccRec : newAcc.values()) {
                //Only publish Platform Event if associated Accounts are Standard
                if(AccRec.RecordType.DeveloperName == 'Standard' && AccRec.Parent.RecordType.DeveloperName == 'Standard' &&
                AccRec.Dealership_Id__c != null && AccRec.Parent.Dealership_Id__c != null){
                    //trigger where Account Parent field has been added from a null value
                    if(oldAccMap.get(AccRec.id).ParentId == null && 
                        AccRec.ParentId != null ){       
                    
                    // Create an instance of the event and store it in the Parent_Organization_Event__e variable 
                        ParentOrgEvents.add(new Parent_Organization_Event__e(
                        Organization_Id__c=AccRec.Dealership_Id__c,
                        Account_Salesforce_Id__c=AccRec.id, 
                        Parent_Organization_Id__c=AccRec.Parent.Dealership_ID__c,
                        Parent_Account_Salesforce_Id__c=AccRec.ParentId,
                        event_type__c = 'add-parent-organization'));
                        idList.add(AccRec.Id);
                    }
                    //trigger where Parent field has been changed which will trigger update-parent-organization event
                    if(oldAccMap.get(AccRec.id).ParentId != null && oldAccMap.get(AccRec.id).ParentId != AccRec.ParentId){
                    
                    // Create an instance of the event and store it in the Parent_Organization_Event__e variable 
                        ParentOrgEvents.add(new Parent_Organization_Event__e(
                        Organization_Id__c=AccRec.Dealership_Id__c,
                        Account_Salesforce_Id__c=AccRec.id, 
                        Parent_Organization_Id__c=AccRec.Parent.Dealership_ID__c,
                        Parent_Account_Salesforce_Id__c=AccRec.ParentId,
                        event_type__c = 'update-parent-organization'));
                        idList.add(AccRec.Id);
                    }
                }
                if(AccRec.RecordType.DeveloperName == 'Standard' && AccRec.Dealership_Id__c != null 
                // && oldAccMap.get(AccRec.id).Parent.RecordType.DeveloperName == 'Standard' &&
                // oldAccMap.get(AccRec.id).Parent.Dealership_Id__c != null
                 ){
                    //trigger where Account Parent field has been nulled from an existing value
                    if(oldAccMap.get(AccRec.id).ParentId != null && 
                    AccRec.ParentId == null ){
                                
                    // Create an instance of the event and store it in the Parent_Organization_Event__e variable 
                        ParentOrgEvents.add(new Parent_Organization_Event__e(
                        Organization_Id__c=AccRec.Dealership_Id__c,
                        Account_Salesforce_Id__c=AccRec.id, 
                        event_type__c = 'remove-parent-organization'));
                        idList.add(AccRec.Id);
                    }
                }   
            }     
            //If the Event variable is NOT empty then fire the Publisher 
            if(!ParentOrgEvents.isempty()){
                parentorganizationpublisher(ParentOrgEvents, idList);
            }
            
    }    
    public override void afterInsert(Map<Id,SObject> incomingMap){ 
        System.debug('stepped here 0');
        Map<Id,Account> newAccountMap = (Map<Id,Account>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Parent_Organization_Event__e> ParentOrgEvents = New List<Parent_Organization_Event__e>();
        System.debug('stepped here 1');
        //query for ID fields found in associated Accounts and add to newAcc
        Map<Id,Account> newAcc = new Map<Id,Account>([Select id, Dealership_Id__c, ParentId, Parent.Dealership_Id__c, RecordType.DeveloperName, 
        Parent.RecordType.DeveloperName From Account Where id in: newAccountMap.keySet()]);

        for(Account AccRec : newAcc.values()) {
            System.debug('stepped here 2');
            //Only publish Platform Event if associated Accounts are Standard and Dealership Ids are populated then create add parent organization event
            if(AccRec.ParentId != null && AccRec.RecordType.DeveloperName == 'Standard' && AccRec.Parent.RecordType.DeveloperName == 'Standard'&&
            AccRec.Dealership_Id__c != null && AccRec.Parent.Dealership_Id__c != null){
                
                // Create an instance of the event and store it in the Parent_Organization_Event__e variable 
                System.debug('stepped here 3');
                ParentOrgEvents.add(new Parent_Organization_Event__e(
                    Organization_Id__c=AccRec.Dealership_Id__c,
                    Account_Salesforce_Id__c=AccRec.id, 
                    Parent_Organization_Id__c=AccRec.Parent.Dealership_ID__c,
                    Parent_Account_Salesforce_Id__c=AccRec.ParentId,
                    event_type__c = 'add-parent-organization'));
                    idList.add(AccRec.Id);
                }
        //If the Event variable is NOT empty then fire the Publisher 
        }
        if(!ParentOrgEvents.isempty()){
            parentorganizationpublisher(ParentOrgEvents, idList);
        }
        
    }


    public static void parentorganizationpublisher(List<Parent_Organization_Event__e> ParentOrgEvents, List<Id> idList){ 
        // Call method to publish list of  Parent Organization events
        system.debug(ParentOrgEvents);
        system.debug(idList);
        system.debug(ParentOrgEvents.size());       
        List<Database.SaveResult> results = EventBus.publish(ParentOrgEvents);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Account Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){	
            Database.SaveResult Result = results[i];
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = 'Parent_Organization_Event__e';
            integrationObj.Integration_Name__c = 'ParentOrganizationChangeEvent';
            integrationObj.recordId__c = string.valueof(idlist[i]);
            integrationObj.Request_Message__c = String.valueof(ParentOrgEvents[i]);
            
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