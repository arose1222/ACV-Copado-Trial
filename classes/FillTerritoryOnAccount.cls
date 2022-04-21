public class FillTerritoryOnAccount extends TriggerInterface {

    public override void beforeUpdate( Map<Id, sObject> oldMap, Map<Id, sObject> newMap ) {
        List<Account> acctLst = new List<Account>();
        Set<Id> assignmentRuleSet = new Set<Id>();

        for ( Account acct : (List<Account>) newMap.values() ) { Account oldAcct = (Account) oldMap.get( acct.Id ); if ( acct.Maps_TM_Assignment_Rule__c != oldAcct.Maps_TM_Assignment_Rule__c ) { acctLst.add( acct ); if ( acct.Maps_TM_Assignment_Rule__c != null ) { assignmentRuleSet.add( acct.Maps_TM_Assignment_Rule__c ); } } }

        updateMapTerritory( acctLst, assignmentRuleSet );
    }

    private static void updateMapTerritory( List<Account> acctLst, Set<Id> assignmentRuleSet ) {
        if ( acctLst != null && !acctLst.isEmpty() ) { Map<Id, maps__AssignmentRule__c> thingMap = new Map<Id, maps__AssignmentRule__c>( [ SELECT Id, maps__ShapeLayer__c, maps__ShapeLayer__r.Name FROM maps__AssignmentRule__c WHERE Id IN :assignmentRuleSet ] ); for ( Account acct : acctLst ) { if ( acct.Maps_TM_Assignment_Rule__c != null && thingMap.get( acct.Maps_TM_Assignment_Rule__c ) != null && thingMap.get( acct.Maps_TM_Assignment_Rule__c ).maps__ShapeLayer__c != null ) { acct.Territory_Name__c = thingMap.get( acct.Maps_TM_Assignment_Rule__c ).maps__ShapeLayer__r.Name; } } }
    }
}