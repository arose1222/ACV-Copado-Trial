public class ResourceAbsenceTimeZone extends TriggerInterface {
    
    public static TimeZone currentTimeZone = UserInfo.getTimeZone();

    //If it's an insert of the Resource Absence
    public override void beforeInsert( List<SObject> newList ) { 
        List<ResourceAbsence> calculateTimeDifferenceCurrentToResources = new List<ResourceAbsence>();
        List<ResourceAbsence> formatStartAndEndDates = new List<ResourceAbsence>();
        List<Id> allRAIds = new List<Id>();
        for(SObject rec : newList) {
            ResourceAbsence ra = (ResourceAbsence) rec;
            
            //If it was uploaded via data load (specified by the new data load checkbox)
            if(ra.Verify_Timezone__c) {
                //Set the new Start and End text fields to be the entered Start and End times.
                calculateTimeDifferenceCurrentToResources.add(ra);
                allRAIds.add(ra.ResourceId);
            }
            //If it was created via the GANTT
            else {
            //Find the Service Resource's Time Zone.
            formatStartAndEndDates.add(ra);
            allRAIds.add(ra.ResourceId);
            }
        }
        changeResourceAbsenceTimeZones(calculateTimeDifferenceCurrentToResources, formatStartAndEndDates, allRAIds);
    }

    public override void beforeUpdate(Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
        List<ResourceAbsence> formatStartAndEndDates = new List<ResourceAbsence>();
        List<Id> allRAIds = new List<Id>();
        for(SObject rec : newMap.values()) {
            
            ResourceAbsence ra = (ResourceAbsence) rec;
            ResourceAbsence oldRA = (ResourceAbsence) oldMap.get(ra.Id);
            if(ra.Start != oldRA.Start || ra.End != oldRA.End) {
                formatStartAndEndDates.add(ra);
                allRAIds.add(ra.ResourceId);
            }
        }
        changeResourceAbsenceTimeZones(null, formatStartAndEndDates, allRAIds);
    }
    
    private void changeResourceAbsenceTimeZones(List<ResourceAbsence> calculateStartEndTimes, List<ResourceAbsence> formatDateTimeStrings, List<Id> allRAIds) {
        Map<Id, ServiceResource> serviceResourceMap = new Map<Id, ServiceResource>([SELECT Id, 
                                                                                        (SELECT Id, OperatingHoursId, OperatingHours.TimeZone, EffectiveStartDate, EffectiveEndDate 
                                                                                        FROM ServiceTerritories 
                                                                                        WHERE TerritoryType = 'P') 
                                                                                    FROM ServiceResource 
                                                                                    WHERE Id IN :allRAIds]);
        if(calculateStartEndTimes != null) {
            for(ResourceAbsence ra : calculateStartEndTimes) {
                
                if(serviceResourceMap.containsKey(ra.ResourceId)) {
                    ServiceResource sr = serviceResourceMap.get(ra.ResourceId);
                    TimeZone serviceResourceTimezone = currentTimeZone;
                    for(ServiceTerritoryMember stm : sr.ServiceTerritories) {
                        if(stm.EffectiveStartDate <= ra.Start && (stm.EffectiveEndDate == null || stm.EffectiveEndDate >= ra.End) && stm.OperatingHours != null) {
                            serviceResourceTimezone = TimeZone.getTimeZone(stm.OperatingHours.TimeZone);
                        }
                    }
                    
                    //If the Service Resources Start and End times are different from the running user's TimeZone, calculate the offset between their TimeZone and our own.
                    ra.Start = RevolvingGenerator.calculateTimeWithOffset(currentTimeZone, serviceResourceTimezone, ra.Start.Date(), ra.Start.Time());
                    ra.End = RevolvingGenerator.calculateTimeWithOffset(currentTimeZone, serviceResourceTimezone, ra.End.Date(), ra.End.time());
                    ra.Start_Time_in_resource_s_time_zone__c = ra.Start.format('MMMMM dd, yyyy hh:mm a z', serviceResourceTimezone.toString());
                    ra.End_Time_in_resource_s_time_zone__c = ra.End.format('MMMMM dd, yyyy hh:mm a z', serviceResourceTimezone.toString());
                }
                ra.Verify_Timezone__c = false;
            }
        }
        if(formatDateTimeStrings != null) {
            for(ResourceAbsence ra : formatDateTimeStrings) {
                if(serviceResourceMap.containsKey(ra.ResourceId)) {
                    ServiceResource sr = serviceResourceMap.get(ra.ResourceId);
                    TimeZone serviceResourceTimezone = currentTimeZone;
                    for(ServiceTerritoryMember stm : sr.ServiceTerritories) {
                        if(stm.EffectiveStartDate <= ra.Start && (stm.EffectiveEndDate == null || stm.EffectiveEndDate >= ra.End) && stm.OperatingHours != null) {
                            serviceResourceTimezone = TimeZone.getTimeZone(stm.OperatingHours.TimeZone);
                        }
                    }
                    //Use the Service Resource's Time Zone.
                    ra.Start_Time_in_resource_s_time_zone__c = ra.Start.format('MMMMM dd, yyyy hh:mm a z', serviceResourceTimezone.toString());
                    ra.End_Time_in_resource_s_time_zone__c = ra.End.format('MMMMM dd, yyyy hh:mm a z', serviceResourceTimezone.toString());
                }
            }
        }
    }
}