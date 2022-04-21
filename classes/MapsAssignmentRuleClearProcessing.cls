public class MapsAssignmentRuleClearProcessing extends TriggerInterface {
    public override void afterUpdate( List<sObject> oldList, List<sObject> newList ) {
        List<maps__AssignmentRule__c> changedAssignRuleLst = new List<maps__AssignmentRule__c>();

        for( Integer index = 0; index < newList.size(); index++ ) {
            maps__AssignmentRule__c newAssignRuleRec = (maps__AssignmentRule__c) newList[index];
            maps__AssignmentRule__c oldAssignRuleRec = (maps__AssignmentRule__c) oldList[index];

            if ( oldAssignRuleRec.maps__User__c != newAssignRuleRec.maps__User__c ) {
                changedAssignRuleLst.add( newAssignRuleRec );
            }
        }

        if ( !changedAssignRuleLst.isEmpty() ) {
            MapsCheckZipcodes.clearAccounts( MapsCheckZipcodes.getZipsFromAssignments( changedAssignRuleLst ) );
        }
    }

    public override void afterDelete( List<SObject> oldList ) {
        if ( !oldList.isEmpty() ) {
            MapsCheckZipcodes.clearAccounts( MapsCheckZipcodes.getZipsFromAssignments( (List<maps__AssignmentRule__c>) oldList ) );
        }
    }
}