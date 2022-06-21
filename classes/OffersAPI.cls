@RestResource(urlMapping='/Offers/*')
global class OffersAPI {

    global class DateException extends Exception {}

    // Post Variables
    private final static String GET_SUCCESS = 'Appointments were found for the provided time range';
    private final static String GET_GENERAL_ERROR = 'There was an error attempting to process the provided information';
    private final static String GET_FORMAT_ERROR = 'There was an error attempting to convert the DataTime data, please review your format';
    private final static String GET_ZIP_ERROR = 'There was an error attempting to find a Territory for that associated Zipcode, please review and contact an administrator if needed';
    private final static String GET_NO_RESULTS = 'There was no avaiable appointment slots found for the provided time range in that Territory';
    private final static String GET_TERRITORY_ERROR = 'There was an issue mapping an Appointment to a Territory. Please try again shortly. If the issue persists, please let someone know to investigate this appointment.';

    private final static Map<String, Integer> GET_RESPONSE_CODE_MAP = new Map<String, Integer>{
        GET_GENERAL_ERROR => 400,
        GET_FORMAT_ERROR => 400,
        GET_ZIP_ERROR => 400,
        GET_TERRITORY_ERROR => 400,
        GET_SUCCESS => 200,
        GET_NO_RESULTS => 200
    };

    private final static String POST_SUCCESS = 'The Appointment has been scheduled without issue';
    private final static String POST_FIELD_MISSING_ERROR = 'The provided data is missing a required field, please see the detailed return for specifics';
    private final static String POST_PROCESS_ERROR = 'There was an issue trying to save the appointment in the system, please see the detailed return for specifics';
    private final static String POST_TERRITORY_ERROR = 'There was an issue mapping an Appointment to a Territory. Please try again shortly. If the issue persists, please let someone know to investigate this appointment.';
    private final static String POST_DOWN_DAY_ERROR = 'This appointment was attempted to be saved during a \'Down Day\' for the provided Appointment Type. Please try a different date.';

    private final static Map<String, Integer> POST_RESPONSE_CODE_MAP = new Map<String, Integer>{
        POST_PROCESS_ERROR => 400,
        POST_FIELD_MISSING_ERROR => 400,
        POST_TERRITORY_ERROR => 400,
        POST_DOWN_DAY_ERROR => 400,
        POST_SUCCESS => 200
    };

    private final static Set<String> REQUIRED_PARAM_SET = new Set<String>{ 'externalUUID', 'startDateTime', 'endDateTime' };

    public final static Integer SA_SLOT_DURATION_BUFFER {
        get {
            if ( SA_SLOT_DURATION_BUFFER == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Offer Duration Buffer' LIMIT 1 ];
                SA_SLOT_DURATION_BUFFER = Integer.valueOf( setting.Value__c );
            }
            return SA_SLOT_DURATION_BUFFER;
        }
        set;
    }


    @HTTPGet
    global static void getOffers() {
        Integer statusCode;
        String statusMsg;
        String errorLineNum;
        String errorMessage;
        String errorTrace;
        List<OfferSlotObject> slotLst = new List<OfferSlotObject>();

        RestRequest request = RestContext.request;

        SplunkHelper.LOGLEVEL logLevel;

        // Get Parameters for Original Request
        String originalParam = '{';
        for ( String key : request.params.keySet() ) {
            originalParam += '"' + key + '"' + ':"' + request.params.get( key ) + '"';
            originalParam += ',';
        }
        originalParam = originalParam.substring( 0, originalParam.length() - 1 );
        originalParam += '}';

        OriginalGetRequest orReturn = new OriginalGetRequest( JSON.deserialize( originalParam, Map<String, String>.class ) );

        // Check Parameters are filled out
        Set<String> errorReturnSet = verifyRequiredParameters( request.params );
        if ( errorReturnSet.isEmpty() ) {
            // Get the proper parameters
            String externalUuid;
            try {
                externalUuid = request.params.get( 'externalUUID' );
            } catch ( exception e ) {
                statusMsg = GET_GENERAL_ERROR;
                errorLineNum = '' + ACVUtility.currentLineNumber();
                errorMessage = e.getMessage();
                errorTrace = 'OffersAPI: ' + e.getStackTraceString();
            }

            DateTime startDateTime;
            DateTime endDateTime;
            try {
                // Convet to GMT, due to inbound in local timezone of user
                startDateTime = DateTime.parse( request.params.get( 'startDateTime' ) );
                startDateTime = DateTime.newInstanceGmt( startDateTime.year(), startDateTime.month(), startDateTime.day(), startDateTime.hour(), startDateTime.minute(), 0 );

                endDateTime = DateTime.parse( request.params.get( 'endDateTime' ) );
                endDateTime = DateTime.newInstanceGmt( endDateTime.year(), endDateTime.month(), endDateTime.day(), endDateTime.hour(), endDateTime.minute(), 0 );

                if ( startDateTime >= endDateTime ) {
                    logLevel = SplunkHelper.LOGLEVEL.ERROR;
                    throw new DateException( 'There is an issue with the dates provided' );
                }
            } catch ( exception e ) {
                statusMsg = GET_GENERAL_ERROR;
                errorLineNum = '' + ACVUtility.currentLineNumber();
                errorMessage = e.getMessage();
                errorTrace = 'OffersAPI: ' + e.getStackTraceString();
            }

            if ( String.isBlank( statusMsg ) ) {
                // Get Service Appointment
                // ServiceAppointment saRec;
                WorkOrderLineItem woli;
                try {
                    woli = [ SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE External_Record_guid__c = :externalUuid LIMIT 1 ];
                    // Callout to Update Record due to system framework limits of SF
                    HttpRequest req = new HTTPRequest();
                    req.setHeader( 'Authorization', 'Bearer ' + UserInfo.getSessionId() );
                    req.setMethod( 'POST' );
                    UpdateApptDateRangeAPI.RequestedApptRange bodyData = new UpdateApptDateRangeAPI.RequestedApptRange();
                    bodyData.uuid = externalUuid;
                    bodyData.startTime = startDateTime;
                    bodyData.endTime = endDateTime;
                    String body = '{';
                    body += '"requestRec":';
                    body += JSON.serialize( bodyData );
                    body += '}';
                    req.setBody( body );
                    req.setHeader( 'Content-Type', 'application/json' );
                    req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/UpdateApptDate' );

                    Http http = new Http();
                    HttpResponse res;
                    if ( !Test.isRunningTest() ) { res = http.send( req ); }

                } catch ( exception e ) {
                    statusMsg = GET_GENERAL_ERROR;
                    errorLineNum = '' + ACVUtility.currentLineNumber();
                    errorMessage = e.getMessage();
                    errorTrace = e.getStackTraceString();
                }

                if ( woli != null && woli.WorkOrderId != null && String.isBlank( statusMsg )) {

                    Response resp = retrieveOffers(woli.WorkOrderId);
                    statusMsg = resp.statusMsg;
                    errorLineNum = resp.errorLineNum;
                    errorMessage = resp.errorMessage;
                    errorTrace = resp.errorTrace;
                    slotLst = resp.slotLst;

                }
            }
        } else {
            statusMsg = GET_GENERAL_ERROR;
            errorLineNum = '' + ACVUtility.currentLineNumber();
            errorMessage = statusMsg;
            errorTrace = 'OffersAPI: ' + errorLineNum;
        }

        // Make Callout
        ErrorInfo errorRec = new ErrorInfo( errorLineNum, errorMessage, errorTrace );
        makeGETLog( errorRec, orReturn, new GetOffersResponse( slotLst ), statusMsg, logLevel );

        // Return Data
        statusCode = GET_RESPONSE_CODE_MAP.get( statusMsg );
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            new GetOffersResponse( slotLst ),
            statusMsg,
            statusCode
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }


    @AuraEnabled
    public static Response retrieveOffers(Id workOrderId){

        Response resp = new Response();

        ServiceAppointment saRec = [ SELECT Id, Status, ServiceTerritoryId, Duration, EarliestStartTime, DueDate, ServiceTerritory.OperatingHoursId,
                                ServiceTerritory.OperatingHours.TimeZone, WorkTypeId, WorkType.Work_Type_Unique_ID__c, WorkType.EstimatedDuration, Account.Dealership_ID__c
                                FROM ServiceAppointment WHERE ParentRecordId = :workOrderId LIMIT 1 ];

        if ( saRec != null ) {
            if ( saRec.ServiceTerritoryId != null ) {
                FSLWorkProcessUtility.setupUniqueWorkHourStructs();
                Boolean hasUniqueHours = FSLWorkProcessUtility.workTypesWithUniqueHoursSet.contains( saRec.WorkType.Work_Type_Unique_Id__c );
                system.debug( 'Does it have Unique Hours Identified? - ' + hasUniqueHours );

                if ( hasUniqueHours ) {
                    // FSL Policy Grabbing Information
                    FSL__Scheduling_Policy__c policy = FSLWorkProcessUtility.PROPER_POLICY;
                    FSL.GradeSlotsService mySlotService = new FSL.GradeSlotsService( policy.Id, saRec.Id );
                    FSL.AdvancedGapMatrix myResultMatrix = mySlotService.getGradedMatrix(FALSE);
                    Map<Id, FSL.ResourceScheduleData> mySRGradedTimeSlotMap = myResultMatrix.ResourceIDToScheduleData;

                    //Get Work Type Filters
                    Set<Date> skipDaySet = getDownDays( saRec.WorkTypeId );

                    Timezone currentUserTz = UserInfo.getTimeZone();

                    List<Appointment_Offer__c> savedOfferLst = new List<Appointment_Offer__c>();
                    Map<String, OfferSlotObject> slotReturnMap = new Map<String, OfferSlotObject>();
                    SlotProcessData processSlotData = new SlotProcessData();
                    processSlotData.savedOfferLst = new List<Appointment_Offer__c>();
                    processSlotData.slotReturnMap = new Map<String, OfferSlotObject>();

                    Set<Id> resourceIdSet = new Set<Id>();
                    for ( Id thisresourceid : mySRGradedTimeSlotMap.keySet() ) {
                        resourceIdSet.add( thisresourceid );
                    }
                    resourceIdSet.remove( null );

                    Set<Id> acvUserIdSet = new Set<Id>();
                    Map<Id, Id> resourceIdToUserIdMap = new Map<Id, Id>();
                    for ( ServiceResource srRec : [ SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :resourceIdSet ] ) {
                        acvUserIdSet.add( srRec.RelatedRecordId );
                        resourceIdToUserIdMap.put( srRec.Id, srRec.RelatedRecordId );
                    }

                    Set<Id> conCheckSet = new Set<Id>();
                    if ( !acvUserIdSet.isEmpty() ) {
                        Id acvUserRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
                        for ( Contact conRec : [ SELECT Id, ACV_User__c, Identity_Id__c FROM Contact WHERE ACV_User__c IN :acvUserIdSet AND RecordTypeId = :acvUserRTId AND Active__c = TRUE ] ) {
                            if ( !String.isBlank( conRec.Identity_Id__c ) ) {
                                conCheckSet.add( conRec.ACV_User__c );
                            }
                        }
                    }

                    if ( !mySRGradedTimeSlotMap.isEmpty() ) {
                        for ( Id thisresourceid : mySRGradedTimeSlotMap.keySet() ) {
                            Id resourceUserId = resourceIdToUserIdMap.get( thisresourceid );
                            if ( ( !ACVUtility.isProd() ) || ( !String.isBlank( resourceUserId ) && conCheckSet.contains( resourceUserId ) ) ) {
                                for ( FSL.SchedulingOption thisso : mySRGradedTimeSlotMap.get( thisresourceid ).SchedulingOptions ) {
                                    if ( !skipDaySet.contains( thisso.Interval.Start?.date() ) ) {
                                        // Times returned here are pure GMT with Daylight savings time in consideration, so in November it is 5 hours off EST
                                        processSlotData = processSlotData(
                                            currentUserTz, thisso.Grade, thisresourceId,
                                            thisso.Interval.Start, thisso.Interval.Finish, saRec,
                                            processSlotData
                                        );
                                        savedOfferLst = processSlotData.savedOfferLst;
                                        slotReturnMap = processSlotData.slotReturnMap;
                                    }
                                }
                            }
                        }
                        resp.slotLst.addAll( slotReturnMap.values() );
                        resp.slotLst.sort();
                        Datetime past15 = DateTime.now().addMinutes(-15);
                        delete [ SELECT Id FROM Appointment_Offer__c WHERE Service_Appointment__c = :saRec.Id AND CreatedDate < :past15 ];
                        insert savedOfferLst;

                        resp.savedOfferMap.put(saRec.WorkType.Work_Type_Unique_ID__c, savedOfferLst);
                        resp.statusMsg = GET_SUCCESS;
                    } else {
                        resp.statusMsg = GET_NO_RESULTS;
                    }
                } else {
                    resp.statusMsg = GET_NO_RESULTS;
                }
            } else {
                resp.statusMsg = GET_TERRITORY_ERROR;
                resp.errorLineNum = '' + ACVUtility.currentLineNumber();
                resp.errorMessage = resp.statusMsg;
                resp.errorTrace = 'OffersAPI: ' + resp.errorLineNum;
            }
        } else {
            resp.statusMsg = GET_GENERAL_ERROR;
            resp.errorLineNum = '' + ACVUtility.currentLineNumber();
            resp.errorMessage = resp.statusMsg;
            resp.errorTrace = 'OffersAPI: ' + resp.errorLineNum;
        }

        if ( resp.slotLst != null && resp.slotLst.isEmpty() ) { resp.statusMsg = GET_NO_RESULTS; }

        return resp;

    }

    public class Response {

        @AuraEnabled public String statusMsg;
        @AuraEnabled public String errorLineNum;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String errorTrace;
        @AuraEnabled public List<OfferSlotObject> slotLst = new List<OfferSlotObject>();
        @AuraEnabled public Map<String,List<Appointment_Offer__c>> savedOfferMap = new Map<String,List<Appointment_Offer__c>>();

    }


    @HTTPPost
    global static void saveOffer( OfferedAppointment offerRec ) {
        OriginalPostRequest orReturn = new OriginalPostRequest( offerRec );
        SaveOfferResponse response;
        String statusMsg;

        String errorLineNum;
        String errorMessage;
        String errorTrace;

        SplunkHelper.LOGLEVEL logLevel;

        List<String> missingFields = FSLWorkProcessUtility.checkRequiredFields( offerRec.workRec );

        if ( missingFields != null && missingFields.isEmpty() && offerRec.startTime != null && offerRec.endTime != null ) {
            // Check for existing Appointments first
            List<WorkOrderLineItem> existingWoliLst = [ SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE External_Record_guid__c = :offerRec.workRec.uuid AND WorkType.Id = :FSLWorkProcessUtility.availableWTMap.get( offerRec.workRec.workDetail.type ).Id ];
            FSLWorkProcessUtility.ConvertWorkParamStruct prepData = new FSLWorkProcessUtility.ConvertWorkParamStruct( new Set<String>{ offerRec.workRec.workDetail.dealerId } );
            FSLWorkProcessUtility.FSLWorkStruct processedReturn = FSLWorkProcessUtility.convertWorkObject( offerRec.workRec, prepData );

            Savepoint sp = Database.setSavepoint();

            if ( existingWoliLst.isEmpty() ) {
                final string MISSING_DATA = 'The provided uuid does not exist in the system';
                response = new SaveOfferResponse(
                    offerRec.workRec.uuid, new List<String>{ MISSING_DATA }
                );
                statusMsg = POST_PROCESS_ERROR;

                errorLineNum = '' + ACVUtility.currentLineNumber();
                errorMessage = MISSING_DATA;
                errorTrace = errorLineNum;
            } else {
                try {
                    processedReturn.wo.Status = processedReturn.woli.Is_In_Jeopardy__c ? 'New' : 'Assigned';
                    processedReturn.wo.Id = existingWoliLst[0].WorkOrderId;
                    update processedReturn.wo;

                    processedReturn.woli.Status = 'New';
                    processedReturn.woli.Id = existingWoliLst[0].Id;
                    update processedReturn.woli;

                    ServiceAppointment saRec = [ SELECT Id, ServiceTerritory.OperatingHoursId, ServiceTerritoryId, WorkType.EstimatedDuration,
                                                ServiceTerritory.OperatingHours.TimeZone, WorkType.Work_Type_Unique_ID__c, Account.Dealership_ID__c
                                                FROM ServiceAppointment WHERE ParentRecordId = :processedReturn.wo.Id LIMIT 1 ];

                    if ( saRec.ServiceTerritoryId != null ) {
                        //Get Work Type Filters
                        Set<Date> skipDaySet = getDownDays( saRec.WorkTypeId );

                        // Get Timezone for converting
                        TimeZone territoryTimezone = TimeZone.getTimeZone( saRec.ServiceTerritory.OperatingHours.TimeZone );

                        // Converts to GMT as needed
                        DateTime properStartTime = convertTime( territoryTimezone, offerRec.startTime, TRUE );
                        DateTime properEndTime = convertTime( territoryTimezone, offerRec.endTime, TRUE );

                        if ( !skipDaySet.contains( properStartTime?.date() ) ) {
                            // Restrict dates to ensure appointment happens when promised to customers
                            saRec.EarliestStartTime = properStartTime;
                            saRec.DueDate = properEndTime;
                            saRec.ArrivalWindowStartTime = properStartTime;
                            saRec.ArrivalWindowEndTime = properEndTime;
                            saRec.Duration = saRec.WorkType.EstimatedDuration;
                            saRec.DurationType = 'Minutes';
                            saRec.Status = processedReturn.woli.Is_In_Jeopardy__c ? 'New' : 'Scheduled';

                            // Force Flag Check
                            // If the Jeopardy is set to True (CURRENTLY - NEEDS TO BE REVISITED IN FUTURE), then in Forced State
                            // If forced, don't check Offers & don't assign a resource
                            if ( !processedReturn.woli.Is_In_Jeopardy__c ) {
                                DateTime limitHour = DateTime.now().addHours(-1);
                                List<Appointment_Offer__c> getAOLst = [ SELECT Service_Resource__c, Scheduled_Start__c FROM Appointment_Offer__c
                                                                                WHERE Service_Appointment__c = :saRec.Id
                                                                                AND Start_Time__c = :properStartTime AND End_Time__c = :properEndTime
                                                                                AND CreatedDate >= :limitHour ORDER BY Grade__c DESC ];
                                if ( getAOLst.isEmpty() ) {
                                    logLevel = SplunkHelper.LOGLEVEL.ERROR;
                                    throw new DateException( 'There was an issue matching that Offer time against the system' );
                                }
                                Appointment_Offer__c aoRec = getAOLst[0];
                                saRec.Selected_Offer__c = aoRec.Id; // Mark the Selected Appointment on the SA for Analytics

                                DateTime properResourceStartTime = aoRec.Scheduled_Start__c;
                                saRec.SchedStartTime = properResourceStartTime;
                                saRec.SchedEndTime = properResourceStartTime.addMinutes( Integer.valueOf( saRec.WorkType.EstimatedDuration ) );

                                UpdateWorkTypeSATimes.apiOverride = TRUE;
                                update saRec;
                                UpdateWorkTypeSATimes.apiOverride = FALSE;

                                AssignedResource ar = new AssignedResource(
                                    ServiceAppointmentId = saRec.Id,
                                    ServiceResourceId = aoRec.Service_Resource__c
                                );
                                insert ar;
                            } else { // Needs to be changed, can't just blindly trust API on Jeopardy Flag
                                saRec.SchedStartTime = properStartTime;
                                saRec.SchedEndTime = properStartTime.addMinutes( Integer.valueOf( saRec.WorkType.EstimatedDuration ) );

                                UpdateWorkTypeSATimes.apiOverride = TRUE;
                                update saRec;
                                UpdateWorkTypeSATimes.apiOverride = FALSE;
                            }

                            response = new SaveOfferResponse( offerRec.workRec.uuid, saRec );
                            statusMsg = POST_SUCCESS;
                        } else {
                            statusMsg = POST_DOWN_DAY_ERROR;
                            errorLineNum = '' + ACVUtility.currentLineNumber();
                            errorMessage = statusMsg;
                            errorTrace = 'OffersAPI: ' + errorLineNum;
                        }
                    } else {
                        statusMsg = POST_TERRITORY_ERROR;
                        errorLineNum = '' + ACVUtility.currentLineNumber();
                        errorMessage = statusMsg;
                        errorTrace = 'OffersAPI: ' + errorLineNum;
                    }
                } catch ( exception e ) {
                    system.debug( e.getStackTraceString() );
                    system.debug( e.getMessage() );

                    response = new SaveOfferResponse(
                        offerRec.workRec.uuid, new List<String>{ e.getMessage() }
                    );
                    statusMsg = POST_PROCESS_ERROR;

                    errorLineNum = '' + e.getLineNumber();
                    errorMessage = e.getMessage();
                    errorTrace = e.getStackTraceString();

                    Database.rollback( sp );

                }
            }
        } else {
            // Missing Required Fields
            List<String> missingFieldErrLst = new List<String>();
            for ( String missingField : missingFields ) {
                missingFieldErrLst.add( 'The given structure has an issue with a required field: ' + missingField );
            }
            response = new SaveOfferResponse( offerRec.workRec.uuid, missingFieldErrLst );

            statusMsg = POST_FIELD_MISSING_ERROR;
            errorLineNum = '' + ACVUtility.currentLineNumber();
            errorMessage = statusMsg;
            errorTrace = 'OffersAPI: ' + errorLineNum;
        }

        // Log
        ErrorInfo errorRec = new ErrorInfo( errorLineNum, errorMessage, errorTrace );
        if ( response == null ) { // This will only happen for Error Scenarios
            response = new SaveOfferResponse(
                offerRec.workRec.uuid, new List<String>{ statusMsg }
            );
        }
        makePOSTLog( errorRec, orReturn, response, statusMsg, logLevel );

        // Return Data
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            response,
            statusMsg,
            POST_RESPONSE_CODE_MAP.get( statusMsg )
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }

    public class OriginalPostRequest {
        public Object originalRequest;

        public OriginalPostRequest( Object rec ) {
            this.originalRequest = rec;
        }
    }

    public class SaveOfferResponse {
        public DateTime startTime;
        public DateTime endTime;
        public String uuid;
        public Boolean hasErrors;
        public List<String> errorMessageLst;

        public SaveOfferResponse( String uuid, ServiceAppointment sa ) {
            this.uuid = uuid;
            this.hasErrors = FALSE;
            this.startTime = sa.ArrivalWindowStartTime;
            this.endTime = sa.ArrivalWindowEndTime;
        }

        public SaveOfferResponse( String uuid, List<String> errorMsgLst ) {
            this.uuid = uuid;
            this.hasErrors = TRUE;
            this.errorMessageLst = errorMsgLst;
        }
    }

    public class OriginalGetRequest {
        public Object originalRequest;

        public OriginalGetRequest( Object newRec ) {
            this.originalRequest = newRec;
        }
    }

    public class GetOffersResponse {
        public List<OfferSlotObject> foundApptSlotLst;

        public GetOffersResponse( List<OfferSlotObject> providedLst ) {
            foundApptSlotLst = providedLst;
        }
    }

    global static Appointment_Offer__c createSavedOffer( Id resourceId, DateTime start, DateTime finish, Decimal grade, ServiceAppointment sa, DateTime scheduledStart, DateTime offerStart, DateTime offerFinish ) {
        return new Appointment_Offer__c(
            Start_Time__c = start,
            End_Time__c = finish,
            Service_Resource__c = resourceId,
            Service_Appointment__c = sa.Id,
            Grade__c = grade,
            Scheduled_Start__c = scheduledStart,
            Salesforce_Offer_Start_Time__c = offerStart,
            Salesforce_Offer_End_Time__c = offerFinish
        );
    }

    global static Set<String> verifyRequiredParameters( Map<String, String> parameters ) {
        Set<String> returnErrorSet = new Set<String>();

        for( String paramName : REQUIRED_PARAM_SET ) {
            if ( !parameters.keySet().contains( paramName ) || ( parameters.keySet().contains( paramName ) && String.isBlank( parameters.get( paramName ) ) ) ) {
                returnErrorSet.add( 'The given structure has an issue with a required field: ' + paramName );
            }
        }

        return returnErrorSet;
    }

    global class SlotProcessData {
        public Map<String, OfferSlotObject> slotReturnMap;
        public List<Appointment_Offer__c> savedOfferLst;
    }

    public static SlotProcessData processSlotData( Timezone currentUserTz, Decimal grade, Id thisresourceId, DateTime startTime, DateTime endTime, ServiceAppointment saRec, SlotProcessData passData ) {
        DateTime offerStart = startTime;
        DateTime offerEnd = endTime;
        TimeZone recZone = null;

        FSLWorkProcessUtility.TimeSlotStruct timeData = UpdateWorkTypeSATimes.getTimeSlotMap( startTime, saRec.WorkType.Work_Type_Unique_Id__c, saRec.ServiceTerritory.OperatingHours.TimeZone );

        if ( saRec?.ServiceTerritory?.OperatingHours?.TimeZone != null ) {
            recZone = TimeZone.getTimeZone( saRec.ServiceTerritory.OperatingHours.TimeZone );
        }
        if ( timeData != null && recZone != null ) {
            // Convert to GMT of Appointment for the sake of Comparison
            Integer offSet = ( recZone.getOffset( startTime ) / 1000 ); // In Seconds

            for ( FSLWorkProcessUtility.InnerTimeSlotStruct innerSlot : timeData.timeRangeLst ) {
                system.debug( 'Slot Data: ' );
                system.debug( innerSlot );

                // Convert to GMT, as it is stored in local time
                Time innerSlotStartTime = innerSlot.startTime.addSeconds( ((-1) * offSet ) );
                Time innerSlotEndTime = innerSlot.endTime.addSeconds( ((-1) * offSet ) );

                system.debug( 'Slot Comparison: ' );
                system.debug( 'Start Times:' + startTime );
                system.debug( 'Inner Slot Start Time: ' + innerSlotStartTime );
                system.debug( 'End Times: '+ endTime );
                system.debug( 'Inner Slot End Time: ' + innerSlotEndTime );

                // Make Slot adjustment to be DateTimes for comparisons in GMT
                DateTime innerSlotStartDT = DateTime.newInstanceGMT( startTime.dateGmt(), innerSlotStartTime );
                Date endDate = ( startTime.dateGmt() != endTime.dateGmt() && innerSlotEndTime.hour() >= 7 ) ? endTime.dateGmt().addDays(-1) : endTime.dateGmt();
                DateTime innerSlotEndDT = DateTime.newInstanceGMT( endDate, innerSlotEndTime );

                system.debug( 'Adjusted InnerSlotStartDT: ' + innerSlotStartDT );
                system.debug( 'EndDate Adjusted: ' + endDate );
                system.debug( 'Adjusted InnerSlotEndDT: ' + innerSlotEndDT );

                if ( startTime >= innerSlotStartDT && endTime <= innerSlotEndDT && ( ( endTime.getTime() - startTime.getTime() ) >= ( ( ( saRec.WorkType.EstimatedDuration * 1000 ) * 60 ) + SA_SLOT_DURATION_BUFFER ) ) ) {
                    system.debug( 'Falls strictly within a single slot!' );
                    // If it falls strictly within a single slot, simply add existing values
                    OfferSlotObject offer = new OfferSlotObject( grade, convertTime( recZone, innerSlotStartDT, FALSE ), convertTime( recZone, innerSlotEndDT, FALSE ) );
                    if ( isNewOffer( passData.slotReturnMap, offer ) ) {
                        passData.slotReturnMap.put( makeSlotMapKey( offer.startTime, offer.endTime ), offer );
                        passData.savedOfferLst.add( createSavedOffer( thisresourceid, innerSlotStartDT, innerSlotEndDT, grade, saRec, startTime, offerStart, offerEnd ) );
                        break;
                    }
                } else if ( startTime >= innerSlotStartDT && startTime <= innerSlotEndDT && endTime > innerSlotEndDT ) {
                    system.debug( 'Falls strictly within two slots! End Time is outside of the current slot check' );
                    // If the start is within the slot, but the end is outside of it - adjust end time for offer return
                    if ( ( innerSlotEndDT.getTime() - startTime.getTime() ) >= ( ( ( saRec.WorkType.EstimatedDuration * 1000 ) * 60 ) + SA_SLOT_DURATION_BUFFER ) ) {
                        OfferSlotObject offer = new OfferSlotObject( grade, convertTime( recZone, innerSlotStartDT, FALSE ), convertTime( recZone, innerSlotEndDT, FALSE ) );
                        if ( isNewOffer( passData.slotReturnMap, offer ) ) {
                            passData.slotReturnMap.put( makeSlotMapKey( offer.startTime, offer.endTime ), offer );
                            passData.savedOfferLst.add( createSavedOffer( thisresourceid, innerSlotStartDT, innerSlotEndDT, grade, saRec, startTime, offerStart, offerEnd ) );
                        }
                    }
                } else if ( startTime < innerSlotStartDT && endTime <= innerSlotEndDT && endTime >= innerSlotStartDT ) {
                    system.debug( 'Falls strictly within two slots! Start Time is outside of the current slot check' );
                    // If the end is within the slot, but the start is outside of it - adjust start time for offer return
                    if ( ( endTime.getTime() - innerSlotStartDT.getTime() ) >= ( ( ( saRec.WorkType.EstimatedDuration * 1000 ) * 60 ) + SA_SLOT_DURATION_BUFFER ) ) {
                        OfferSlotObject offer = new OfferSlotObject( grade, convertTime( recZone, innerSlotStartDT, FALSE ), convertTime( recZone, innerSlotEndDT, FALSE ) );
                        if ( isNewOffer( passData.slotReturnMap, offer ) ) {
                            passData.slotReturnMap.put( makeSlotMapKey( offer.startTime, offer.endTime ), offer );
                            passData.savedOfferLst.add( createSavedOffer( thisresourceid, innerSlotStartDT, innerSlotEndDT, grade, saRec, innerSlotStartDT, offerStart, offerEnd ) );
                        }
                    }
                } else if ( startTime < innerSlotStartDT && endTime > innerSlotEndDT ) {
                    system.debug( 'Falls strictly outside of a single slot!' );
                    // If both the start and the end is outside of the slow - adjust both times for offer return
                    if ( ( innerSlotEndDT.getTime() - innerSlotStartDT.getTime() ) >= ( ( ( saRec.WorkType.EstimatedDuration * 1000 ) * 60 ) + SA_SLOT_DURATION_BUFFER ) ) {
                        OfferSlotObject offer = new OfferSlotObject( grade, convertTime( recZone, innerSlotStartDT, FALSE ), convertTime( recZone, innerSlotEndDT, FALSE) );
                        if ( isNewOffer( passData.slotReturnMap, offer ) ) {
                            passData.slotReturnMap.put( makeSlotMapKey( offer.startTime, offer.endTime ), offer );
                            passData.savedOfferLst.add( createSavedOffer( thisresourceid, innerSlotStartDT, innerSlotEndDT, grade, saRec, innerSlotStartDT, offerStart, offerEnd ) );
                        }
                    }
                }
            }
        }
        return passData;
    }

    global static DateTime convertTime( Timezone territoryTimezone, Datetime timeRec, Boolean GMTDirectionalChange ) {
        Integer offSetTime = territoryTimezone.getOffset( timeRec );
        // Converts to GMT as needed
        Integer directionChange = GMTDirectionalChange ? -1 : 1;
        return offSetTime > 0 ? timeRec : timeRec.addSeconds( ( (directionChange) * ( offSetTime / 1000 ) ) );
    }

    global static String makeSlotMapKey( DateTime startTime, DateTime endTime ) {
        return startTime + ':' + endTime;
    }

    global static Boolean isNewOffer( Map<String, OfferSlotObject> offerMap, OfferSlotObject offer ) {
        String key = makeSlotMapKey( offer.startTime, offer.endTime );
        OfferSlotObject existingOffer = offerMap.get( key );
        if ( ( existingOffer != null && offer.grade > existingOffer.grade ) || ( existingOffer == null ) ) {
            return true;
        }
        return false;
    }

    global static Set<Date> getDownDays( Id workTypeId ) {
        Set<Date> downDaySet = new Set<Date>();
        for( Down_Day__c downDay : [ SELECT Id, Start__c FROM Down_Day__c WHERE Work_Type__c = :workTypeId ] ) {
            downDaySet.add( downDay.Start__c.date() );
        }
        return downDaySet;
    }

    public class ErrorInfo {
        public String lineNumber;
        public String message;
        public String stackTrace;

        public ErrorInfo ( String lineNumber, String message, String stackTrace ) {
            this.lineNumber =lineNumber;
            this.message = message;
            this.stackTrace = stackTrace;
        }
    }

    public static void makeGETLog( ErrorInfo e, OriginalGetRequest orReturn, GetOffersResponse slotRes, String message, SplunkHelper.LOGLEVEL logLevel ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet

        if ( e != null && !String.isBlank( e.message ) ) {
            infoLog.logLevel = logLevel != null ? logLevel : SplunkHelper.LOGLEVEL.FATAL;
            infoLog.location = 'OffersAPI:' + e.lineNumber;
            infoLog.message = e.message;
            infoLog.stackTrace = e.stackTrace;
        } else {
            infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
            infoLog.location = 'OffersAPI:' + ACVUtility.currentLineNumber();
            infoLog.message = 'OffersAPI ran without issue to report';
            infoLog.stackTrace = 'OffersAPI:' + ACVUtility.currentLineNumber();
        }
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'OffersAPI';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem, ServiceAppointment, AssignedResource, ServiceResource';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.SALES };

        HTTPResponse res = new HTTPResponse();
        res.setBody( JSON.serialize( new ACVAPIHelper.SFResponse(
            orReturn,
            slotRes,
            message,
            GET_RESPONSE_CODE_MAP.get( message )
        ) ) );
        res.setStatusCode( GET_RESPONSE_CODE_MAP.get( message ) );

        HTTPRequest req = new HTTPRequest();
        req.setBody( JSON.serialize( orReturn ) );
        req.setMethod( 'GET' );
        req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/OFFERS' );

        SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }

    public static void makePOSTLog( ErrorInfo e, OriginalPostRequest orReturn, SaveOfferResponse saveOfferRec, String message, SplunkHelper.LOGLEVEL logLevel ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        if ( e != null && !String.isBlank( e.message ) ) {
            infoLog.logLevel = logLevel != null ? logLevel : SplunkHelper.LOGLEVEL.FATAL;
            infoLog.location = 'OffersAPI:' + e.lineNumber;
            infoLog.message = e.message;
            infoLog.stackTrace = e.stackTrace;
        } else {
            infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
            infoLog.location = 'OffersAPI:' + ACVUtility.currentLineNumber();
            infoLog.message = 'WorkAPI ran without issue to report';
            infoLog.stackTrace = 'OffersAPI:' + ACVUtility.currentLineNumber();
        }
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'OffersAPI';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem, ServiceAppointment, AssignedResource, ServiceResource';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.SALES };

        List<SplunkHelper.SFErrorRecord> errorReturnLst = new List<SplunkHelper.SFErrorRecord>();
        Set<String> successfulIdSet = new Set<String>();
        if ( saveOfferRec.hasErrors ) {
            SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
            errRec.jsonStruct = saveOfferRec.uuid;
            errRec.errorMessage = saveOfferRec.errorMessageLst.isEmpty() ? 'Unknown Error' : saveOfferRec.errorMessageLst[0]; // Only put an error message in if there is one to select
            errorReturnLst.add( errRec );
        } else {
            Set<String> uuidSet = new Set<String>();
            uuidSet.add( saveOfferRec.uuid );
            successfulIdSet = new Set<String>();
            for ( WorkOrderLineItem woli : [ SELECT Id, External_Record_Guid__c FROM WorkOrderLineItem WHERE External_Record_Guid__c IN :uuidSet ]) {
                successfulIdSet.add( JSON.serialize( woli ) );
            }
        }

        HTTPResponse res = new HTTPResponse();
        res.setBody( JSON.serialize( new ACVAPIHelper.SFResponse(
            orReturn,
            saveOfferRec,
            message,
            POST_RESPONSE_CODE_MAP.get( message )
        ) ) );
        res.setStatusCode( POST_RESPONSE_CODE_MAP.get( message ) );

        HTTPRequest req = new HTTPRequest();
        req.setBody( JSON.serialize( orReturn ) );
        req.setMethod( 'POST' );
        req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/OFFERS' );

        SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND, errorReturnLst, successfulIdSet );
    }
}