public class ContactUniqueIdGeneration extends TriggerInterface {
    //TODO: Pull out common parts of the Code to a method

    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
    Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    public override void afterInsert(List<sObject> objectList) {
    
        List<Contact> newContacts = (List<Contact>) objectList;
        Map<id, String> idMap = new Map<id, String>();
        List<Contact> updateList = new List<Contact>();
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