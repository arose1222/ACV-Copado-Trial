global class DealerDocExpirationHandler extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful {
    public static List<String> errorList = new List<String>();
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    public static final Id confirmationId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('License_Renewal_Confirmation').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Expiration_Date__c, Document_Expired__c, Review_Status__c, RecordTypeId, Compliant__c, Compliance_Issues__c, Account__c, Account__r.Name, Document_State__c, Related_Dealer_License__c FROM Dealer_Docs__c WHERE (Expiration_Date__c <= TODAY AND Document_Expired__c = false AND No_Expiration__c = false)';
        //Account__r.IST_Account_Owner__r.Email, (pulling this out)
        //select (a bunch of fields) from Dealer Docs where:
        //expiration date is today or earlier,
        //document is not marked as expired yet,
        //and no expiration is not checked
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Dealer_Docs__c> scope) {
        Set<String> specialStates = new Set<String>{'NH', 'DE', 'OR', 'MT', 'AK'};
        Set<Id> cdocDealersToday = new Set<Id>();
        Set<Id> cdocRelatedLicToday = new Set<Id>();
        List<Dealer_Docs__c> expTwoWeeks = new List<Dealer_Docs__c>();
        Map<Id, List<Dealer_Docs__c>> confirmationDocsExpTwoWeeks = new Map<Id, List<Dealer_Docs__c>>();
        for (Dealer_Docs__c d : scope) {
            if (d.RecordTypeId == confirmationId) {
                cdocDealersToday.add(d.Account__c);
                cdocRelatedLicToday.add(d.Related_Dealer_License__c);
                d.Document_Expired__c = true;
                d.Compliant__c = false;
                d.Compliance_Issues__c = 'Document expired';
                d.Review_Status__c = null;
            }
            else {
                if (d.RecordTypeId == licenseId || d.RecordTypeId == resaleId) {
                    d.Document_Expired__c = true;
                    d.Compliant__c = false;
                    d.Compliance_Issues__c = 'Document expired';
                    d.Review_Status__c = null;
                }
            }
        }

        if (!cdocRelatedLicToday.isEmpty()) {
            ConfirmationDocExpirationLogic.handleExpiringToday(cdocDealersToday, cdocRelatedLicToday); //this will handle the license expiration
        }

        Database.SaveResult[] mesgList = Database.update(scope, false); //try to update docs
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                DealerDocExpirationHandler.errorList.add(errMesg);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //finish
        if (DealerDocExpirationHandler.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('DealerDocExpirationHandler: ' + a.Status);
            String body = 'Results from DealerDocExpirationHandler Batch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(DealerDocExpirationHandler.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    public override void executeScheduledLogic() {
        //schedule
        DealerDocExpirationHandler almb = new DealerDocExpirationHandler();
        Database.executeBatch(almb, 200);
    }
}