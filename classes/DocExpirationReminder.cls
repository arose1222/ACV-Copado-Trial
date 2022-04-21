public without sharing class DocExpirationReminder extends TriggerInterface {
    public static final Set<String> exculdedStates = new Set<String>{'IL', 'AZ', 'MI', 'NE', 'WA', 'FL', 'LA', 'ME', 'AL', 'IA'}; //for some of the code based validation rules
    public static final Set<String> specialStates = new Set<String>{'NH', 'DE', 'OR', 'MT', 'AK'}; //document_state__c is a picklist so no need to include full state names
    public static final Set<String> goodInactiveReasons = new Set<String>{'1', '8', null}; //Incomplete, Dealer Docs Out of Compliance
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    public static final Id confirmationId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('License_Renewal_Confirmation').getRecordTypeId();

    public override void beforeInsert(List<sObject> objectList) {
        //get list of docs
        List<Dealer_Docs__c> docList = (List<Dealer_Docs__c>)objectList;
        Map<String, Dealer_Docs__c> confirmationDocsMap = new Map<String, Dealer_Docs__c>(); 
        Set<Id> accountIds = new Set<Id>();
        //for each doc:
        for (Dealer_Docs__c d : docList) {
            accountIds.add(d.Account__c); //get a set of accountId's for each doc being inserted
        }

        List<Account> accountList = [SELECT Id, Dealer_Doc_Compliance__c, Compliant_Resale_Certificate__c, Inactive_Sub_Status__c, Active__c FROM Account WHERE Id IN :accountIds];

        //Map<Id, Account> accountEmails = new Map<Id, Account>(); //IST_Account_Owner__r.Email, Owner.Email, 
        Map<Id, Account> accountCompliance = new Map<Id, Account>();
        for (Account a : accountList) {
            //accountEmails.put(a.Id, a);
            accountCompliance.put(a.Id, a);
        }

        Map<Id, String> accountStates = new Map<Id, String>();
        Map<Id, Boolean> validResaleDocs = new Map<Id, Boolean>();
        Map<Id, Boolean> validLicenseDocs = new Map<Id, Boolean>();

        List<Dealer_Docs__c> validDocList = [SELECT Id, RecordTypeId, Document_State__c, Account__c FROM Dealer_Docs__c WHERE Compliant__c = true AND Account__c IN :accountIds]; //get any valid docs related to accountId set

        for (Dealer_Docs__c vd : validDocList) {
            if (accountStates.get(vd.Account__c) == null) {
                //need to crate a map with the account id and the string of the state (gotten from the document state field on dealer docs)
                accountStates.put(vd.Account__c, vd.Document_State__c);
            }

            if (vd.RecordTypeId == resaleId) {
                validResaleDocs.put(vd.Account__c, true);
                if (validLicenseDocs.get(vd.Account__c) == null) {
                    validLicenseDocs.put(vd.Account__c, false);
                }
            }
            else if (vd.RecordTypeId == licenseId) {
                validLicenseDocs.put(vd.Account__c, true);
                if (validResaleDocs.get(vd.Account__c) == null) {
                    validResaleDocs.put(vd.Account__c, false);
                }
            }
        }

        for (Dealer_Docs__c dd : docList) { //this will also check the documents you are currently intserting to evaluate the account against
            if (dd.Compliant__c == true && (dd.No_Expiration__c == true || dd.Expiration_Date__c > System.Today())) {
                if (accountStates.get(dd.Account__c) == null) {
                    //need to crate a map with the account id and the string of the state (gotten from the document state field on dealer docs)
                    accountStates.put(dd.Account__c, dd.Document_State__c);
                }
                else if (accountStates.get(dd.Account__c) != null && accountStates.get(dd.Account__c) != dd.Document_State__c && dd.Compliant__c == true && dd.RecordTypeId == licenseId && DocExpirationReminder.specialStates.contains(dd.Document_State__c)) {
                    accountStates.put(dd.Account__c, dd.Document_State__c);
                }

                if (dd.RecordTypeId == resaleId) {
                    validResaleDocs.put(dd.Account__c, true);
                    if (validLicenseDocs.get(dd.Account__c) == null) {
                        validLicenseDocs.put(dd.Account__c, false);
                    }
                }
                else if (dd.RecordTypeId == licenseId) {
                    validLicenseDocs.put(dd.Account__c, true);
                    if (validResaleDocs.get(dd.Account__c) == null) {
                        validResaleDocs.put(dd.Account__c, false);
                    }
                }
            }
        }

        for (Dealer_Docs__c doc : docList) {
            // if (doc.Account__c != null && accountEmails.get(doc.Account__c) != null && accountEmails.get(doc.Account__c).IST_Account_Owner__r.Email != null) {
            //     doc.IST_Account_Manager_Email__c = accountEmails.get(doc.Account__c).IST_Account_Owner__r.Email;
            // }
            // else {
            //     doc.addError('Please populate the IST Account Manager on the Dealer and try creating the document record again.');
            // }

            // if (doc.Account__c != null && accountEmails.get(doc.Account__c) != null && accountEmails.get(doc.Account__c).Owner.Email != null) {
            //     doc.TM_Email__c = accountEmails.get(doc.Account__c).Owner.Email;
            // }
            // else {
            //     doc.addError('Please populate the Account Owner on the Dealer and try creating the document record again.');
            // }

            if (doc.No_Expiration__c == false) {
                if (doc.RecordTypeId == resaleId && (!DocExpirationReminder.exculdedStates.contains(doc.Document_State__c) || (doc.Document_State__c == 'AL' && doc.AL_Sales_Tax__c == false))) {
                    doc.addError('Please mark the \'No Expiration\' field as true for this record.'); //this is from the fill_out_no_expiration_field validation rule
                }
                else if (doc.RecordTypeId == licenseId && (doc.Document_State__c == 'VT' || doc.Document_State__c == 'AZ')) {
                    doc.addError('Please mark the \'No Expiration\' field as true for this record.'); //this is new validation i am adding for illinois (also fires for VT and AZ licenses if no expiration is not checked)
                }
                else if (doc.Expiration_Date__c == null) {
                    doc.addError('Please either provide an Expiration Date or select No Expiration.'); //this is just an added failsafe, not a rule
                }
                //else if (doc.Expiration_Date__c != null) {
                    //doc.Expiration_Reminder_Date__c = doc.Expiration_Date__c.addDays(-14); //actually needs to fire
                //}
            }

            if (accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c != 'Compliant') { //if account is not currently compliant
                //check all valid docs and if they fill the account compliance requirements, mark account as compliant
                if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true && DocExpirationReminder.specialStates.contains(doc.Document_State__c)))) { //account is in a special state and there is a valid license
                    //set account to compliant
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
                else if (!DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true)) && (validResaleDocs.get(doc.Account__c) == true || (doc.RecordTypeId == resaleId && doc.Compliant__c == true))) { //account is not in a special state and there is both a valid license and resale doc
                    //set account to compliant
                    
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
            }

            if (doc.Compliant__c == false) {
                if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && ((validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null) && (doc.RecordTypeId == licenseId && doc.Compliant__c == false))) { //account is in a special state and there is not a valid license
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
                else if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) == false && (((validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null) && (doc.RecordTypeId == licenseId && doc.Compliant__c == false)) || ((validResaleDocs.get(doc.Account__c) == false || validResaleDocs.get(doc.Account__c) == null) && (doc.RecordTypeId == resaleId && doc.Compliant__c == false)))) { //account is not in a special state and there is both a valid license and resale doc
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
            }

            if (DocExpirationReminder.specialStates.contains(doc.Document_State__c) && doc.RecordTypeId == licenseId && doc.Compliant__c == true && accountCompliance.get(doc.Account__c).Compliant_Resale_Certificate__c == false) {
                accountCompliance.get(doc.Account__c).Compliant_Resale_Certificate__c = true; //if false and new doc is a dealer license for a special state, make true
            }
        }
        update accountCompliance.values();
    }

    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Dealer_Docs__c> newDocList = (List<Dealer_Docs__c>)newList;
        List<Dealer_Docs__c> oldDocList = (List<Dealer_Docs__c>)oldList;
        Map<Id, Dealer_Docs__c> newDocMap = new Map<Id, Dealer_Docs__c>(newDocList);
        Map<Id, Dealer_Docs__c> oldDocMap = new Map<Id, Dealer_Docs__c>(oldDocList);
        Set<Id> accountIds = new Set<Id>();
        Set<Id> docsBeingUpdated = new Set<Id>();
        //for each doc:
        for (Dealer_Docs__c d : newDocList) {
            //Expiration_Reminder_Date__c = Expiration_Date__c.addDays(-14);
            accountIds.add(d.Account__c);
            docsBeingUpdated.add(d.Id);
        }

        Map<Id, Account> accountCompliance = new Map<Id, Account>([SELECT Id, Dealer_Doc_Compliance__c, Compliant_Resale_Certificate__c, Inactive_Sub_Status__c, Active__c FROM Account WHERE Id IN :accountIds]);

        Map<Id, String> accountStates = new Map<Id, String>();
        Map<Id, Boolean> validResaleDocs = new Map<Id, Boolean>();
        Map<Id, Boolean> validLicenseDocs = new Map<Id, Boolean>();

        List<Dealer_Docs__c> validDocList = [SELECT Id, RecordTypeId, Document_State__c, Account__c, Compliant__c, License_Number__c FROM Dealer_Docs__c WHERE Compliant__c = true AND Account__c IN :accountIds];

        for (Dealer_Docs__c vd : validDocList) {
            if (!docsBeingUpdated.contains(vd.Id)) { //docs that were being marked as expired in this update were being added to this and effecting the valid maps
                if (accountStates.get(vd.Account__c) == null) {
                    //need to crate a map with the account id and the string of the state (gotten from the document state field on dealer docs)
                    accountStates.put(vd.Account__c, vd.Document_State__c);
                }

                if (vd.RecordTypeId == resaleId) {
                    validResaleDocs.put(vd.Account__c, true);
                    if (validLicenseDocs.get(vd.Account__c) == null) {
                        validLicenseDocs.put(vd.Account__c, false);
                    }
                }
                else if (vd.RecordTypeId == licenseId) {
                    validLicenseDocs.put(vd.Account__c, true);
                    if (validResaleDocs.get(vd.Account__c) == null) {
                        validResaleDocs.put(vd.Account__c, false);
                    }
                }
            }
        }

        for (Dealer_Docs__c dm : newDocMap.values()) { //this will also check the documents you are currently updating to evaluate the account against
            if (dm.Compliant__c == true && (dm.No_Expiration__c == true || dm.Expiration_Date__c > System.Today())) {
                if (accountStates.get(dm.Account__c) == null) {
                    //need to crate a map with the account id and the string of the state (gotten from the document state field on dealer docs)
                    accountStates.put(dm.Account__c, dm.Document_State__c);
                }
                else if (accountStates.get(dm.Account__c) != null && accountStates.get(dm.Account__c) != dm.Document_State__c) {
                    if (DocExpirationReminder.specialStates.contains(dm.Document_State__c)) {
                        //accountStates.get(dm.Account__c).Document_State__c = dm.Document_State__c;
                        accountStates.put(dm.Account__c, dm.Document_State__c); //seems to work
                    }
                }

                if (dm.RecordTypeId == resaleId) {
                    validResaleDocs.put(dm.Account__c, true);
                    if (validLicenseDocs.get(dm.Account__c) == null) {
                        validLicenseDocs.put(dm.Account__c, false);
                    }
                }
                else if (dm.RecordTypeId == licenseId) {
                    validLicenseDocs.put(dm.Account__c, true);
                    if (validResaleDocs.get(dm.Account__c) == null) {
                        validResaleDocs.put(dm.Account__c, false);
                    }
                }
            }
        }

        for (Dealer_Docs__c doc : newDocMap.values()) {
            if (doc.Expiration_Date__c != oldDocMap.get(doc.Id).Expiration_Date__c && doc.Expiration_Date__c > System.Today()) {
                //if the expiration_date has changed and the new date is in the future (don't feel that i need to check the old date is in the past)
                //then make sure docuemnt_expired is false
                doc.Document_Expired__c = false;
            }

            if (doc.Compliant__c == true && oldDocMap.get(doc.Id).Compliant__c == false) { //if the doc was just marked as compliant
                //check all valid docs and if they fill the account compliance requirements, mark account as compliant
                if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true && DocExpirationReminder.specialStates.contains(doc.Document_State__c)))) { //account is in a special state and there is a valid license
                    //set account to compliant
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
                else if (!DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true)) && (validResaleDocs.get(doc.Account__c) == true || (doc.RecordTypeId == resaleId && doc.Compliant__c == true))) { //account is not in a special state and there is both a valid license and resale doc
                    //set account to compliant
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
            }

            if (doc.Compliant__c == false && oldDocMap.get(doc.Id).Compliant__c == true) { //if the doc was just marked as not compliant
                if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && ((validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null) && (doc.RecordTypeId == licenseId && doc.Compliant__c == false))) { //account is in a special state and there is not a valid license
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
                else if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) == false && (((validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null) && (doc.RecordTypeId == licenseId && doc.Compliant__c == false)) || ((validResaleDocs.get(doc.Account__c) == false || validResaleDocs.get(doc.Account__c) == null) && (doc.RecordTypeId == resaleId && doc.Compliant__c == false)))) { //account is not in a special state and there is both a valid license and resale doc
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
            }

            if (doc.No_Expiration__c == false) {
                if (doc.RecordTypeId == resaleId && (!DocExpirationReminder.exculdedStates.contains(doc.Document_State__c) || (doc.Document_State__c == 'AL' && doc.AL_Sales_Tax__c == false))) {
                    doc.addError('Please mark the \'No Expiration\' field as true for this record.'); //this is from the fill_out_no_expiration_field validation rule
                }
                else if (doc.RecordTypeId == licenseId && (doc.Document_State__c == 'VT' || doc.Document_State__c == 'AZ')) {
                    doc.addError('Please mark the \'No Expiration\' field as true for this record.'); //this is new validation i am adding for illinois (also fires for VT and AZ licenses if no expiration is not checked)
                }
                else if (doc.Expiration_Date__c == null) {
                    doc.addError('Please either provide an Expiration Date or select No Expiration.');
                }
                //else if (doc.Expiration_Date__c != null) {
                    //doc.Expiration_Reminder_Date__c = doc.Expiration_Date__c.addDays(-14);
                //}
            }

            if (doc.Document_State__c != oldDocMap.get(doc.Id).Document_State__c) { //if state has changed
                //re-check compliance and set compliant resale certificate to true on account if new doc state is special and type is license
                if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true && DocExpirationReminder.specialStates.contains(doc.Document_State__c)))) { //account is in a special state and there is a valid license
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
                else if (!DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true)) && (validResaleDocs.get(doc.Account__c) == true || (doc.RecordTypeId == resaleId && doc.Compliant__c == true))) { //account is not in a special state and there is both a valid license and resale doc
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
                else if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null)) { //account is in a special state and there is not a valid license
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
                else if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) == false && ((validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null) || (validResaleDocs.get(doc.Account__c) == false || validResaleDocs.get(doc.Account__c) == null))) { //account is not in a special state and there is both a valid license and resale doc
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
                
                if ((DocExpirationReminder.specialStates.contains(doc.Document_State__c) && !DocExpirationReminder.specialStates.contains(oldDocMap.get(doc.Id).Document_State__c)) && doc.Compliant__c == true && accountCompliance.get(doc.Account__c).Compliant_Resale_Certificate__c == false) {
                    //if the state went from a normal to a special one and field is false change to true
                    //not sure i need to check that the old state was not special... think about that
                    accountCompliance.get(doc.Account__c).Compliant_Resale_Certificate__c = true;
                }
            }

            if (doc.RecordTypeId != oldDocMap.get(doc.Id).RecordTypeId) {
                //if document type has changed, re-evaluate account compliance
                if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true && DocExpirationReminder.specialStates.contains(doc.Document_State__c)))) { //account is in a special state and there is a valid license
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
                else if (!DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == true || (doc.RecordTypeId == licenseId && doc.Compliant__c == true)) && (validResaleDocs.get(doc.Account__c) == true || (doc.RecordTypeId == resaleId && doc.Compliant__c == true))) { //account is not in a special state and there is both a valid license and resale doc
                    accountCompliance.put(doc.Account__c, setAccountCompliantAndActive(accountCompliance.get(doc.Account__c), doc));
                }
                else if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) && (validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null)) { //account is in a special state and there is not a valid license
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
                else if (DocExpirationReminder.specialStates.contains(accountStates.get(doc.Account__c)) == false && ((validLicenseDocs.get(doc.Account__c) == false || validLicenseDocs.get(doc.Account__c) == null) || (validResaleDocs.get(doc.Account__c) == false || validResaleDocs.get(doc.Account__c) == null))) { //account is not in a special state and there is both a valid license and resale doc
                    accountCompliance.get(doc.Account__c).Dealer_Doc_Compliance__c = 'Out of Compliance';
                }
            }
        }
        update accountCompliance.values();
    }

    public override void beforeDelete(Map<Id, sObject> oldMap) { //, List<sObject> newList //is there even a newList? for delete? no, because the records will be gone, right?
        //just need to search all/any dealer docs for accounts being affected by the delete and see if they will still be compliant
        //really need to consider making a check compliance method i can call
        //because this is redonk at this point
        Map<Id, Dealer_Docs__c> oldDocMap = (Map<Id, Dealer_Docs__c>)oldMap;
        Set<Id> accountIds = new Set<Id>();
        Set<Id> docsBeingDeleted = new Set<Id>();
        //for each doc:
        for (Dealer_Docs__c d : oldDocMap.values()) {
            //Expiration_Reminder_Date__c = Expiration_Date__c.addDays(-14);
            accountIds.add(d.Account__c);
            docsBeingDeleted.add(d.Id);
        }

        Map<Id, Account> accountCompliance = new Map<Id, Account>([SELECT Id, Dealer_Doc_Compliance__c FROM Account WHERE Id IN :accountIds]);

        Map<Id, String> accountStates = new Map<Id, String>();
        Map<Id, Boolean> validResaleDocs = new Map<Id, Boolean>();
        Map<Id, Boolean> validLicenseDocs = new Map<Id, Boolean>();

        List<Dealer_Docs__c> validDocList = [SELECT Id, RecordTypeId, Document_State__c, Account__c FROM Dealer_Docs__c WHERE Compliant__c = true AND Account__c IN :accountIds];

        for (Dealer_Docs__c vd : validDocList) {
            if (!docsBeingDeleted.contains(vd.Id)) {
                if (accountStates.get(vd.Account__c) == null) {
                    accountStates.put(vd.Account__c, vd.Document_State__c);
                }

                if (vd.RecordTypeId == resaleId) {
                    validResaleDocs.put(vd.Account__c, true);
                    if (validLicenseDocs.get(vd.Account__c) == null) {
                        validLicenseDocs.put(vd.Account__c, false);
                    }
                }
                else if (vd.RecordTypeId == licenseId) {
                    validLicenseDocs.put(vd.Account__c, true);
                    if (validResaleDocs.get(vd.Account__c) == null) {
                        validResaleDocs.put(vd.Account__c, false);
                    }
                }
            }
            else {
                if (accountStates.get(vd.Account__c) == null) {
                    accountStates.put(vd.Account__c, vd.Document_State__c);
                }
            }
        }

        //then check if account should still be compliant - so should i loop over the accounts?
        for (Account a : accountCompliance.values()) {
            if (DocExpirationReminder.specialStates.contains(accountStates.get(a.Id)) && (validLicenseDocs.get(a.Id) == true)) { //account is in a special state and there is a valid license
                accountCompliance.get(a.Id).Dealer_Doc_Compliance__c = 'Compliant';
                // if (accountCompliance.get(doc.Account__c).Active__c == false && goodInactiveReasons.contains(accountCompliance.get(doc.Account__c).Inactive_Sub_Status__c)) {
                //     accountCompliance.get(doc.Account__c).Inactive_Sub_Status__c = null;
                //     accountCompliance.get(doc.Account__c).Active__c = true;
                // }
            }
            else if (!DocExpirationReminder.specialStates.contains(accountStates.get(a.Id)) && validLicenseDocs.get(a.Id) == true && validResaleDocs.get(a.Id) == true) { //account is not in a special state and there is both a valid license and resale doc
                accountCompliance.get(a.Id).Dealer_Doc_Compliance__c = 'Compliant';
                // if (accountCompliance.get(doc.Account__c).Active__c == false && goodInactiveReasons.contains(accountCompliance.get(doc.Account__c).Inactive_Sub_Status__c)) {
                //     accountCompliance.get(doc.Account__c).Inactive_Sub_Status__c = null;
                //     accountCompliance.get(doc.Account__c).Active__c = true;
                // }
            }
            else if (DocExpirationReminder.specialStates.contains(accountStates.get(a.Id)) && (validLicenseDocs.get(a.Id) == false || validLicenseDocs.get(a.Id) == null)) { //account is in a special state and there is not a valid license
                accountCompliance.get(a.Id).Dealer_Doc_Compliance__c = 'Out of Compliance';
            }
            else if (DocExpirationReminder.specialStates.contains(accountStates.get(a.Id)) == false && ((validLicenseDocs.get(a.Id) == false || validLicenseDocs.get(a.Id) == null) || (validResaleDocs.get(a.Id) == false || validResaleDocs.get(a.Id) == null))) { //account is not in a special state and there is both a valid license and resale doc
                accountCompliance.get(a.Id).Dealer_Doc_Compliance__c = 'Out of Compliance';
            }
        }
        update accountCompliance.values();
    }

    // public void checkCompliance(Boolean inSpecState, Boolean validLicense, Boolean validResale...) {
    //  //so what would need to be passed in here?
    //  //there are so many ways that I check for compliance I may need to create a number of different versions of this and just overload the method
    //  //this really should be a tech debt thing...
    //  //should be returning true or false based on compliance
    // }

    public Account setAccountCompliantAndActive(Account acct, Dealer_Docs__c doc) {
        if (acct != null) {
            acct.Dealer_Doc_Compliance__c = 'Compliant';
            if (acct.Active__c == false && goodInactiveReasons.contains(acct.Inactive_Sub_Status__c)) {
                acct.Inactive_Sub_Status__c = null;
                acct.Active__c = true;
            }
        }
        return acct;
    }
}