global class BatchUnwindOutbound implements Database.Batchable<sObject>, Schedulable{
	
	String query;
	
	global BatchUnwindOutbound() {
		Id unwindRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
		query = 'SELECT id, status, Auction_Number_Case__c, Saved_Auction_Id__c, Unwind_Type__c FROM Case WHERE RecordTypeId = \''+unwindRecordTypeId+'\' AND Send_To_ACV__c = true';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(SchedulableContext sc) {
		BatchUnwindOutbound batchClass = new BatchUnwindOutbound();
		database.executebatch(batchClass,200);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Case> lUnwindCases = (List<Case>)scope;
		System.enqueueJob(new AcvIntegrationQueueableJob('Unwind Auction', lUnwindCases, null));   
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}