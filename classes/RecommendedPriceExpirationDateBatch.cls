global class RecommendedPriceExpirationDateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static List<String> errorList = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //string query
        String query = 'SELECT Id, Expiration_Date__c, Recommended_Price_Active__c, Pricing_Status__c FROM Recommended_Price__c WHERE Expiration_Date__c <= TODAY AND Recommended_Price_Active__c = TRUE AND Pricing_Status__c != \'Expired\'';
        //return
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Recommended_Price__c> scope){
        //batch process
        for (Recommended_Price__c r : scope) {
            //changing record to inactive
            r.Recommended_Price_Active__c = false;
            //marking as expired in picklist
            r.Pricing_Status__c = 'Expired';
        }
        //update records
        Database.SaveResult[] mesgList = Database.update(scope, false); //try to update docs
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                RecommendedPriceExpirationDateBatch.errorList.add(errMesg);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //error handling/emailing
        if (RecommendedPriceExpirationDateBatch.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('RecommendedPriceExpirationDateBatch: ' + a.Status);
            String body = 'Results from RecommendedPriceExpirationDateBatch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(RecommendedPriceExpirationDateBatch.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    global void execute(SchedulableContext sc) {
        //scheduling
        RecommendedPriceExpirationDateBatch rpedb = new RecommendedPriceExpirationDateBatch();
        Database.executeBatch(rpedb, 200);
    }
}