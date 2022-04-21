public class SetContactRecordType extends TriggerInterface {
    
    Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Contact> newContacts = (List<Contact>) objectList;
        
            for ( Contact newCon : newContacts ) {
                if (LeadConversion.isConverting) {
                    newCon.RecordTypeId = acvuserRecordTypeId;
                    newCon.Creation_Source__c= 'Registration';
                    newCon.Policy_Email_Status__c= 'Policy Email Not Sent';
                    newCon.Active__c= false;
                }
            }
    }
    
}