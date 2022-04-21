global class AffiliationChangeEvent extends TriggerInterface{
    //TODO: Remove Integration Results from publisher
    //TODO: Create Method for generating the Platform event record(pass it fields and event type as parameter)

    @testvisible
    
    public static boolean CauseFailure = false;

    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        Map<Id,Affiliation__c> newAffMap = (Map<Id,Affiliation__c>) incomingNewMap;
        Map<Id,Affiliation__c> oldAffMap = (Map<Id,Affiliation__c>) incomingOldMap;
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> AffiliationEvents = New List<Organization_Contact__e>();
        Map<Id, Set<String>> ChangedFieldsMap = ACVUtility.getChangedFields(newAffMap, oldAffMap, 'Affiliation__c');


        Map<id,Affiliation__c> affMap = new Map<Id, Affiliation__c>([Select id, id__c, Account__c, Account__r.Dealership_Id__c, 
        Contact__c, Contact__r.id__c, Contact__r.RecordTypeId, LastModifiedBy.Email From Affiliation__c Where id IN: newAffMap.keyset()]);
            
            for(Affiliation__c AffRec : newAffMap.values()) {

                //trigger where Contact fields have been updated    
                System.debug('affrec');
                System.debug(affMap);
                System.debug(AffRec);
                if((affMap.get(AffRec.id).Contact__r.RecordTypeId == acvuserRecordTypeId &&
                affMap.get(AffRec.id).Account__r.Dealership_Id__c != null &&
                affMap.get(AffRec.id).Contact__r.id__c != null) && ChangedFieldsMap.get(AffRec.Id) != null &&
                (ChangedFieldsMap.get(AffRec.Id).Contains('active__c') ||
                ChangedFieldsMap.get(AffRec.Id).Contains('primary_contact__c') ||
                ChangedFieldsMap.get(AffRec.Id).Contains('receive_email__c') ||
                ChangedFieldsMap.get(AffRec.Id).Contains('receive_push__c') ||
                ChangedFieldsMap.get(AffRec.Id).Contains('type__c')
                )){
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                AffiliationEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = affMap.get(AffRec.id).Account__r.Dealership_ID__c,
                    User_Id__c = affMap.get(AffRec.id).Contact__r.id__c,
                    Affiliation_Id__c = AffRec.id__c,
                    Active__c = AffRec.Active__c,
                    Primary_Contact__c = AffRec.primary_contact__c,
                    Receive_Email__c = AffRec.Receive_Email__c,
                    Receive_Push__c = AffRec.Receive_Push__c,
                    Type__c = AffRec.Type__c,
                    Changed_By_Sf_User_Id__c = AffRec.LastModifiedById,
                    Changed_By_Username__c = affMap.get(AffRec.Id).LastModifiedBy.Email,
                    event_type__c = 'update-affiliation'));
                    idList.add(AffRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AffiliationEvents.isempty()){
                EventPublisherUtility.publishEvent(AffiliationEvents, idList, 'Organization_Contact__e', 'AffiliationChangeEvent', 'Affiliation');
            }         
    }   
    

    public override void afterInsert(Map<Id,SObject> incomingMap){ 

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        Salesforce_Setting__mdt createdDateDelay = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Created Time in Minutes Delay' ];
        Salesforce_Setting__mdt delayInSeconds = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Platform Event Publish Delay in Seconds' ];

        Map<Id,Affiliation__c> newAffiliation = (Map<Id,Affiliation__c>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> AffiliationEvents = New List<Organization_Contact__e>();

        Map<id,Affiliation__c> affMap = new Map<Id, Affiliation__c>([Select id, id__c, Account__c, Account__r.Dealership_Id__c, 
        Contact__c, Contact__r.id__c, Contact__r.RecordTypeId, LastModifiedBy.Email, Account__r.CreatedDate, Contact__r.CreatedDate From Affiliation__c Where id IN: newAffiliation.keyset()]);

            //trigger anytime an Affilication is Created
            for(Affiliation__c AffRec : newAffiliation.values()) {
                Datetime start = System.Now().addSeconds(Integer.valueOf(delayInSeconds.Value__c));
                if(affMap.get(AffRec.id).Account__r.CreatedDate < System.Now().addMinutes(Integer.valueOf(createdDateDelay.Value__c)) || 
                affMap.get(AffRec.id).Contact__r.CreatedDate < System.Now().addMinutes(Integer.valueOf(createdDateDelay.Value__c))){
                    ACVUtility.delay(Integer.valueOf(delayInSeconds.Value__c));
                    System.debug('Delay successful');
                }
                // if Contact is an ACV User &&  
                if(affMap.get(AffRec.id).Contact__r.RecordTypeId == acvuserRecordTypeId &&
                affMap.get(AffRec.id).Account__r.Dealership_Id__c != null &&
                affMap.get(AffRec.id).Contact__r.id__c != null){
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                AffiliationEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = affMap.get(AffRec.id).Account__r.Dealership_ID__c,
                    User_Id__c = affMap.get(AffRec.id).Contact__r.id__c,
                    Affiliation_Id__c = AffRec.id__c,
                    Active__c = AffRec.Active__c,
                    Primary_Contact__c = AffRec.primary_contact__c,
                    Receive_Email__c = AffRec.Receive_Email__c,
                    Receive_Push__c = AffRec.Receive_Push__c,
                    Type__c = AffRec.Type__c,
                    Changed_By_Sf_User_Id__c = AffRec.LastModifiedById,
                    Changed_By_Username__c = affMap.get(AffRec.Id).LastModifiedBy.Email,
                    Event_Type__c = 'add-affiliation'));
                    idList.add(AffRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AffiliationEvents.isempty()){
                EventPublisherUtility.publishEvent(AffiliationEvents, idList, 'Organization_Contact__e', 'AffiliationChangeEvent', 'Affiliation');
            }
    }

    public override void beforeDelete(Map<Id,SObject> incomingMap){ 
        affiliationDeleteEvent(new Map<Id, Affiliation__c>([Select id, id__c, Account__c, Account__r.Dealership_Id__c, 
        Contact__c, Contact__r.id__c, Contact__r.RecordTypeId, LastModifiedBy.Email From Affiliation__c Where id IN: incomingMap.keyset()]));
    }

    public override void afterUndelete(Map<Id,SObject> incomingMap){ 

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

    
        Map<Id,Affiliation__c> newAffiliation = (Map<Id,Affiliation__c>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> AffiliationEvents = New List<Organization_Contact__e>();

        Map<id,Affiliation__c> affMap = new Map<Id, Affiliation__c>([Select id, id__c, Account__c, Account__r.Dealership_Id__c, 
        Contact__c, Contact__r.id__c, Contact__r.RecordTypeId, LastModifiedBy.Email From Affiliation__c Where id IN: newAffiliation.keyset()]);

            //trigger anytime an Affilication is Undeleted
            for(Affiliation__c AffRec : newAffiliation.values()) {
                // if Contact is an ACV User &&  
                if(affMap.get(AffRec.id).Contact__r.RecordTypeId == acvuserRecordTypeId &&
                affMap.get(AffRec.id).Account__r.Dealership_Id__c != null &&
                affMap.get(AffRec.id).Contact__r.id__c != null){
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                AffiliationEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = affMap.get(AffRec.id).Account__r.Dealership_ID__c,
                    User_Id__c = affMap.get(AffRec.id).Contact__r.id__c,
                    Affiliation_Id__c = AffRec.id__c,
                    Active__c = AffRec.Active__c,
                    Primary_Contact__c = AffRec.primary_contact__c,
                    Receive_Email__c = AffRec.Receive_Email__c,
                    Receive_Push__c = AffRec.Receive_Push__c,
                    Type__c = AffRec.Type__c,
                    Changed_By_Sf_User_Id__c = AffRec.LastModifiedById,
                    Changed_By_Username__c = affMap.get(AffRec.Id).LastModifiedBy.Email,
                    Event_Type__c = 'undelete-affiliation'));
                    idList.add(AffRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AffiliationEvents.isempty()){
                EventPublisherUtility.publishEvent(AffiliationEvents, idList, 'Organization_Contact__e', 'AffiliationChangeEvent', 'Affiliation');
            }
    }

    global static void affiliationDeleteEvent(Map<Id,SObject> incomingMap){
        System.debug('affiliationDeleteEvent');

        Map<Id,Affiliation__c> delAccountMap = (Map<Id,Affiliation__c>) incomingMap;
        
        System.debug(delAccountMap);

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        List<Id> idList = New List<Id>();
        List<Organization_Contact__e> AffiliationEvents = New List<Organization_Contact__e>();



            //trigger anytime an Affiliation is Deleted
            for(Affiliation__c AffRec : delAccountMap.values()) {
                // if Contact is an ACV User &&  
                if(AffRec.Contact__r.RecordTypeId == acvuserRecordTypeId &&
                AffRec.Account__r.Dealership_Id__c != null &&
                AffRec.Contact__r.id__c != null){
                // Create an instance of the event and store it in the Organization_Contact__e variable 
                AffiliationEvents.add(new Organization_Contact__e(    
                    Organization_Id__c = AffRec.Account__r.Dealership_ID__c,
                    User_Id__c = AffRec.Contact__r.id__c,
                    Affiliation_Id__c = AffRec.id__c,
                    Changed_By_Sf_User_Id__c = AffRec.LastModifiedById,
                    Changed_By_Username__c = AffRec.LastModifiedBy.Email,
                    Event_Type__c = 'delete-affiliation'));
                    idList.add(AffRec.Id);
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AffiliationEvents.isempty()){
                EventPublisherUtility.publishEvent(AffiliationEvents, idList, 'Organization_Contact__e', 'AffiliationChangeEvent', 'Affiliation');
            }

    }
}