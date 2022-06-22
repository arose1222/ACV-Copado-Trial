/**
 * @description A batch process to populate missing Related records on Cases.
 * 				A shell Case record is created in TitleService to avoid ROW LOCK error. This batch process populated the missing related info on Cases where
 * 				Title__c.Is_Pending_Related_Info__c is True (i.e. related info missing).
 * 
 * @author Manmeet Vaseer
 * @date 04/27/2022
 * 
 * @history
 * 		04/27/2022 Manmeet Vaseer - Initial.
 * 
 */
global with sharing class TitleServicePopulateRelatedDataBatch extends SchedulingInterface implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    public Integer totalRecsReceived = 0;
    public Integer totalRecsProcessed = 0;
    
   /**
     * Intiliaze the Batch Job.
     * 
     */
    public TitleServicePopulateRelatedDataBatch()	{
    }

    public override void executeScheduledLogic() {
        TitleServicePopulateRelatedDataBatch batchClass = new TitleServicePopulateRelatedDataBatch();
		database.executebatch( batchClass, 20 ); // lower batch size to reduce the probability of the Row Lock error.
    }

    
    /**
     * Find all Titles with missing data.
     * 
     * @param BC Batch Context
     * @return  `Database.QueryLocator` All Titles where Is_Pending_Related_Info__c=true.
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(getQuery());
    }
    
    /**
     * Populate missing Case & Title data.
     * 
     * @param BC Batch Context
     * @param titles A batch of new titles that will be processed to populate missing related data.
     */
    global void execute(Database.BatchableContext BC, List<Title__c> titles){
        try	{
            totalRecsReceived = totalRecsReceived + titles.size();
            populateMissingRelatedData(titles);
            totalRecsProcessed = totalRecsProcessed + titles.size();
        }
        catch(Exception e)	{
            String logMsg = 'Found Error while Processing Batch: ' + e.getMessage();
			makeSplunkLog(null, ACVUtility.currentLineNumber(), logMsg, e.getStackTraceString(), SplunkHelper.LOGLEVEL.ERROR);
        }
    }
    
    /**
     * Log into Splunk when the batch is finished.
     * 
     * @param BC Batch Context
     */
    global void finish(Database.BatchableContext BC){
        List<Title__c> leftToBeProcessed = [SELECT Id FROM Title__c WHERE Is_Pending_Related_Info__c = true];
        String msg = 'Title records Processed/Received: ' + totalRecsProcessed + '/' + totalRecsReceived + '\n';
        msg = msg + 'Title records left to be processed in Title__c: ' + leftToBeProcessed.size() + '\n';
        msg = msg + 'TitleServicePopulateRelatedDataBatch Finished.\n';
        
        makeSplunkLog(null, 0, msg, '', SplunkHelper.LOGLEVEL.INFO);
        
        //
        // Usually, related info should be populated by this batch process within a day. We want to know if the related info is not populated within a day
        // so that we can send alert on channel.
        // 
        List<Title__c> olderTitlesNotProcessedYet = [SELECT Id, CreatedDate FROM Title__c WHERE Is_Pending_Related_Info__c = true AND CreatedDate < TODAY];
        if(olderTitlesNotProcessedYet != null && olderTitlesNotProcessedYet.size() > 0)	{
            String warnMsg = 'Warning: These titles should have been processed as they are older than a day: ' + olderTitlesNotProcessedYet.size();
        	makeSplunkLog(null, 0, warnMsg, '', SplunkHelper.LOGLEVEL.WARN);            
        }
    } 

    /**
     * Fetch all Titles where Related Record Info are missing.
     * 
     * @return Query String
     */
    public String getQuery()	{
        String query = 'SELECT Id, Is_Pending_Related_Info__c, Case__c, Buyer_User_Id__c, Seller_User_Id__c, Buyer_Organization_Id__c, Seller_Organization_Id__c, VIN__c, Legacy_Auction_Id__c FROM Title__c ' + 
            'WHERE Is_Pending_Related_Info__c = true';

		return query;        
    }
    
    public void populateMissingRelatedData(List<Title__c> titles)	{
        List<Case> updatedCases = new List<Case>();
        List<Title__c> updatedTitles = new List<Title__c>();
        
        // Load various maps in bulk - it is mostly used to load Salesforce Ids.
        IdMaps variousMaps = mapAllIds(titles);
        
        for(Title__c aTitle : titles)	{
            // Find various Salesforce Ids from the maps.
            String buyerContactId = variousMaps.userIdContactIdMap.get(aTitle.Buyer_User_Id__c);
            String sellerContactId = variousMaps.userIdContactIdMap.get(aTitle.Seller_User_Id__c);
            String buyerAcctId = variousMaps.dealerIdAccountIdMap.get(aTitle.Buyer_Organization_Id__c);
            String sellerAcctId = variousMaps.dealerIdAccountIdMap.get(aTitle.Seller_Organization_Id__c);
            String vehicleId = variousMaps.vinVehicleIdMap.get(aTitle.VIN__c);
            String auctionId = variousMaps.auctionNumberAuctionIdMap.get(aTitle.Legacy_Auction_Id__c);
            
            // Create a new case record.
            Case updateCase = new Case (
                Id = aTitle.Case__c,
                AccountId = buyerAcctId,
                ContactId = buyerContactId,
                Seller_Dealership__c = sellerAcctId,
                Seller_Contact__c = sellerContactId,
                //Vehicle_Id__c = vehicleId,
                Vehicle__c = vehicleId,
                Auction_Number__c = auctionId
            );
            
            updatedCases.add(updateCase);
            
            aTitle.Is_Pending_Related_Info__c = false; // Related Records Ids are populated.
            updatedTitles.add(aTitle);
        } // for
        
        if(updatedCases.size() > 0) {
            update updatedCases;
            update updatedTitles;
        }
    }
    
    /**
     * Create mapping between Salesforce Ids and various fields in the Event.
     * 
     * @titleList A list of titles records/events that will be mapped.
     * 
     */
    private static IdMaps mapAllIds(List<Title__c> titleList)	{        
		List<String> dealerIds = new List<String>();
        List<String> userIds = new List<String>();
        List<String> vins = new List<String>();
        List<String> auctionIds = new List<String>();
        
        // Collect all values from the events of specific types.
        for(Title__c aTitle : titleList)	{
            if(aTitle.Seller_User_Id__c != null) userIds.add(aTitle.Seller_User_Id__c);
            if(aTitle.Buyer_User_Id__c != null) userIds.add(aTitle.Buyer_User_Id__c);
            
            if(aTitle.Seller_Organization_Id__c != null) dealerIds.add(aTitle.Seller_Organization_Id__c);
            if(aTitle.Buyer_Organization_Id__c != null) dealerIds.add(aTitle.Buyer_Organization_Id__c);
            
            if(aTitle.VIN__c != null) vins.add(aTitle.VIN__c);
            
            if(aTitle.Legacy_Auction_Id__c != null) auctionIds.add(aTitle.Legacy_Auction_Id__c);
        }
        
        // A collection of maps
        IdMaps variousMaps = new IdMaps();
        
        // Fetch all the Salesforce Id for the corresponding Dealer Ids in the events.
		List<Account> accts = [SELECT Id, Dealership_ID__c FROM Account WHERE Dealership_ID__c IN :dealerIds FOR UPDATE];
        for(Account a : accts)	{
            variousMaps.dealerIdAccountIdMap.put(a.Dealership_ID__c, a.Id);
        }
        
        // Fetch all the Salesforce Id for the corresponding buyer/seller User Ids in the events.
		List<Contact> conts = [SELECT Id, ID__c FROM Contact WHERE ID__c IN :userIds FOR UPDATE];
        for(Contact c : conts)	{
            variousMaps.userIdContactIdMap.put(c.ID__c, c.Id);
        }

        // Fetch all the Salesforce Id for the corresponding Vehicle VIN in the events.
		List<Vehicle__c> vehicles = [SELECT Id, Name FROM Vehicle__c WHERE Name IN :vins FOR UPDATE];
        for(Vehicle__c v : vehicles)	{
            variousMaps.vinVehicleIdMap.put(v.Name, v.Id);
        }

        // Fetch all the Salesforce Id for the corresponding Auction Number in the events.
		List<Auction__c> auctions = [SELECT Id, Name FROM Auction__c WHERE Name IN :auctionIds FOR UPDATE];
        for(Auction__c v : auctions)	{
            variousMaps.auctionNumberAuctionIdMap.put(v.Name, v.Id);
        }
        
        return variousMaps;
    }

    public static void makeSplunkLog(Object anyObj, Integer lineNumber, String message, String stackTrace, SplunkHelper.LOGLEVEL LogLevel)	{
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.componentName = 'TitleServicePopulateRelatedDataBatch';
        if(anyObj != null) infoLog.sfObject = JSON.serialize(anyObj);
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS};
        infoLog.location = 'TitleServicePopulateRelatedDataBatch: '+ lineNumber;
        infoLog.logLevel = LogLevel;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.version = 'v1';
        infoLog.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        
        if(!Test.isRunningTest())	SplunkHelper.processLog(infoLog);
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
 

}