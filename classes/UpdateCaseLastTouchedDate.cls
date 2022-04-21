public class UpdateCaseLastTouchedDate extends TriggerInterface {
    public override void beforeInsert( List<sObject> newList ) {
        processCases( new Map<Id, Case>(), (List<Case>) newList );
    }

    public override void beforeUpdate( Map<Id,sObject> oldMap, Map<Id,sObject> newMap ) {
        processCases( (Map<Id, Case>) oldMap, (List<Case>) newMap.values() );
    }

    public static List<Case> processCases( Map<Id,sObject> oldMap, List<sObject> newLst ){
        Map<Id, Case> oldCaseMap =  (Map<Id, Case>) oldMap;

        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : (List<Case>) newLst ) {
            if ( ACVUtility.profileNameMap.get( UserInfo.getProfileId() ) != 'System Administrator' ) {
                titleCaseLst.add( caseRec );
            }
        }

        return stampDate( titleCaseLst );
    }

    // Only called on Status Changes
    private static List<Case> stampDate( List<Case> caseLst ) {
        for ( Case caseRec : caseLst ) {
            caseRec.Last_Touched__c = Datetime.now();
        }
        return caseLst;
    }
}