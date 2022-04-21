public class AccountTriggerHandler extends TriggerInterface{
    
    public override void beforeInsert(List<SObject> newList){
        SalesAccountProcesses.runBeforeInsert(newList);
        ArbitrationAccountProcesses.runBeforeInsert(newList);
        AccountTerritoryProcesses.insertRegionProcess(newList);
    }

    public override void afterInsert(Map<Id, SObject> newMap) {
        SalesAccountProcesses.runAfterInsert(newMap, new Map<Id, SObject>());
        ArbitrationAccountProcesses.runAfterInsert(newMap, new Map<Id, SObject>());
    }
    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        SalesAccountProcesses.runBeforeUpdate(newMap, oldMap);
        ArbitrationAccountProcesses.runBeforeUpdate(newMap, oldMap);
        AccountTerritoryProcesses.updateRegionProcess(newMap, oldMap);
    }
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        SalesAccountProcesses.runAfterUpdate(newMap, oldMap);
        ArbitrationAccountProcesses.runAfterUpdate(newMap, oldMap);
        AccountTriggerHandler.filterAccounts((Map<Id, Account>)newMap, (Map<Id, Account>)oldMap);
    }

    public static void filterAccounts( Map<Id, Account> newMap, Map<Id, Account> oldMap ) {
        Set<Id> acctIdSet = new Set<Id>();
        Map<Id, Id> acctContMap = new Map<Id, Id>();

        for ( Account acctRec : newMap.values() ) {
            if ( acctRec.Primary_Contact__c != oldMap.get( acctRec.Id ).Primary_Contact__c ) {
                acctIdSet.add( acctRec.Id );
                acctContMap.put( acctRec.Id, acctRec.Primary_Contact__c);
            }
        }

        if ( acctIdSet != null && !acctIdSet.isEmpty() ) {
            AccountTriggerHandler.updateCases( acctIdSet, acctContMap );
        }
    }

    @future
    public static void updateCases( Set<Id> acctIdSet, Map<Id, Id> acctContSet ) {
        List<Case> updateCaseLst = [ SELECT Id, Seller_Dealership__c FROM Case WHERE Seller_Dealership__c IN :acctIdSet AND isClosed = FALSE ];

        for ( Case caseRec : updateCaseLst ) {
            caseRec.Seller_Contact__c = acctContSet.get( caseRec.Seller_Dealership__c );
        }

        update updateCaseLst;
    }

}