global class ISTAccountEmailBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable { //ONE TIME ONLY BATCH FOR BACKFILL PURPOSES
    public List<String> errorList = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //get id of transporter accounts to exclude them
        //0120a0000000MaNAAU
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        String query = 'SELECT Id, IST_Account_Owner__c, IST_Account_Owner__r.Email, Owner.Email FROM Account WHERE RecordTypeId != :recordTypeId';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        //so if we query for accounts the for loop will look like this:
        Map<Id, Account> accountMap = new Map<Id, Account>(scope);
        Map<Id, Dealer_Docs__c> docsToUpdate = new Map<Id, Dealer_Docs__c>();
        //query for dealer docs
        List<Dealer_Docs__c> docList = [SELECT Id, IST_Account_Manager_Email__c, TM_Email__c, Account__r.IST_Account_Owner__c, Account__r.IST_Account_Owner__r.Email, Account__r.Owner.Email FROM Dealer_Docs__c WHERE Account__c IN :accountMap.keyset()];
        //then i should loop over docs
        for (Dealer_Docs__c d : docList) {
            if (d.TM_Email__c != accountMap.get(d.Account__c).Owner.Email) {
                //docMap.get(d.Id).IST_Account_Manager_Email__c = accountMap.get(d.Account__c).IST_Account_Owner__r.Email;
                d.TM_Email__c = accountMap.get(d.Account__c).Owner.Email;
                docsToUpdate.put(d.Id, d);
            }

            if (d.IST_Account_Manager_Email__c != accountMap.get(d.Account__c).IST_Account_Owner__r.Email) {
                d.IST_Account_Manager_Email__c = accountMap.get(d.Account__c).IST_Account_Owner__r.Email;
                docsToUpdate.put(d.Id, d);
            }
        }
        if (docsToUpdate.values().size() > 0) { // if there are docs to update, update them
            Database.SaveResult[] mesgList = Database.update(docsToUpdate.values(), false); //try to update accounts
            for (Database.SaveResult upRes : mesgList) {
                if (!upRes.isSuccess()) {
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    this.errorList.add(errMesg);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        //finish
        //System.debug(this.errorList.size());
        if (this.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            //String[] toAddresses = new String[]{'kpriebe@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('ISTAccountEmailBatch: ' + a.Status);
            String body = 'Results from ISTAccountEmailBatch: <br/>' + 'Number of Batches Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(this.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    global void execute(SchedulableContext sc) {
        //schedule
        ISTAccountEmailBatch almb = new ISTAccountEmailBatch();
        Database.executeBatch(almb, 50);
    }
}