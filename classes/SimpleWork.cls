@RestResource(urlMapping='/SimpleWork/*')
global class SimpleWork {

    // Post Variables
    private final static String ERROR = 'There was an error attempting to process the return: ';
    private final static String POST_SUCCESS = 'All records have been successfully processed';

    private final static Map<String, Integer> POST_RESPONSE_CODE_MAP = new Map<String, Integer>{
        ERROR => 400,
        POST_SUCCESS => 200
    };

    private final static String PUT_SUCCESS = 'All records have been successfully canceled';


    private static final String STANDARD_INSPECT = 'inspection';
    // Utilitized to change between API friendly names to SF WorkType Objects
    public static Map<String, WorkType> availableWorkTypes {
        get {
            if ( availableWorkTypes == null ) {
                availableWorkTypes = FSLWorkProcessUtility.availableWTMap;
            }
            return availableWorkTypes;
        }
        set;
    }

    @HTTPPut
    global static void cancelWork( List<CancelRequest> inputLst ) {
        List<ProcessedWorkStruct> goodReturnLst = new List<ProcessedWorkStruct>();
        List<ProcessedWorkStruct> badReturnLst = new List<ProcessedWorkStruct>();
        String message = '';
        Integer messageCode;

        OriginalRequest orReturn = new OriginalRequest( inputLst );

        Set<String> dealerIdSet = new Set<String>();
        Set<String> vinSet = new Set<String>();
        Set<String> uuidSet = new Set<String>();

        if ( inputLst.size() > 1 ) {
            Integer lineNum = ACVUtility.currentLineNumber();
            message = 'There was an issue trying to parse your input and locate records in the system';
            messageCode = 400;
            for ( CancelRequest canRec : inputLst ) {
                badReturnLst.add( new ProcessedWorkStruct( canRec, new List<String>{ message } ) );
            }
            makeLog( lineNum, message, 'cancelWork: line ' + lineNum + ', column 1' );
        } else {
            for ( CancelRequest canRec : inputLst ) {
                if( !String.isBlank( canRec.uuid ) ){
                    uuidSet.add( canRec.uuid );
                }
                else if ( !String.isBlank( canRec.dealerId ) && !String.isBlank( canRec.vin ) ) {
                    dealerIdSet.add( canRec.dealerId );
                    vinSet.add( canRec.vin );
                }
            }

            try {
                Map<String, WorkOrderLineItem> woliMap = new Map<String, WorkOrderLineItem>();
                Map<String, WorkOrderLineItem> uuidToWoliMap = new Map<String, WorkOrderLineItem>();
                Set<String> checkWoliMap = new Set<String>();
                Set<String> checkUuidWoliMap = new Set<String>();
                String workTypeId = availableWorkTypes.get( STANDARD_INSPECT ).Id;
                String completedQuery = 'SELECT Id, WorkOrderId, External_Record_Guid__c, Vin__c, WorkOrder.Account.Dealership_ID__c FROM WorkOrderLineItem';
                    completedQuery += ' WHERE StatusCategory IN (\'Completed\', \'Canceled\') AND WorkTypeId = :workTypeId';
                String notCompletedQuery = 'SELECT Id, WorkOrderId, External_Record_Guid__c, Vin__c, WorkOrder.Account.Dealership_ID__c FROM WorkOrderLineItem';
                    notCompletedQuery += ' WHERE StatusCategory NOT IN (\'Completed\', \'Canceled\') AND WorkTypeId = :workTypeId';

                String filterBasedOffOf = '';
                if( !uuidSet.isEmpty() ){
                    filterBasedOffOf = ' AND External_Record_guid__c IN :uuidSet';
                }else{
                    filterBasedOffOf = ' AND Vin__c IN :vinSet AND WorkOrder.Account.Dealership_ID__c IN :dealerIdSet';
                }

                completedQuery += filterBasedOffOf + ' LIMIT 1';
                notCompletedQuery += filterBasedOffOf;
                // LIMIT 1 until Supply uses UUIDs for canceling
                for ( WorkOrderLineItem woli : Database.query(completedQuery) ) {
                    checkWoliMap.add( createKey( woli.WorkOrder.Account.Dealership_ID__c, woli.Vin__c ) );
                    checkUuidWoliMap.add( woli.External_record_guid__c );
                }

                for ( WorkOrderLineItem woli : Database.query(notCompletedQuery) ) {
                    woliMap.put( createKey( woli.WorkOrder.Account.Dealership_ID__c, woli.Vin__c ), woli );
                    uuidToWoliMap.put( woli.External_Record_guid__c, woli );
                }

                // Process and Commit logic methods
                if ( !inputLst.isEmpty() && ( !woliMap.isEmpty() || !checkWoliMap.isEmpty() ) ) {
                    List<SObject> updateLst = new List<SObject>();
                    Boolean missedRec = FALSE;
                    List<CancelRequest> missedRecLst = new List<CancelRequest>();
                    List<CancelRequest> approvedRecLst = new List<CancelRequest>();

                    for ( CancelRequest canRec : inputLst ) {
                        WorkOrderLineItem thisWoli = woliMap.get( createKey(canRec) ) != null ? woliMap.get( createKey( canRec ) ) : uuidToWoliMap.get( createKey( canRec ) );
                        if ( thisWoli != null ) {
                            updateLst.add( new WorkOrder(
                                Id = thisWoli.WorkOrderId,
                                Status = 'Canceled'
                            ) );

                            updateLst.add( new WorkOrderLineItem(
                                Id = thisWoli.Id,
                                Status = 'Canceled'
                            ) );
                            approvedRecLst.add( canRec );
                        } else if ( checkWoliMap.contains( createKey( canRec ) ) || checkUuidWoliMap.contains( createKey( canRec )) ) {
                            missedRec = TRUE;
                            missedRecLst.add( canRec );
                        }
                    }
                    update updateLst;

                    // Set Statuses properly, mark bad records if needed
                    if ( missedRec ) {
                        Integer lineNum = ACVUtility.currentLineNumber();
                        message = 'This was an issue cancelling some of the records. Please see the return for more information';
                        messageCode = 409;

                        for ( CancelRequest canRec : missedRecLst ) {
                            badReturnLst.add( new ProcessedWorkStruct( canRec,
                                new List<String>{ 'This record could not be cancelled, as it is already marked as completed' }
                            ) );
                        }
                        makeLog( lineNum, message, 'cancelWork: line ' + lineNum + ', column 1' );
                    } else {
                        message = PUT_SUCCESS;
                        messageCode = 200;
                    }
                    // Add the good records
                    for ( CancelRequest canRec : approvedRecLst ) {
                        goodReturnLst.add( new ProcessedWorkStruct( canRec ) );
                    }
                } else {
                    Integer lineNum = ACVUtility.currentLineNumber();
                    message = 'There was an issue trying to parse your input and locate records in the system';
                    messageCode = 400;
                    for ( CancelRequest canRec : inputLst ) {
                        badReturnLst.add( new ProcessedWorkStruct( canRec, new List<String>{ message } ) );
                    }
                    makeLog( lineNum, message, 'cancelWork: line ' + lineNum + ', column 1' );
                }
            } catch ( exception e ) {
                system.debug( e.getStackTraceString() );
                system.debug( e.getMessage() );

                message = ERROR + '' + e.getMessage();
                messageCode = 400;

                for ( CancelRequest canRec : inputLst ) {
                    badReturnLst.add( new ProcessedWorkStruct( canRec, new List<String>{ message } ) );
                }

                makeLog( e );
            }
        }

        // Set REST Return
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            new WorkUpdateAPIResponse( goodReturnLst, badReturnLst ),
            message,
            messageCode
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }

    /*
    * createWork
    *   GIVEN a List of Work-line based structures
    *   WHEN Work needs to be upserted against the database
    *   THEN an organized list of Work Structures are returned, but not committed to the DB
    *
    * @param List<WorkObject> - A list of custom WorkObject structures
    */
    @HTTPPost
    global static void createWork( List<WorkObject> newWork ) {
        List<FSLWorkProcess.ProcessedWorkStruct> returnLst = new List<FSLWorkProcess.ProcessedWorkStruct>();
        List<FSLWorkProcess.ProcessedWorkStruct> goodReturnLst = new List<FSLWorkProcess.ProcessedWorkStruct>();
        List<FSLWorkProcess.ProcessedWorkStruct> badReturnLst = new List<FSLWorkProcess.ProcessedWorkStruct>();
        String message = '';

        OriginalRequest orReturn = new OriginalRequest( new List<WorkObject>( newWork ) );

        Integer statusCode;

        try {
            // Process and Commit logic methods
            if ( !newWork.isEmpty() ) {
                Map<String, WorkOrder> woMap = new Map<String, WorkOrder>();
                List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();

                // For Queries
                Set<Id> workTypeIdSet = new Set<Id>();
                Set<String> streetSet = new Set<String>();
                Set<String> zipSet = new Set<String>();

                for ( WorkObject workRec : newWork ) {
                    zipSet.add( workRec.address.postalCode );
                    streetSet.add( workRec.address.street );
                    workTypeIdSet.add( availableWorkTypes.get( workRec.workDetail.type ).Id );
                }

                // Organize Existing Work Order information into Key (Address:WorkType) map for reference
                // Map<String, Id> organizedWorkMap = new Map<String, Id>();
                Map<String, WorkOrder> organizedWorkMap = new Map<String, WorkOrder>();
                for ( WorkOrder wo : [ SELECT Id, Street, City, State, PostalCode, Country, WorkTypeId, WorkType.Name, WorkType.Work_Type_Unique_ID__c, LineItemCount FROM WorkOrder WHERE Street IN :streetSet AND PostalCode IN :zipSet AND isClosed = FALSE AND WorkTypeId IN :workTypeIdSet AND LineItemCount > 0 AND createdDate = TODAY] ) {
                    WorkObject woRec = new WorkObject();
                    woRec.address = new AddressObject();
                    woRec.address.street = wo.Street;
                    woRec.address.city = wo.City;
                    woRec.address.state = wo.State;
                    woRec.address.country = wo.Country;
                    woRec.address.postalCode = wo.PostalCode;
                    woRec.workDetail = new InspectionDetails();
                    woRec.workDetail.type = wo.WorkType.Work_Type_Unique_ID__c;
                    String key = createFSLKey( woRec );
                    // organizedWorkMap.put( key, wo.Id );
                    organizedWorkMap.put( key, wo );
                }
                List<SObject> insertLst = new List<SObject>();
                for ( WorkObject workRec : newWork ) {
                    if ( organizedWorkMap.get( createFSLKey( workRec ) ) == null ) {
                        insertLst.add( new WorkOrder(
                            Account = new Account( Dealership_ID__c = workRec.workDetail.dealerId ),
                            Street = workRec.address.street,
                            City = workRec.address.city,
                            State = workRec.address.state,
                            Country = workRec.address.country,
                            PostalCode = workRec.address.postalCode,
                            Origin__c = workRec.origin,
                            WorkTypeId = availableWorkTypes.get( workRec.workDetail.type ).Id,
                            Subject =  availableWorkTypes.get( workRec.workDetail.type ).Name,
                            //ServiceTerritoryId = ( serviceTerritoryMap.get( workRec.address.postalCode ) != null ) ? serviceTerritoryMap.get( workRec.address.postalCode ).Id : null,
                            //OwnerId = ( serviceQueueMap.get( serviceTerritoryMap.get( workRec.address.postalCode ).Name ) != null ) ? serviceQueueMap.get( serviceTerritoryMap.get( workRec.address.postalCode ).Name ) : UserInfo.getUserId(),
                            External_Record_guid__c = workRec.uuid
                        ) );
                    }

                    WorkOrderLineItem woli = new WorkOrderLineItem(
                        Make__c = workRec.vehicle.make,
                        Model__c = workRec.vehicle.model,
                        Year__c = workRec.vehicle.year,
                        Stock_Number__c = workRec.workDetail.stockNumber,
                        VIN__c = workRec.vehicle.vin,
                        WorkTypeId = availableWorkTypes.get( workRec.workDetail.type ).Id,
                        State = workRec.address.state,
                        City = workRec.address.city,
                        Street = workRec.address.street,
                        PostalCode = workRec.address.postalCode,
                        Country = workRec.address.country,
                        Color__c = workRec.vehicle.color,
                        Title_with_Dealer__c = makeBool( workRec.workDetail.isTitleWithDealer ),
                        Dealer_Contact__c = workRec.workDetail.dealerContactName,
                        Residential__c = makeBool( workRec.workDetail.isResidential ),
                        Add_To_Run_List__c = makeBool( workRec.workDetail.addToRunList ),
                        Floor_Price__c = ( !String.isBlank( workRec.workDetail.floorPrice ) ) ? Decimal.valueOf( workRec.workDetail.floorPrice ) : null,
                        Date_Inspected__c = makeDate( workRec.workDetail.dateInspected ),
                        Duration = availableWorkTypes.get( workRec.workDetail.type ).EstimatedDuration,
                        DurationType = availableWorkTypes.get( workRec.workDetail.type ).DurationType,
                        External_Record_guid__c = workRec.uuid,
                        Due_Date__c = makeDate( workRec.workDetail.dueDate ),
                        Status = 'New',
                        Transport_Status__c = workRec.workDetail.transportStatus,
                        Description = workRec.workDetail.inspectionNotes,
                        Dealership_Name__c = workRec.workDetail.dealershipName,
                        Earliest_Start_Date__c = makeDate( workRec.workDetail.earliestStartDate ),
                        Origin__c = workRec.origin
                    );
                    if ( organizedWorkMap.get( createFSLKey( workRec ) ) != null ) {

                        WorkOrder wo = organizedWorkMap.get( createFSLKey( workRec ) );
                        if(wo.LineItemCount < FSLWorkProcess.WORKTYPE_MAX_WOLI_MAP.get(wo.WorkType.Work_Type_Unique_ID__c)){
                            woli.WorkOrderId = organizedWorkMap.get( createFSLKey( workRec ) ).Id;
                        } else {
                            insertLst.add( new WorkOrder(
                                Account = new Account( Dealership_ID__c = workRec.workDetail.dealerId ),
                                Street = workRec.address.street,
                                City = workRec.address.city,
                                State = workRec.address.state,
                                Country = workRec.address.country,
                                PostalCode = workRec.address.postalCode,
                                Origin__c = workRec.origin,
                                WorkTypeId = availableWorkTypes.get( workRec.workDetail.type ).Id,
                                Subject =  availableWorkTypes.get( workRec.workDetail.type ).Name,
                                //ServiceTerritoryId = ( serviceTerritoryMap.get( workRec.address.postalCode ) != null ) ? serviceTerritoryMap.get( workRec.address.postalCode ).Id : null,
                                //OwnerId = ( serviceQueueMap.get( serviceTerritoryMap.get( workRec.address.postalCode ).Name ) != null ) ? serviceQueueMap.get( serviceTerritoryMap.get( workRec.address.postalCode ).Name ) : UserInfo.getUserId(),
                                External_Record_guid__c = workRec.uuid
                            ));
                            woli.WorkOrder = new WorkOrder( External_Record_guid__c = workRec.uuid );
                        }
                    } else {
                        woli.WorkOrder = new WorkOrder( External_Record_guid__c = workRec.uuid );
                    }
                    insertLst.add( woli );
                }
                insert insertLst;
            }

        message = POST_SUCCESS;

        // If we don't error by here, it was successful
        for ( WorkObject woRec : newWork ) {
            goodReturnLst.add( new FSLWorkProcess.ProcessedWorkStruct( woRec.uuid ) );
        }

        } catch ( exception e ) {
            system.debug( e.getStackTraceString() );
            system.debug( e.getMessage() );

            message = ERROR + '' + e.getMessage();
            statusCode = 400;

            for ( WorkObject errorWO : newWork ) {
                badReturnLst.add( new FSLWorkProcess.ProcessedWorkStruct(
                    errorWO.uuid, new List<String>{ e.getMessage() }
                ) );
            }

            makeLog( e );
        }

        statusCode = statusCode == null ? POST_RESPONSE_CODE_MAP.get( message ) : statusCode;

        // Set REST Return
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            new WorkAPIResponse( goodReturnLst, badReturnLst ),
            message,
            statusCode
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }

    public class WorkAPIResponse {
        // Two lists, one success, one failures
        public List<FSLWorkProcess.ProcessedWorkStruct> successfulRecords;
        public List<FSLWorkProcess.ProcessedWorkStruct> errorRecords;

        public WorkAPIResponse( List<FSLWorkProcess.ProcessedWorkStruct> returnLst, List<FSLWorkProcess.ProcessedWorkStruct> badReturnlst ) {
            this.successfulRecords = returnLst;
            this.errorRecords = badReturnlst;
        }
    }

    public class WorkUpdateAPIResponse {
        public List<ProcessedWorkStruct> successfulRecords;
        public List<ProcessedWorkStruct> errorRecords;

        public WorkUpdateAPIResponse( List<ProcessedWorkStruct> returnLst, List<ProcessedWorkStruct> badReturnlst ) {
            this.successfulRecords = returnLst;
            this.errorRecords = badReturnlst;
        }
    }

    public class OriginalRequest {
        public List<Object> originalRequest;

        public OriginalRequest( List<Object> newLst ) {
            this.originalRequest = newLst;
        }
    }

    global class CancelRequest {
        public String dealerId;
        public String vin;
        public String uuid;
    }

    public class ProcessedWorkStruct {
        public CancelRequest request;
        public Boolean hasErrors;
        public List<String> errorMessageLst;

        public ProcessedWorkStruct( CancelRequest canRec ) {
            this.request = canRec;
            this.hasErrors = FALSE;
        }

        public ProcessedWorkStruct( CancelRequest canRec, List<String> errorMessageLst ) {
            this.request = canRec;
            this.hasErrors = TRUE;
            this.errorMessageLst = errorMessageLst;
        }
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
        if ( val != null && ( val.toLowerCase() == 'yes' || val.toLowerCase() == 'true' ) ) {
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
        if ( String.isBlank( val ) ) { return null; }
        try {
            return Date.valueOf( val );
        } catch ( exception e ) {
            val = val.replaceAll( '-', '/' );
            List<String> dateArray = val.split( '/' );
            Integer year = dateArray[2].length() == 2 ? Integer.valueOf( '20' + dateArray[2] ) : Integer.valueOf( dateArray[2] );
            return Date.newInstance( year, Integer.valueOf( dateArray[0] ), Integer.valueOf( dateArray[1] ) );
        }
    }

    public static String createKey( CancelRequest canRec ) {
        if( !String.isBlank(canRec.uuid) ){
            return canRec.uuid;
        }else{
        	return createKey( canRec.dealerId, canRec.vin );
        }
    }

    public static String createKey( String dealerId, String vin ) {
        return dealerId + ':' + vin;
    }

    public static String createFSLKey( WorkObject workRec ) {
        return workRec.address.toString() + ':' + availableWorkTypes.get( workRec.workDetail.type ).Name;
    }

    public static void makeLog( Exception e ) {
        makeLog( e.getLineNumber(), e.getMessage(), e.getStackTraceString() );
    }

    public static void makeLog( Integer lineLocation, String message, String stackTrace ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        infoLog.location = 'SimpleWork:' + lineLocation;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'SimpleWork';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SUPPLY };

        SplunkHelper.buildandProcessLog( infoLog );
    }
}