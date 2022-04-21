public class EventPublisherUtility {

    public static boolean CauseFailure = false;

    public static void publishEvent(List<sObject> Events, List<Id> idList, String objectName, String integrationName, String genericName){ 
        
        // Call method to publish list of Contact events       
        List<Database.SaveResult> results = EventBus.publish(Events);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Contact Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){
            Database.SaveResult Result = results[i];  
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = objectName;
            integrationObj.Integration_Name__c = integrationName;
            integrationObj.recordId__c = string.valueof(idlist[i]);
            integrationObj.Request_Message__c = String.valueof(Events[i]);

            if (!result.isSuccess() || CauseFailure) {
                if(result.getErrors().size() > 0 || CauseFailure)
                        IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                        '' + integrationName + ': ' + genericName + ' Event failed to publish to event bus', 
                        SplunkHelper.LOGLEVEL.ERROR, integrationName, 
                        '' + genericName + ' Event failed to publish to event bus', 
                        genericName);
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