public class AccountUpdateLogisticsFromCase {
    private Static boolean alreadyProcessedInsert = false;
    private Static boolean alreadyProcessedUpdate = false;

    public static void run(List<sObject> objectList) {
        if (AccountUpdateLogisticsFromCase.alreadyProcessedInsert == true && AccountUpdateLogisticsFromCase.alreadyProcessedUpdate == true) {
            System.debug('Stopping Recursive Loop and Exiting2');
            return;
        }
        else {
            filteredCaseHandler(objectList);
            //AccountUpdateLogisticsFromCase.alreadyProcessed = true;
            if (Trigger.isInsert) {
                AccountUpdateLogisticsFromCase.alreadyProcessedInsert = true;
            }
            else if (Trigger.isUpdate) {
                AccountUpdateLogisticsFromCase.alreadyProcessedUpdate = true;
            }
        }
    }

    // public static void toggle() {
    //     AccountUpdateLogisticsFromCase.alreadyProcessed = !AccountUpdateLogisticsFromCase.alreadyProcessed;
    // }

    //filter first, ask questions later
    public static void filteredCaseHandler(List<sObject> objectList) {
        List<Case> casesList = (List<Case>)objectList;
        Set<Id> accountIdSet = new Set<Id>();
        List<Case> filteredCaseList = new List<Case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        for (Case c : casesList) {
            if (c.AccountId != null && c.RecordTypeId == recordTypeId) {
                // c.Status == 'Closed' &&
                filteredCaseList.add(c);
                accountIdSet.add(c.AccountId);
            }
        }
        if (accountIdSet.isEmpty()) {
            return;
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, All_Time_Arbs__c, Date_Most_Recent_Arb__c FROM Account WHERE Id IN :accountIdSet FOR UPDATE]);
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        if (Trigger.isInsert) {
            accountsToUpdate = updateAllTimeArbs(filteredCaseList, accountMap);
        }
        else if (Trigger.isUpdate) {
            accountsToUpdate = updateLastArbDate(filteredCaseList, accountMap);
        }

        if (accountsToUpdate.values().size() > 0) {
            update accountsToUpdate.values();
        }
    }

    //All Time Arbs
    //if null search historical data, if not null just look at recent arbs? triggered by auction and narrowed down like the others?
    public static Map<Id, Account> updateAllTimeArbs(List<Case> filteredCaseList, Map<Id, Account> accountMap) {
        //essentially the same as all time purchases but need to know status's to filter by first
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Map<Id, Integer> allTimeArbs = new Map<Id, Integer>();

        for (Case c : filteredCaseList) {
            if (allTimeArbs.get(c.AccountId) == null) {
                allTimeArbs.put(c.AccountId, 1);
            }
            else {
                allTimeArbs.put(c.AccountId, (allTimeArbs.get(c.AccountId) + 1));
            }
        }
        for (Account acc : accountMap.values()) {
            accountMap.get(acc.Id).All_Time_Arbs__c = accountMap.get(acc.Id).All_Time_Arbs__c + allTimeArbs.get(acc.Id);
            accountsToUpdate.put(acc.Id, acc);
        }
        return accountsToUpdate;
    }

    //Date Most Recent Arb
    public static Map<Id, Account> updateLastArbDate(List<Case> filteredCaseList, Map<Id, Account> accountMap) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Map<Id, dateTime> accountTimeMap = new Map<Id, dateTime>();
        for (Case c : filteredCaseList) {
            System.debug('ENTER DATE LOOP');
            if (accountMap.get(c.AccountId).Date_Most_Recent_Arb__c != null && c.ClosedDate != null && c.Status == 'Closed') {
                System.debug('DATE MOST RECENT ARB POPULATED');
                if (c.ClosedDate > accountMap.get(c.AccountId).Date_Most_Recent_Arb__c) {
                    System.debug('CLOSED DATE MORE RECENT');
                    accountTimeMap.put(c.AccountId, c.ClosedDate);
                    System.debug(accountTimeMap.get(c.AccountId));
                }
                //so this should now only add the case's close date to accountTimeMap if the close date is newer than last arb date
            }
            else if (accountMap.get(c.AccountId).Date_Most_Recent_Arb__c == null && c.ClosedDate != null && c.Status == 'Closed') {
                System.debug('DATE MOST RECENT ARB NULL');
                accountTimeMap.put(c.AccountId, c.ClosedDate);
                System.debug(accountTimeMap.get(c.AccountId));
            }
        }

        System.debug('Account Time Map: ' + accountTimeMap);
        if (accountTimeMap.values().size() > 0) {
            for (Account acc : accountMap.values()) {
                accountMap.get(acc.Id).Date_Most_Recent_Arb__c = date.valueOf(accountTimeMap.get(acc.Id));
                accountsToUpdate.put(acc.Id, acc);
                //acc.Date_Most_Recent_Arb__c = date.valueOf(accountTimeMap.get(acc.Id));
            }
        }
        return accountsToUpdate;
    }
}

//System.debug(accountMap.get(acc.Id).Date_Most_Recent_Arb__c);