public class OverlappingTimeSheetEntryCheck extends TriggerInterface {
    public override void afterInsert( List<SObject> newList ) {
        getParentIdSet( (List<TimeSheetEntry>) newList, null );
    }

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        getParentIdSet( (List<TimeSheetEntry>) newMap.values(), (Map<Id, TimeSheetEntry>) oldMap );
    }

    public static void getParentIdSet( List<TimeSheetEntry> timeSheetEntryLst, Map<Id, TimeSheetEntry> oldTimeSheetEntryMap ) {
        List<TimeSheetEntry> checkTSELst = new List<TimeSheetEntry>();
        Set<Id> timeSheetIdSet = new Set<Id>();
        Set<Id> timeSheetEntryIdSet = new Set<Id>();

        for ( TimeSheetEntry tse : (List<TimeSheetEntry>) timeSheetEntryLst ) {
            TimeSheetEntry oldTSE;
            if ( oldTimeSheetEntryMap != null ) { 
                oldTSE = (TimeSheetEntry) oldTimeSheetEntryMap.get( tse.Id );
            }

            if ( oldTimeSheetEntryMap == null || ( oldTimeSheetEntryMap != null && ( tse.StartTime != oldTSE.StartTime || tse.EndTime != oldTSE.EndTime || tse.TimeSheetId != oldTSE.TimeSheetId || ( tse.Overlapping_Time_Sheet_Entry__c == null && tse.Overlapping_Time_Sheet_Entry__c != oldTSE.Overlapping_Time_Sheet_Entry__c ) ) ) ) {
                checkTSELst.add( tse );
                timeSheetIdSet.add( tse.TimeSheetId );
                
                if ( tse.Id != null ) {
                    timeSheetEntryIdSet.add( tse.Id );
                }
            }
        }

        checkOverlaps( checkTSELst, timeSheetIdSet, timeSheetEntryIdSet );
    }

    // Id is Parent Record Id
    public static void checkOverlaps( List<TimeSheetEntry> entriesLst, Set<Id> parentSheetIdSet, Set<Id> existingTimeEntryIdSet ) {
        Map<Id, List<TimeBlock>> timeCheckMap = new Map<Id, List<TimeBlock>>();
        
        // Organized List by Time Sheet for all entries
        for ( TimeSheetEntry tseRec : [ SELECT Id, StartTime, EndTime, TimeSheetId FROM TimeSheetEntry WHERE TimeSheetId IN :parentSheetIdSet AND Id NOT IN :existingTimeEntryIdSet ] ) {
            if ( timeCheckMap.get( tseRec.TimeSheetId ) == null ) {
                timeCheckMap.put( tseRec.TimeSheetId, new List<TimeBlock>() );
            }
            timeCheckMap.get( tseRec.TimeSheetId ).add( new TimeBlock( tseRec ) );
        }

        for ( Id timesheetId : timeCheckMap.keySet() ) {
            timeCheckMap.get( timesheetId ).sort();
        }

        List<TimeSheetEntry> updateTimeSheetEntryLst = new List<TimeSheetEntry>();

        for ( TimeSheetEntry checkTSERec : entriesLst ) { // Records requesting the check
            List<TimeBlock> checkBlockLst = timeCheckMap.get( checkTSERec.TimeSheetId );
            Id timeConflickId = null;

            if ( checkBlockLst != null ) {
                if ( checkBlockLst.isEmpty() ) { break; }

                for ( TimeBlock blockCheckRec : checkBlockLst ) {
                    // If it isn't possible to have more conflicts, break the loop early
                    if ( checkTSERec.startTime > blockCheckRec.endTime ) { break; }
                    
                    // Check if we're within the gap in any angle
                    if ( ( checkTSERec.StartTime >= blockCheckRec.startTime && checkTSERec.StartTime < blockCheckRec.endTime )
                    || ( checkTSERec.EndTime <= blockCheckRec.endTime && checkTSERec.EndTime > blockCheckRec.startTime ) ) {
                        timeConflickId = blockCheckRec.timesheetEntryId;
                        break;
                        // Find one conflict, end there
                    }
                }

                if ( timeConflickId != null ) {
                    updateTimeSheetEntryLst.add( new TimeSheetEntry(
                        Id = timeConflickId,
                        Overlapping_Time_Sheet_Entry__c = checkTSERec.Id
                    ) );
                } else {
                    if ( checkTSERec.Overlapping_Time_Sheet_Entry__c != null ) {
                        updateTimeSheetEntryLst.add( new TimeSheetEntry(
                            Id = checkTSERec.Overlapping_Time_Sheet_Entry__c,
                            Overlapping_Time_Sheet_Entry__c = null
                        ) );
                    }
                }
                updateTimeSheetEntryLst.add( new TimeSheetEntry(
                    Id = checkTSERec.Id,
                    Overlapping_Time_Sheet_Entry__c = timeConflickId
                ) );
        
        }
    }
        if ( !updateTimeSheetEntryLst.isEmpty() ) {
            update updateTimeSheetEntryLst;
        }
    }
   
}