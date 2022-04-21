global class DealerDocExpirationReminderHandler extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful {
    public static List<String> errorList = new List<String>();
    public static Date fourteen = System.Today().addDays(14);
    public static Date thirty = System.Today().addDays(30);
    public static Date fortyfive = System.Today().addDays(45);

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date days14 = DealerDocExpirationReminderHandler.fourteen;
        Date days30 = DealerDocExpirationReminderHandler.thirty;
        Date days45 = DealerDocExpirationReminderHandler.fortyfive;
        String query = 'SELECT Id, Expiration_Date__c, Reminder_Email_Sent__c FROM Dealer_Docs__c WHERE Expiration_Date__c = :days14 OR Expiration_Date__c = :days30 OR Expiration_Date__c = :days45';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Dealer_Docs__c> scope) {
        Date days14 = DealerDocExpirationReminderHandler.fourteen;
        Date days30 = DealerDocExpirationReminderHandler.thirty;
        Date days45 = DealerDocExpirationReminderHandler.fortyfive;
        List<Dealer_Docs__c> days14Docs = new List<Dealer_Docs__c>();
        List<Dealer_Docs__c> days30Docs = new List<Dealer_Docs__c>();
        List<Dealer_Docs__c> days45Docs = new List<Dealer_Docs__c>();
        List<Dealer_Docs__c> docsToUpdate = new List<Dealer_Docs__c>();

        for (Dealer_Docs__c d : scope) {
            if (days14 == d.Expiration_Date__c) {
                days14Docs.add(d);
            }
            else if (days30 == d.Expiration_Date__c) {
                days30Docs.add(d);
            }
            else if (days45 == d.Expiration_Date__c) {
                days45Docs.add(d);
            }
        }

        if (days14Docs.size() > 0) {
            days14Docs = updateCheckbox(days14Docs, 'Reminder_Email_Sent__c');
            docsToUpdate.addAll(days14Docs);
        }

        if (days30Docs.size() > 0) {
            days30Docs = updateCheckbox(days30Docs, 'Thirty_Day_Reminder_Email_Sent__c');
            docsToUpdate.addAll(days30Docs);
        }

        if (days45Docs.size() > 0) {
            days45Docs = updateCheckbox(days45Docs, 'Forty_Five_Day_Reminder_Email_Sent__c');
            docsToUpdate.addAll(days45Docs);
        }

        if (docsToUpdate.size() > 0) {
            //update docsToUpdate; //but do it the fancy way
            Database.SaveResult[] mesgList = Database.update(docsToUpdate, false); //try to update docs
            for (Database.SaveResult upRes : mesgList) {
                if (!upRes.isSuccess()) {
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    DealerDocExpirationReminderHandler.errorList.add(errMesg);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (DealerDocExpirationReminderHandler.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('DealerDocExpirationReminderHandler: ' + a.Status);
            String body = 'Results from DealerDocExpirationReminderHandler Batch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(DealerDocExpirationReminderHandler.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    public override void executeScheduledLogic() {
        //schedule
        DealerDocExpirationReminderHandler dderh = new DealerDocExpirationReminderHandler();
        Database.executeBatch(dderh, 200);
    }

    public static List<Dealer_Docs__c> updateCheckbox(List<Dealer_Docs__c> docList, String fieldName) {
        for (Dealer_Docs__c dd : docList) {
            dd.put(fieldName, true);
        }
        return docList;
    }
}