global class DealershipContactChangeEvent extends TriggerInterface{
    //TODO: Pull out add to PE record method
    //TODO: Remvoe integration results

    @testvisible
    
    public static boolean CauseFailure = false;
   
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();

        Map<Id,Contact> newContactMap = (Map<Id,Contact>) incomingNewMap;
        Map<Id,Contact> oldContactMap = (Map<Id,Contact>) incomingOldMap;
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> DealerContactEvents = New List<Organization_Contact__e>();
        String fullName;
        Map<Id, Set<String>> ChangedFieldsMap = ACVUtility.getChangedFields(newContactMap, oldContactMap, 'Contact');

        Map<id,Contact> NewConMap = new Map<Id, Contact>([Select id, AccountId, Account.Dealership_Id__c, LastModifiedBy.Email 
        From Contact Where id IN: newContactMap.keyset()]);
            
            for(Contact ConRec : newContactMap.values()) {

                //add Middle Name if its not null
                if(ConRec.MiddleName == null && ConRec.FirstName == null){
                    fullName = ConRec.LastName;
                }
                else if(ConRec.MiddleName == null){
                    fullName = ConRec.FirstName + ' ' + ConRec.LastName; 
                }
                else{
                    fullName = ConRec.FirstName + ' ' + ConRec.MiddleName + ' ' + ConRec.LastName; 
                }

                //trigger where Contact fields have been updated    
                if(ConRec.RecordTypeId == contactRecordTypeId && ChangedFieldsMap.get(ConRec.Id) != null && 
                (ChangedFieldsMap.get(ConRec.Id).Contains('email') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('active__c') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('lastname') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('firstname') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('middlename') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('phone') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('title') ||
                ChangedFieldsMap.get(ConRec.Id).Contains('title_2__c') 
                )){
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                    DealerContactEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = NewConMap.get(ConRec.id).Account.Dealership_ID__c,
                    Contact_Id__c = ConRec.Dealership_Contact_Id__c, 
                    Contact_Guid__c = ConRec.Contact_Guid__c,
                    Active__c = ConRec.Active__c,
                    Email__c = ConRec.Email,
                    Full_Name__c = fullName,
                    Phone__c = ConRec.Phone,
                    Title__c = ConRec.Title,
                    Title_Legacy__c = ConRec.Title_2__c,
                    Changed_By_SF_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = NewConMap.get(ConRec.Id).LastModifiedBy.Email,
                    event_type__c = 'update-contact'));
                    idList.add(ConRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!DealerContactEvents.isempty()){
                EventPublisherUtility.publishEvent(DealerContactEvents, idList, 'Organization_Contact__e', 'DealershipContactChangeEvent', 'DealershipContact');
            }         
    }   
    

    public override void afterInsert(Map<Id,SObject> incomingMap){ 

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();

    
        Map<Id,Contact> newContact = (Map<Id,Contact>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> DealerContactEvents = New List<Organization_Contact__e>();
        String fullName;


        Map<id,Contact> ConMap = new Map<Id, Contact>([Select id, AccountId, Account.Dealership_Id__c,  Dealership_Contact_Id__c, Contact_Guid__c, Account.CreatedDate,
        Active__c, Email, Phone, Title, Title_2__c, FirstName, MiddleName, LastName, LastModifiedBy.Email From Contact Where id IN: newContact.keyset()]);

            //trigger anytime a Contact(Dealership Contact) is Created
            for(Contact ConRec : newContact.values()) {
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                if(ConRec.RecordTypeId == contactRecordTypeId){
                    //add Middle Name if its not null
                    if(ConMap.get(ConRec.id).MiddleName == null && ConMap.get(ConRec.id).FirstName == null){
                        fullName = ConMap.get(ConRec.id).LastName;
                    }
                    else if(ConMap.get(ConRec.id).MiddleName == null){
                        fullName = ConMap.get(ConRec.id).FirstName + ' ' + ConMap.get(ConRec.id).LastName; 
                    }
                    else{
                        fullName = ConMap.get(ConRec.id).FirstName + ' ' + ConMap.get(ConRec.id).MiddleName + ' ' + ConMap.get(ConRec.id).LastName; 
                    }
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                    DealerContactEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = ConMap.get(ConRec.id).Account.Dealership_ID__c,
                    Contact_Id__c = ConMap.get(ConRec.id).Dealership_Contact_Id__c, 
                    Contact_Guid__c = ConMap.get(ConRec.id).Contact_Guid__c,
                    Active__c = ConMap.get(ConRec.id).Active__c,
                    Email__c = ConMap.get(ConRec.id).Email,
                    Full_Name__c = fullName,
                    Phone__c = ConMap.get(ConRec.id).Phone,
                    Title__c = ConMap.get(ConRec.id).Title,
                    Title_Legacy__c = ConMap.get(ConRec.id).Title_2__c,
                    Changed_By_SF_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = ConMap.get(ConRec.Id).LastModifiedBy.Email,
                    Event_Type__c = 'add-contact'));
                    idList.add(ConRec.Id);
                }
                
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!DealerContactEvents.isempty()){
                EventPublisherUtility.publishEvent(DealerContactEvents, idList, 'Organization_Contact__e', 'DealershipContactChangeEvent', 'DealershipContact');
            }
    }

    public override void beforeDelete(Map<Id,SObject> incomingMap){ 
        dealershipContactDeleteEvent(new Map<Id, Contact>([Select id, AccountId, Account.Dealership_Id__c, LastModifiedBy.Email, RecordTypeId, Contact_Guid__c, Dealership_Contact_Id__c
        From Contact Where id IN: incomingMap.keyset()]));
    }

    public override void afterUndelete(Map<Id,SObject> incomingMap){ 

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();

    
        Map<Id,Contact> newContact = (Map<Id,Contact>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> DealerContactEvents = New List<Organization_Contact__e>();
        String fullName;


        Map<id,Contact> ConMap = new Map<Id, Contact>([Select id, AccountId, Account.Dealership_Id__c, LastModifiedBy.Email
        From Contact Where id IN: newContact.keyset()]);

            //trigger anytime a Contact(Dealership Contact) is Created
            for(Contact ConRec : newContact.values()) {
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                if(ConRec.RecordTypeId == contactRecordTypeId){
                    //add Middle Name if its not null
                    if(ConRec.MiddleName == null && ConRec.FirstName == null){
                        fullName = ConRec.LastName;
                    }
                    else if(ConRec.MiddleName == null){
                        fullName = ConRec.FirstName + ' ' + ConRec.LastName; 
                    }
                    else{
                        fullName = ConRec.FirstName + ' ' + ConRec.MiddleName + ' ' + ConRec.LastName; 
                    }
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                    DealerContactEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = ConMap.get(ConRec.id).Account.Dealership_ID__c,
                    Contact_Id__c = ConRec.Dealership_Contact_Id__c, 
                    Contact_Guid__c = ConRec.Contact_Guid__c,
                    Active__c = ConRec.Active__c,
                    Email__c = ConRec.Email,
                    Full_Name__c = fullName,
                    Phone__c = ConRec.Phone,
                    Title__c = ConRec.Title,
                    Title_Legacy__c = ConRec.Title_2__c,
                    Changed_By_SF_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = ConMap.get(ConRec.Id).LastModifiedBy.Email,
                    Event_Type__c = 'undelete-contact'));
                    idList.add(ConRec.Id);
                }
                
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!DealerContactEvents.isempty()){
                EventPublisherUtility.publishEvent(DealerContactEvents, idList, 'Organization_Contact__e', 'DealershipContactChangeEvent', 'DealershipContact');
            }
    }

    global static void dealershipContactDeleteEvent(Map<Id,SObject> incomingMap){

        System.debug('dealershipContactDeleteEvent');

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
    
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> DealerContactEvents = New List<Organization_Contact__e>();


        Map<id,Contact> ConMap = (Map<Id, Contact>)incomingMap;

            //trigger anytime a Contact(Dealership Contact) is Deleted
            for(Contact ConRec : ConMap.values()) {
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                if(ConRec.RecordTypeId == contactRecordTypeId){
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                    DealerContactEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = ConMap.get(ConRec.id).Account.Dealership_ID__c,
                    Contact_Id__c = ConRec.Dealership_Contact_Id__c, 
                    Contact_Guid__c = ConRec.Contact_Guid__c,
                    Changed_By_SF_User_Id__c = ConRec.LastModifiedById,
                    Changed_By_Username__c = ConMap.get(ConRec.Id).LastModifiedBy.Email,
                    Event_Type__c = 'delete-contact'));
                    idList.add(ConRec.Id);
                }
                
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!DealerContactEvents.isempty()){
                EventPublisherUtility.publishEvent(DealerContactEvents, idList, 'Organization_Contact__e', 'DealershipContactChangeEvent', 'DealershipContact');
            }
    }
}