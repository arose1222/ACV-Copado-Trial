global class DealerDocTimeStampBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static List<String> errorList = new List<String>();
    public static final Set<String> specialStates = new Set<String>{'NH', 'DE', 'OR', 'MT', 'AK'};
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        String query = 'SELECT Id, Required_Docs_Uploaded__c, (SELECT Id, CreatedDate, RecordTypeId, Document_State__c FROM Dealer_Docs__r ORDER BY CreatedDate ASC) FROM Account WHERE RecordTypeId != :recordTypeId';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> acctsToUpdate = new List<Account>();

        for (Account a : scope) {
            DateTime firstLicense = null; //can i set these to null at first? or will i have to set to a temp future date?
            DateTime firstResale = null; //can i set these to null at first? or will i have to set to a temp future date?
            Boolean specialStateAccount = false;
            Boolean licProcessed = false;
            Boolean resProcessed = false;

            for (Dealer_Docs__c d : a.Dealer_Docs__r) {
                if (!licProcessed && d.RecordTypeId == licenseId) {
                    if (specialStates.contains(d.Document_State__c)) { //weakness - if the first dealer license isn't a speical state, but another one is - this will be weird
                        firstLicense = utcToEST(d.CreatedDate);
                        licProcessed = true;
                        specialStateAccount = true;
                    }
                    else {
                        firstLicense = utcToEST(d.CreatedDate);
                        licProcessed = true;
                    }
                }
                else if (!resProcessed && d.RecordTypeId == resaleId) {
                    firstResale = utcToEST(d.CreatedDate);
                    resProcessed = true;
                }
                
                if (specialStateAccount && licProcessed) {
                    a.Required_Docs_Uploaded__c = firstLicense;
                    acctsToUpdate.add(a);
                }
                else if (!specialStateAccount && licProcessed && resProcessed) {
                    if (firstLicense > firstResale) { //can i do this?
                        a.Required_Docs_Uploaded__c = firstLicense;
                        acctsToUpdate.add(a);
                    }
                    else if (firstResale >= firstLicense) { //can i do this? //also adding = because if they are the same it can just have the license date
                        a.Required_Docs_Uploaded__c = firstResale;
                        acctsToUpdate.add(a);
                    }
                }
                
                if ((licProcessed & resProcessed) || (licProcessed && specialStateAccount)) {
                    break;
                }
            }
        }
        Database.SaveResult[] mesgList = Database.update(acctsToUpdate, false); //try to update docs
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                DealerDocTimeStampBatch.errorList.add(errMesg);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        if (DealerDocTimeStampBatch.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('DealerDocTimeStampBatch: ' + a.Status);
            String body = 'Results from DealerDocTimeStampBatch: <br/>' + 'Number of Batches Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(DealerDocTimeStampBatch.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    global void execute(SchedulableContext sc) {
        //schedule
        DealerDocTimeStampBatch ddtsb = new DealerDocTimeStampBatch();
        Database.executeBatch(ddtsb, 50);
    }

    public static DateTime utcToEST(DateTime utcCreatedDate) {
        Integer Day = utcCreatedDate.Day();
        Integer Month = utcCreatedDate.Month();
        Integer Year = utcCreatedDate.Year();
        Integer Hour = utcCreatedDate.Hour(); //so this is showing up as the EST hour, but the value in the field at the end is UTC still
        Integer estHour = Hour - 5; //i don't know how this works, but it works
        Integer Minute = utcCreatedDate.Minute();
        Integer Second = utcCreatedDate.Second();
        DateTime correctedDateTime = DateTime.newInstance(Year, Month, Day, estHour, Minute, Second); //so when it creates the new instance, it makes it UTC. fun.
        //System.debug(correctedDateTime);
        return correctedDateTime;
    }
}