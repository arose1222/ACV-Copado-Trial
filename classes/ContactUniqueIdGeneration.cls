public class ContactUniqueIdGeneration extends TriggerInterface {
    //TODO: Pull out common parts of the Code to a method

    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
    Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
    Salesforce_Setting__mdt auto_inc_jump = Salesforce_Setting__mdt.getInstance('uat_users_unique_id_jump');
    String environmentName = ACVUtility.getEnvironmentName();

    public override void afterInsert(List<sObject> objectList) {
    
        List<Contact> newContacts = (List<Contact>) objectList;
        Map<id, String> idMap = new Map<id, String>();
        List<Contact> updateList = new List<Contact>();
        /* commented as part of IO-1646 - refactoring code, querying is not needed
        for(Contact newCons : newContacts){
            idMap.put(newCons.id, newCons.Auto_Inc_Id__c);
        }
        List<Contact> conLst = new List<Contact>([Select id, Auto_Inc_Id__c, id__c, Dealership_Contact_Id__c,
        RecordTypeId From Contact Where id IN: newContacts]);

            for ( Contact newCon : conLst ) {
                if (string.isBlank(newCon.Id__c) && newCon.RecordTypeId == acvuserRecordTypeId) {
                    newCon.id__c = idMap.get(newCon.id);
                    updateList.add(newCon);
                }
                if (string.isBlank(newCon.Dealership_Contact_Id__c) && newCon.RecordTypeId == contactRecordTypeId) {
                    newCon.Dealership_Contact_Id__c = idMap.get(newCon.id);
                    updateList.add(newCon);
                }
            }*/
            for ( Contact newCon : newContacts ) {
                if(string.isBlank(newCon.Id__c) && newCon.RecordTypeId == acvuserRecordTypeId && environmentName == 'UAT') {	
                    // newCon.id__c = String.valueOf(Integer.valueOf(idMap.get(newCon.id)) + Integer.valueOf(auto_inc_jump.Value__c));	
                    String id = String.valueOf(Integer.valueOf(newCon.Auto_Inc_Id__c) + Integer.valueOf(auto_inc_jump.Value__c));
                    updateList.add(new Contact(Id = newCon.Id, Id__c = id));
                }
                if (string.isBlank(newCon.Id__c) && newCon.RecordTypeId == acvuserRecordTypeId && environmentName !='UAT') {
                    updateList.add(new Contact(Id = newCon.Id, Id__c = newCon.Auto_Inc_Id__c));
                }
                if (string.isBlank(newCon.Dealership_Contact_Id__c) && newCon.RecordTypeId == contactRecordTypeId) {
                    updateList.add(new Contact(Id = newCon.Id, Dealership_Contact_Id__c = newCon.Auto_Inc_Id__c));
                }
            }
            try{
                if(!updateList.isempty()){
                    update updateList;
                }
            }
            catch(Exception e){
                IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                    'ContactUniqueIdGeneration: Get Contact Id failure: '+e.getStackTraceString(), 
                    SplunkHelper.LOGLEVEL.ERROR, 'ContactUnqiueIdGeneration', 
                    e.getMessage(), 
                    'Contact');
                    //TODO: Throw Fatal error after Splunk log
            }
    }

    public override void afterUpdate(List<Sobject> oldList, List<Sobject> newlist){
    
        List<Contact> newContacts = (List<Contact>) newlist;
        Map<id, String> idMap = new Map<id, String>();
        List<Contact> updateList = new List<Contact>();
        /* commented as part of IO-1646 - refactoring code, querying is not needed
        for(Contact newCons : newContacts){
            idMap.put(newCons.id, newCons.Auto_Inc_Id__c);
        }
        List<Contact> conLst = new List<Contact>([Select id, Auto_Inc_Id__c, id__c, Dealership_Contact_Id__c,
        RecordTypeId From Contact Where id IN: newContacts]);

            for ( Contact newCon : conLst ) {
                if (string.isBlank(newCon.Id__c) && newCon.RecordTypeId == acvuserRecordTypeId) {
                    newCon.id__c = idMap.get(newCon.id);
                    updateList.add(newCon);
                }
                if (string.isBlank(newCon.Dealership_Contact_Id__c) && newCon.RecordTypeId == contactRecordTypeId) {
                    newCon.Dealership_Contact_Id__c = idMap.get(newCon.id);
                    updateList.add(newCon);
                }
            }*/
            for ( Contact newCon : newContacts ) {
                if(string.isBlank(newCon.Id__c) && newCon.RecordTypeId == acvuserRecordTypeId && environmentName == 'UAT') {	
                    // newCon.id__c = String.valueOf(Integer.valueOf(idMap.get(newCon.id)) + Integer.valueOf(auto_inc_jump.Value__c));	
                    String id = String.valueOf(Integer.valueOf(newCon.Auto_Inc_Id__c) + Integer.valueOf(auto_inc_jump.Value__c));
                    updateList.add(new Contact(Id = newCon.Id, Id__c = id));	
                }
                if (string.isBlank(newCon.Id__c) && newCon.RecordTypeId == acvuserRecordTypeId && environmentName != 'UAT') {
                    updateList.add(new Contact(Id = newCon.Id, Id__c = newCon.Auto_Inc_Id__c));
                }
                if (string.isBlank(newCon.Dealership_Contact_Id__c) && newCon.RecordTypeId == contactRecordTypeId) {
                    updateList.add(new Contact(Id = newCon.Id, Dealership_Contact_Id__c = newCon.Auto_Inc_Id__c));
                }
            }          
            try{
                if(!updateList.isempty()){
                    update updateList;
                }
            }
            catch(Exception e){
                IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                    'ContactUniqueIdGeneration: Get Contact Id failure: '+e.getStackTraceString(), 
                    SplunkHelper.LOGLEVEL.ERROR, 'ContactUnqiueIdGeneration', 
                    e.getMessage(), 
                    'Contact');
            }
    }
}