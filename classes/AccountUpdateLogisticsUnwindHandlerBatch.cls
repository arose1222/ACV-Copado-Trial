global class AccountUpdateLogisticsUnwindHandlerBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<String> errorList = new List<String>();

    global Database.QueryLocator start (Database.BatchableContext bc) {
        String query = 'SELECT Id, Date_of_First_Buy__c, Date_of_Last_Purchase__c, Date_of_Last_Sale__c, Flagged_for_Unwind_Batch__c FROM Account WHERE Flagged_for_Unwind_Batch__c != NULL';
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc, List<Account> scope){
        for (Account a : scope) {
            System.debug('Flag value: ' + a.Flagged_for_Unwind_Batch__c);
            if (a.Flagged_for_Unwind_Batch__c == 'seller') {
                //process setting of last sale date
                //query for the most recent accepted auction where seller is the account
                Id sellerId = a.Id;
                Auction__c latestSale = [SELECT Id, End_Time__c FROM Auction__c WHERE Seller_Dealership__c = :sellerId AND Status__c LIKE '%_Accepted' ORDER BY End_Time__c DESC LIMIT 1];
                //set last_sold to the end_time
                //a.Date_of_Last_Sale__c = latestSale[0].End_Time__c;
                if (latestSale != null) {
                    a.Date_of_Last_Sale__c = date.valueOf(latestSale.End_Time__c);
                }
                else {
                    a.Date_of_Last_Sale__c = null;
                }
            }
            else if (a.Flagged_for_Unwind_Batch__c == 'buyerFirst') {
                //process setting date of first purchase
                //query for the oldest accepted auction where buyer is the account
                Id buyerFirstId = a.Id;
                Auction__c firstBuy = [SELECT Id, End_Time__c FROM Auction__c WHERE Buyer_Dealership__c = :buyerFirstId AND Status__c LIKE '%_Accepted' ORDER BY End_Time__c ASC LIMIT 1];
                //set date_of_first_buy to end_time
                //a.Date_of_First_Buy__c = date.valueOf(firstBuy[0].End_Time__c);
                if (firstBuy != null) {
                    a.Date_of_First_Buy__c = date.valueOf(firstBuy.End_Time__c);
                }
                else {
                    a.Date_of_First_Buy__c = null;
                }
            }
            else if (a.Flagged_for_Unwind_Batch__c == 'buyerLast') {
                //process setting date of last purchase
                //query for the most recent accepted auction where buyer is the account
                Id buyerLastId = a.Id;
                Auction__c lastBuy = [SELECT Id, End_Time__c FROM Auction__c WHERE Buyer_Dealership__c = :buyerLastId AND Status__c LIKE '%_Accepted' ORDER BY End_Time__c DESC LIMIT 1];
                //set date_of_last_purchase to end_time
                //a.Date_of_Last_Purchase__c = date.valueOf(lastBuy[0].End_Time__c);
                if (lastBuy != null) {
                    a.Date_of_Last_Purchase__c = date.valueOf(lastBuy.End_Time__c);
                }
                else {
                    a.Date_of_First_Buy__c = null;
                }
            }
            else if (a.Flagged_for_Unwind_Batch__c == 'firstAndLast') {
                //process setting date of first and last purchase together
                //if both first and last dates are unwound, there are no other auctions
                //both date fields need to be set to null
                a.Date_of_First_Buy__c = null;
                a.Date_of_Last_Purchase__c = null;
            }
            else {
                //add and error
                //take note of flagged value
                String loopErr = 'ERROR: Account did not meet conditional criteria.<br/>Account Id: ' + a.Id + '<br/>Flag value: ' + a.Flagged_for_Unwind_Batch__c;
                errorList.add(loopErr);
            }
            a.Flagged_for_Unwind_Batch__c = null;
        }

        Database.SaveResult[] mesgList = Database.update(scope, false);
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                errorList.add(errMesg);
            }
        }
    }

    global void finish (Database.BatchableContext bc) {
        if (errorList.size() > 0) {
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('AccountUpdateLogisticsUnwindHandlerBatch: ' + a.Status);
            String body = 'Results from AccountUpdateLogisticsUnwindHandlerBatch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(errorList, '<br/>');
            mail.setHtmlBody(body);
            if(!Test.isRunningTest()){ Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}
        }
    }
}