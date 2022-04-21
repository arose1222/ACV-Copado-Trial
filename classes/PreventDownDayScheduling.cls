public class PreventDownDayScheduling extends TriggerInterface {
    @TestVisible private static final String CANT_SCHEDULE_ON_DOWN_DAY_ERROR = 'You cannot schedule a CPO Job on this Company\'s \'Down Day\'';

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<Date> dateCheckSet = new Set<Date>();
        Set<Id> workTypeIdSet = new Set<Id>();
        List<ServiceAppointment> saReviewLst = new List<ServiceAppointment>();

        for ( ServiceAppointment newSARec : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSARec = (ServiceAppointment) oldMap.get( newSARec.Id );

            if ( FSLWorkProcessUtility.workTypeIdMap.get( newSARec.WorkTypeId )?.Work_Type_Unique_ID__c != null && ( FSLWorkProcessUtility.workTypeIdMap.get( newSARec.WorkTypeId ).Work_Type_Unique_ID__c.contains( 'cpo' ) ) && ( ( newSARec.SchedStartTime != oldSARec.SchedStartTime && newSARec.SchedStartTime != null ) || ( newSARec.ArrivalWindowStartTime != oldSARec.ArrivalWindowStartTime && newSARec.ArrivalWindowStartTime != null ) ) ) {
                dateCheckSet.add( newSARec.SchedStartTime?.dateGMT() );
                dateCheckSet.add( newSARec.ArrivalWindowStartTime?.dateGMT() );
                workTypeIdSet.add( newSARec.WorkTypeId );
                saReviewLst.add( newSARec );
            }
        }

        dateCheckSet.remove( null );
        workTypeIdSet.remove( null ); // Remove any nulls since no null checking above

        if ( !dateCheckSet.isEmpty() ) {
            Set<String> downDayKeySet = new Set<String>();
            for ( Down_Day__c downDay : [ SELECT Id, Start__c, Work_Type__c FROM Down_Day__c WHERE DAY_ONLY( Start__c ) IN :dateCheckSet AND Work_Type__c IN :workTypeIdSet ] ) {
                downDayKeySet.add( createKey( downDay.Start__c.date(), downDay.Work_Type__c ) );
            }

            for ( ServiceAppointment saRec : saReviewLst ) {
                if ( (saRec.SchedStartTime != null && downDayKeySet.contains( createKey( saRec.SchedStartTime.date(), saRec.WorkTypeId ) ) ) || ( saRec.ArrivalWindowStartTime != null && downDayKeySet.contains( createKey( saRec.ArrivalWindowStartTime.date(), saRec.WorkTypeId ) ) ) ) {
                    newMap.get( saRec.Id ).addError( CANT_SCHEDULE_ON_DOWN_DAY_ERROR );
                }
            }
        }
    }

    public static String createKey( Date givenDate, Id workTypeId ) {
        return givenDate + ':' + workTypeId;
    }
}