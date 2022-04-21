/**
 * @description A supporting component that is used by DisplayRelatedFields LWC. 
 * 				DisplayRelatedFields LWC is used to display related fields in the specified order.
 * 				Requirements: https://acvauctions.atlassian.net/browse/TDO-473
 * 
 * @author Manmeet Vaseer
 * @date 09/24/2021
 * 
 */
public class DisplayRelatedFieldsController {
    
    /**
     * It is called by DisplayRelatedFields LWC. It converts SOQL output to JSON that is consumed by the LWC.
     * This uses Display_Related_Fields__mdt custom metadata.
     * Action_Type__c - This informs what type of action to be executed. Currently, only SOQL action is supported i.e. it will execute the SOQL specified in Action__c.
     * Action__c - Execute the SOQL specified in this field. The query ':id:' token will be replace by the record id where the LWC component is being displayed.
     * 			   All fields in the query must be relative to the object page where the LWC is being displayed. That is, if you have LWC configured on the Quality Control record page
     * 			   then the query should have 'FROM Quality_Control__c' and all the fields used in the query should be from the Quality_Control__c object.
     * Fields_Display_Order__c - After the execution of the Action__c/SOQL, the result is converted into JSON and the properties/fields in the JSON are ordered specified in this field.
     * 							 It is a comma separated list of name=value pairs e.g. Odometer=Case__r.Odometer_Reading__c, Payment Status=Case__r.Payment_Status__c
     * 
     * @param recId Record Id of an object/record where the LWC is being loaded.
     * @param metadataTypeRecName You can have multiple DisplayRelatedFields LWC on the same page. During configuration of the LWC, you have to specify 
     * 							  the record unique name (Custom Metadata Record Name/DeveloperName) to use to load this component.
     *                           
     * @return JSON in order specified by Fields_Display_Order__c field in the Display_Related_Fields__mdt Custom Metadata Type.
     * Retruned JSON Example:
     * [
			{"value":"0031100001rJrLhAAK","label":"Contact Id"},
			{"value":"ee949fa1-59da-4fbf-91d1-4884d9a29321@test.com","label":"Contact Email"},
			{"value":"00111000029EBxUAAW","label":"Seller Id"},
			{"value":"7161234560","label":"Seller Phone"},
			{"value":"12 Test St","label":"Selling Billing Street"}
	 * ]
     * 
     */
    @AuraEnabled(cacheable=true)    
    public static String getFieldLabelValuePairs(String recId, String metadataTypeRecName)	{
        List<Payload> payloadList = new List<Payload>(); // return values
        
        // Retrieve the custom metadata record by name that was used during LWC configuration.
        List<Display_Related_Fields__mdt> fdyMD = [SELECT Action_Type__c, Action__c, Fields_Display_Order__c FROM Display_Related_Fields__mdt WHERE DeveloperName = :metadataTypeRecName];
        if(fdyMD != null && fdyMD.size() > 0) {
            // Parse the Fields_Display_Order__c field.
            FieldNameLabel fieldNameLabelVO = getFieldsNameValue(fdyMD[0].Fields_Display_Order__c);
            
            if(fdyMD[0].Action_Type__c == 'SOQL')	{
                // Execute SOQL and generate the Payload.
				payloadList = soqlActionType(fdyMD, recId, fieldNameLabelVO);
            }
            else if(fdyMD[0].Action_Type__c == 'Apex Class')	{
                // TODO
                // A class that will implement DisplayRelatedFieldsInterface, which will return JSON in the order specified by 
                // Fields_Display_Order__c field in the Display_Related_Fields__mdt Custom Metadata Type.
            }
        }
        
        return JSON.serialize(payloadList);
    }
    
    /**
     * Execute SOQL and return the Payload.
     * 
     */
    private static List<Payload> soqlActionType(List<Display_Related_Fields__mdt> fdyMD, String recId, FieldNameLabel fieldNameLabelVO)	{
        List<Payload> payloadList = new List<Payload>();
        
        String query = fdyMD[0].Action__c; // get the SOQL query that will be executed.
        if(!String.isBlank(query))	{
            // Replace the ':id:' token with the record id from the page where the LWC is being displayed
            query = query.replace(':id:', recId);
            List<SObject> sObjs = Database.query(query);
            if(sObjs != null && sObjs.size() > 0)	{
                // As we fetch the record by ID so expecting only one recrod from the query execution.
                SObject sObj = sObjs[0];
                
                // Order the fields and get the corresponding value of each field (if available).
                for(String fieldAPIName : fieldNameLabelVO.orderedAPIFieldNames)	{
                    String value;
                    String label = fieldNameLabelVO.fieldAPINameLabelMap.get(fieldAPIName);
                    
                    // Get the corresponding value of the label.
                    // Also, check if the query used the parent.child relationships e.g. Case__r.Account.BillingPostalCode
                    // Upto 3 level deep parent.child relationship supported for now.
                    if(fieldAPIName.contains('.'))	{
                        List<String> splitApiName = fieldAPIName.split('\\.');
                        if(splitApiName.size() == 2)		value = String.valueOf(sObj.getSObject(splitApiName[0])?.get(splitApiName[1]));
                        else if(splitApiName.size() == 3)	value = String.valueOf(sObj.getSObject(splitApiName[0])?.getSObject(splitApiName[1])?.get(splitApiName[2]));
                        else if(splitApiName.size() == 4)	value = String.valueOf(sObj.getSObject(splitApiName[0])?.getSObject(splitApiName[1])?.getSObject(splitApiName[2])?.get(splitApiName[3]));
                    }
                    else value = String.valueOf(sObj.get(fieldAPIName)); // no parent.child relationship used
                    
                    // Create the payload for Label=Value.
                    Payload pl = new Payload();
                    pl.label = label;
                    pl.value = value;
                    payloadList.add(pl);                            
                } // for fieldAPIName
            }
        }        
        
        return payloadList;
    }
    
    /**
     * Parse the Fields_Display_Order__c field in the Custom Metadata Type.
     * 
     * It is a comma separated list of name=value pairs e.g. Odometer=Case__r.Odometer_Reading__c, Payment Status=Case__r.Payment_Status__c
     * 
     */
    private static FieldNameLabel getFieldsNameValue(String fieldsDisplayOrder)	{
        FieldNameLabel fieldNameLabelRet = new FieldNameLabel();
        
        if(!String.isBlank(fieldsDisplayOrder))	{
            // Split a list of Label=API_Name by Comma
        	List<String> splitByComma = fieldsDisplayOrder.split(',');
            for(String pair : splitByComma)	{
                if(!String.isBlank(pair.trim()))	{
                    // Split Label=API_Name
                    List<String> splitLabelAPIName = pair.split('=');
                    if(splitLabelAPIName != null && splitLabelAPIName.size() > 0) {
                        fieldNameLabelRet.orderedLabels.add(splitLabelAPIName[0].trim());
                    }
                    
                    if(splitLabelAPIName != null && splitLabelAPIName.size() > 1) {
                        fieldNameLabelRet.orderedAPIFieldNames.add(splitLabelAPIName[1].trim());
                        fieldNameLabelRet.fieldAPINameLabelMap.put(splitLabelAPIName[1].trim(), splitLabelAPIName[0].trim()); // Field API Name : Field Label
                    }
                }
            }            
        }
        
        return fieldNameLabelRet;
    }
    
    public class FieldNameLabel	{
        public List<String> orderedAPIFieldNames = new List<String>();
        public List<String> orderedLabels = new List<String>();
        public Map<String, String> fieldAPINameLabelMap = new Map<String, String>();
    }
    
    public class Payload	{
        public String label;
        public String value;
    }

}