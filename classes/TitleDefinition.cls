/**
 * @description A value object that is used by the TitleService class. It holds the JSON event data sent by Phython Titles Consumer.
 * 
  * 
 * Requirements:
 * https://acvauctions.atlassian.net/browse/TDO-355
 * https://acvauctions.atlassian.net/browse/TDO-374
 * 
 * @author Manmeet Vaseer
 * @date 11/08/2021
 */ 
global class TitleDefinition extends CoreObject {
    public Boolean fromHistoricalLoad;		// Not stored in Salesforce. It is used to determine if the Event is related to Retro/Historic load.
    public String titleId;					// Case.ACV_Titles_External_ID__c in Salesforce. Switching Title Id from Number to GUID for new Cases.
    public Integer legacyTitleId;			// Case.ACV_Titles_External_ID__c in Salesfroce. New Titles will have GUID. 
    public String titleIdType;				// Title__c.Title_Id_Type__c in Salesforce. It will be either guid or int. If 'guid', use titleId otherwise use legacyTitleId.
    public Integer legacyAuctionId;			// Auction__c.Name (Auction Number) in Salesforce. 
    public Boolean titleAbsent;				// Case.Title_Attached__c (Title Absent) in Salesforce.
    public Integer sellerUserId;			// Contact.ID__c (ACV Contact Id) in Salesforce.
    public Integer buyerUserId;				// Contact.ID__c (ACV Contact Id) in Salesforce.
    public Integer sellerOrganizationId;	// Account.Dealership_ID__c (Dealer Id) in Salesforce.
    public Integer buyerOrganizationId;		// Account.Dealership_ID__c (Dealer Id) in Salesforce.
    public Boolean digitalTitle;			// Case.Digital_Title__c in Salesforce.
    public String legacyStatus;				// New field in Salesforce.
    public String status;					// Case.Status in Salesforce.
    
    public VehicleInfo vehicle;
    public PaymentInfo payment;
    public DealershipNoteInfo dealershipNote;
    public MetaInfo metadata;
    
    global class VehicleInfo extends CoreObject{
        public String make;					// Vehicle__c.make__c in Salesforce.
        public String model;				// Vehicle__c.model__c in Salesforce.
        public Integer odometer;			// Vehicle__c.odometer__c in Salesforce.
        public String vin;					// Vehicle__c.Name & Vehicle__c.vin__c in Salesforce.
        public String year;					// Vehicle__c.Year__c in Salesforce.
    }

    global class PaymentInfo extends CoreObject{
        public String method;				// Auction__c.Payment_Method__c (Buyer Payment Method) in Salesforce.
        public String status;				// Auction__c.Payment_Status__c (Buyer Payment Status) in Salesforce.
    }    

    global class DealershipNoteInfo extends CoreObject{
        public String noteId;			// Dealership_Note__c.Name
        public String note;				// Dealership_Note__c.Note__c
        public Integer authorId;		// Seller Dealership Contact.ID__c (ACV Contact Id) in Salesforce. It will be used to populate Dealership_Note__c.Note_Author__c (Contact Salesforce Id). 
    }    
    
    global class MetaInfo extends CoreObject{
        public String entity;
        public String version;
        public String eventId;
        public String correlationId;
        public String eventType;
        public Datetime timestamp;
        public String domain;
        /*
         * listOfAvailableFieldNamesInJson only has a list of field/property names that were updated by the
         * datahub Titles Producer. This helps update the field value in Salesforce to null/blank. In other words, we only
         * update the Salesforce fields that are present in the listOfAvailableFieldNamesInJson.
         */
		public List<String> listOfAvailableFieldNamesInJson;
    }        
    
}