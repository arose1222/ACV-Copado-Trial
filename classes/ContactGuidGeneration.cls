public class ContactGuidGeneration extends TriggerInterface {
    //TODO: Use utility method for recordType checks

    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
    Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Contact> newContacts = (List<Contact>) objectList;
        
            for ( Contact newCon : newContacts ) {
                if (string.isBlank(newCon.Contact_Guid__c	) && (newCon.RecordTypeId == contactRecordTypeId ||  newCon.RecordTypeId == acvuserRecordTypeId) 
                && (newCon.Id__c != null || newCon.Dealership_Contact_Id__c != null)) {
                    newCon.Contact_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Contact> newConList = (List<Contact>)newlist;
        
            for ( Contact newCon : newConList ) {
                if (string.isBlank(newCon.Contact_Guid__c	) && (newCon.RecordTypeId == contactRecordTypeId ||  newCon.RecordTypeId == acvuserRecordTypeId) 
                && (newCon.Id__c != null || newCon.Dealership_Contact_Id__c != null)) {
                    newCon.Contact_Guid__c = ACVUtility.NewGuid(); 
                }
            }
    }
}