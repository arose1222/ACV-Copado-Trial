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
 * 
 * @history
 * 		03/08/2022 Manmeet Vaseer - Added new Case.Title__c field and populate it in the Created event.
 * 		03/14/2022 Manmeet Vaseer - Title Review created & updated events.
 * 		04/05/2022 Manmeet Vaseer - Title Review Document Added event.
 * 		04/25/2022 Manmeet Vaseer - Added Row Lock retries.
 * 		04/27/2022 Manmeet Vaseer - A shell Case & Title records will be created. Later, we will add Related Records using TitleServicePopulateRelatedDataBatch.
 * 									This is to avoid ROW LOCK issue.
 * 		05/06/2022 Manmeet Vaseer - Dedup payload based on event id.
 * 
 */ 
@RestResource(urlMapping='/titleService')
global class TitleService {
    static public String ENDPOINT_URL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/titleService';

    static public String TITLE_ID_TYPE_INT = 'int';
    
    // Types of Events.
    static public String EVENT_CREATED = 'created';
    static public String EVENT_UPDATED = 'updated';
    static public String EVENT_DELETED = 'deleted';
    static public String EVENT_UNDELETED = 'undeleted';
    static public String EVENT_DEALERSHIP_NOTE_ADDED = 'note-added'; // only seller dealership notes are added
    static public String EVENT_TITLE_REVIEW_CREATED = 'title-review-created';
    static public String EVENT_TITLE_REVIEW_UPDATED = 'title-review-updated';
    static public String EVENT_TITLE_REVIEW_DOCUMENT_ADDED = 'title-review-document-added';
    
    /*
     * Entry point for the Python Title Consumer. The Title Consumer will pass the JSON message that will have
     * a list of events to Create or Update title cases in Salesforce.
     * 
     * @param titleList A list of Event JSON message converted into a list of TitleDefinition object.
     * 
     */
    @httpPost
    global static CreateNewTitleCaseResponse processTitles(List<TitleDefinition> titleList){
        makeSplunkLog(ENDPOINT_URL, 'POST', titleList, null, 200, ACVUtility.currentLineNumber(), 'Total Events Received for Processing: ' + titleList.size(), '', 'TitleService.processTitles()', SplunkHelper.LOGLEVEL.INFO);
        
        CreateNewTitleCaseResponse res = new CreateNewTitleCaseResponse();
        try {
            // List to hold specific types of events
            List<TitleDefinition> createdEvents = new List<TitleDefinition>();
            List<TitleDefinition> updatedEvents = new List<TitleDefinition>();
            List<TitleDefinition> deletedEvents = new List<TitleDefinition>();
            List<TitleDefinition> undeletedEvents = new List<TitleDefinition>();
            List<TitleDefinition> dealershipNoteAddedEvents = new List<TitleDefinition>();
            List<TitleDefinition> titleReviewCreatedEvents = new List<TitleDefinition>();
            List<TitleDefinition> titleReviewUpdatedEvents = new List<TitleDefinition>();
            List<TitleDefinition> titleReviewDocumentAddedEvents = new List<TitleDefinition>();
            
            /* 
             * ACV Titles External Id is the link between Events and the records in Salesforce.
             * We will use the ACV Titles External Id to find the Salesforce Ids, if it is an existing record.
             */
            List<String> acvTitlesExternalIds = new List<String>();

            /*
             * Title Review UUIDs from backend. It will be used to find corresponding Salesforce Ids
             * to update/delete Title Review records.
             */
            List<String> acvTitleReviewExternalIds = new List<String>();
            
            // Remove any duplicate Events
            titleList = dedupPayloadByEventId(titleList);
            
            // Process all the Events and populate the event specific list.
            for(TitleDefinition aTitle : titleList)	{
                /*
				 * ACV Titles External Id could be either GUID (new) or INT (old) type.
				 * ACV Titles External Id will be either in titleId (guid) or legacyTitleId (int) based on the titleIdType (guid/int).
				 */
                String acvTitlesExternalId = aTitle.titleId;
                if(aTitle.titleIdType == TITLE_ID_TYPE_INT)	{
                    acvTitlesExternalId = String.valueOf(aTitle.legacyTitleId);
                }
                acvTitlesExternalIds.add(acvTitlesExternalId);
                
                // ignore events from Retro/Historic load.
                if(aTitle.fromHistoricalLoad == false && aTitle.metadata.eventType == EVENT_CREATED)	createdEvents.add(aTitle);
                else if(aTitle.fromHistoricalLoad == false && aTitle.metadata.eventType == EVENT_UPDATED)	updatedEvents.add(aTitle);
                else if(aTitle.fromHistoricalLoad == false && aTitle.metadata.eventType == EVENT_DELETED)	deletedEvents.add(aTitle);
                else if(aTitle.fromHistoricalLoad == false && aTitle.metadata.eventType == EVENT_UNDELETED)	undeletedEvents.add(aTitle);                    
                else if(aTitle.metadata.eventType == EVENT_DEALERSHIP_NOTE_ADDED) dealershipNoteAddedEvents.add(aTitle);
                else if(aTitle.metadata.eventType == EVENT_TITLE_REVIEW_CREATED) titleReviewCreatedEvents.add(aTitle);
                else if(aTitle.metadata.eventType == EVENT_TITLE_REVIEW_UPDATED) {
                    titleReviewUpdatedEvents.add(aTitle);
                    acvTitleReviewExternalIds.add(aTitle.titleReview.reviewId);
                }
                else if(aTitle.metadata.eventType == EVENT_TITLE_REVIEW_DOCUMENT_ADDED) {
                    titleReviewDocumentAddedEvents.add(aTitle);
                    acvTitleReviewExternalIds.add(aTitle.titleReview.reviewId);
                }
            }            
                        
            if(createdEvents.size() > 0)	createTitles(createdEvents);
            
            /*
             * Disabling Titles update event as per discussion with Matt G. (we don't need it).
             * Also, there is an issue where same Title Id is being updated in 2 different events that are being sent by the backend/Producer at the same time/payload.
             * So, either backend needs to ensure that they don't send 2 different updated events for the same Title Id in a same payload.
             * Or, we need to modify the updateTitles() logic in a way that we don't insert same Title Ids in updatedCases list to avoid 'Duplicate id in list'
             * error when updating the Cases.
             * 
             * Salesforce solution could be we check the updatedCases list for the existing Title Id and if it exists then we modify the same instance of Case.
             */
            //if(updatedEvents.size() > 0)	updateTitles(updatedEvents, acvTitlesExternalIds); 
            
            //if(deletedEvents.size() > 0)	deleteTitles(deletedEvents);
            //if(undeletedEvents.size() > 0)	undeleteTitles(undeletedEvents);
            if(dealershipNoteAddedEvents.size() > 0)	addDealershipsNote(dealershipNoteAddedEvents, acvTitlesExternalIds);
            if(titleReviewCreatedEvents.size() > 0)	createTitleReviews(titleReviewCreatedEvents, acvTitlesExternalIds);
            if(titleReviewUpdatedEvents.size() > 0)	updateTitleReviews(titleReviewUpdatedEvents, acvTitleReviewExternalIds);
            if(titleReviewDocumentAddedEvents.size() > 0)	addTitleReviewDocument(titleReviewDocumentAddedEvents, acvTitleReviewExternalIds);
            
            res.message = titleList.size() + ' Events Processed Successfully.';
            res.errors = false; // No Errors
        	makeSplunkLog(ENDPOINT_URL, 'POST', titleList, res, 200, ACVUtility.currentLineNumber(), res.message, '', 'TitleService.processTitles()', SplunkHelper.LOGLEVEL.INFO);            
        }
        catch(Exception e)	{
            // Errors found while processing the events.
            res.errors = true; 
            res.message = e.getMessage();

            String logMsg = 'Found Error while Processing Events: ' + e.getMessage();
        	makeSplunkLog(ENDPOINT_URL, 'POST', titleList, res, 500, ACVUtility.currentLineNumber(), logMsg, '', e.getStackTraceString(), SplunkHelper.LOGLEVEL.ERROR);
            //ErrorLogHandler.addError('Title Service', 'Error', logMsg, e.getStackTraceString(), JSON.serialize(titleList));
            //ErrorLogHandler.save();
            if(Test.isRunningTest())	throw e;
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
     * Add documents to title reviews.
     * 
     * @titleList A list of titles records that will be updated.
     * @acvTitleReviewExternalIds A list of associated ACV Title Review Ids.
     * 
     */
    private static void addTitleReviewDocument(List<TitleDefinition> titleList, List<String> acvTitleReviewExternalIds)	{
        // Nothing to do if there are no records.
        if(acvTitleReviewExternalIds.size() == 0) return;
        if(titleList.size() == 0) return;

        // Load various maps in bulk - it is mostly used to load Salesforce Ids using data provided in the event.
        IdMaps variousMaps = populateMapsForTitleReviewDocuments(titleList);
        
        /*
		 * Process all the Title Review Document events.
		*/
        List<Title_Review_Document__c> addTitleReviewDocs = new List<Title_Review_Document__c>();
        for(TitleDefinition aTitle : titleList)	{
            String userContactId = variousMaps.userIdContactIdMap.get(String.valueOf(aTitle.titleReview.titleReviewDocument.userId));
            if(String.isBlank(userContactId)) {
                String msg = 'Invalid User Id ' + aTitle.titleReview.titleReviewDocument.userId + ' for Title Review Id ' + aTitle.titleReview.reviewId;
                makeSplunkLog(ENDPOINT_URL, 'POST', aTitle, null, 412, ACVUtility.currentLineNumber(), msg, '', 'TitleService.addTitleReviewDocument()', SplunkHelper.LOGLEVEL.ERROR);
            }
            else {            
                // Create a new Title Review Document record.
                Title_Review_Document__c addTitleReviewDoc = new Title_Review_Document__c (
                    Name = aTitle.titleReview.titleReviewDocument.documentId,
                    Document_URI__c = aTitle.titleReview.titleReviewDocument.documentUri,
                    User_Id__c = userContactId,
                    Title_Review__c = aTitle.titleReview.salesforceId
                );
                
                addTitleReviewDocs.add(addTitleReviewDoc);
            }
        }
        
        if(addTitleReviewDocs.size() > 0) {
			upsertWithRetry(true, addTitleReviewDocs, 'Title_Review_Document__c'); // insert
        }
    }    
    
   /**
     * Update title review records.
     * 
     * @titleList A list of titles records that will be updated.
     * @acvTitleReviewExternalIds A list of associated ACV Title Review Ids.
     * 
     */
    private static void updateTitleReviews(List<TitleDefinition> titleList, List<String> acvTitleReviewExternalIds)	{
        // Nothing to do if there are no records.
        if(acvTitleReviewExternalIds.size() == 0) return;
        if(titleList.size() == 0) return;
        
        Map<String, Title_Review__c> titleReviewExtIdMap = new Map<String, Title_Review__c>();
        
        List<Title_Review__c> existingTitleReviews = [SELECT Id, Name, Commit_Pending__c FROM Title_Review__c WHERE Name IN :acvTitleReviewExternalIds];
        for(Title_Review__c aTR : existingTitleReviews)	{
            titleReviewExtIdMap.put(aTR.Name, aTR);
        }

        // List of Title_Review__c records that will be updated in Salesforce.
        List<Title_Review__c> updatedTitleReviews = new List<Title_Review__c>();
        
		// Process each updated event        
        for(TitleDefinition td : titleList)	{
            /*
             * Only process the events if listOfAvailableFieldNamesInJson is not empty.
             * 
             * See TitleDefinition class for info on listOfAvailableFieldNamesInJson.
             */
            List<String> listOfAvailableFieldNamesInJson = td.metadata.listOfAvailableFieldNamesInJson;
            if(listOfAvailableFieldNamesInJson != null && listOfAvailableFieldNamesInJson.size() > 0) {
                Title_Review__c existingTitleReview = titleReviewExtIdMap.get(td.titleReview.reviewId);
                if(existingTitleReview == null) {
                    String msg = 'Invalid Title Review Id ' + td.titleReview.reviewId;
        			makeSplunkLog(ENDPOINT_URL, 'POST', td, null, 412, ACVUtility.currentLineNumber(), msg, '', 'TitleService.updateTitleReviews()', SplunkHelper.LOGLEVEL.ERROR);
                }                
                else {
                    /*
                     * listOfAvailableFieldNamesInJson only has a list of field/property names that were updated by the
                     * datahub Titles Producer. This helps update the field value to null/blank. In other words, we only
                     * update the Salesforce fields that are present in the listOfAvailableFieldNamesInJson.
                     */
                    if(listOfAvailableFieldNamesInJson.contains('commitPending')) existingTitleReview.Commit_Pending__c = td.titleReview.commitPending;
                    
                    updatedTitleReviews.add(existingTitleReview);
                }                
            } // listOfAvailableFieldNamesInJson not Null
        } // for td
        
        if(updatedTitleReviews.size() > 0) {
			upsertWithRetry(false, updatedTitleReviews, 'Title_Review__c'); // update
        }
    }

    /**
     * 
     * Create new Title Review record in the Title_Review__c object.
     * 
     * @titleList A list of title review records that will be created.
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
        "eventType": "title-review-created",
        "timestamp": "2021-10-15T15:50:02.3015162Z",
        "domain": "title",		
		"titleId": "e0442543-561a-4d15-b00f-e6c21e4b3b01",
		"titleIdType": "guid",
        "reviewId": "91e2b93c-b9c7-4077-bd27-d727e372b05d"
    }
]
	 *
	 *      
     */
    private static void createTitleReviews(List<TitleDefinition> titleList, List<String> acvTitlesExternalIds)	{
        // Nothing to do if there are no records.
        if(acvTitlesExternalIds.size() == 0) return;
        if(titleList.size() == 0) return;
        
        // Load various maps in bulk - it is mostly used to load Salesforce Ids using data provided in the event.
        IdMaps variousMaps = populateMapsForTitleReviews(titleList, acvTitlesExternalIds);
        
        /*
		 * Process all the Title Review events.
		*/
        List<Title_Review__c> newTitleReviews = new List<Title_Review__c>();
        for(TitleDefinition aTitle : titleList)	{
            // Find out if ACV Titles External Id is GUID or INT type.
            String acvTitlesExternalId = aTitle.titleId;
            if(aTitle.titleIdType == TITLE_ID_TYPE_INT)	{
                acvTitlesExternalId = String.valueOf(aTitle.legacyTitleId);
            }
            
            // Find various Salesforce Ids from the maps.
            String titleId = variousMaps.acvTitleExtIdTitleMap.get(acvTitlesExternalId);
            if(String.isBlank(titleId)) {
                String msg = 'Invalid Title Id ' + acvTitlesExternalId + ' for Title Review Id ' + aTitle.titleReview.reviewId;
                makeSplunkLog(ENDPOINT_URL, 'POST', aTitle, null, 412, ACVUtility.currentLineNumber(), msg, '', 'TitleService.createTitleReviews()', SplunkHelper.LOGLEVEL.ERROR);
            }
            else {            
                // Create a new case record.
                Title_Review__c aNewTitleReview = new Title_Review__c (
                    Name = aTitle.titleReview.reviewId,
                    Title__c = titleId
                );
                
                newTitleReviews.add(aNewTitleReview);
            }
        }
        
        if(newTitleReviews.size() > 0) {
			upsertWithRetry(true, newTitleReviews, 'Title_Review__c'); // insert
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
            if(String.isBlank(authorContactId)) {
                String msg = 'Invalid Author Id ' + aTitle.dealershipNote.authorId + ' for Note Id ' + aTitle.dealershipNote.noteId;
                makeSplunkLog(ENDPOINT_URL, 'POST', aTitle, null, 412, ACVUtility.currentLineNumber(), msg, '', 'TitleService.addDealershipsNote()', SplunkHelper.LOGLEVEL.ERROR);
            }
            String titleId = variousMaps.acvTitleExtIdTitleMap.get(acvTitlesExternalId);
            if(String.isBlank(titleId)) {
                String msg = 'Invalid Title Id ' + acvTitlesExternalId + ' for Note Id ' + aTitle.dealershipNote.noteId;
                makeSplunkLog(ENDPOINT_URL, 'POST', aTitle, null, 412, ACVUtility.currentLineNumber(), msg, '', 'TitleService.addDealershipsNote()', SplunkHelper.LOGLEVEL.ERROR);
            }
            
            if(!String.isBlank(authorContactId) && !String.isBlank(titleId)) {
                // Create a new case record.
                Dealership_Note__c aNewNote = new Dealership_Note__c (
                    Name = aTitle.dealershipNote.noteId,
                    Note__c = aTitle.dealershipNote.note,
                    Title__c = titleId,
                    Note_Author__c = authorContactId
                );
                
                newDealershipNotes.add(aNewNote);
            }
        } //for
        
        if(newDealershipNotes.size() > 0) {
			upsertWithRetry(true, newDealershipNotes, 'Dealership_Note__c'); // insert
        }
    }
    
    
   /*
    * Disabling Titles update event as per discussion with Matt G. (we don't need it YET).
    * Also, there is an issue where same Title Id is being updated in 2 different events that are being sent by the backend/Producer at the same time/payload.
    * So, either backend needs to ensure that they don't send 2 different updated events for the same Title Id in a same payload.
    * Or, we need to modify the updateTitles() logic in a way that we don't insert same Title Ids in updatedCases list to avoid 'Duplicate id in list'
    * error when updating the Cases.
    * 
    * Salesforce solution could be we check the updatedCases list for the existing Title Id and if it exists then we modify the same instance of Case.
    */
    
    /**
     * Update title case records.
     * 
     * @titleList A list of titles records that will be updated.
     * @acvTitlesExternalIds A list of associated ACV Titles External Ids.
     * 
     */
    /*
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
            //
            // Only process the events if listOfAvailableFieldNamesInJson is not empty.
            // 
            // See TitleDefinition class for info on listOfAvailableFieldNamesInJson.
            //
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
                    //
                    // listOfAvailableFieldNamesInJson only has a list of field/property names that were updated by the
                    // datahub Titles Producer. This helps update the field value to null/blank. In other words, we only
                    // update the Salesforce fields that are present in the listOfAvailableFieldNamesInJson.
                    //
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
                
                //
                // Also update the associated Title__c record.
                //
                Title__c aTitle = acvTitleExtIdTitleMap.get(acvTitlesExternalId);
                if(aTitle != null)	{
                    //aTitle.Title_Id_Type__c = td.titleIdType; // don't want to update the Title Id Type if we cannot update the TitleId.
                    aTitle.Buyer_User_Id__c = String.valueOf(td.buyerUserId);
                    aTitle.Seller_User_Id__c = String.valueOf(td.sellerUserId);
                    aTitle.Buyer_Organization_Id__c = String.valueOf(td.buyerOrganizationId);
                    aTitle.Seller_Organization_Id__c = String.valueOf(td.sellerOrganizationId);
                    aTitle.VIN__c = String.valueOf(td.vehicle.vin);
                    aTitle.Legacy_Auction_Id__c = String.valueOf(td.legacyAuctionId);
                    
                    updatedTitles.add(aTitle); 
                } 
            } // listOfAvailableFieldNamesInJson not Null
        } // for td
        
        if(updatedCases.size() > 0) update updatedCases;
        if(updatedTitles.size() > 0) update updatedTitles;        
    }
    */

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
		Map<String,Title__c> titleExternalIdTitleObjMap = new Map<String,Title__c>();
        
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
            
            // Create a new case record.
            Case aNewCase = new Case (
                RecordTypeId = caseRecordTypeId,
                ACV_Titles_External_ID__c = acvTitlesExternalId,
                Title_Attached__c = aTitle.titleAbsent,
                Digital_Title__c = aTitle.digitalTitle,
                Status = aTitle.status,
                Vehicle_VIN__c = aTitle.vehicle.vin
            );
            
            // it is used later to get the Case Id for the associated Title__c.
            titleExternalIdCaseMap.put(acvTitlesExternalId, aNewCase);
            
			Id titleRecordTypeId = physicalTitleRecordTypeId;
            if(aTitle.digitalTitle)	titleRecordTypeId = digitalTitleRecordTypeId;
            
            // Create Title__c record
            Title__c aNewTitle = new Title__c (
                RecordTypeId = titleRecordTypeId,
                Name = acvTitlesExternalId,
                ACV_Titles_External_ID__c = acvTitlesExternalId,
                Title_Id_Type__c = aTitle.titleIdType,
                Buyer_User_Id__c = String.valueOf(aTitle.buyerUserId),
                Seller_User_Id__c = String.valueOf(aTitle.sellerUserId),
                Buyer_Organization_Id__c = String.valueOf(aTitle.buyerOrganizationId),
                Seller_Organization_Id__c = String.valueOf(aTitle.sellerOrganizationId),
                VIN__c = String.valueOf(aTitle.vehicle.vin),
                Legacy_Auction_Id__c = String.valueOf(aTitle.legacyAuctionId),
                Is_Pending_Related_Info__c = true
            );
            
            // it is used later to get the Title__c Id for the associated Case.
            titleExternalIdTitleObjMap.put(acvTitlesExternalId, aNewTitle);
            
            newCases.add(aNewCase);
            newTitles.add(aNewTitle);
        } // for
        
        if(newCases.size() > 0) {
			upsertWithRetry(true, newTitles, 'Title__c'); // insert
            
            // Associate Title__c Id with Case
            for(Case c : newCases)	{
                Title__c t = titleExternalIdTitleObjMap.get(c.ACV_Titles_External_ID__c);
                if(t != null)	c.Title__c = t.Id;
            }
            
			upsertWithRetry(true, newCases, 'Case'); // insert
                                
            // Associate Case Id with Title__c
            for(Title__c t : newTitles)	{
                Case c = titleExternalIdCaseMap.get(t.Name);
                if(c != null)	t.Case__c = c.Id;
            }
            
			upsertWithRetry(false, newTitles, 'Title__c'); // update
        }
    }
    
    private static IdMaps populateMapsForTitleReviewDocuments(List<TitleDefinition> titleList)	{        
        List<String> userIds = new List<String>();
        
        // Collect all values from the events of specific types.
        for(TitleDefinition aTitle : titleList)	{
            if(aTitle?.titleReview?.titleReviewDocument?.userId != null) userIds.add(String.valueOf(aTitle.titleReview.titleReviewDocument.userId));
        }
        
        // A collection of maps
        IdMaps variousMaps = new IdMaps();
        
        // Fetch all the Salesforce Id for the corresponding buyer/seller User/Author Ids in the events.
		List<Contact> conts = [SELECT Id, ID__c FROM Contact WHERE ID__c IN :userIds];
        for(Contact c : conts)	{
            variousMaps.userIdContactIdMap.put(c.ID__c, c.Id);
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

    private static IdMaps populateMapsForTitleReviews(List<TitleDefinition> titleList, List<String> acvTitlesExternalIds)	{        
        // A collection of maps
        IdMaps variousMaps = new IdMaps();
        
        // Map of ACV Titles External Id & Title__c Record
        List<Title__c> newTitles = [SELECT Id, Name FROM Title__c WHERE Name IN :acvTitlesExternalIds];
        for(Title__c aTitle : newTitles)	{
            variousMaps.acvTitleExtIdTitleMap.put(aTitle.Name, aTitle.Id);
        }
        
        return variousMaps;
    }
    
    public static void makeSplunkLog(String reqEndpoint, String reqMethodType, Object reqObj, Object resObj, Integer resStatusCode, Integer lineNumber, String message, String sfRecordId, String stackTrace, SplunkHelper.LOGLEVEL LogLevel){
        HttpRequest req = new HttpRequest();
        if(reqObj != null) req.setBody(JSON.serialize(reqObj));
        req.setMethod(reqMethodType);
        req.setEndpoint(reqEndpoint);
        
        HttpResponse res = new HttpResponse();
        if(resObj != null) res.setBody(JSON.serialize(resObj));
        res.setStatus(message);
        res.setStatusCode(resStatusCode);
        
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'TitleService:' + lineNumber;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = sfRecordId;
        infoLog.componentName = 'TitleService';
        infoLog.sfObject = 'Case, Title__c';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS};
            
        if(!Test.isRunningTest()) SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
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
 
    static void upsertWithRetry(Boolean isInsert, List<SObject> objs, String objApiName)	{
        if(objs != null && objs.size() > 0)	{
            Integer retry = 3;
            while(retry > 0)	{
                String upsertType = 'insert';
                try {
                    if(isInsert)	{
                        insert objs;
                    }
                    else {
                        upsertType = 'update';
                        update objs;
                    }
                    retry = 0;
                }
                catch(Exception e)	{
                    String msg = e.getMessage();
                    if(retry > 0 && !String.isBlank(msg) && msg.contains('UNABLE_TO_LOCK_ROW'))	{
                        //sleepForWhile(500); //half a second delay
                    }
                    else {
                        String logMsg = 'Exception: Unable to ' + upsertType + ' ' + objApiName + ': ' + msg;
        				makeSplunkLog(ENDPOINT_URL, 'POST', objs, null, 500, ACVUtility.currentLineNumber(), logMsg, '', e.getStackTraceString(), SplunkHelper.LOGLEVEL.ERROR);                       
                        throw e;
                    }
                    
                    retry = retry - 1;
                }
            } // while
        }
    }
    
    // Not Safe for CPU - find other alternative
    static private void sleepForWhile(Integer delayInMilliseconds)	{
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
        }    
    }
    
   /**
     * Remove duplicate events from the payload using event id.
     * 
     * @titleList A list of titles records that will be deduped.
     * 
     * @return Deduped list of payload.
     */
    static private List<TitleDefinition> dedupPayloadByEventId(List<TitleDefinition> titleList)	{
        List<TitleDefinition> retTitleList = new List<TitleDefinition>();
        
        Map<String, TitleDefinition> titleMap = new Map<String, TitleDefinition>();
        
        if(titleList != null)	{            
            for(TitleDefinition aTitle : titleList)	{
                String eventId = aTitle.metadata?.eventId;
                if(!String.isBlank(eventId)) titleMap.put(eventId, aTitle);
            }
            
            retTitleList = titleMap.values();
        }
                   
        return retTitleList;
    }
        
	public class TitleServiceException extends Exception {}    
}