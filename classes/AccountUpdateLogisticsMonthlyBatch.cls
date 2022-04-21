global class AccountUpdateLogisticsMonthlyBatch implements Database.Batchable<sObject>, Database.Stateful {
    //private String query;
    List<String> messageList = new List<String>();
    String debug = '';
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        //String query = 'SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c FROM Account WHERE MTD_Purchases__c != NULL AND Purchase_Last_Month__c != NULL AND ((MTD_Purchases__c = 0 AND Purchase_Last_Month__c != 0) OR (MTD_Purchases__c != 0 AND Purchase_Last_Month__c = 0) OR (MTD_Purchases__c != 0 AND Purchase_Last_Month__c != 0))';
        String query = 'SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c, MTD_Sales__c FROM Account WHERE MTD_Purchases__c != NULL OR MTD_Sales__c != 0';
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc, List<Account> scope){
        Map<Id, Decimal> mtdMap = new Map<Id, Decimal>();
        for (Account a : scope) {
            Decimal tempMTD = a.MTD_Purchases__c;
            a.Purchase_Last_Month__c = tempMTD;
            a.MTD_Purchases__c = 0;
            a.MTD_Sales__c = 0;
            mtdMap.put(a.Id, tempMTD);
        }
        Database.SaveResult[] mesgList = Database.update(scope, false);
        for (Database.SaveResult upRes : mesgList) {
            if (upRes.isSuccess()) {
                //success message
                String sucMesg = 'SUCCESS on Id: ' + upRes.getId() + ' - New Purchased Last Month Value: ' + mtdMap.get(upRes.getId());
                messageList.add(sucMesg);
            }
            else {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                messageList.add(errMesg);
            }
        }
        //update scope;
    }

    global void finish (Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
        //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('AccountUpdateLogisticsMonthlyBatch: ' + a.Status);
        String body = 'Results from AccountUpdateLogisticsMonthlyBatch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
        body += String.join(messageList, '<br/>');
        mail.setHtmlBody(body);
        if (!test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}