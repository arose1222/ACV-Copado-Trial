global class DealerDocInfoAccountPopulationBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static List<String> errorList = new List<String>();
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        String query = 'SELECT Id, License_Number__c, Permit_Resale_Number__c FROM Account WHERE License_S3_Link__c= \'\' or Permit_Resale_S3_Link__c=\'\'';
		return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext bc, List<sObject> scope) {
        List<Account> acctList = (List<Account>)scope;
        Map<Id, Account> accountMap = new Map<Id, Account>(); 
        Map<Id, List<Dealer_Docs__c>> docMap = new Map<Id, List<Dealer_Docs__c>>();
        List<Dealer_Docs__c> dealerdocs= [SELECT Id, RecordTypeId, Account__c, S3_Link__c, License_Number__c, Permit_Resale_Number__c, CreatedDate FROM Dealer_Docs__c WHERE Compliant__c = true AND Account__c IN :scope Order by CreatedDate asc];
        for (Dealer_Docs__c d : dealerdocs) {
            System.Debug(dealerdocs.size());
            if (docMap.get(d.Account__c) == null) {
                docMap.put(d.Account__c, new List<Dealer_Docs__c>());
            }
            docMap.get(d.Account__c).add(d);
        }

        for (Account a : acctList) {
            if (docMap.get(a.Id) != null) {
                Datetime latestLicenseDate= DateTime.newInstance(1700, 1, 1, 0, 0, 0);//Min Date
                Datetime latestResaleDate= DateTime.newInstance(1700, 1, 1, 0, 0, 0);//Min Date
                String licenseS3Link='';
                String resaleS3Link='';
               // String licenseNumber='';
                //String resaleNumber='';

                for (Dealer_Docs__c d : docMap.get(a.Id)) {
                    if (d.RecordTypeId == licenseId && d.CreatedDate>latestLicenseDate && a.License_Number__c == d.License_Number__c) {
                        licenseS3Link= d.S3_Link__c; 
                        latestLicenseDate= d.CreatedDate;
                       // licenseNumber= d.License_Number__c;
                    }
                    else if (d.RecordTypeId == resaleId && d.CreatedDate>latestResaleDate && a.Permit_Resale_Number__c == d.Permit_Resale_Number__c ) {
                        resaleS3Link= d.S3_Link__c; 
                        latestResaleDate= d.CreatedDate;
                       // resaleNumber= d.Permit_Resale_Number__c;
                    }
                }

                if (!string.isblank(licenseS3Link) && !string.isblank(resaleS3Link)) {
                    Account updated = new Account(Id = a.Id, License_S3_Link__c = licenseS3Link, Permit_Resale_S3_Link__c= resaleS3Link);
                    accountMap.put(updated.Id, updated);
                }
                else if(!string.isblank(licenseS3Link))
                {
                    Account updated = new Account(Id = a.Id, License_S3_Link__c = licenseS3Link);
                    accountMap.put(updated.Id, updated);
                }
                else if(!string.isblank(resaleS3Link))
                {
                    Account updated = new Account(Id = a.Id, Permit_Resale_S3_Link__c= resaleS3Link);
                    accountMap.put(updated.Id, updated);
                }
            }
        }

        //update accountMap.values(); //but do it the fancy, feedback filled, way
        if (accountMap.values().size() > 0) {
            Database.SaveResult[] mesgList = Database.update(accountMap.values(), false);
            for (Database.SaveResult upRes : mesgList) {
                if (!upRes.isSuccess()) {
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    DealerDocInfoAccountPopulationBatch.errorList.add(errMesg);
                }
            }
        }
    }

    global void finish (Database.BatchableContext bc) {
        //finish and send emails if anything goes wrong or just a summary about the ones that were successful
        if (DealerDocInfoAccountPopulationBatch.errorList.size() > 0) {
            AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:bc.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            String[] toAddresses = new String[]{'v-jpelpudi@acvauctions.com', 'arichbart@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('DealerDocInfoAccountPopulationBatch: ' + a.Status);
            String body = 'Results from DealerDocInfoAccountPopulationBatch: <br/>' + 'Number of Items Processed: ' + a.JobItemsProcessed + '<br/>Number of Errors: ' + a.NumberOfErrors + '<br/>';
            body += String.join(DealerDocInfoAccountPopulationBatch.errorList, '<br/>');
            mail.setHtmlBody(body);
            if (!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }

    global void execute(SchedulableContext sc) {
        //schedule
        DealerDocInfoAccountPopulationBatch ddi = new DealerDocInfoAccountPopulationBatch();
        Database.executeBatch(ddi, 25); //updating accounts, starting with 50 batch size - dropping to 25
    }
}