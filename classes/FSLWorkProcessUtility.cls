public class FSLWorkProcessUtility {

    public static Map<String, Set<String>> availableWTGMap {
        get {
            if ( availableWTGMap == null ) {
                availableWTGMap = new Map<String, Set<String>>();
                for ( WorkTypeGroupMember wtgm : [ SELECT WorkTypeGroup.Work_Type_Group_Unique_ID__c, WorkType.Work_Type_Unique_ID__c FROM WorkTypeGroupMember WHERE WorkTypeGroup.IsActive = TRUE ] ) {
                    if ( availableWTGMap.get( wtgm.WorkTypeGroup.Work_Type_Group_Unique_ID__c ) == null ) {
                        availableWTGMap.put( wtgm.WorkTypeGroup.Work_Type_Group_Unique_ID__c, new Set<String>() );
                    }
                    availableWTGMap.get( wtgm.WorkTypeGroup.Work_Type_Group_Unique_ID__c ).add( wtgm.WorkType.Work_Type_Unique_Id__c );
                }
            }
            return availableWTGMap;
        }
        set;
    }

    public static Map<String, WorkType> availableWTMap {
        get {
            if ( availableWTMap == null ) {     
                availableWTMap = new Map<String, WorkType>();
                for( WorkType wt : [ SELECT Id, Name, Work_Type_Unique_ID__c, EstimatedDuration, DurationInMinutes, DurationType, Work_Type_Color__c, Respects_Number_of_Vehicles__c	
                                    FROM WorkType ] ) {
                    availableWTMap.put( wt.Work_Type_Unique_ID__c, wt );
                }
            }
            return availableWTMap;
        }
        set;
    }

    public static Set<Id> getWorkTypeIdByGroupName( Set<String> groupNameSet ) {
        Set<Id> returnWorkTypeIdSet = new Set<Id>();
        for ( String groupName : groupNameSet ) {
            if ( FSLWorkProcessUtility.availableWTGMap.get( groupName ) != null ) {
                for ( String workTypeName : FSLWorkProcessUtility.availableWTGMap.get( groupName ) ) {
                    returnWorkTypeIdSet.add( availableWTMap.get( workTypeName )?.Id );
                }
            }
        }
        returnWorkTypeIdSet.remove(null);
        
        return returnWorkTypeIdSet;
    }

    public static Map<Id, Set<Id>> getSkillRequirementsByWorkTypeId( Set<Id> workTypeIdSet ) {
        Map<Id, Set<Id>> returnRequiredSkillMap = new Map<Id, Set<Id>>();
        for ( SkillRequirement sr : [ SELECT SkillId, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId IN :workTypeIdSet ] ) {
            if ( returnRequiredSkillMap.get( sr.RelatedRecordId ) == null ) {
                returnRequiredSkillMap.put( sr.RelatedRecordId, new Set<Id>() );
            }
            returnRequiredSkillMap.get( sr.RelatedRecordId ).add( sr.SkillId );
        }
        return returnRequiredSkillMap;
    }

    public static Map<Id, Set<Id>> getSkillRequirementsBySkillId( Set<Id> workTypeIdSet ) {
        Map<Id, Set<Id>> returnRequiredSkillMap = new Map<Id, Set<Id>>();
        for ( SkillRequirement sr : [ SELECT SkillId, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId IN :workTypeIdSet ] ) {
            if ( returnRequiredSkillMap.get( sr.SkillId ) == null ) {
                returnRequiredSkillMap.put( sr.SkillId, new Set<Id>() );
            }
            returnRequiredSkillMap.get( sr.SkillId ).add( sr.RelatedRecordId );
        }
        return returnRequiredSkillMap;
    }

    public static Map<Id, WorkType> workTypeIdMap {
        get {
            if ( workTypeIdMap == null ) {     
                workTypeIdMap = new Map<Id, WorkType>();
                for( WorkType wt : availableWTMap.values() ) {
                    workTypeIdMap.put( wt.Id, wt );
                }
            }
            return workTypeIdMap;
        }
        set;
    }

    public static Integer getNumberOfMinutes( String workTypeUniqueName, Integer numberOfVehicles ) {
        return getNumberOfMinutes( availableWTMap.get( workTypeUniqueName )?.Id, numberOfVehicles );
    }

    public static Integer getNumberOfMinutes( Id workTypeId, Integer numberOfVehicles ) {
        Integer numberOfMinutes = 0;
        WorkType processWorkType = workTypeIdMap.get( workTypeId );

        if ( processWorkType != null ) {
            numberOfMinutes = Integer.valueOf( ( processWorkType.Respects_Number_of_Vehicles__c && numberOfVehicles != null && numberOfVehicles > 0 ) ? numberOfVehicles * processWorkType.EstimatedDuration : processWorkType.EstimatedDuration );
        }

        return numberOfMinutes;
    }

    public final static String LEGACY_INSPECTION_SOURCE {
        get {
            if ( LEGACY_INSPECTION_SOURCE == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Legacy InspectionDB Source' LIMIT 1 ];
                LEGACY_INSPECTION_SOURCE = setting.Value__c;
            }
            return LEGACY_INSPECTION_SOURCE;
        }
        set;
    }

    public final static FSL__Scheduling_Policy__c PROPER_POLICY {
        get {
            if ( PROPER_POLICY == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Main Scheduling Policy Name' LIMIT 1 ];
                PROPER_POLICY = [ SELECT Id, Name FROM FSL__Scheduling_Policy__c WHERE Name = :setting.Value__c LIMIT 1 ];
            }
            return PROPER_POLICY;
        }
        set;
    }

    public final static String SA_COMPELTED_CATEGORY {
        get {
            if ( SA_COMPELTED_CATEGORY == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Service Appointment Completed Category' LIMIT 1 ];
                SA_COMPELTED_CATEGORY = setting.Value__c;
            }
            return SA_COMPELTED_CATEGORY;
        }
        set;
    }

    public final static String SA_INCOMPELTE_CATEGORY {
        get {
            if ( SA_INCOMPELTE_CATEGORY == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Service Appointment Incomplete Category' LIMIT 1 ];
                SA_INCOMPELTE_CATEGORY = setting.Value__c;
            }
            return SA_INCOMPELTE_CATEGORY;
        }
        set;
    }

    public final static String SA_CANCEL_CATEGORY {
        get {
            if ( SA_CANCEL_CATEGORY == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Service Appointment Cancel Category' LIMIT 1 ];
                SA_CANCEL_CATEGORY = setting.Value__c;
            }
            return SA_CANCEL_CATEGORY;
        }
        set;
    }

    public final static String SA_DISPATCH_STATUS {
        get {
            if ( SA_DISPATCH_STATUS == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Service Appointment Dispatch Status' LIMIT 1 ];
                SA_DISPATCH_STATUS = setting.Value__c;
            }
            return SA_DISPATCH_STATUS;
        }
        set;
    }

    public final static String SA_POST_DISPATCH_STATUS_CATEGORY {
        get {
            if ( SA_POST_DISPATCH_STATUS_CATEGORY == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'SA Post Dispatch Status Category' LIMIT 1 ];
                SA_POST_DISPATCH_STATUS_CATEGORY = setting.Value__c;
            }
            return SA_POST_DISPATCH_STATUS_CATEGORY;
        }
        set;
    }

    public final static Integer LOWEST_TERRITORY_LEVEL {
        get {
            if ( LOWEST_TERRITORY_LEVEL == null ) {
                LOWEST_TERRITORY_LEVEL = 0;
                List<ServiceTerritory> returnLst = [ SELECT FSL__TerritoryLevel__c FROM ServiceTerritory 
                                                                            WHERE isActive = TRUE 
                                                                            AND FSL__TerritoryLevel__c != null 
                                                                            ORDER BY FSL__TerritoryLevel__c DESC 
                                                                            LIMIT 1 ];
                if ( returnLst != null && returnLst.size() == 1 ) {
                    LOWEST_TERRITORY_LEVEL = Integer.valueOf( returnLst[0].FSL__TerritoryLevel__c );
                }
            }
            return LOWEST_TERRITORY_LEVEL;
        }
        set;
    }

    public final static Integer HIGHEST_TERRITORY_LEVEL {
        get {
            if ( HIGHEST_TERRITORY_LEVEL == null ) {
                HIGHEST_TERRITORY_LEVEL = 0;
                List<ServiceTerritory> returnLst = [ SELECT FSL__TerritoryLevel__c FROM ServiceTerritory 
                                                                            WHERE isActive = TRUE 
                                                                            AND FSL__TerritoryLevel__c != null 
                                                                            ORDER BY FSL__TerritoryLevel__c ASC 
                                                                            LIMIT 1 ];
                if ( returnLst != null && returnLst.size() == 1 ) {
                    HIGHEST_TERRITORY_LEVEL = Integer.valueOf( returnLst[0].FSL__TerritoryLevel__c );
                }
            }
            return HIGHEST_TERRITORY_LEVEL;
        }
        set;
    }

    public static FSLWorkStruct convertWorkObject( WorkObject workRec, ConvertWorkParamStruct paramData ) {

        FSLWorkStruct newWorkReturn = new FSLWorkStruct();
        newWorkReturn.wo = new WorkOrder(
            Account = new Account( Dealership_ID__c = workRec.workDetail.dealerId ),
            Street = workRec.address.street,
            City = workRec.address.city,
            State = workRec.address.state,
            Country = workRec.address.country,
            PostalCode = workRec.address.postalCode,
            WorkTypeId = availableWTMap.get( workRec.workDetail.type ).Id,
            ContactId = paramData?.dealerIdMap?.get( workRec.workDetail.dealerId ) != null ? paramData?.dealerIdMap?.get( workRec.workDetail.dealerId )?.Primary_Contact__c : null,
            Subject = paramData?.dealerIdMap?.get( workRec.workDetail.dealerId ) != null ? paramData?.dealerIdMap?.get( workRec.workDetail.dealerId )?.Name + ' ' + availableWTMap?.get( workRec?.workDetail?.type )?.Name : null
        );

        newWorkReturn.woli = new WorkOrderLineItem();
        newWorkReturn.woli.Make__c = workRec?.vehicle?.make;
        newWorkReturn.woli.Model__c = workRec?.vehicle?.model;
        newWorkReturn.woli.Year__c = workRec?.vehicle?.year;
        newWorkReturn.woli.Stock_Number__c = workRec?.workDetail?.stockNumber;
        newWorkReturn.woli.VIN__c = workRec?.vehicle?.vin;
        newWorkReturn.woli.WorkTypeId = availableWTMap?.get( workRec?.workDetail?.type )?.Id;
        newWorkReturn.woli.State = workRec?.address?.state;
        newWorkReturn.woli.City = workRec?.address?.city;
        newWorkReturn.woli.Street = workRec?.address?.street;
        newWorkReturn.woli.PostalCode = workRec?.address?.postalCode;
        newWorkReturn.woli.Country = workRec?.address?.country;
        newWorkReturn.woli.Color__c = workRec?.vehicle?.color;
        newWorkReturn.woli.Title_with_Dealer__c = !String.isBlank( workRec?.workDetail?.isTitleWithDealer ) ? makeBool( workRec?.workDetail?.isTitleWithDealer ) : FALSE;
        newWorkReturn.woli.Dealer_Contact__c = workRec?.workDetail?.dealerContactName;
        newWorkReturn.woli.Residential__c = !String.isBlank( workRec?.workDetail?.isResidential ) ? makeBool( workRec?.workDetail?.isResidential ) : FALSE;
        newWorkReturn.woli.Add_To_Run_List__c = !String.isBlank( workRec?.workDetail?.addToRunList ) ? makeBool( workRec?.workDetail?.addToRunList ) : FALSE;
        newWorkReturn.woli.Floor_Price__c = !String.isBlank( workRec?.workDetail?.floorPrice ) ? Decimal.valueOf( workRec?.workDetail?.floorPrice ) : null;
        newWorkReturn.woli.Date_Inspected__c = !String.isBlank( workRec?.workDetail?.dateInspected ) ? makeDate( workRec?.workDetail?.dateInspected ) : null;
        newWorkReturn.woli.Duration = availableWTMap?.get( workRec?.workDetail?.type )?.EstimatedDuration;
        newWorkReturn.woli.DurationType = availableWTMap?.get( workRec?.workDetail?.type )?.DurationType;
        newWorkReturn.woli.External_Record_guid__c = workRec?.uuid;
        newWorkReturn.woli.Due_Date__c = workRec?.workDetail?.dueDate != null ? makeDate( workRec?.workDetail?.dueDate ) : null;
        newWorkReturn.woli.Status = !String.isBlank( workRec?.workDetail?.status ) ? workRec?.workDetail?.status : 'New';
        newWorkReturn.woli.Transport_Status__c = workRec?.workDetail?.transportStatus;
        newWorkReturn.woli.Description = workRec?.workDetail?.inspectionNotes;
        newWorkReturn.woli.Dealership_Name__c = workRec?.workDetail?.dealershipName;
        newWorkReturn.woli.Earliest_Start_Date__c = workRec?.workDetail?.earliestStartDate != null ? makeDate( workRec?.workDetail?.earliestStartDate ) : null;
        newWorkReturn.woli.External_Invoice_Id__c = workRec?.workDetail?.invoiceId;
        newWorkReturn.woli.Origin__c = workRec?.origin;
        newWorkReturn.woli.Series__c = workRec?.vehicle?.series;
        newWorkReturn.woli.External_Assignment_Id__c = workRec?.workDetail?.assignmentId;
        newWorkReturn.woli.Is_In_Jeopardy__c = !String.isBlank( workRec?.workDetail?.isInJeopardy ) ? makeBool( workRec?.workDetail?.isInJeopardy ) : FALSE;
        newWorkReturn.woli.Jeopardy_State__c = workRec?.workDetail?.jeopardyState;
        newWorkReturn.woli.Lesse_Name__c = workRec?.workDetail?.lesseName;
        newWorkReturn.woli.Open_Date__c = !String.isBlank( workRec?.workDetail?.openDate ) ? makeDate( workRec?.workDetail?.openDate ) : null;
        newWorkReturn.woli.Maturity_Date__c = !String.isBlank( workRec?.workDetail?.maturityDate ) ? makeDate( workRec?.workDetail?.maturityDate ) : null;
        newWorkReturn.woli.Customer_Email__c = workRec?.workDetail?.customerEmail;
        newWorkReturn.woli.Driving_Directions__c = workRec?.workDetail?.drivingDirections;
        newWorkReturn.woli.Contact_Name__c = ( workRec?.contactInfo != null ) ? workRec?.contactInfo?.name : null;
        newWorkReturn.woli.Contact_Phone_Number__c = ( workRec?.contactInfo != null ) ? workRec?.contactInfo?.phoneNumber : null;
        newWorkReturn.woli.Contact_Mobile_Number__c = ( workRec?.contactInfo != null ) ? workRec?.contactInfo?.mobileNumber : null;
        newWorkReturn.woli.Contact_Email__c = ( workRec?.contactInfo != null ) ? workRec?.contactInfo?.email : null;

        return newWorkReturn;
    }

     /*
    * makeBool
    *   GIVEN a String that (ideally) represents a Boolean
    *   WHEN a String needs to be converted to a Boolean
    *   THEN a Boolean is defined and returned
    *
    * @param String - A String that (ideally) represents a Boolean
    *
    * @return Boolean - A boolean representation of the String provided
    */
    public static Boolean makeBool( String val ) {
        if ( val.toLowerCase() == 'yes' || val.toLowerCase() == 'true' ) {
            return TRUE;
        }
        return FALSE;
    }

    /*
    * makeDate
    *   GIVEN a String that (ideally) represents a Date
    *   WHEN a String needs to be converted to a Date
    *   THEN a Date is defined and returned
    *
    * @param String - A String that (ideally) represents a Date
    *
    * @return Date - A Date representation of the String provided
    */
    public static Date makeDate( String val ) {
        try {           
            return Date.valueOf( val );
        } catch ( exception e ) {
            val = val.replaceAll( '-', '/' );
            List<String> dateArray = val.split( '/' );
            Integer year = dateArray[2].length() == 2 ? Integer.valueOf( '20' + dateArray[2] ) : Integer.valueOf( dateArray[2] );
            return Date.newInstance( year, Integer.valueOf( dateArray[0] ), Integer.valueOf( dateArray[1] ) );
        }
    }

    private static Set<String> vinRequiredWTSet {
        get {
            if ( vinRequiredWTSet == null ) {     
                vinRequiredWTSet = new Set<String>();
                for(WorkType wt:[select id, VIN_Required__c, Work_Type_Unique_ID__c FROM WorkType WHERE VIN_required__c = TRUE]){
                    vinRequiredWTSet.add( wt.Work_Type_Unique_ID__c );
                }
            }
            return vinRequiredWTSet;
        }
        set;
    }

    /*
    * checkRequiredFields
    *   GIVEN a WorkObject structure that wants to be upserted into the DB
    *   WHEN required fields needs to be validated before progressing with logic
    *   THEN a list of identified fields
    *
    * @param WorkObject - A custom WorkObject structure
    *
    * @return List<String> - A list of structure priorities that are required, but missing or have data quality issues from the given method parameter
    */
    public static List<String> checkRequiredFields( WorkObject specificWork ) {
        List<String> returnLst = new List<String>();
        final String MISSING_FIELD = ' is undefined in the structure';

        if ( specificWork.address == null ) {
            returnLst.add( 'street' + MISSING_FIELD );
            returnLst.add( 'city' + MISSING_FIELD );
            returnLst.add( 'state' + MISSING_FIELD );
            returnLst.add( 'postalCode' + MISSING_FIELD );
            returnLst.add( 'country' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.address.street ) ) {
            returnLst.add( 'street' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.address.city ) ) {
            returnLst.add( 'city' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.address.state ) ) {
            returnLst.add( 'state' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.address.postalCode ) ) {
            returnLst.add( 'postalCode' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.address.country ) ) {
            returnLst.add( 'country' + MISSING_FIELD );
        }

        if ( String.isBlank( specificWork.uuid ) ) {
            returnLst.add( 'uuid' + MISSING_FIELD );
        }

        if ( specificWork.workDetail == null ) {
            returnLst.add( 'dealerId' + MISSING_FIELD );
            returnLst.add( 'type' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.workDetail.dealerId ) ) {
            returnLst.add( 'dealerId' + MISSING_FIELD );
        } else if ( String.isBlank( specificWork.workDetail.type ) ) {
            returnLst.add( 'type' + MISSING_FIELD );
        } else if ( !String.isBlank( specificWork.workDetail.type ) && availableWTMap.get( specificWork.workDetail.type ) == null ) {
            returnLst.add( 'The given type is not a defined value in the system' );
        }

        if ( vinRequiredWTSet.contains( specificWork.workDetail.type ) && ( specificWork.vehicle == null || ( specificWork.vehicle != null && String.isBlank( specificWork.vehicle.vin ) ) ) ) {
            returnLst.add( 'vin' + MISSING_FIELD );
        }

        return returnLst;
    }

    public class FSLWorkStruct {
        public WorkOrder wo;
        public WorkOrderLineItem woli;
    }

    public class ConvertWorkParamStruct {
        public Map<String, Account> dealerIdMap;

        public ConvertWorkParamStruct( Set<String> dealerIdSet ) {
            this.dealerIdMap = new Map<String, Account>();
            for ( Account acct : [ SELECT Id, Name, Dealership_ID__c, Primary_Contact__c FROM Account WHERE Dealership_ID__c IN :dealerIdSet ] ) {
                this.dealerIdMap.put( acct.Dealership_ID__c, acct );
            }
        }
    }

    // If Id is missing from return, there was an issue
    public static Map<Id, Id> getServiceTerritories( Set<WorkGeoDataStruct> providedGeoDataSet ) {
        Map<Id, Id> returnMap = new Map<Id, Id>();
    
        for ( WorkGeoDataStruct workGeoRec : providedGeoDataSet ) {
            Id serviceTerritoryId = null; // clear for data safety
            if ( workGeoRec.longitude != null && workGeoRec.latitude != null ) {
                serviceTerritoryId = FSL.PolygonUtils.getTerritoryIdByPolygons( Double.valueOf( workGeoRec.longitude ), Double.valueOf( workGeoRec.latitude ) );

                if ( serviceTerritoryId != null ) {
                    returnMap.put( workGeoRec.recId, serviceTerritoryId );
                }
            }
        }

        return returnMap;
    }

    public class WorkGeoDataStruct {
        public Id recId;
        public Decimal longitude;
        public Decimal latitude;

        public WorkGeoDataStruct( Id recId, Decimal longitude, Decimal latitude ) {
            this.recId = recId;
            this.longitude = longitude;
            this.latitude = latitude;
        }
    }


    /*
        Section for working with Operating Hours for Unique Work Type Hours
    */
    public static String makeWorkTypeOptHourKey( String workTypeUniqueName, String operatingTerritoryTimeZone ) {
        return workTypeUniqueName + ':' + operatingTerritoryTimeZone;
    }

    public static void setupUniqueWorkHourStructs() {
        workTypesWithUniqueHoursSet = new Set<String>();
        workTypeToUniqueHourMap = new Map<String, OperatingHours>();
        workTypeToDayOfWeekMap = new Map<String, Map<String, TimeSlotStruct>>();
        for ( OperatingHours optHourRec : [ SELECT Unique_Work_Hours__c, Id, TimeZone, ( SELECT Id, StartTime, EndTime, DayOfWeek FROM TimeSlots ) FROM OperatingHours WHERE Unique_Work_Hours__c != null ] ) {
            List<String> splitKey = optHourRec.Unique_Work_Hours__c.split(':');
            if ( splitKey.size() == 2 ) { 
                workTypesWithUniqueHoursSet.add( splitKey[0] ); 
            }
            for ( TimeSlot ts : optHourRec.TimeSlots ) {
                if ( workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ) == null ) {
                    workTypeToDayOfWeekMap.put( optHourRec.Unique_Work_Hours__c, new Map<String, TimeSlotStruct>() );
                    workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).put( ts.DayOfWeek, new TimeSlotStruct( ts, optHourRec ) );
                    workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).timeRangeLst.add( new InnerTimeSlotStruct( ts.startTime, ts.endTime ) );
                } else if ( workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ) != null && workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ) == null ) {
                    workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).put( ts.DayOfWeek, new TimeSlotStruct( ts, optHourRec ) );
                    workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).timeRangeLst.add( new InnerTimeSlotStruct( ts.startTime, ts.endTime ) );
                } else {
                    if ( workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).startTime > ts.StartTime ) {
                        workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).startTime = ts.StartTime;
                    }
                    if ( workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).endTime < ts.EndTime ) {
                        workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).endTime = ts.EndTime;
                    }
                    workTypeToDayOfWeekMap.get( optHourRec.Unique_Work_Hours__c ).get( ts.DayOfWeek ).timeRangeLst.add( new InnerTimeSlotStruct( ts.startTime, ts.endTime ) );
                }
            }         
            workTypeToUniqueHourMap.put( optHourRec.Unique_Work_Hours__c, optHourRec );
        }
    }

    // Call setupUniqueWorkHourStructs before using either
    public static Set<String> workTypesWithUniqueHoursSet;
    // Both below use unique key method from above
    public static Map<String, Map<String, TimeSlotStruct>> workTypeToDayOfWeekMap;
    public static Map<String, OperatingHours> workTypeToUniqueHourMap;

    public class TimeSlotStruct {
        public OperatingHours optHours;
        public Time startTime; // Earliest start time of all time slots
        public Time endTime; // Latest end time of all time slots
        public List<InnerTimeSlotStruct> timeRangeLst;
        public String dayOfWeek;

        public TimeSlotStruct ( TimeSlot tsRec, OperatingHours optRec ) {
            this.startTime = tsRec.StartTime;
            this.endTime = tsRec.EndTime;
            this.dayOfWeek = tsRec.DayOfWeek;
            this.optHours = optRec;
            this.timeRangeLst = new List<InnerTimeSlotStruct>();
        }
    }

    public class InnerTimeSlotStruct {
        public Time startTime;
        public Time endTime;

        public InnerTimeSlotStruct( Time startTime, Time endTime ) {
            this.startTime = startTime;
            this.endTime = endTime;
        }
    }

    public static String determineSystemOrigin( String sfUserId ) {
        String systemOrigin = 'Salesforce';

        if ( !String.isBlank( sfUserId ) && userIntegrationMap != null && !String.isBlank( userIntegrationMap.get( sfUserId ) ) ) {
            systemOrigin = userIntegrationMap.get( sfUserId );
        }

        return systemOrigin;
    }

    private static Map<String, String> userIntegrationMap {
        get {
            if ( userIntegrationMap == null ) {     
                userIntegrationMap = new Map<String, String>();
                for( Integration_User_Mapping__mdt ium : [ SELECT Integration_Definition__c, SF_Id__c
                                    FROM Integration_User_Mapping__mdt ] ) {
                    userIntegrationMap.put( ium.SF_Id__c, ium.Integration_Definition__c );
                }
            }
            return userIntegrationMap;
        }
        set;
    }
    
    public static void makeLogFromEvent( List<Database.SaveResult> saveLst, List<String> orderedUuidLst, String className, String lineInfo ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet

        List<SplunkHelper.SFErrorRecord> errorReturnLst = new List<SplunkHelper.SFErrorRecord>();
        Set<String> uuidSet = new Set<String>();

        for ( Integer index = 0; index < saveLst.size(); index++ ) {            
            Database.SaveResult srRec = saveLst[index];            
            if ( !srRec.isSuccess() ) {             
                SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
                if ( orderedUuidLst != null && orderedUuidLst.size() < index ) { errRec.jsonStruct = orderedUuidLst[index]; }
                if ( srRec.getErrors() != null && srRec.getErrors().size() > 0 ) { errRec.errorMessage = srRec.getErrors().isEmpty() ? 'Unknown Error Encountered' : srRec.getErrors()[0]?.getMessage(); }
                errorReturnLst.add( errRec );
            } else {        
                if ( orderedUuidLst != null && orderedUuidLst.size() < index ) { uuidSet.add( orderedUuidLst[index] ); }
            }
        }
        Boolean hasError = errorReturnLst.size() > 0 ? TRUE : FALSE;

        infoLog.logLevel = !hasError ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR; 
        infoLog.location = className + ':' + lineInfo;
        infoLog.message = !hasError ? className + ' ran without issue to report' : className + ' had some issues processing, seeing the results for specifics';
        infoLog.stackTrace = className + ':' + lineInfo; 
        //infoLog.sfRecordId = UserInfo.getUserId(); - Don't set, it might be the cause of some odd errors we've seen with event generation
        infoLog.componentName = 'Work Request Event: ' + className ;
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem, ServiceAppointment, AssignedResource';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.INSPECTOR_DISPATCH, SplunkHelper.DOMAIN.SUPPLY, SplunkHelper.DOMAIN.CAPITAL };

        Set<String> successfulIdSet = new Set<String>();

        try { 
            Map<Id, WorkOrderLineItem> woliMap = new Map<Id, WorkOrderLineItem>([ SELECT Id FROM WorkOrderLineItem WHERE External_Record_Guid__c IN :uuidSet ]);
            successfulIdSet = (Set<String>) JSON.deserialize( JSON.serialize( woliMap.keyset() ), Set<String>.class );
        } catch ( exception e ) {
            system.debug( e.getMessage() );
            system.debug( e.getStackTraceString() );
        }

        SplunkHelper.buildAndProcessLog( infoLog, errorReturnLst, successfulIdSet );
    }

    public class EventSaveStruct {
        public Id id;
        public String uuid;

        public EventSaveStruct( Id idVal, String uuidVal ) {
            this.id = idVal;
            this.uuid = uuidVal;
        }
    }
}