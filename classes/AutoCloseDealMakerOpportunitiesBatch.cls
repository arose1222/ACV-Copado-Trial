global class AutoCloseDealMakerOpportunitiesBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id DealerMakerOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Maker').getRecordTypeId();
        Date proposedClosedDate = System.Today().addDays(-1);

        List<String> auctionsListNegotiating = new List<String>{'awaiting_acceptance, counter_sent, active'};
        String query = 'Select Id, StageName, Objection__c, Auction_ID__c From Opportunity Where CloseDate = :proposedClosedDate AND RecordTypeId = :DealerMakerOppRecordType AND isClosed = FALSE AND Auction__r.status__c NOT IN :auctionsListNegotiating';
        System.debug(query); 

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List <Opportunity> oppList = (List <Opportunity>)scope;

        for (Opportunity o :oppList) {
            o.Objection__c = 'ACV Fees'; // might need to revisit this, currently field validation rule is blocking close unless we populate this
            o.StageName = 'Closed Lost';
            o.Auction_ID__c = '';
        }

        update oppList;
    }

    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('AutoCloseDealMakerOpportunitiesBatch: ' + a.Status);
        mail.setPlainTextBody('DealMaker Opportunity Batch Status \n SUCCESS: ' + a.JobItemsProcessed + '\n FAIL: '+ a.NumberOfErrors);
        if(!Test.isRunningTest()) {Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}
    }
}