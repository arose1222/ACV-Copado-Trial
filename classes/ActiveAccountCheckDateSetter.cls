public without sharing class ActiveAccountCheckDateSetter extends TriggerInterface {
    //this replaces DeactivateInToolsStatusDateSetter
    public override void beforeInsert(List<sObject> objectList) {
        List<Account> accountList = (List<Account>)objectList;
        for (Account a : accountList) {
            if (a.Active__c == true) {
                a.Set_Active_Account_Check_Date__c = System.Today().addDays(11);
            }
        }
    }

    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        List<Account> newAccountList = (List<Account>)newList;
        List<Account> oldAccountList = (List<Account>)oldList;
        Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldAccountList);

        for (Account a : newAccountList) {
            if (a.Active__c == true && oldAccountMap.get(a.Id).Active__c == false) {
                a.Set_Active_Account_Check_Date__c = System.Today().addDays(11);
            }
        }
    }
}