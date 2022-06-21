/**
 * @description This service is used by Datahub Title Consumer, which is written in Python (https://github.com/acv-auctions/salesforce-titles-consumer).
 * 
 * The Python Title Consumer call this service to create new Title Cases and update existing Title Cases in Salesforce.
 * This service does not process any historical load. The historical events are represented by fromHistoricalLoad=true.
 * This service could process multiple events i.e. it could create/update multiple records in Salesforce passed through JSON by the Title Consumer.
 * 
 * Requirements:
 * https://acvauctions.atlassian.net/browse/TDO-355
 * https://acvauctions.atlassian.net/browse/TDO-374
 * 
 * Below is a sample Python Title Consumer event passed to this service:
 [
    {
        "entity": "title",
        "version": "v2.0",
        "eventId": "24cd625f-9d44-403d-8835-c708926886ed",
        "correlationId": "8334c9b3-4f62-4583-b8eb-cee2c82336c1",
        "eventType": "created",
        "timestamp": "2021-10-20T15:50:02.3015162Z",
        "domain": "title",
        "fromHistoricalLoad": false,
        "titleId": "e0442543-561a-4d15-b00f-e6c21e4b3b01",
        "legacyTitleId": 272730,
        "titleIdType": "int",
        "legacyAuctionId": 346712,
        "titleAbsent": false,
        "sellerUserId": 901765,
        "buyerUserId": 567321,
        "sellerOrganizationId": 890321,
        "buyerOrganizationId": 678456,
        "digitalTitle": true,
        "vehicle": {
            "make": "jeep",
            "model": "wrangler",
            "odometer": 100000,
            "vin": "1J4F4C9SX5P328524",
            "year": 2005
        },
        "payment": {
            "method": "afc",
            "status": "pending"
        }
    }
]
 * 
 * @author Manmeet Vaseer
 * @date 11/08/2021
 */ 
@RestResource(urlMapping='/titleService')
global class TitleService {

    static public String TITLE_ID_TYPE_INT = 'int';
    
    // Types of Events.
    static public String EVENT_CREATED = 'created';
    static public String EVENT_UPDATED = 'updated';
    static public String EVENT_DELETED = 'deleted';
    static public String EVENT_UNDELETED = 'undeleted';
    static public String DEALERSHIP_NOTE_ADDED = 'note-added'; // only seller dealership notes are added
    
    /*
     * Entry point for the Python Title Consumer. The Title Consumer will pass the JSON message that will have
     * a list of events to Create or Update title cases in Salesforce.
     * 
     * @param titleList A list of Event JSON message converted into a list of TitleDefinition object.
     * 
     */
    @httpPost
    global static CreateNewTitleCaseResponse processTitles(List<TitleDefinition> titleList){
        
        CreateNewTitleCaseResponse res = new CreateNewTitleCaseResponse();
        try {
            // List to hold specific types of events
            List<TitleDefinition> createdEvents = new List<TitleDefinition>();
            List<TitleDefinition> updatedEvents = new List<TitleDefinition>();
            List<TitleDefinition> deletedEvents = new List<TitleDefinition>();
            List<TitleDefinition> undeletedEvents = new List<TitleDefinition>();
            List<TitleDefinition> dealershipNoteAddedEvents = new List<TitleDefinition>();
            
            /* 
             * ACV Titles External Id is the link between Events and the records in Salesforce.
             * We will use the ACV Titles External Id to find the Salesforce Ids, if it is an existing record.
             */
            List<String> acvTitlesExternalIds = new List<String>();
            
            // Process all the Events and populate the event specific list.
            for(TitleDefinition aTitle : titleList)	{
                if(aTitle.fromHistoricalLoad == false)	{ // ignore events from Retro/Historic load.
                    if(aTitle.metadata.eventType == EVENT_CREATED)	createdEvents.add(aTitle);
                    else if(aTitle.metadata.eventType == EVENT_UPDATED)	updatedEvents.add(aTitle);
                    else if(aTitle.metadata.eventType == EVENT_DELETED)	deletedEvents.add(aTitle);
                    else if(aTitle.metadata.eventType == EVENT_UNDELETED)	undeletedEvents.add(aTitle);
                    
                    /*
                     * ACV Titles External Id could be either GUID (new) or INT (old) type.
                     * ACV Titles External Id will be either in titleId (guid) or legacyTitleId (int) based on the titleIdType (guid/int).
                     */
                    String acvTitlesExternalId = aTitle.titleId;
                    if(aTitle.titleIdType == TITLE_ID_TYPE_INT)	{
                        acvTitlesExternalId = String.valueOf(aTitle.legacyTitleId);
                    }
                    acvTitlesExternalIds.add(acvTitlesExternalId);
                }
                else if(aTitle.metadata.eventType == DEALERSHIP_NOTE_ADDED)	{
                    dealershipNoteAddedEvents.add(aTitle);
                    
                    /*
                     * ACV Titles External Id could be either GUID (new) or INT (old) type.
                     * ACV Titles External Id will be either in titleId (guid) or legacyTitleId (int) based on the titleIdType (guid/int).
                     */
                    String acvTitlesExternalId = aTitle.titleId;
                    if(aTitle.titleIdType == TITLE_ID_TYPE_INT)	{
                        acvTitlesExternalId = String.valueOf(aTitle.legacyTitleId);
                    }
                    acvTitlesExternalIds.add(acvTitlesExternalId);
                }
            }            
                        
            if(createdEvents.size() > 0)	createTitles(createdEvents);
            if(updatedEvents.size() > 0)	updateTitles(updatedEvents, acvTitlesExternalIds);
            //if(deletedEvents.size() > 0)	deleteTitles(deletedEvents);
            //if(undeletedEvents.size() > 0)	undeleteTitles(undeletedEvents);
            if(dealershipNoteAddedEvents.size() > 0)	addDealershipsNote(dealershipNoteAddedEvents, acvTitlesExternalIds);
            
            res.errors = false; // No Errors
        }
        catch(Exception e)	{
            // Errors found while processing the events.
            res.errors = true; 
            res.message = e.getMessage();
        }
        
        return res;
    }

    /*
     * Response (success or failure) is sent back to Python Title Consumer using this class as JSON.
     */
    global class CreateNewTitleCaseResponse {
        public Boolean errors;
        public String message;
        
        global CreateNewTitleCaseResponse(){
            this.errors = false;
        }
    }    

    /**
     * 
     * Create new Note(s) in the Dealership_Note__c object.
     * 
     * @titleList A list of dealership note records that will be created.
     * @acvTitlesExternalIds A list of associated ACV Titles External Ids.
     * 
     * 
 	 * Below is a sample Python Title Consumer event passed to this service:
        [
            {
                "entity": "title",
                "version": "v2.0",
                "eventId": "24cd625f-9d44-403d-8835-c708926886ed",
                "correlationId": "8334c9b3-4f62-4583-b8eb-cee2c82336c1",
                "eventType": "note-added",
                "timestamp": "2021-10-15T15:50:02.3015162Z",
                "domain": "title",		
                "titleId": "e0442543-561a-4d15-b00f-e6c21e4b3b01",
                "titleIdType": "int",
                "noteId": "91e2b93c-b9c7-4077-bd27-d727e372b05d",
                "legacyTitleId": 12345,
                "authorId": 123,
                "note": "this is the text of the note."
            }
        ]
	 *
	 *      
     */
    private static void addDealershipsNote(List<TitleDefinition> titleList, List<String> acvTitlesExternalIds)	{
        // Nothing to do if there are no records.
        if(acvTitlesExternalIds.size() == 0) return;
        if(titleList.size() == 0) return;
        
        // Load various maps in bulk - it is mostly used to load Salesforce Ids using data provided in the event.
        IdMaps variousMaps = populateMapsForDealershipNotes(titleList, acvTitlesExternalIds);
        
        /*
		 * Process all the Dealership Notes events.
		*/
        List<Dealership_Note__c> newDealershipNotes = new List<Dealership_Note__c>();
        for(TitleDefinition aTitle : titleList)	{
            // Find out if ACV Titles External Id is GUID or INT type.
            String acvTitlesExternalId = aTitle.titleId;
            if(aTitle.titleIdType == TITLE_ID_TYPE_INT)	{
                acvTitlesExternalId = String.valueOf(aTitle.legacyTitleId);
            }
            
            // Find various Salesforce Ids from the maps.
            String authorContactId = variousMaps.userIdContactIdMap.get(String.valueOf(aTitle.dealershipNote.authorId));
            if(String.isBlank(authorContactId)) throw new TitleServiceException('Invalid Author Id ' + aTitle.dealershipNote.authorId + ' for Note Id ' + aTitle.dealershipNote.noteId);
            
            String titleId = variousMaps.acvTitleExtIdTitleMap.get(acvTitlesExternalId);
            if(String.isBlank(titleId)) throw new TitleServiceException('Invalid Title Id ' + acvTitlesExternalId + ' for Note Id ' + aTitle.dealershipNote.noteId);
            
            // Create a new case record.
            Dealership_Note__c aNewNote = new Dealership_Note__c (
                Name = aTitle.dealershipNote.noteId,
                Note__c = aTitle.dealershipNote.note,
                Title__c = titleId,
                Note_Author__c = authorContactId
            );
            
            newDealershipNotes.add(aNewNote);
        }
        
        if(newDealershipNotes.size() > 0) insert newDealershipNotes;
    }
    
    /**
     * Update title case records.
     * 
     * @titleList A list of titles records that will be updated.
     * @acvTitlesExternalIds A list of associated ACV Titles External Ids.
     * 
     */
    private static void updateTitles(List<TitleDefinition> titleList, List<String> acvTitlesExternalIds)	{
 
        // Nothing to do if there are no records.
        if(acvTitlesExternalIds.size() == 0) return;
        if(titleList.size() == 0) return;
        
        // Load various maps in bulk - it is mostly used to load Salesforce Ids using data provided in the event.
        IdMaps variousMaps = mapAllIds(titleList);

        // Fetch all the title Cases and Title__c records using ACV Titles External Ids.
        List<Case> existingCases = [SELECT Id, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle_Id__c, Auction_Number__c FROM Case WHERE ACV_Titles_External_ID__c IN :acvTitlesExternalIds];
        List<Title__c> existingTitles = [SELECT Id, Name, Title_Id_Type__c, Case__c FROM Title__c WHERE Name IN :acvTitlesExternalIds];
        
        // Map of ACV Titles External Id & Case Record
        Map<String, Case> acvTitleExtIdCaseMap = new Map<String, Case>();
        for(Case aCase : existingCases)	{
            acvTitleExtIdCaseMap.put(aCase.ACV_Titles_External_ID__c, aCase);
        }
        
        // Map of ACV Titles External Id & Title__c Record
        Map<String, Title__c> acvTitleExtIdTitleMap = new Map<String, Title__c>();
        for(Title__c aTitle : existingTitles)	{
            acvTitleExtIdTitleMap.put(aTitle.Name, aTitle);
        }
        
        // List of Case & Title__c records that will be updated in Salesforce.
        List<Case> updatedCases = new List<Case>();
        List<Title__c> updatedTitles = new List<Title__c>();
        
		// Process each updated event        
        for(TitleDefinition td : titleList)	{
            /*
             * Only process the events if listOfAvailableFieldNamesInJson is not empty.
             * 
             * See TitleDefinition class for info on listOfAvailableFieldNamesInJson.
             */
            List<String> listOfAvailableFieldNamesInJson = td.metadata.listOfAvailableFieldNamesInJson;
            if(listOfAvailableFieldNamesInJson != null && listOfAvailableFieldNamesInJson.size() > 0) {
                // Find out if ACV Titles External Id is GUID or INT type.
                String acvTitlesExternalId = td.titleId;
                if(td.titleIdType == TITLE_ID_TYPE_INT)	{
                    acvTitlesExternalId = String.valueOf(td.legacyTitleId);
                }
                
                // Find various Salesforce Ids from the maps.
                String buyerContactId = variousMaps.userIdContactIdMap.get(String.valueOf(td.buyerUserId));
                String sellerContactId = variousMaps.userIdContactIdMap.get(String.valueOf(td.sellerUserId));
                String buyerAcctId = variousMaps.dealerIdAccountIdMap.get(String.valueOf(td.buyerOrganizationId));
                String sellerAcctId = variousMaps.dealerIdAccountIdMap.get(String.valueOf(td.sellerOrganizationId));
                String vehicleId = variousMaps.vinVehicleIdMap.get(String.valueOf(td.vehicle.vin));
                String auctionId = variousMaps.auctionNumberAuctionIdMap.get(String.valueOf(td.legacyAuctionId));
                
                // Fetch the Case record from the map using ACV External Titles Id.
                Case aCase = acvTitleExtIdCaseMap.get(acvTitlesExternalId);
                if(aCase != null)	{
                    /*
                     * listOfAvailableFieldNamesInJson only has a list of field/property names that were updated by the
                     * datahub Titles Producer. This helps update the field value to null/blank. In other words, we only
                     * update the Salesforce fields that are present in the listOfAvailableFieldNamesInJson.
                     */
                    if(listOfAvailableFieldNamesInJson.contains('titleAbsent')) aCase.Title_Attached__c = td.titleAbsent;
                    if(listOfAvailableFieldNamesInJson.contains('digitalTitle')) aCase.Digital_Title__c = td.digitalTitle;
                    if(listOfAvailableFieldNamesInJson.contains('status')) aCase.Status = td.status;
                    if(listOfAvailableFieldNamesInJson.contains('buyerOrganizationId')) aCase.AccountId = buyerAcctId;
                    if(listOfAvailableFieldNamesInJson.contains('buyerUserId')) aCase.ContactId = buyerContactId;
                    if(listOfAvailableFieldNamesInJson.contains('sellerOrganizationId')) aCase.Seller_Dealership__c = sellerAcctId;
                    //if(listOfAvailableFieldNamesInJson.contains('vehicle.vin')) aCase.Vehicle_Id__c = vehicleId;
                    if(listOfAvailableFieldNamesInJson.contains('vehicle.vin')) aCase.Vehicle__c = vehicleId;
                    if(listOfAvailableFieldNamesInJson.contains('vehicle.vin')) aCase.Vehicle_VIN__c = td.vehicle.vin;
                    if(listOfAvailableFieldNamesInJson.contains('legacyAuctionId')) aCase.Auction_Number__c = auctionId;
                    
                    updatedCases.add(aCase);
                }
                
                /*
                 * Also update the associated Title__c record.
                 */
                Title__c aTitle = acvTitleExtIdTitleMap.get(acvTitlesExternalId);
                if(aTitle != null)	{
                    //aTitle.Title_Id_Type__c = td.titleIdType; // don't want to update the Title Id Type if we cannot update the TitleId.
                    
                    //updatedTitles.add(aTitle); // uncomment this line when you add a Title field to update.
                } 
            } // listOfAvailableFieldNamesInJson not Null
        } // for td
        
        if(updatedCases.size() > 0) update updatedCases;
        if(updatedTitles.size() > 0) update updatedTitles;        
    }
    
    /**
     * Create title case records.
     * 
     * @titleList A list of titles records that will be created.
     * 
     */
    private static void createTitles(List<TitleDefinition> titleList)	{
        List<Title__c> newTitles = new List<Title__c>();
        List<Case> newCases = new List<Case>();
        
		Map<String,Case> titleExternalIdCaseMap = new Map<String,Case>();
        
        // Load various maps in bulk - it is mostly used to load Salesforce Ids using data provided in the event.
        IdMaps variousMaps = mapAllIds(titleList);
        
        // Create Case of Title Informatin Record Type
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        
        // Title__c could be either Digital or Physical Title.
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
        /*
         * Process all the created events.
         */
        for(TitleDefinition aTitle : titleList)	{
            // Find out if ACV Titles External Id is GUID or INT type.
            String acvTitlesExternalId = aTitle.titleId;
            if(aTitle.titleIdType == TITLE_ID_TYPE_INT)	{
                acvTitlesExternalId = String.valueOf(aTitle.legacyTitleId);
            }
            
            // Find various Salesforce Ids from the maps.
            String buyerContactId = variousMaps.userIdContactIdMap.get(String.valueOf(aTitle.buyerUserId));
            String sellerContactId = variousMaps.userIdContactIdMap.get(String.valueOf(aTitle.sellerUserId));
            String buyerAcctId = variousMaps.dealerIdAccountIdMap.get(String.valueOf(aTitle.buyerOrganizationId));
            String sellerAcctId = variousMaps.dealerIdAccountIdMap.get(String.valueOf(aTitle.sellerOrganizationId));
            String vehicleId = variousMaps.vinVehicleIdMap.get(String.valueOf(aTitle.vehicle.vin));
            String auctionId = variousMaps.auctionNumberAuctionIdMap.get(String.valueOf(aTitle.legacyAuctionId));
            
            // Create a new case record.
            Case aNewCase = new Case (
                RecordTypeId = caseRecordTypeId,
                ACV_Titles_External_ID__c = acvTitlesExternalId,
                Title_Attached__c = aTitle.titleAbsent,
                Digital_Title__c = aTitle.digitalTitle,
                Status = aTitle.status,
                AccountId = buyerAcctId,
                ContactId = buyerContactId,
                Seller_Dealership__c = sellerAcctId,
                //Vehicle_Id__c = vehicleId,
                Vehicle__c = vehicleId,
                Vehicle_VIN__c = aTitle.vehicle.vin,
                Auction_Number__c = auctionId
            );
            
            // it is used later to get the Case Id for the associated Title__c.
            titleExternalIdCaseMap.put(acvTitlesExternalId, aNewCase);
            
			Id titleRecordTypeId = physicalTitleRecordTypeId;
            if(aTitle.digitalTitle)	titleRecordTypeId = digitalTitleRecordTypeId;
            
            // Create Title__c record
            Title__c aNewTitle = new Title__c (
                RecordTypeId = titleRecordTypeId,
                Name = acvTitlesExternalId,
                Title_Id_Type__c = aTitle.titleIdType
            );
            
            newCases.add(aNewCase);
            newTitles.add(aNewTitle);
        }
        
        if(newCases.size() > 0) {
            insert newCases;
        
            // Associate Case Id with Title__c
            for(Title__c t : newTitles)	{
                Case c = titleExternalIdCaseMap.get(t.Name);
                if(c != null)	t.Case__c = c.Id;
            }
            
            insert newTitles;
        }
    }
    
    /**
     * Create mapping between Salesforce Ids and various fields in the Event.
     * 
     * @titleList A list of titles records/events that will be mapped.
     * 
     */
    private static IdMaps mapAllIds(List<TitleDefinition> titleList)	{        
		List<String> dealerIds = new List<String>();
        List<String> userIds = new List<String>();
        List<String> vins = new List<String>();
        List<String> auctionIds = new List<String>();
        
        // Collect all values from the events of specific types.
        for(TitleDefinition aTitle : titleList)	{
            if(aTitle.sellerUserId != null) userIds.add(String.valueOf(aTitle.sellerUserId));
            if(aTitle.buyerUserId != null) userIds.add(String.valueOf(aTitle.buyerUserId));
            
            if(aTitle.sellerOrganizationId != null) dealerIds.add(String.valueOf(aTitle.sellerOrganizationId));
            if(aTitle.buyerOrganizationId != null) dealerIds.add(String.valueOf(aTitle.buyerOrganizationId));
            
            if(aTitle.vehicle.vin != null) vins.add(aTitle.vehicle.vin);
            
            if(aTitle.legacyAuctionId != null) auctionIds.add(String.valueOf(aTitle.legacyAuctionId));
        }
        
        // A collection of maps
        IdMaps variousMaps = new IdMaps();
        
        // Fetch all the Salesforce Id for the corresponding Dealer Ids in the events.
		List<Account> accts = [SELECT Id, Dealership_ID__c FROM Account WHERE Dealership_ID__c IN :dealerIds];
        for(Account a : accts)	{
            variousMaps.dealerIdAccountIdMap.put(a.Dealership_ID__c, a.Id);
        }
        
        // Fetch all the Salesforce Id for the corresponding buyer/seller User Ids in the events.
		List<Contact> conts = [SELECT Id, ID__c FROM Contact WHERE ID__c IN :userIds];
        for(Contact c : conts)	{
            variousMaps.userIdContactIdMap.put(c.ID__c, c.Id);
        }

        // Fetch all the Salesforce Id for the corresponding Vehicle VIN in the events.
		List<Vehicle__c> vehicles = [SELECT Id, Name FROM Vehicle__c WHERE Name IN :vins];
        for(Vehicle__c v : vehicles)	{
            variousMaps.vinVehicleIdMap.put(v.Name, v.Id);
        }

        // Fetch all the Salesforce Id for the corresponding Auction Number in the events.
		List<Auction__c> auctions = [SELECT Id, Name FROM Auction__c WHERE Name IN :auctionIds];
        for(Auction__c v : auctions)	{
            variousMaps.auctionNumberAuctionIdMap.put(v.Name, v.Id);
        }
        
        return variousMaps;
    }

    private static IdMaps populateMapsForDealershipNotes(List<TitleDefinition> titleList, List<String> acvTitlesExternalIds)	{        
        List<String> userIds = new List<String>();
        
        // Collect all values from the events of specific types.
        for(TitleDefinition aTitle : titleList)	{
            if(aTitle.dealershipNote.authorId != null) userIds.add(String.valueOf(aTitle.dealershipNote.authorId));
        }
        
        // A collection of maps
        IdMaps variousMaps = new IdMaps();
        
        // Fetch all the Salesforce Id for the corresponding buyer/seller User/Author Ids in the events.
		List<Contact> conts = [SELECT Id, ID__c FROM Contact WHERE ID__c IN :userIds];
        for(Contact c : conts)	{
            variousMaps.userIdContactIdMap.put(c.ID__c, c.Id);
        }
 
        // Map of ACV Titles External Id & Title__c Record
        List<Title__c> newTitles = [SELECT Id, Name FROM Title__c WHERE Name IN :acvTitlesExternalIds];
        for(Title__c aTitle : newTitles)	{
            variousMaps.acvTitleExtIdTitleMap.put(aTitle.Name, aTitle.Id);
        }
        
        return variousMaps;
    }
    
    /**
     * A collection of Maps
     */
    public class IdMaps	{
        public Map<String,String> dealerIdAccountIdMap = new Map<String,String>();
        public Map<String,String> userIdContactIdMap = new Map<String,String>();
        public Map<String,String> vinVehicleIdMap = new Map<String,String>();
        public Map<String,String> auctionNumberAuctionIdMap = new Map<String,String>();        
        public Map<String,String> acvTitleExtIdTitleMap = new Map<String,String>();        
    }
    
	public class TitleServiceException extends Exception {}    
}