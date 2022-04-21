public class UpdateWorkTypeSATimes extends TriggerInterface {
    public static boolean apiOverride = FALSE;

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<Id> workIdSet = new Set<Id>();
        List<ServiceAppointment> processSALst = new List<ServiceAppointment>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newMap.values() ) {
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get( sa.Id );
            if ( ( sa.ServiceTerritoryId != oldSA.ServiceTerritoryId || sa.WorkTypeId != oldSA.WorkTypeId ||
            sa.Latitude != oldSA.Latitude || sa.Longitude != oldSA.Longitude ||
            sa.EarliestStartTime != oldSA.EarliestStartTime || sa.DueDate != oldSA.DueDate )
            && sa.Work_Order__c != null )
            {
                processSALst.add( sa );
                workIdSet.add( sa.Work_Order__c );
            }
        }

        if ( !processSALst.isEmpty() ) {
            if ( !apiOverride ) { processUpdate( processSALst, workIdSet ); }
        }
    }

    public override void beforeInsert( List<SObject> newList ) {
        Set<Id> workIdSet = new Set<Id>();
        for ( ServiceAppointment sa : (List<ServiceAppointment>) newList ) {
            if ( sa.Work_Order__c != null ) {
                workIdSet.add( sa.Work_Order__c );
            }
        }
        if ( !apiOverride ) { processUpdate( (List<ServiceAppointment>) newList, workIdSet ); }
    }

    private static void processUpdate ( List<ServiceAppointment> filteredSALst, Set<Id> woIdSet ) {
        FSLWorkProcessUtility.setupUniqueWorkHourStructs();
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>( [ SELECT Id, WorkTypeId, Occurrence__c FROM WorkOrder WHERE Id IN :woIdSet ] );
        Map<Id, String> territoryToTimeZoneStrMap = getOperatingTimeZones( (List<ServiceAppointment>) filteredSALst );

        for ( ServiceAppointment sa : filteredSALst ) {
            if(woMap.get( sa.Work_Order__c )?.Occurrence__c != null){continue;}

            String uniqueWorkTypeTag = convertWorkTypeIdToUniqueName( woMap.get( sa.Work_Order__c )?.WorkTypeId );
            if ( FSLWorkProcessUtility.workTypesWithUniqueHoursSet.contains( uniqueWorkTypeTag ) ) {
                if ( sa.EarliestStartTime != null ) {
                    sa.EarliestStartTime = processTimeAdjustment( sa.EarliestStartTime, uniqueWorkTypeTag, territoryToTimeZoneStrMap.get( sa.ServiceTerritoryId ), TRUE, sa.CreatedDate );
                }
                if ( sa.DueDate != null ) {
                    DateTime processedDueDate = processTimeAdjustment( sa.DueDate, uniqueWorkTypeTag, territoryToTimeZoneStrMap.get( sa.ServiceTerritoryId ), FALSE, sa.CreatedDate );
                    if(sa.EarliestStartTime == null || sa.EarliestStartTime < processedDueDate){
                        sa.DueDate = processedDueDate;
                    }
                }
            }
        }
    }

    private static DateTime processTimeAdjustment( DateTime providedTime, String uniqueWorkTypeName, String territoryZoneString, Boolean startTime, DateTime createdDate ) {
        FSLWorkProcessUtility.TimeSlotStruct timeData = getTimeSlotMap( providedTime, uniqueWorkTypeName, territoryZoneString );
        if ( timeData != null ) {
            Time timeVal;
            if ( startTime && ( Datetime.now() != null && ( Datetime.now() < providedTime ) ) ) {
                timeVal = timeData.startTime;
            } else if ( !startTime ) {
                timeVal = timeData.endTime;
            }
            if ( timeVal != null ) { return removeConvertDTTZ( TimeZone.getTimeZone( territoryZoneString ), providedTime.date(), timeVal ); }
        }
        return providedTime; // If there is no config data for that date, just return untouched
    }

    public static FSLWorkProcessUtility.TimeSlotStruct getTimeSlotMap ( DateTime providedTime, String uniqueWorkTypeName, String territoryZoneString ) {
        String dayOfWeek = providedTime.format( 'EEEE' );
        Map<String, FSLWorkProcessUtility.TimeSlotStruct> timeSlotMap = FSLWorkProcessUtility.workTypeToDayOfWeekMap.get( FSLWorkProcessUtility.makeWorkTypeOptHourKey( uniqueWorkTypeName, territoryZoneString ) );
        return timeSlotMap?.get( dayOfWeek );
    }

    // REMOVE ONCE JAMES GIVES UTILITY METHOD
    private static DateTime removeConvertDTTZ( Timezone tz, Date givenDate, Time givenTime ) {
        Integer timezoneOffset = -1;
        timezoneOffset = timezoneOffset * tz.getOffset( DateTime.newInstanceGMT( givenDate, givenTime ) ) / 1000;
        return DateTime.newInstanceGMT( givenDate, givenTime ).addSeconds( timezoneOffset );
    }

    private static Map<Id, String> getOperatingTimeZones( List<ServiceAppointment> saLst ) {
        Set<Id> serviceTerritoryIdSet = new Set<Id>();
        for ( ServiceAppointment sa : saLst ) {
            serviceTerritoryIdSet.add( sa.ServiceTerritoryId );
        }

        Map<Id, String> returnMap = new Map<Id, String>();
        for ( ServiceTerritory st : [ SELECT Id, OperatingHours.TimeZone FROM ServiceTerritory WHERE Id IN :serviceTerritoryIdSet ] ) {
            returnMap.put( st.Id, st.OperatingHours.TimeZone );
        }

        return returnMap;
    }

    private static String convertWorkTypeIdToUniqueName( Id workTypeId ) {
        return FSLWorkProcessUtility.workTypeIdMap?.get( workTypeId )?.Work_Type_Unique_Id__c;
    }
}