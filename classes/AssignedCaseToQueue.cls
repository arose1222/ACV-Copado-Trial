public class AssignedCaseToQueue extends TriggerInterface {

    public override void beforeUpdate( Map<Id,sObject> oldMap, Map<Id,sObject> newMap ) {
        processCases( (Map<Id, Case>) oldMap, (Map<Id, Case>) newMap );
    }

    public static List<Case> processCases( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Map<Id, Case> oldCaseMap =  (Map<Id, Case>) oldMap;

        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : (List<Case>) newMap.values() ) {
            if ( !oldCaseMap.isEmpty() && caseRec.OwnerId != oldCaseMap.get( caseRec.Id ).OwnerId ) {
                titleCaseLst.add( caseRec );
            }
        }

        return stampDate( titleCaseLst );
    }

    // Only called on Status Changes
    private static List<Case> stampDate( List<Case> caseLst ) {
        for ( Case caseRec : caseLst ) {
            if ( caseRec.OwnerId.getSObjectType() == Schema.Group.SObjectType ) {
                caseRec.Date_Time_Assigned_to_Queue__c = DateTime.now();
            }
        }
        return caseLst;
    }
}