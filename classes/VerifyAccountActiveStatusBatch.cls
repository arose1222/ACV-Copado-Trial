global class VerifyAccountActiveStatusBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful {
    public static List<String> errorList = new List<String>();
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //query
        String query = 'SELECT Id, Dealer_Doc_Compliance__c, Set_Active_Account_Check_Date__c, Name FROM Account WHERE Set_Active_Account_Check_Date__c <= TODAY';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        //execute
        System.debug('Scope: ' + scope);
        Set<String> specialStates = new Set<String>{'NH', 'DE', 'OR', 'MT', 'AK'}; //document_state__c is a picklist so no need to include full state names
        Map<Id, String> accountStates = new Map<Id, String>();
        Map<Id, Boolean> validResaleDocs = new Map<Id, Boolean>();
        Map<Id, Boolean> validLicenseDocs = new Map<Id, Boolean>();
        Set<Id> accountIdSet = new Set<Id>();
        for (Account a : scope) {
            accountIdSet.add(a.Id);
        }

        List<Dealer_Docs__c> docList = [SELECT Id, Expiration_Date__c, Compliant__c, RecordTypeId, Document_State__c, Account__c FROM Dealer_Docs__c WHERE (Expiration_Date__c > TODAY OR No_Expiration__c = true) AND Compliant__c = true AND Account__c IN :accountIdSet];

        for (Dealer_Docs__c d : docList) {
            if (accountStates.get(d.Account__c) == null) {
                //need to crate a map with the account id and the string of the state (gotten from the document state field on dealer docs)
                accountStates.put(d.Account__c, d.Document_State__c);
            }

            if (d.RecordTypeId == resaleId) {
                validResaleDocs.put(d.Account__c, true);
            }
            else if (d.RecordTypeId == licenseId) {
                validLicenseDocs.put(d.Account__c, true);
            }
        }

        for (Account ac : scope) {
            if (ac.Dealer_Doc_Compliance__c == 'Compliant') {
                if (accountStates.get(ac.Id) == null) { //account has no valid docs at all
                    //mark as out of compliance
                    ac.Dealer_Doc_Compliance__c = 'Out Of Compliance';
                }
                else if (specialStates.contains(accountStates.get(ac.Id)) && (validLicenseDocs.get(ac.Id) == false || validLicenseDocs.get(ac.Id) == null)) { //account is in one of the special states and there is no valid license
                    //mark as out of compliance
                    ac.Dealer_Doc_Compliance__c = 'Out Of Compliance';
                }
                else if (!specialStates.contains(accountStates.get(ac.Id)) && ((validLicenseDocs.get(ac.Id) == false || validLicenseDocs.get(ac.Id) == null) || (validResaleDocs.get(ac.Id) == false || validResaleDocs.get(ac.Id) == null))) { //account is in a normal state and either there is no valid license or resale cert
                    //mark as out of compliance
                    ac.Dealer_Doc_Compliance__c = 'Out Of Compliance';
                }

                ac.Set_Active_Account_Check_Date__c = null; //null field so it is not included in the batch again
            }
            else { //if the account is already out of compliance, no need to check
                ac.Set_Active_Account_Check_Date__c = null; //null field so it is not included in the batch again
            }
        }
        //update accounts
        Database.SaveResult[] mesgList = Database.update(scope, false); //try to update docs
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                VerifyAccountActiveStatusBatch.errorList.add(errMesg);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //finish
        if (VerifyAccountActiveStatusBatch.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('VerifyAccountActiveStatusBatch: ' + a.Status);
            String body = 'Results from VerifyAccountActiveStatusBatch: <br/>' + 'Number of Batches Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(VerifyAccountActiveStatusBatch.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    public override void executeScheduledLogic() {
        //schedule
        VerifyAccountActiveStatusBatch almb = new VerifyAccountActiveStatusBatch();
        Database.executeBatch(almb, 200);
    }
}