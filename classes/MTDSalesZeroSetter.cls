global class MTDSalesZeroSetter implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static List<String> toSendList = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get is of transporter accounts to exclude them
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        //0120a0000000MaNAAU
        //query
        String query = 'SELECT Id, MTD_Sales__c FROM Account WHERE RecordTypeId != :recordTypeId AND MTD_Sales__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        //simply set MTD_Sales__c == 0 for all accounts
        for (Account a : scope) {
            a.MTD_Sales__c = 0;
        }

        //update accounts
        Database.SaveResult[] mesgList = Database.update(scope, false); //try to update account
        if (mesgList.size() > 0) { //null handler
            for (Database.SaveResult upRes : mesgList) {
                if (upRes.isSuccess()) {
                    //success message
                    String sucMesg = 'SUCCESS on Id: ' + upRes.getId();
                    MTDSalesZeroSetter.toSendList.add(sucMesg);
                }
                else {
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    MTDSalesZeroSetter.toSendList.add(errMesg);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //finish
        if (MTDSalesZeroSetter.toSendList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('MTDSalesZeroSetter: ' + a.Status);
            String body = 'Results from MTDSalesZeroSetter: <br/>' + 'Number of Batches Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(MTDSalesZeroSetter.toSendList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    global void execute(SchedulableContext sc) {
        //schedule
        MTDSalesZeroSetter dfsb = new MTDSalesZeroSetter();
        Database.executeBatch(dfsb, 50);
    }
}