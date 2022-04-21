public class ContactAccountChangeError extends TriggerInterface{
    //TODO: Make this a validation rule 
    
    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();

    public override void beforeUpdate(Map<Id, Sobject> oldMap, Map<Id, Sobject> newMap){

        Map<Id, Contact> newConMap = (Map<Id, Contact>)newMap;
        Map<Id, Contact> oldConMap = (Map<Id, Contact>)oldMap;
        
            for ( Contact newCon : newConMap.values() ) {
                //Upon update of Contact Record, trigger an error if the Account field is already populated and attempting to change
                if (newCon.RecordTypeId == contactRecordTypeId && 
                    oldConMap.get(newCon.id).AccountId != newCon.AccountId) {
                        newCon.adderror('Cannot change Contact account after creation. If this Contact record was created in error, please de-activiate this record and create a new Contact with the correct Account association.');
                }
            }
    }
}