public class DateStampCaseStatusChange extends TriggerInterface {
    private final static Id TITLE_RESOLUTION_QUEUE_ID {
        get {
            if ( TITLE_RESOLUTION_QUEUE_ID == null ) {
                Salesforce_Setting__mdt titleName = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Title Resolution Queue Name' ];
                Group titleQueue = [ SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :titleName.Value__c LIMIT 1 ];
                TITLE_RESOLUTION_QUEUE_ID = titleQueue.Id;
            }
            return TITLE_RESOLUTION_QUEUE_ID;
        }
        set;
    }

    public override void beforeUpdate( Map<Id,sObject> oldMap, Map<Id,sObject> newMap ) {
        processCases( (Map<Id, Case>) oldMap, (Map<Id, Case>) newMap );
    }

    public static List<Case> processCases( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Map<Id, Case> oldCaseMap =  (Map<Id, Case>) oldMap;

        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : (List<Case>) newMap.values() ) {
            if ( ACVUtility.recordTypeCheck( CaseUtility.TITLES_RECORDTYPE_DEV_NAME, 'Case', caseRec.RecordTypeId )
            && ( !oldCaseMap.isEmpty() && caseRec.Status != oldCaseMap.get( caseRec.Id ).Status ) ) {
                titleCaseLst.add( caseRec );
            }
        }

        return stampDate( titleCaseLst );
    }

    // Only called on Status Changes
    private static List<Case> stampDate( List<Case> caseLst ) {
        for ( Case caseRec : caseLst ) {
            caseRec.Status_Last_Updated__c = Date.today();

            if ( caseRec.Status == 'Working' ) {
                caseRec.Title_Clerked_Date__c = Date.today();
            } else if ( caseRec.Status == 'Problem' ) {
                caseRec.Was_Problem__c = TRUE;
            } else if ( caseRec.Status == 'Closed Unwound' ) {
                caseRec.OwnerId = TITLE_RESOLUTION_QUEUE_ID;
            } else if ( caseRec.Status == '48 Hour Notice' ) {
                caseRec.Date_Time_of_48_Hour_Notice__c = Datetime.now();
            }
        }
        return caseLst;
    }
}