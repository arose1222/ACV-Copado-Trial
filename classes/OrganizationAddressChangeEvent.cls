global class OrganizationAddressChangeEvent extends TriggerInterface{
    //TODO: Check for 12345-1234 in else if statement
    //TODO: change idlist to set
    //TODO: Get rid of integration results
    //TODO: Take out all re-occurring queries 
    

    @testvisible
    public static boolean CauseFailure = false;

    //this Prevent boolean is due to data.com causing random updates
    @testvisible
    public static boolean PreventRogueUpdate = false;

    public override void afterInsert(Map<Id,SObject> incomingMap){ 
        
        Salesforce_Setting__mdt createdDateDelay = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Created Time in Minutes Delay' ];
        Salesforce_Setting__mdt delayInSeconds = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Platform Event Publish Delay in Seconds' ];
        
        Map<Id,AssociatedLocation> newAddMap = (Map<Id,AssociatedLocation>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Address__e> AddressEvents = New List<Organization_Address__e>();
        String zipCode;
        String zipCodeExt;
        String state;
        String country;

        Map<id,AssociatedLocation> newAdd = new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, Organization_Address_Id__c, Inherited_Address_Id__c, ActiveTo, From_Historical_Load__c,
        Organization_Address_Guid__c, LocationId, Alternate_Address_Name__c, Location.VisitorAddressId, Location.VisitorAddress.Street, Location.VisitorAddress.City,
        Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, Location.VisitorAddress.Address_Guid__c, ParentRecord.Dealership_Id__c,
        Location.VisitorAddress.Latitude, Location.VisitorAddress.Longitude, LastModifiedBy.Email, ParentRecord.CreatedDate, TimeZone__c, Transportation_Primary_Contact__r.Id__c,
        Address_Subtype__c, After_hour_deliveries_allowed__c, Monday_Friday_Start_Time__c, Monday_Friday_End_Time__c, Saturday_Start_Time__c, Saturday_End_Time__c, Sunday_Start_Time__c, Sunday_End_Time__c
        From AssociatedLocation Where id IN: newAddMap.keyset()]);

            //trigger anytime an AssociatedLocation is Created
            for(AssociatedLocation Add : newAdd.values()) {
                Datetime start = System.Now().addSeconds(Integer.valueOf(delayInSeconds.Value__c));
                if(newAdd.get(Add.id).ParentRecord.CreatedDate < System.Now().addMinutes(Integer.valueOf(createdDateDelay.Value__c))){
                    ACVUtility.delay(Integer.valueOf(delayInSeconds.Value__c));
                }
                // if Parent has a Dealership Id  
                if(newAdd.get(Add.id).ParentRecord.Dealership_Id__c != null && Add.Organization_Address_Id__c != null){
                    if(newAdd.get(Add.id).Location.VisitorAddress.PostalCode.length() == 5){
                        zipCode = newAdd.get(Add.id).Location.VisitorAddress.PostalCode;
                    }
                    else{
                        String[] zip = newAdd.get(Add.id).Location.VisitorAddress.PostalCode.split('-');
                        zipCode = zip[0];
                        if(zip.size() > 1) {
                            zipCodeExt = zip[1];
                        }
                    }

                    Integer primaryContactId;
                    if (Add.Transportation_Primary_Contact__r.Id__c != null) {
                        primaryContactId = Add.Transportation_Primary_Contact__r.Id__c.isNumeric() ? Integer.valueOf(Add.Transportation_Primary_Contact__r.Id__c) : null;
                    }

                    if(Add.Inherited_Address_Id__c == false){
                        // Create an instance of the event and store it in the Organization_Address__e variable 
                        AddressEvents.add(new Organization_Address__e(    
                            Organization_Id__c = newAdd.get(Add.id).ParentRecord.Dealership_Id__c,
                            Org_Address_Id__c = Add.Organization_Address_Id__c,
                            Org_Address_Guid__c = Add.Organization_Address_Guid__c,
                            Address_Guid__c = newAdd.get(Add.id).Location.VisitorAddress.Address_Guid__c,
                            Type__c = Add.Type,
                            Notes__c = Add.Notes__c,
                            Address__c = newAdd.get(Add.id).Location.VisitorAddress.Street,
                            City__c = newAdd.get(Add.id).Location.VisitorAddress.City,
                            Zip_Code__c = zipCode,
                            Zip_Code_Ext__c = zipCodeExt,
                            State__c = newAdd.get(Add.id).Location.VisitorAddress.State.toUpperCase(),
                            Country__c = newAdd.get(Add.id).Location.VisitorAddress.Country.toUpperCase(),
                            From_Historical_Load__c = Add.From_Historical_Load__c,
                            Name__c = Add.Alternate_Address_Name__c,
                            Latitude__c = newAdd.get(Add.id).Location.VisitorAddress.Latitude,
                            Longitude__c = newAdd.get(Add.id).Location.VisitorAddress.Longitude,
                            Changed_By_Sf_User_Id__c = Add.LastModifiedById,
                            Changed_By_Username__c = newAdd.get(Add.id).LastModifiedBy.Email,
                            Address_Subtype__c = Add.Address_Subtype__c,
                            After_hour_deliveries_allowed__c = Add.After_hour_deliveries_allowed__c == 'Yes' ? true : false,
                            Monday_Friday_Start_Time__c = Add.Monday_Friday_Start_Time__c,
                            Monday_Friday_End_Time__c = Add.Monday_Friday_End_Time__c,
                            Saturday_Start_Time__c = Add.Saturday_Start_Time__c,
                            Saturday_End_Time__c = Add.Saturday_End_Time__c,
                            Sunday_Start_Time__c = Add.Sunday_Start_Time__c,
                            Sunday_End_Time__c = Add.Sunday_End_Time__c,
                            Timezone__c = Add.TimeZone__c,
                            Transportation_Primary_Contact__c = primaryContactId,
                            event_type__c = 'add-address')
                        );
                        idList.add(Add.Id);
                    }
                    if(Add.Inherited_Address_Id__c == true){
                        // Create an instance of the event and store it in the Organization_Address__e variable 
                        AddressEvents.add(new Organization_Address__e(    
                            Organization_Id__c = newAdd.get(Add.id).ParentRecord.Dealership_Id__c,
                            Org_Address_Id__c = Add.Organization_Address_Id__c,
                            Org_Address_Guid__c = Add.Organization_Address_Guid__c,
                            Address_Guid__c = newAdd.get(Add.id).Location.VisitorAddress.Address_Guid__c,
                            Type__c = Add.Type,
                            Notes__c = Add.Notes__c,
                            Address__c = newAdd.get(Add.id).Location.VisitorAddress.Street,
                            City__c = newAdd.get(Add.id).Location.VisitorAddress.City,
                            Zip_Code__c = zipCode,
                            Zip_Code_Ext__c = zipCodeExt,
                            State__c = newAdd.get(Add.id).Location.VisitorAddress.State.toUpperCase(),
                            Country__c = newAdd.get(Add.id).Location.VisitorAddress.Country.toUpperCase(),
                            Name__c = Add.Alternate_Address_Name__c,
                            Latitude__c = newAdd.get(Add.id).Location.VisitorAddress.Latitude,
                            Longitude__c = newAdd.get(Add.id).Location.VisitorAddress.Longitude,
                            Changed_By_Sf_User_Id__c = Add.LastModifiedById,
                            Changed_By_Username__c = newAdd.get(Add.id).LastModifiedBy.Email,
                            Address_Subtype__c = Add.Address_Subtype__c,
                            After_hour_deliveries_allowed__c = Add.After_hour_deliveries_allowed__c == 'Yes' ? true : false,
                            Monday_Friday_Start_Time__c = Add.Monday_Friday_Start_Time__c,
                            Monday_Friday_End_Time__c = Add.Monday_Friday_End_Time__c,
                            Saturday_Start_Time__c = Add.Saturday_Start_Time__c,
                            Saturday_End_Time__c = Add.Saturday_End_Time__c,
                            Sunday_Start_Time__c = Add.Sunday_Start_Time__c,
                            Sunday_End_Time__c = Add.Sunday_End_Time__c,
                            Timezone__c = Add.TimeZone__c,
                            Transportation_Primary_Contact__c = primaryContactId,
                            event_type__c = 'update-address')
                        );
                            
                        idList.add(Add.Id);
                    }
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AddressEvents.isempty()){
                // addresspublisher(AddressEvents, idList);
                EventPublisherUtility.publishEvent(AddressEvents, idList, 'Organization_Address__e', 'AddressChangeEvent', 'Address');
            }
    }

    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 
        if(PreventRogueUpdate){
            return;
        }
        Map<Id,AssociatedLocation> newAddMap = (Map<Id,AssociatedLocation>) incomingNewMap;
        Map<Id,AssociatedLocation> oldAddMap = (Map<Id,AssociatedLocation>) incomingOldMap;
        List<Id> idList = New List<Id>();
        List<Organization_Address__e> AddressEvents = New List<Organization_Address__e>();
        String zipCode;
        String zipCodeExt;
        Map<Id, Set<String>> ChangedFieldsMap = ACVUtility.getChangedFields(newAddMap, oldAddMap, 'AssociatedLocation');

        Map<id,AssociatedLocation> newAdd = new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, Organization_Address_Id__c, Location.VisitorAddressId, Inherited_Address_Id__c, ActiveTo,
        Organization_Address_Guid__c, LocationId, Location.VisitorAddress.Street, Location.VisitorAddress.City, Location.VisitorAddress.Latitude, Location.VisitorAddress.Longitude, Alternate_Address_Name__c,
        Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, Location.VisitorAddress.Address_Guid__c, ParentRecord.Dealership_Id__c, LastModifiedBy.Email,
        TimeZone__c, Address_Subtype__c, After_hour_deliveries_allowed__c, Monday_Friday_Start_Time__c, Monday_Friday_End_Time__c, Saturday_Start_Time__c, Transportation_Primary_Contact__r.Id__c,
        Saturday_End_Time__c, Sunday_Start_Time__c, Sunday_End_Time__c
        From AssociatedLocation Where id IN: newAddMap.keyset()]);
            //trigger anytime an AssociatedLocation is updated
            for(AssociatedLocation Add : newAdd.values()) {
                // if Parent has a Dealership Id, org address ID isn't NULL and org address id isn't being changed. Which is an odd bug thats causing duplicate update events to fire
                if(newAdd.get(Add.id).ParentRecord.Dealership_Id__c != null && Add.Organization_Address_Id__c != Null && !ChangedFieldsMap.get(Add.Id).Contains('organization_address_id__c')){
                    if(newAdd.get(Add.id)?.Location?.VisitorAddress?.PostalCode?.length() == 5){
                        zipCode = newAdd.get(Add.id).Location.VisitorAddress.PostalCode;
                    }
                    else {
                        String[] zip = newAdd.get(Add.id)?.Location?.VisitorAddress?.PostalCode?.split('-');
                        if(zip != null && !zip.isEmpty()){
                            zipCode = zip[0];
                            if(zip.size() > 1) {
                                zipCodeExt = zip[1];
                            }
                        }
                        else {
                            throw new CustomException('There was issue with the zip code, please verify the address or log an R&I ticket');
                        }
                    }
                    if(Add.Activeto == null){
                        Integer primaryContactId;
                        if (Add.Transportation_Primary_Contact__r.Id__c != null) {
                            primaryContactId = Add.Transportation_Primary_Contact__r.Id__c.isNumeric() ? Integer.valueOf(Add.Transportation_Primary_Contact__r.Id__c) : null;
                        }
                        // Create an instance of the event and store it in the Organization_Address__e variable 
                        AddressEvents.add(new Organization_Address__e(    
                            Organization_Id__c = newAdd.get(Add.id).ParentRecord.Dealership_Id__c,
                            Org_Address_Id__c = Add.Organization_Address_Id__c,
                            Org_Address_Guid__c = Add.Organization_Address_Guid__c,
                            Address_Guid__c = newAdd.get(Add.id).Location.VisitorAddress.Address_Guid__c,
                            Type__c = Add.Type,
                            Notes__c = Add.Notes__c,
                            Address__c = newAdd.get(Add.id).Location.VisitorAddress.Street,
                            City__c = newAdd.get(Add.id).Location.VisitorAddress.City,
                            Zip_Code__c = zipCode,
                            Zip_Code_Ext__c = zipCodeExt,
                            State__c = newAdd.get(Add.id).Location.VisitorAddress.State.toUpperCase(),
                            Country__c = newAdd.get(Add.id).Location.VisitorAddress.Country.toUpperCase(),
                            Name__c = Add.Alternate_Address_Name__c,
                            Latitude__c = newAdd.get(Add.id).Location.VisitorAddress.Latitude,
                            Longitude__c = newAdd.get(Add.id).Location.VisitorAddress.Longitude,
                            Changed_By_Sf_User_Id__c = Add.LastModifiedById,
                            Changed_By_Username__c = newAdd.get(Add.id).LastModifiedBy.Email,
                            Address_Subtype__c = Add.Address_Subtype__c,
                            After_hour_deliveries_allowed__c = Add.After_hour_deliveries_allowed__c == 'Yes' ? true : false,
                            Monday_Friday_Start_Time__c = Add.Monday_Friday_Start_Time__c,
                            Monday_Friday_End_Time__c = Add.Monday_Friday_End_Time__c,
                            Saturday_Start_Time__c = Add.Saturday_Start_Time__c,
                            Saturday_End_Time__c = Add.Saturday_End_Time__c,
                            Sunday_Start_Time__c = Add.Sunday_Start_Time__c,
                            Sunday_End_Time__c = Add.Sunday_End_Time__c,
                            Timezone__c = Add.TimeZone__c,
                            Transportation_Primary_Contact__c = primaryContactId,
                            event_type__c = 'update-address')
                        );
                        idList.add(Add.Id);
                    }

                    if(Add.Activeto != null){
                        // Create an instance of the event and store it in the Organization_Address__e variable 
                        AddressEvents.add(new Organization_Address__e(    
                            Organization_Id__c = newAdd.get(Add.id).ParentRecord.Dealership_Id__c,
                            Org_Address_Id__c = Add.Organization_Address_Id__c,
                            Org_Address_Guid__c = Add.Organization_Address_Guid__c,
                            Changed_By_Sf_User_Id__c = Add.LastModifiedById,
                            Changed_By_Username__c = newAdd.get(Add.id).LastModifiedBy.Email,
                            event_type__c = 'delete-address')
                        );
                        idList.add(Add.Id);
                    }
                }   
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AddressEvents.isempty()){
                // addresspublisher(AddressEvents, idList);
                EventPublisherUtility.publishEvent(AddressEvents, idList, 'Organization_Address__e', 'AddressChangeEvent', 'Address');
            }
    }      
   

    public override void beforeDelete(Map<Id,SObject> incomingMap){ 
        organizationAddressDeleteEvent(new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, Organization_Address_Id__c, Inherited_Address_Id__c, ActiveTo,
        Organization_Address_Guid__c, LocationId, Location.VisitorAddressId, Location.VisitorAddress.Street, Location.VisitorAddress.City, Alternate_Address_Name__c,  
        Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, Location.VisitorAddress.Address_Guid__c, ParentRecord.Dealership_Id__c,
        LastModifiedBy.Email            
        From AssociatedLocation Where id IN: incomingMap.keyset()]));
        
    }

    public override void afterUndelete(Map<Id,SObject> incomingMap){ 

        Map<Id,AssociatedLocation> newAddMap = (Map<Id,AssociatedLocation>) incomingMap;
        List<Id> idList = New List<Id>();
        List<Organization_Address__e> AddressEvents = New List<Organization_Address__e>();
        String zipCode;
        String zipCodeExt;

        Map<id,AssociatedLocation> newAdd = new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, Organization_Address_Id__c, Inherited_Address_Id__c, ActiveTo,
        Organization_Address_Guid__c, LocationId, Location.VisitorAddressId, Location.VisitorAddress.Street, Location.VisitorAddress.City,  
        Location.VisitorAddress.Longitude,  Location.VisitorAddress.Latitude,  Alternate_Address_Name__c,
        Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, Location.VisitorAddress.Address_Guid__c, ParentRecord.Dealership_Id__c, 
        LastModifiedBy.Email, TimeZone__c, Address_Subtype__c, After_hour_deliveries_allowed__c, Monday_Friday_Start_Time__c, Monday_Friday_End_Time__c, Saturday_Start_Time__c, Transportation_Primary_Contact__r.Id__c,
        Saturday_End_Time__c, Sunday_Start_Time__c, Sunday_End_Time__c
        From AssociatedLocation Where id IN: newAddMap.keyset()]);

            //trigger anytime an AssociatedLocation is Created
            for(AssociatedLocation Add : newAdd.values()) {
                // if Parent has a Dealership Id  
                if(newAdd.get(Add.id).ParentRecord.Dealership_Id__c != null && Add.Organization_Address_Id__c != null){
                    if(newAdd.get(Add.id).Location.VisitorAddress.PostalCode.length() == 5){
                        zipCode = newAdd.get(Add.id).Location.VisitorAddress.PostalCode;
                    }
                    else {
                        String[] zip = newAdd.get(Add.id).Location.VisitorAddress.PostalCode.split('-');
                        zipCode = zip[0];
                        if(zip.size() > 1) {
                            zipCodeExt = zip[1];
                        }
                    }

                    Integer primaryContactId;
                    if (Add.Transportation_Primary_Contact__r.Id__c != null) {
                        primaryContactId = Add.Transportation_Primary_Contact__r.Id__c.isNumeric() ? Integer.valueOf(Add.Transportation_Primary_Contact__r.Id__c) : null;
                    }
                    // Create an instance of the event and store it in the Organization_Address__e variable 
                    AddressEvents.add(new Organization_Address__e(    
                        Organization_Id__c = newAdd.get(Add.id).ParentRecord.Dealership_Id__c,
                        Org_Address_Id__c = Add.Organization_Address_Id__c,
                        Org_Address_Guid__c = Add.Organization_Address_Guid__c,
                        Address_Guid__c = newAdd.get(Add.id).Location.VisitorAddress.Address_Guid__c,
                        Type__c = Add.Type,
                        Notes__c = Add.Notes__c,
                        Address__c = newAdd.get(Add.id).Location.VisitorAddress.Street,
                        City__c = newAdd.get(Add.id).Location.VisitorAddress.City,
                        Zip_Code__c = zipCode,
                        Zip_Code_Ext__c = zipCodeExt,
                        State__c = newAdd.get(Add.id).Location.VisitorAddress.State.toUpperCase(),
                        Country__c = newAdd.get(Add.id).Location.VisitorAddress.Country.toUpperCase(),
                        Name__c = Add.Alternate_Address_Name__c,
                        Latitude__c = newAdd.get(Add.id).Location.VisitorAddress.Latitude,
                        Longitude__c = newAdd.get(Add.id).Location.VisitorAddress.Longitude,
                        Changed_By_Sf_User_Id__c = Add.LastModifiedById,
                        Changed_By_Username__c = newAdd.get(Add.id).LastModifiedBy.Email,
                        Address_Subtype__c = Add.Address_Subtype__c,
                        After_hour_deliveries_allowed__c = Add.After_hour_deliveries_allowed__c == 'Yes' ? true : false,
                        Monday_Friday_Start_Time__c = Add.Monday_Friday_Start_Time__c,
                        Monday_Friday_End_Time__c = Add.Monday_Friday_End_Time__c,
                        Saturday_Start_Time__c = Add.Saturday_Start_Time__c,
                        Saturday_End_Time__c = Add.Saturday_End_Time__c,
                        Sunday_Start_Time__c = Add.Sunday_Start_Time__c,
                        Sunday_End_Time__c = Add.Sunday_End_Time__c,
                        Timezone__c = Add.TimeZone__c,
                        Transportation_Primary_Contact__c = primaryContactId,
                        event_type__c = 'Undelete-address')
                    );
                    idList.add(Add.Id);
                }
            }
            //If the Event variable is NOT empty then fire the Publisher 
            if(!AddressEvents.isempty()){
                // addresspublisher(AddressEvents, idList);
                EventPublisherUtility.publishEvent(AddressEvents, idList, 'Organization_Address__e', 'AddressChangeEvent', 'Address');
            }
    }

    global static void organizationAddressDeleteEvent(Map<Id,SObject> incomingMap){

        List<Id> idList = New List<Id>();
        List<Organization_Address__e> AddressEvents = New List<Organization_Address__e>();
        String zipCode;
        String zipCodeExt;

        Map<id,AssociatedLocation> newAdd = (Map<Id,AssociatedLocation>)incomingMap;

        //trigger anytime an AssociatedLocation is Created
        for(AssociatedLocation Add : newAdd.values()) {
            // if Parent has a Dealership Id  
            if(newAdd.get(Add.id).ParentRecord.Dealership_Id__c != null && Add.Organization_Address_Id__c != null){
                if(Add.Inherited_Address_Id__c == false || Add.ActiveTo == null){
                // Create an instance of the event and store it in the Organization_Address__e variable 
                AddressEvents.add(new Organization_Address__e(    
                    Organization_Id__c = newAdd.get(Add.id).ParentRecord.Dealership_Id__c,
                    Org_Address_Id__c = Add.Organization_Address_Id__c,
                    Org_Address_Guid__c = Add.Organization_Address_Guid__c,
                    Changed_By_Sf_User_Id__c = Add.LastModifiedById,
                    Changed_By_Username__c = newAdd.get(Add.id).LastModifiedBy.Email,
                    event_type__c = 'delete-address'));
                    idList.add(Add.Id);
                }
            }   
        }
        if(!AddressEvents.isempty()){
            // addresspublisher(AddressEvents, idList);
            EventPublisherUtility.publishEvent(AddressEvents, idList, 'Organization_Address__e', 'AddressChangeEvent', 'Address');
        }
    }
}