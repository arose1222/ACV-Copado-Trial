global class DealerDocComplianceBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    global static List<String> errorLst = new List<String>();
    // final static String RESALE = 'Resale Certificate';
    // final static String DEALER_LICENSE = 'Dealer License';
    final static Set<String> specialStates = new Set<String>{'DE', 'NH', 'OR', 'AK', 'MT'};
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    final static Set<Id> DOC_TYPE_CHECK = new Set<Id>{ resaleId, licenseId };

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        final Boolean TRUE_VAR = TRUE;

        String query = 'SELECT Id, Compliant_Dealer_License__c, Compliant_Resale_Certificate__c, ';
        query += '( SELECT Id, Compliant__c, RecordTypeId, Account__c, Document_State__c FROM Dealer_Docs__r WHERE Compliant__c = :TRUE_VAR ) ';
        query += 'FROM Account';

		return Database.getQueryLocator( query );
	}

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        //List<Account> acctUpdateLst = new List<Account>();
        Map<Id, Account> acctUpdateMap = new Map<Id, Account>();

        for ( Account acct : (List<Account>) scope ) {
            Boolean isResaleCompliant = FALSE;
            Boolean isDealerCompliant = FALSE;
            Boolean isSpecialState = false;

            for ( Dealer_Docs__c doc : acct.Dealer_Docs__r ) {
                if ( doc.Compliant__c ) {
                    if ( doc.RecordTypeId == resaleId ) {
                        isResaleCompliant = TRUE;
                    } else if ( doc.RecordTypeId == licenseId ) {
                        isDealerCompliant = TRUE;
                        if (specialStates.contains(doc.Document_State__c)) { //if the license is in a special state, make boolean true
                            isSpecialState = true;
                        }
                    }

                    if ( isDealerCompliant && isResaleCompliant ) {
                        break;
                    }
                }
            }

            if ( isResaleCompliant && !acct.Compliant_Resale_Certificate__c ) {
                acct.Compliant_Resale_Certificate__c = true;
                acctUpdateMap.put(acct.Id, acct);
            }
            else if ( !isResaleCompliant && acct.Compliant_Resale_Certificate__c && !isSpecialState ) { //only change to false if there is no doc and it's not a special state
                acct.Compliant_Resale_Certificate__c = false;
                acctUpdateMap.put(acct.Id, acct);
            }

            if ( isDealerCompliant && !acct.Compliant_Dealer_License__c ) {
                acct.Compliant_Dealer_License__c = true;
                if (acctUpdateMap.get(acct.Id) == null) {
                    acctUpdateMap.put(acct.Id, acct);
                }
                else {
                    acctUpdateMap.get(acct.Id).Compliant_Dealer_License__c = true;
                }
            }
            else if ( !isDealerCompliant && acct.Compliant_Dealer_License__c ) {
                acct.Compliant_Dealer_License__c = false;
                if (acctUpdateMap.get(acct.Id) == null) {
                    acctUpdateMap.put(acct.Id, acct);
                }
                else {
                    acctUpdateMap.get(acct.Id).Compliant_Dealer_License__c = false;
                }
            }
        }

        //if (acctUpdateMap.values() > 0) {
            Database.SaveResult[] saveResultLst = Database.update( acctUpdateMap.values(), FALSE );
            System.debug(saveResultLst.size());
            for ( Integer position = 0; position < saveResultLst.size(); position++ ) {
                Database.SaveResult saveRecord = saveResultLst[position];
    
                System.debug(saveRecord.isSuccess());
                System.debug(Test.isRunningTest());
                System.debug(DealerDocComplianceTest.BatchTestFlag);
                if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && DealerDocComplianceTest.BatchTestFlag ) ) {
                    String errorStrMsg = 'Error Updating Account Id ' + saveRecord.getId() + ' has occurred. Error Messages: ';
                    List<String> strMsgLst = new List<String>();
                    for ( Database.Error errorMsg : saveRecord.getErrors() ) {
                        strMsgLst.add( errorMsg.getMessage() );
                    }
                    errorLst.add( errorStrMsg + String.join( strMsgLst, '; ' ) );
                }
            }
        //}
    }

    global void finish(Database.BatchableContext BC) {
        if ( !errorLst.isEmpty() ) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SF-DevAlerts@acvauctions.com'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Account Dealer Doc Update - Results Batch Errors!');
            mail.setPlainTextBody('Account Dealer Doc Update Batch has resulted in the followiong errors: \n' + String.join( errorLst, '\n' ) );
            if ( !Test.isRunningTest() ) { Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } ); }
        }
    }

    global void execute(SchedulableContext sc) {
        DealerDocComplianceBatch ddcb = new DealerDocComplianceBatch();
        Database.executeBatch(ddcb, 50);
    }
}