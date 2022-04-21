global class BatchTitleOutbound implements Database.Batchable<sObject>, Schedulable{
	
	String query;
	
	global BatchTitleOutbound() {
		Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		query = 'SELECT id, status, Auction_Number_Case__c, Title_Received_Date__c, Title_Sent_Date__c, ACV_Titles_External_ID__c, Easypost_Tracker__c  FROM Case WHERE RecordTypeId = \''+titleRecordTypeId+'\' AND Send_To_ACV__c = true';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(SchedulableContext sc) {
		BatchTitleOutbound batchClass = new BatchTitleOutbound();
		database.executebatch(batchClass,200);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Case> lTitleCases = (List<Case>)scope;
		System.enqueueJob(new AcvIntegrationQueueableJob('Update Title', lTitleCases, null));   
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}