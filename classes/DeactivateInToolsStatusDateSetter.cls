//todo: delete
public without sharing class DeactivateInToolsStatusDateSetter extends TriggerInterface {
    // public override void beforeInsert(List<sObject> objectList) {
    //     //on insert:
    //     //System.debug('insert account');
    //     List<Account> accountList = (List<Account>)objectList;
    //     for (Account a : accountList) {
    //         //if account is active
    //         if (a.Active__c == true) {
    //             //get today's date
    //             //add 11 days
    //             //set new date to Set_Active_Account_Check_Date__c
    //             a.Set_Active_Account_Check_Date__c = System.Today().addDays(11);
    //         }

    //         if (a.Dealer_Doc_Compliance__c == 'Out Of Compliance') {
    //             //get today's date
    //             //add 11 days
    //             //set new date to Set_for_Deactivation_Date__c
    //             a.Set_for_Deactivation_Date__c = System.Today().addDays(11);
    //         }
    //     }
    // }

    // public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
    //     //on update:
    //     //System.debug('update account');
    //     List<Account> newAccountList = (List<Account>)newList;
    //     List<Account> oldAccountList = (List<Account>)oldList;
    //     Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldAccountList);
    //     //Map<Id, Account> newAccountMap = new Map<Id, Account>();
    //     //if newMap.Dealer_Doc_Compliance__c == 'Out of Compliance' && oldMap.Dealer_Doc_Compliance__c != 'Out of Compliance'

    //     for (Account a : newAccountList) {
    //         if (a.Dealer_Doc_Compliance__c == 'Out Of Compliance' && oldAccountMap.get(a.Id).Dealer_Doc_Compliance__c != 'Out Of Compliance') {
    //             //get today's date
    //             //add 11 days
    //             //set new date to Set_for_Deactivation_Date__c
    //             a.Set_for_Deactivation_Date__c = System.Today().addDays(11);
    //         }

    //         if (a.Active__c == true && oldAccountMap.get(a.Id).Active__c == false) {
    //             //get toay's date
    //             //add 11 days
    //             //set new date to Set_Active_Account_Check_Date__c
    //             a.Set_Active_Account_Check_Date__c = System.Today().addDays(11);
    //         }
    //     }
    // }

    // public override void afterUpdate(List<sObject> oldList, List<sObject> newList) { //needs to be after update because needs to query on the new data that was entered
    //     List<Account> newAccountList = (List<Account>)newList;
    //     List<Account> oldAccountList = (List<Account>)oldList;
    //     Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldAccountList);
    //     Set<Id> accountIds = new Set<Id>();

    //     for (Account a : newAccountList) {
    //         //if owner has changed
    //         if (a.IST_Account_Owner__c != oldAccountMap.get(a.Id).IST_Account_Owner__c) {
    //             //put Id into a set
    //             accountIds.add(a.Id);
    //         }
    //     }

    //     //if set is not null:
    //     if (accountIds.size() > 0) {
    //         //query docs for those accounts
    //         //query account for IST_Account_Manager__r.Email...... except that wont work unless this is an after update. bleh
    //         // Map<Id, Account> updatedISTManagers = new Map<Id, Account>([SELECT Id, IST_Account_Owner__r.Email FROM Account WHERE Id IN :accountIds]);
    //         List<Dealer_Docs__c> docList = [SELECT Id, IST_Account_Manager_Email__c, Account__c, Account__r.IST_Account_Owner__r.Email FROM Dealer_Docs__c WHERE Account__c IN :accountIds];
    //         //then need to loop over the docs and change the email field to the new IST Account Manager's email (use the map)
    //         for (Dealer_Docs__c d : docList) {
    //             d.IST_Account_Manager_Email__c = d.Account__r.IST_Account_Owner__r.Email;
    //         }

    //         update docList;
    //     }
    // }
}