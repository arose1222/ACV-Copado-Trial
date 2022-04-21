global class DealerDocAttachmentMarkBackfillBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id from Dealer_Docs__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Dealer_Docs__c> scope) {
        Map<Id,Dealer_Docs__c> docMap = new Map<Id,Dealer_Docs__c>(scope);
        if(docMap.keySet().size() > 0){
            update [Select id from ContentDocumentLink where LinkedEntityId In :docMap.keySet()];
        }
    }

    global void finish(Database.BatchableContext bc) {
    }

    global void execute(SchedulableContext sc) {
        //schedule
        DealerDocAttachmentMarkBackfillBatch batch = new DealerDocAttachmentMarkBackfillBatch();
        Database.executeBatch(batch, 200);
    }
}