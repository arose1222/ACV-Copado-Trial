global class AccountLogisticsMainBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    global Database.QueryLocator start (Database.BatchableContext bc) {
        String query = 'SELECT Id, Status__c, End_Time__c, Counted_for_Account_Logistics__c, Buyer_Dealership__c, Seller_Dealership__c FROM Auction__c WHERE (Status__c LIKE \'%_Accepted\' AND End_Time__c != null AND Buyer_Dealership__c != null AND Seller_Dealership__c != null AND Counted_for_Account_Logistics__c = false) OR (Status__c = \'Ended_Unwound\' AND End_Time__c != null AND Buyer_Dealership__c != null AND Seller_Dealership__c != null AND Counted_for_Account_Logistics__c = true)';
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc, List<Auction__c> scope){
        AccountUpdateLogisticsFromAuction.run(scope);
    }

    global void finish (Database.BatchableContext bc) {
        List<SplunkHelper.SFErrorRecord> dummyErrorList = new List<SplunkHelper.SFErrorRecord>();
        Set<String> dummySuccessSet = new Set<String>(); //adding these two to use the .processBatchLog call, but they are not needed for the way i will be using the splunk alert

        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'Account Logistics Main Batch';
        log.sfObject = 'Account';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.SALES);
        log.logLevel = SplunkHelper.LOGLEVEL.INFO;
        log.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        log.sfRecordId = bc.getJobId();
        log.stackTrace = 'AccountLogisticsMainBatch: '+ACVUtility.currentLineNumber()+2;
        log.location = 'AccountLogisticsMainBatch: '+ACVUtility.currentLineNumber()+1;
        log.message = 'Account Logistics Main Batch still running.';
        SplunkHelper.processBatchLog(log, dummyErrorList, dummySuccessSet);

        ACVUtility.scheduleJob(System.now().addMinutes(2), 'AccountLogisticsMainBatch');

        if (AccountUpdateLogisticsFromAuction.accountErrorList.size() > 0 || AccountUpdateLogisticsFromAuction.auctionErrorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('AccountLogisticsMainBatch: ' + a.Status);
            String body = 'Results from AccountUpdateLogisticsFromAuction / AccountLogisticsMainBatch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(AccountUpdateLogisticsFromAuction.accountErrorList, '<br/>');
            body += String.join(AccountUpdateLogisticsFromAuction.auctionErrorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    global void execute (SchedulableContext sc) {
       AccountLogisticsMainBatch almb = new AccountLogisticsMainBatch();
       Database.executeBatch(almb, 50);
    }
}