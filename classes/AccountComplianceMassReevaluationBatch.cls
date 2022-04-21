global class AccountComplianceMassReevaluationBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public Map<Id, Account> accountsShouldBeCompliant = new Map<Id, Account>();
    public Map<Id, Account> accountsShouldBeOOC = new Map<Id, Account>();
    public static final Set<String> specialStates = new Set<String>{'NH', 'DE', 'OR', 'MT', 'AK'};
    public List<String> errorList = new List<String>();
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get id of transporter accounts to exclude them
        //0120a0000000MaNAAU
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        String query = 'SELECT Id, Dealership_Id__c, Dealer_Doc_Compliance__c, Active__c, RecordType.Name FROM Account WHERE RecordTypeId != :recordTypeId';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        //make the list into a map
        Map<Id, Account> accountMap = new Map<Id, Account>(scope);
        Map<Id, String> accountStates = new Map<Id, String>();
        Map<Id, Boolean> validResaleDoc = new Map<Id, Boolean>();
        Map<Id, Boolean> validLicenseDoc = new Map<Id, Boolean>();
        //query for dealer docs
        List<Dealer_Docs__c> docList = [SELECT Id, Account__c, Document_State__c, RecordTypeId FROM Dealer_Docs__c WHERE Compliant__c = true AND Account__c IN :accountMap.keyset()];
        //then evaluate each account for their compliance
        //need to loop over docs to figure out if there is a compliant license or resale doc and add them to maps
        //also need to get the account's correct state (based on Dealer License)
        for (Dealer_Docs__c d : docList) {
            if (accountStates.get(d.Account__c) == null) {
                accountStates.put(d.Account__c, d.Document_State__c);
            }
            else if (accountStates.get(d.Account__c) != null && d.RecordTypeId == licenseId && AccountComplianceMassReevaluationBatch.specialStates.contains(d.Document_State__c)) { //will only overwrite the account state if the doc is a license in a special state
                accountStates.put(d.Account__c, d.Document_State__c);
            }

            if (d.RecordTypeId == resaleId) {
                validResaleDoc.put(d.Account__c, true);
                if (validLicenseDoc.get(d.Account__c) == null) {
                    validLicenseDoc.put(d.Account__c, false);
                }
            }
            else if (d.RecordTypeId == licenseId) {
                validLicenseDoc.put(d.Account__c, true);
                if (validResaleDoc.get(d.Account__c) == null) {
                    validResaleDoc.put(d.Account__c, false);
                }
            }
        }
        //then loop over accounts
        for (Account a : accountMap.values()) {
            if (a.Dealer_Doc_Compliance__c == 'Compliant') {
                //if compliant: run check and see if still compliant or not
                if (AccountComplianceMassReevaluationBatch.specialStates.contains(accountStates.get(a.Id)) && (validLicenseDoc.get(a.Id) == false || validLicenseDoc.get(a.Id) == null)) {
                    //should be out of compliance
                    this.accountsShouldBeOOC.put(a.Id, a);
                }
                else if (!AccountComplianceMassReevaluationBatch.specialStates.contains(accountStates.get(a.Id)) && ((validLicenseDoc.get(a.Id) == false || validLicenseDoc.get(a.Id) == null) || (validResaleDoc.get(a.Id) == false || validResaleDoc.get(a.Id) == null))) {
                    //should be out of compliance
                    this.accountsShouldBeOOC.put(a.Id, a);
                }
            }
            else {
                //if not compliant: run check and see if still OOC or not
                if (AccountComplianceMassReevaluationBatch.specialStates.contains(accountStates.get(a.Id)) && validLicenseDoc.get(a.Id) == true) {
                    //should be compliant
                    this.accountsShouldBeCompliant.put(a.Id, a);
                }
                else if (!AccountComplianceMassReevaluationBatch.specialStates.contains(accountStates.get(a.Id)) && (validLicenseDoc.get(a.Id) == true && validResaleDoc.get(a.Id) == true)) {
                    //should be compliant
                    this.accountsShouldBeCompliant.put(a.Id, a);
                }
            }
        }
        //write update code for these, but make sure it is commented out:
        // Database.SaveResult[] mesgList = Database.update(accountsShouldBeCompliant.values(), false); //try to update docs
        // for (Database.SaveResult upRes : mesgList) {
        //     if (!upRes.isSuccess()) {
        //         //error message
        //         Database.Error errors = upRes.getErrors()[0];
        //         String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
        //         AccountComplianceMassReevaluationBatch.errorList.add(errMesg);
        //     }
        // }
        // Database.SaveResult[] mesgList2 = Database.update(accountsShouldBeOOC.values(), false); //try to update accounts
        // for (Database.SaveResult upRes2 : mesgList2) {
        //     if (!upRes2.isSuccess()) {
        //         //error message
        //         Database.Error errors2 = upRes2.getErrors()[0];
        //         String errMesg2 = 'ERROR on Id: ' + upRes2.getId() + '<br/>With Status Code of: ' + errors2.getStatusCode() + '<br/>And Error of: ' + errors2.getMessage();
        //         AccountComplianceMassReevaluationBatch.errorList.add(errMesg2);
        //     }
        // }
    }

    global void finish(Database.BatchableContext bc) {
        // System.debug(this.accountsShouldBeCompliant.values());
        // System.debug(this.accountsShouldBeOOC.values());
        //finish
        AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
        String[] toAddresses = new String[]{'kpriebe@acvauctions.com'}; //do want this one to email me directly
        mail.setToAddresses(toAddresses);
        mail.setSubject('AccountComplianceMassReevaluationBatch: ' + a.Status);
        String body = 'Results from AccountComplianceMassReevaluationBatch: <br/>' + 'Number of Batches Processed: ' + a.JobItemsProcessed + '<br/><br/>'; // + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>'
        body += 'TOTAL OUT OF COMPLIANCE -> COMPLIANT: ' + this.accountsShouldBeCompliant.size() + '<br/>';
        for (Account ac : this.accountsShouldBeCompliant.values()) {
            String debug = 'Salesforce Id: ' + this.accountsShouldBeCompliant.get(ac.Id).Id + ', Dealer Id: ' + this.accountsShouldBeCompliant.get(ac.Id).Dealership_Id__c + ', Active Status: ' + this.accountsShouldBeCompliant.get(ac.Id).Active__c + ', Dealer Type: ' + this.accountsShouldBeCompliant.get(ac.Id).RecordType.Name + ', Out of Compliance -> Compliant <br/>';
            System.debug(debug);
            body += 'Salesforce Id: ' + this.accountsShouldBeCompliant.get(ac.Id).Id + ', Dealer Id: ' + this.accountsShouldBeCompliant.get(ac.Id).Dealership_Id__c + ', Active Status: ' + this.accountsShouldBeCompliant.get(ac.Id).Active__c + ', Dealer Type: ' + this.accountsShouldBeCompliant.get(ac.Id).RecordType.Name + ', Out of Compliance -> Compliant <br/>';
        }
        body += '<br/> ------------------------------------------------- <br/> <br/>';
        body += 'TOTAL COMPLIANT -> OUT OF COMPLIANCE: ' + this.accountsShouldBeOOC.size() + '<br/>';
        for (Account acc : this.accountsShouldBeOOC.values()) {
            String debug2 = 'Salesforce Id: ' + this.accountsShouldBeOOC.get(acc.Id).Id + ', Dealer Id: ' + this.accountsShouldBeOOC.get(acc.Id).Dealership_Id__c + ', Active Status: ' + this.accountsShouldBeOOC.get(acc.Id).Active__c + ', Dealer Type: ' + this.accountsShouldBeOOC.get(acc.Id).RecordType.Name + ', Compliant -> Out of Compliance <br/>';
            System.debug(debug2);
            body += 'Salesforce Id: ' + this.accountsShouldBeOOC.get(acc.Id).Id + ', Dealer Id: ' + this.accountsShouldBeOOC.get(acc.Id).Dealership_Id__c + ', Active Status: ' + this.accountsShouldBeOOC.get(acc.Id).Active__c + ', Dealer Type: ' + this.accountsShouldBeOOC.get(acc.Id).RecordType.Name + ', Compliant -> Out of Compliance <br/>';
        }
        body += '<br/>' + this.accountsShouldBeCompliant;
        body += '<br/>' + this.accountsShouldBeOOC;
        mail.setHtmlBody(body);
        //System.debug(body);
        if (!test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        //is fine to have this not commented out since the only thing that populates it is commented out
        // if (this.errorList.size() > 0) {
        //     AsyncApexJob aaj = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        //     Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
        //     //String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
        //     String[] toAddresses2 = new String[]{'kpriebe@acvauctions.com'}; //do want this one to email me directly
        //     mail2.setToAddresses(toAddresses2);
        //     mail2.setSubject('AccountComplianceMassReevaluationBatch: ' + aaj.Status);
        //     String body2 = 'Results from AccountComplianceMassReevaluationBatch: <br/>' + 'Number of Batches Processed: ' + aaj.JobItemsProcessed + '<br/>Number of Errors: ' + aaj.NumberOfErrors + '<br/>';
        //     body2 += String.join(this.errorList, '<br/>');
        //     mail2.setHtmlBody(body2);
        //     if (!test.isRunningTest()) {
        //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //     }
        // }
    }

    global void execute(SchedulableContext sc) {
        //schedule
        AccountComplianceMassReevaluationBatch almb = new AccountComplianceMassReevaluationBatch();
        Database.executeBatch(almb, 50); //this is disgustingly small
    }
}