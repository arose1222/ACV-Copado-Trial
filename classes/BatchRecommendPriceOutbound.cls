global class BatchRecommendPriceOutbound implements Database.Batchable<sObject>, Schedulable{
	
	String query;
	
	global BatchRecommendPriceOutbound() {
		query = 'SELECT Id, Saved_Auction_Id__c, condition_rating__c,Price_Ceiling__c, Pricing_Status__c, External_Notes_to_Seller__c, Price_Floor__c, CreatedDate, LastModifiedDate FROM Recommended_Price__c WHERE Send_To_ACV__c = true AND Saved_Auction_Id__c != null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(SchedulableContext sc) {
		BatchRecommendPriceOutbound batchClass = new BatchRecommendPriceOutbound();
		database.executebatch(batchClass,200);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Recommended_Price__c> lRecPrices = (List<Recommended_Price__c>)scope;
		System.enqueueJob(new AcvIntegrationQueueableJob('Create Pricing', lRecPrices, null));   
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}