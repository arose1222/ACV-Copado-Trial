/**
 * @description apex controller for the tracRecurringEvent component
 * @name tracRecurringEventController
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-22
 */

public class tracRecurringEventController {
    private final static Integer MAX_RESULTS = 5;

    
    /**
     * @description finds territories based on string
     * @param searchTerm string to search
     * @param selectedIds list of ids to exclude from the search
     * @return list of lookup results
     */
    /*@AuraEnabled
    public static List<LookupSearchResult> getTerritories(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
                ServiceTerritory (Id, Name WHERE id NOT IN :selectedIds) LIMIT :MAX_RESULTS];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String icon = 'standard:service_territory_location';
        ServiceTerritory [] serviceTerritories = ((List<ServiceTerritory>) searchResults[0]);
        for (ServiceTerritory st : serviceTerritories) {
            results.add(new LookupSearchResult(st.Id, 'ServiceTerritory', icon, st.Name, ''));
        }

        return results;
    }*/

    @AuraEnabled
    public static String getOperatingHours( String acctId ) {      
        Account acct = [ SELECT Id, OperatingHoursId, Billinglongitude, BillingLatitude FROM Account WHERE Id = :acctId LIMIT 1 ];
        OperatingHoursRange returnData = new OperatingHoursRange();
        if ( acct.OperatingHoursId != null ) {
            returnData = processOperatingHours(
                getTimeSlots( acct.OperatingHoursId ), 
                returnData
            );
        }

        if ( acct.Billinglongitude != null && acct.BillingLatitude != null ) {
            Id serviceTerritoryId = FSL.PolygonUtils.getTerritoryIdByPolygons( Double.valueOf( acct.Billinglongitude ), Double.valueOf( acct.BillingLatitude ) );
            if ( serviceTerritoryId != null ) {
                ServiceTerritory st = [ SELECT Id, OperatingHoursId FROM ServiceTerritory WHERE Id = :serviceTerritoryId LIMIT 1 ];
                returnData = processOperatingHours(
                    getTimeSlots( st.OperatingHoursId ), 
                    returnData
                );
            }
        }
        return JSON.serialize( returnData );
    }

    @AuraEnabled
    public static String getUpdatedOperatingHours( String optHourRange, String serviceResourceId, String providedAcctId ) {     
        OperatingHoursRange returnRangeData = (OperatingHoursRange) JSON.deserialize( optHourRange, OperatingHoursRange.class );
        if ( !String.isBlank( serviceResourceId ) ) {
            Account providedAcct = [ SELECT Id, BillingLongitude, BillingLatitude FROM Account WHERE Id = :providedAcctId LIMIT 1 ];
            if ( providedAcct.Billinglongitude != null && providedAcct.BillingLatitude != null ) {
                Id territoryId = FSL.PolygonUtils.getTerritoryIdByPolygons( Double.valueOf( providedAcct.Billinglongitude ), Double.valueOf( providedAcct.BillingLatitude ) );
                if ( territoryId != null ) {
                    ServiceTerritoryMember stmRec = [ SELECT Id, OperatingHoursId FROM ServiceTerritoryMember WHERE ServiceResourceId = :serviceResourceId 
                                                        AND ServiceTerritoryId = :territoryId AND ( EffectiveEndDate = null OR EffectiveEndDate > :Date.today() ) ];
                    if ( stmRec != null ) {
                        returnRangeData = processOperatingHours(
                            getTimeSlots( stmRec.OperatingHoursId ), 
                            returnRangeData
                        );
                    }
                }
            }
        }

        return JSON.serialize( returnRangeData );
    }

    private static List<TimeSlot> getTimeSlots( Id operatingHoursId ) {
        return [ SELECT StartTime, EndTime FROM TimeSlot WHERE OperatingHoursId = :operatingHoursId ];
    }

    private static OperatingHoursRange processOperatingHours( List<TimeSlot> tsLst, OperatingHoursRange optRange ) {
        for ( TimeSlot tsRec : tsLst ) {
            if ( optRange.startingHour == null || ( optRange.startingHour != null && tsRec.StartTime > optRange.startingHour ) ) {
                optRange.startingHour = tsRec.StartTime;
            }
            if ( optRange.closingHour == null || ( optRange.closingHour != null && tsRec.EndTime < optRange.closingHour ) ) {
                optRange.closingHour = tsRec.EndTime;
            }
        }

        return optRange;
    }

    public class OperatingHoursRange {
        public Time startingHour;
        public Time closingHour;
    }

    /**
     * @description finds territories based on string
     * @param searchTerm string to search
     * @param selectedIds list of ids to exclude from the search
     * @return list of lookup results
     */
    // @AuraEnabled
    // public static List<LookupSearchResult> getResources(String searchTerm, List<String> selectedIds) {
    //     // Prepare query paramters
    //     searchTerm += '*';
    //     System.debug('selectedIds'+selectedIds);
    //     // Execute search query
    //     List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
    //             ServiceResource (Id, Name WHERE id NOT IN :selectedIds) LIMIT :MAX_RESULTS];

    //     // Prepare results
    //     List<LookupSearchResult> results = new List<LookupSearchResult>();

    //     // Extract Accounts & convert them into LookupSearchResult
    //     String icon = 'standard:service_resource';
    //     ServiceResource [] serviceResources = ((List<ServiceResource>) searchResults[0]);
    //     for (ServiceResource st : serviceResources) {
    //         results.add(new LookupSearchResult(st.Id, 'ServiceResource', icon, st.Name, ''));
    //     }

    //     return results;
    // }


    /**
     * @description get child occurrences from a timeline
     * @param recordId timeline id
     * @return list of occurrences
     */
    @AuraEnabled(Cacheable=false)
    public static List<Occurrence__c> getOccurrences(String recordId) {
        return [SELECT Day__c,End_Time__c,Every__c,Frequency__c,Id,Start_Time__c,Timeline__c
                FROM Occurrence__c WHERE Timeline__c = :recordId];
    }

    /**
     * @description get account from record Id
     * @param recordId account Id
     * @return Account
     */
    @AuraEnabled
    public static Account getAccountAddress(String recordId) {
        return [SELECT BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Halt_True360_Appointments__c 
                FROM Account WHERE Id = :recordId];
    }

    /**
     * @description deletes a timeline record
     * @param recordId id of the timeline to delete
     */
    @AuraEnabled
    public static void deleteTimeline(String recordId) {
        delete new Timeline__c(Id=recordId);
    }
}