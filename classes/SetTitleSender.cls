public class SetTitleSender extends TriggerInterface {
    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        processCases( oldMap, newMap );
    }
    
    public static List<Case> processCases( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Map<Id, Case> oldCaseMap = (Map<Id, Case>) oldMap;

        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : (List<Case>) newMap.values() ) {
            if ( ACVUtility.recordTypeCheck( CaseUtility.TITLES_RECORDTYPE_DEV_NAME, 'Case', caseRec.RecordTypeId )
            && caseRec.Status == 'Sent' && caseRec.Status != oldCaseMap.get( caseRec.Id ).Status 
            && caseRec.Title_Scanner__c == null  ) {
                titleCaseLst.add( caseRec );
            }
        }

        return updateCaseTitleSender( titleCaseLst );
    }

    private static List<Case> updateCaseTitleSender( List<Case> caseLst ) {
        for ( Case c : caseLst ) {
            c.Title_Scanner__c = UserInfo.getUserId();
        }
        
        return caseLst;
    }
}