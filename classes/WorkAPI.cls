@RestResource(urlMapping='/Work/*')
global class WorkAPI {

    // Post Variables
    private final static String POST_ERROR = 'There was an error attempting to process the return: ';
    private final static String POST_PROCESS_ERROR = 'There was an error processing the return, please review the processedReturns for more information';
    private final static String POST_MIX_SUCCESS = 'Mixed success and failures, please look at the processedReturns for individual results by provided id';
    private final static String POST_SUCCESS = 'All records have been successfully processed';

    private final static Map<String, Integer> POST_RESPONSE_CODE_MAP = new Map<String, Integer>{
        POST_ERROR => 400,
        POST_PROCESS_ERROR => 400,
        POST_MIX_SUCCESS => 207,
        POST_SUCCESS => 200
    };

    // Get Variables
    private final static String GET_ERROR = 'The provided information did not match data in the system, please review and adjust';
    private final static String GET_MIX_SUCCESS = 'Mixed success and failures, please look at the apiResponse for individual results by provided id';
    private final static String GET_SUCCESS = 'Records successfully located';

    private final static Map<String, Integer> GET_RESPONSE_CODE_MAP = new Map<String, Integer>{
        GET_ERROR => 400,
        GET_MIX_SUCCESS => 207,
        GET_SUCCESS => 200
    };

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
        Integer responseCode;

        OriginalRequest orReturn = new OriginalRequest( new List<WorkObject>( newWork ) );
        ErrorInfo errorRec; // Only utilized if Critical Error hit
        try {

            // Exclude
            Set<String> uuidSet = new Set<String>();
            for ( Integer index = 0; index < newWork.size(); index++ ) {
                WorkObject workRec = newwork[index];

                if ( !String.isBlank( workRec.uuid ) ) {
                    uuidSet.add( workRec.uuid );
                } else {
                    WorkObject removedWork = newWork.remove( index );
                    index--;

                    returnLst.add( new FSLWorkProcess.ProcessedWorkStruct(
                        removedWork.uuid, new List<String>{ 'The given structure has an issue with a required field: uuid' }
                    ) );
                }
            }

            Set<String> existingRecSet = new Set<String>();
            for ( WorkOrderLineItem woliRec : [ SELECT Id, External_Record_guid__c FROM WorkOrderLineItem WHERE External_Record_guid__c IN :uuidSet ] ) {
                existingRecSet.add( woliRec.External_Record_guid__c );
            }

            // Look to identify and remove any records with missing required fields
            for ( Integer index = 0; index < newWork.size(); index++ ) {
                if ( !existingRecSet.contains( newWork[index].uuid ) ) {
                    List<String> returnMissingFields = FSLWorkProcessUtility.checkRequiredFields( newWork[index] );

                    if ( !returnMissingFields.isEmpty() ) {
                        WorkObject removedWork = newWork.remove( index );
                        index--;

                        List<String> missingFieldErrLst = new List<String>();
                        for ( String missingField : returnMissingFields ) {
                            missingFieldErrLst.add( 'The given structure has an issue with a required field: ' + missingField );
                        }

                        returnLst.add( new FSLWorkProcess.ProcessedWorkStruct(
                            removedWork.uuid, missingFieldErrLst
                        ) );
                    } else {
                        if ( !String.isBlank( newWork[index].workDetail.type ) ) {
                            newWork[index].workDetail.type = newWork[index].workDetail.type.toLowerCase();
                        }
                    }
                } else {
                    if ( !String.isBlank( newWork[index].workDetail.type ) ) {
                        newWork[index].workDetail.type = newWork[index].workDetail.type.toLowerCase();
                    }
                }
            }

            // Process and Commit logic methods
            if ( !newWork.isEmpty() ) {
                returnLst.addAll( FSLWorkProcess.commitWork( FSLWorkProcess.groupWork( newWork ) ) );
            }

            Boolean hasError = FALSE;
            Boolean hasSuccess = FALSE;

            // Organize by successes and failures
            for ( FSLWorkProcess.ProcessedWorkStruct workStructRec : returnLst ) {
                if ( workStructRec.hasErrors ) {
                    hasError = TRUE;
                    badReturnLst.add( workStructRec );
                } else {
                    hasSuccess = TRUE;
                    goodReturnLst.add( workStructRec );
                }
            }

            if ( hasError && hasSuccess ) {
                message = POST_MIX_SUCCESS;
                responseCode = POST_RESPONSE_CODE_MAP.get( POST_MIX_SUCCESS );
            } else if ( hasSuccess && !hasError ) {
                message = POST_SUCCESS;
                responseCode = POST_RESPONSE_CODE_MAP.get( POST_SUCCESS );
            } else {
                message = POST_PROCESS_ERROR;
                responseCode = POST_RESPONSE_CODE_MAP.get( POST_PROCESS_ERROR );
            }

            // Add Log
        } catch ( exception e ) {
            system.debug( e.getStackTraceString() );
            system.debug( e.getMessage() );

            message = POST_ERROR + '' + e.getMessage();
            responseCode = POST_RESPONSE_CODE_MAP.get( POST_PROCESS_ERROR );

            errorRec = new ErrorInfo( e );

            for ( WorkObject errorWO : newWork ) {
                badReturnLst.add( new FSLWorkProcess.ProcessedWorkStruct(
                    errorWO.uuid, new List<String>{ e.getMessage() }
                ) );
            }
        }

        makeLog( errorRec, orReturn, goodReturnLst, badReturnLst, message, responseCode );

        // Set REST Return
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            new WorkAPIResponse( goodReturnLst, badReturnLst ),
            message,
            responseCode
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }

    @HTTPPut
    global static void getWork( List<SearchWorkObject> findWorkLst ) {
        List<SearchWorkObject> badRequests = new List<SearchWorkObject>();
        List<WorkObject> goodRequests = new List<WorkObject>();
        String returnMsg;
        Integer responseCode;
        OriginalRequest orReturn = new OriginalRequest( new List<SearchWorkObject>( findWorkLst ) );

        Map<String, String> uuidConfirmationMap = new Map<String, String>();
        Map<String, SearchWorkObject> requestRefMap = new Map<String, SearchWorkObject>();
        if ( findWorkLst != null && !findWorkLst.isEmpty() ) {
            for ( Integer index = 0; index < findWorkLst.size(); index++ ) {
                SearchWorkObject searchRec = findWorkLst[index];

                if ( !String.isblank( searchRec.uuid ) && !String.isblank( searchRec.vin ) ) {
                    uuidConfirmationMap.put( searchRec.uuid, searchRec.vin );
                    requestRefMap.put( searchRec.uuid, searchRec );
                } else {
                    badRequests.add( searchRec );
                    findWorkLst.remove( index );
                    index--;
                }
            }

            Boolean hasSuccess = FALSE;
            Boolean hasError = FALSE;

            for ( WorkOrderLineItem checkWoliRec : [ SELECT Id, Stock_Number__c, Street, City, State, PostalCode, Country, vin__c, year__c, make__c, model__c, color__c, Title_Status__c, Title_with_Dealer__c, Dealer_Contact__c, Residential__c, Add_To_Run_List__c, Floor_Price__c, Date_Inspected__c, WorkTypeId, WorkType.Name, External_Record_guid__c, WorkOrder.Account.Dealership_ID__c, WorkOrder.Origin__c, Earliest_Start_Date__c, Due_Date__c, Status, Transport_Status__c, Job_Notes__c, Dealership_Name__c, External_Invoice_Id__c, Inspection_Location__c, Series__c, External_Assignment_Id__c,
            Is_In_Jeopardy__c, Jeopardy_State__c, Lesse_Name__c, Open_Date__c, Maturity_Date__c, Contact_Name__c, Contact_Phone_Number__c, Contact_Mobile_Number__c, Contact_Email__c,
            Customer_Email__c, Driving_Directions__c, WorkType.Work_Type_Unique_ID__c
            FROM WorkOrderLineItem WHERE External_Record_guid__c IN :uuidConfirmationMap.keyset() AND vin__c IN :new Set<String>( uuidConfirmationMap.values() ) ] ) {
                if ( uuidConfirmationMap.get( checkWoliRec.External_Record_guid__c ) == checkWoliRec.vin__c ) {
                    WorkObject rec = new WorkObject();
                    rec.uuid = checkWoliRec.External_Record_guid__c;
                    rec.origin = checkWoliRec.WorkOrder.Origin__c;

                    rec.address = new AddressObject();
                    rec.address.street = checkWoliRec.Street;
                    rec.address.city = checkWoliRec.City;
                    rec.address.state = checkWoliRec.State;
                    rec.address.postalCode = checkWoliRec.PostalCode;
                    rec.address.country = checkWoliRec.Country;
                    rec.address.location = checkWoliRec.Inspection_Location__c;

                    rec.vehicle = new VehicleObject();
                    rec.vehicle.vin = checkWoliRec.Vin__c;
                    rec.vehicle.year = checkWoliRec.Year__c;
                    rec.vehicle.model = checkWoliRec.Model__c;
                    rec.vehicle.make = checkWoliRec.Make__c;
                    rec.vehicle.color = checkWoliRec.Color__c;
                    rec.vehicle.series = checkWoliRec.Series__c;

                    rec.workDetail = new InspectionDetails();
                    rec.workDetail.stockNumber = checkWoliRec.Stock_Number__c;
                    rec.workDetail.titleStatus = checkWoliRec.Title_Status__c;
                    rec.workDetail.isTitleWithDealer = String.valueOf( checkWoliRec.Title_With_Dealer__c );
                    rec.workDetail.dealerContactName = checkWoliRec.Dealer_Contact__c;
                    rec.workDetail.isResidential = String.valueOf( checkWoliRec.Residential__c );
                    rec.workDetail.addToRunList = String.valueOf( checkWoliRec.Add_To_Run_List__c );
                    rec.workDetail.floorPrice = String.valueOf( checkWoliRec.Floor_Price__c );
                    rec.workDetail.dateInspected = String.valueOf( checkWoliRec.Date_Inspected__c );
                    rec.workDetail.dealerId = checkWoliRec.WorkOrder.Account.Dealership_Id__c;
                    rec.workDetail.type = checkWoliRec.WorkType.Work_Type_Unique_ID__c;
                    rec.workDetail.dueDate = String.valueOf( checkWoliRec.Due_Date__c );
                    rec.workDetail.status = checkWoliRec.status;
                    rec.workDetail.transportStatus = checkWoliRec.Transport_Status__c;
                    rec.workDetail.inspectionNotes = checkWoliRec.Job_Notes__c;
                    rec.workDetail.dealershipName = checkWoliRec.Dealership_Name__c;
                    rec.workDetail.earliestStartDate = String.valueOf( checkWoliRec.Earliest_Start_Date__c );
                    rec.workDetail.invoiceId = checkWoliRec.External_Invoice_Id__c;
                    rec.workDetail.assignmentId = checkWoliRec.External_Assignment_Id__c;
                    rec.workDetail.isInJeopardy = String.valueOf( checkWoliRec.Is_In_Jeopardy__c );
                    rec.workDetail.jeopardyState = checkWoliRec.Jeopardy_State__c;
                    rec.workDetail.lesseName = checkWoliRec.Lesse_Name__c;
                    rec.workDetail.openDate = String.valueOf( checkWoliRec.Open_Date__c );
                    rec.workDetail.maturityDate = String.valueOf( checkWoliRec.Maturity_Date__c );
                    rec.workDetail.customerEmail = checkWoliRec.Customer_Email__c;
                    rec.workDetail.drivingDirections = checkWoliRec.Driving_Directions__c;

                    rec.contactInfo = new ContactInformationObject();
                    rec.contactInfo.name = checkWoliRec.Contact_Name__c;
                    rec.contactInfo.phoneNumber = checkWoliRec.Contact_Phone_Number__c;
                    rec.contactInfo.mobileNumber = checkWoliRec.Contact_Mobile_Number__c;
                    rec.contactInfo.email = checkWoliRec.Contact_Email__c;

                    goodRequests.add( rec );
                    hasSuccess = TRUE;
                } else {
                    badRequests.add( requestRefMap.get( checkWoliRec.External_Record_guid__c ) );
                    hasError = TRUE;
                }
            }

            if ( hasSuccess && !hasError ) {
                responseCode = GET_RESPONSE_CODE_MAP.get( GET_SUCCESS );
                returnMsg = GET_SUCCESS;
            } else if ( hasSuccess && hasError ) {
                responseCode = GET_RESPONSE_CODE_MAP.get( GET_MIX_SUCCESS );
                returnMsg = GET_MIX_SUCCESS;
            } else {
                responseCode = GET_RESPONSE_CODE_MAP.get( GET_ERROR );
                returnMsg = GET_ERROR;

                if ( badRequests.isEmpty() ) { // If only errors, but nothing registered as a bad request, add all 'filled in' requests
                    for ( String badUuid : requestRefMap.keyset() ) {
                        badRequests.add( requestRefMap.get( badUuid ) );
                    }
                }
            }
        } else {
            returnMsg = 'No values were submitted in the request';
            responseCode = 400;
        }

        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            new GetWorkResponse( goodRequests, badRequests ),
            returnMsg,
            responseCode
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );
    }

    @HTTPGet
    global static void getWorkInfo() {

        List<String> badRequests = new List<String>();
        List<WorkObject> goodRequests = new List<WorkObject>();
        Map<String, WorkObject> goodRequestMap = new Map<String, WorkObject>();
        String returnMsg;
        Integer responseCode;

        RestRequest request = RestContext.request;

        String originalParam = '{';
        for ( String key : request.params.keySet() ) {
            originalParam += '"' + key + '"' + ':"' + request.params.get( key ) + '"';
            originalParam += ',';
        }
        originalParam = originalParam.substring( 0, originalParam.length() - 1 );
        originalParam += '}';

        OriginalGetRequest orReturn = new OriginalGetRequest( JSON.deserialize( originalParam, Map<String, String>.class ) );
        Set<String> queryUUIDSet;
        Boolean errorsFound = FALSE;

        if ( request.params.get( 'uuid' ) != null ) {
            Map<Id, String> woIdToGuidMap = new Map<Id, String>();
            queryUUIDSet = new Set<String>( request.params.get( 'uuid' ).split( ',' ) );

            for ( WorkOrderLineItem checkWoliRec : [ SELECT Id, Stock_Number__c, Street, City, State, PostalCode, Country, vin__c, year__c, make__c, model__c, color__c, Title_Status__c, Title_with_Dealer__c, Dealer_Contact__c, Residential__c, Add_To_Run_List__c, Floor_Price__c, Date_Inspected__c, WorkTypeId, WorkType.Name, External_Record_guid__c, WorkOrder.Account.Dealership_ID__c, WorkOrder.Origin__c, Earliest_Start_Date__c, Due_Date__c, Status, Transport_Status__c, Job_Notes__c, Dealership_Name__c, External_Invoice_Id__c, Inspection_Location__c, Series__c, External_Assignment_Id__c,
            Is_In_Jeopardy__c, Jeopardy_State__c, Lesse_Name__c, Open_Date__c, Maturity_Date__c, Contact_Name__c, Contact_Phone_Number__c, Contact_Mobile_Number__c, Contact_Email__c,
            Customer_Email__c, Driving_Directions__c, WorkType.Work_Type_Unique_ID__c, WorkOrderId
            FROM WorkOrderLineItem WHERE External_Record_guid__c IN :queryUUIDSet ] ) {
                woIdToGuidMap.put( checkWoliRec.WorkOrderId, checkWoliRec.External_Record_guid__c );

                WorkObject rec = new WorkObject();
                rec.uuid = checkWoliRec.External_Record_guid__c;
                rec.origin = checkWoliRec.WorkOrder.Origin__c;

                rec.address = new AddressObject();
                rec.address.street = checkWoliRec.Street;
                rec.address.city = checkWoliRec.City;
                rec.address.state = checkWoliRec.State;
                rec.address.postalCode = checkWoliRec.PostalCode;
                rec.address.country = checkWoliRec.Country;
                rec.address.location = checkWoliRec.Inspection_Location__c;

                rec.vehicle = new VehicleObject();
                rec.vehicle.vin = checkWoliRec.Vin__c;
                rec.vehicle.year = checkWoliRec.Year__c;
                rec.vehicle.model = checkWoliRec.Model__c;
                rec.vehicle.make = checkWoliRec.Make__c;
                rec.vehicle.color = checkWoliRec.Color__c;
                rec.vehicle.series = checkWoliRec.Series__c;

                rec.workDetail = new InspectionDetails();
                rec.workDetail.stockNumber = checkWoliRec.Stock_Number__c;
                rec.workDetail.titleStatus = checkWoliRec.Title_Status__c;
                rec.workDetail.isTitleWithDealer = String.valueOf( checkWoliRec.Title_With_Dealer__c );
                rec.workDetail.dealerContactName = checkWoliRec.Dealer_Contact__c;
                rec.workDetail.isResidential = String.valueOf( checkWoliRec.Residential__c );
                rec.workDetail.addToRunList = String.valueOf( checkWoliRec.Add_To_Run_List__c );
                rec.workDetail.floorPrice = String.valueOf( checkWoliRec.Floor_Price__c );
                rec.workDetail.dateInspected = String.valueOf( checkWoliRec.Date_Inspected__c );
                rec.workDetail.dealerId = checkWoliRec.WorkOrder.Account.Dealership_Id__c;
                rec.workDetail.type = checkWoliRec.WorkType.Work_Type_Unique_ID__c;
                rec.workDetail.dueDate = String.valueOf( checkWoliRec.Due_Date__c );
                rec.workDetail.status = checkWoliRec.status;
                rec.workDetail.transportStatus = checkWoliRec.Transport_Status__c;
                rec.workDetail.inspectionNotes = checkWoliRec.Job_Notes__c;
                rec.workDetail.dealershipName = checkWoliRec.Dealership_Name__c;
                rec.workDetail.earliestStartDate = String.valueOf( checkWoliRec.Earliest_Start_Date__c );
                rec.workDetail.invoiceId = checkWoliRec.External_Invoice_Id__c;
                rec.workDetail.assignmentId = checkWoliRec.External_Assignment_Id__c;
                rec.workDetail.isInJeopardy = String.valueOf( checkWoliRec.Is_In_Jeopardy__c );
                rec.workDetail.jeopardyState = checkWoliRec.Jeopardy_State__c;
                rec.workDetail.lesseName = checkWoliRec.Lesse_Name__c;
                rec.workDetail.openDate = String.valueOf( checkWoliRec.Open_Date__c );
                rec.workDetail.maturityDate = String.valueOf( checkWoliRec.Maturity_Date__c );
                rec.workDetail.customerEmail = checkWoliRec.Customer_Email__c;
                rec.workDetail.drivingDirections = checkWoliRec.Driving_Directions__c;

                rec.contactInfo = new ContactInformationObject();
                rec.contactInfo.name = checkWoliRec.Contact_Name__c;
                rec.contactInfo.phoneNumber = checkWoliRec.Contact_Phone_Number__c;
                rec.contactInfo.mobileNumber = checkWoliRec.Contact_Mobile_Number__c;
                rec.contactInfo.email = checkWoliRec.Contact_Email__c;

                goodRequestMap.put( rec.uuid, rec );
            }

            if ( !woIdToGuidMap.isEmpty() ) {
                for ( ServiceAppointment sa : [ SELECT Id, Status, ParentRecordId, ServiceTerritoryId, Bundled__c FROM ServiceAppointment WHERE ParentRecordId IN : woIdToGuidMap.keySet() ] ) {
                    String uuid = woIdToGuidMap.get( sa.ParentRecordId );
                    WorkObject updateRec = goodRequestMap.get( uuid );
                    if ( updateRec != null ) {
                        updateRec.workDetail.status = sa.Status;
                        updateRec.workDetail.hasTerritoryAssignment = sa.ServiceTerritoryId != null ? 'true' : 'false';
                        updateRec.workDetail.isBundled = String.valueOf(sa.Bundled__c);
                        goodRequestMap.put( uuid, updateRec );
                    }
                }
            }

            goodRequests = goodRequestMap.values();

            if ( goodRequests.isEmpty() ) {
                errorsFound = TRUE;
            } else if ( goodRequests.size() != queryUUIDSet.size() ) {
                for ( WorkObject confirmedInfo : goodRequests ) {
                    queryUUIDSet.remove( confirmedInfo.uuid );
                }

                errorsFound = TRUE;
                responseCode = 207;
                returnMsg = 'Partial Success in returning data. See return for more details';
            }

        } else {
            errorsFound = TRUE;
        }

        if ( errorsFound ) {
            responseCode = responseCode != null ? responseCode : 400;
            returnMsg = !String.isBlank( returnMsg ) ? returnMsg : 'No values were returned for the provided request';
            for ( String uuid : queryUUIDSet ) {
                badRequests.add( uuid );
            }
        } else {
            returnMsg = 'Records successfully located';
            responseCode = 200;
        }

        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse(
            orReturn,
            new GetWorkResponse( goodRequests, badRequests ),
            returnMsg,
            responseCode
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

    public class GetWorkResponse {
        public List<Object> successfulMatches;
        public List<Object> failedMatches;

        public GetWorkResponse( List<Object> successLst, List<Object> badLst ) {
            this.successfulMatches = successLst;
            this.failedMatches = badLst;
        }
    }

    public class OriginalRequest {
        public List<Object> originalRequest;

        public OriginalRequest( List<Object> newLst ) {
            this.originalRequest = newLst;
        }
    }

    public class ErrorInfo {
        public Integer lineNumber;
        public String message;
        public String stackTrace;

        public ErrorInfo ( Exception e ) {
            this.lineNumber = e.getLineNumber();
            this.message = e.getMessage();
            this.stackTrace = e.getStackTraceString();
        }
    }

    public class OriginalGetRequest {
        public Object originalRequest;

        public OriginalGetRequest( Object newRec ) {
            this.originalRequest = newRec;
        }
    }

    public static void makeLog( ErrorInfo e, OriginalRequest orReturn, List<FSLWorkProcess.ProcessedWorkStruct> goodReturnLst, List<FSLWorkProcess.ProcessedWorkStruct> badReturnLst, String message, Integer responseCode ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        if ( e != null ) {
            infoLog.logLevel = SplunkHelper.LOGLEVEL.FATAL;
            infoLog.location = 'WorkAPI:' + e.lineNumber;
            infoLog.message = e.message;
            infoLog.stackTrace = e.stackTrace;
        } else {
            infoLog.logLevel = badReturnLst.isEmpty() ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR;
            infoLog.location = 'WorkAPI:' + ACVUtility.currentLineNumber();
            infoLog.message = badReturnLst.isEmpty() ? 'WorkAPI ran without issue to report' : 'WorkAPI had some issues processing, seeing the results for specifics';
            infoLog.stackTrace = 'WorkAPI:' + ACVUtility.currentLineNumber();
        }
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'WorkAPI';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.SALES, SplunkHelper.DOMAIN.SUPPLY, SplunkHelper.DOMAIN.CAPITAL };

        List<SplunkHelper.SFErrorRecord> errorReturnLst = new List<SplunkHelper.SFErrorRecord>();
        for ( FSLWorkProcess.ProcessedWorkStruct badRec : badReturnLst ) {
            SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
            errRec.jsonStruct = badRec.uuid;
            errRec.errorMessage = badRec.errorMessageLst.isEmpty() ? '' : badRec.errorMessageLst[0]; // Only put an error message in if there is one to select
            errorReturnLst.add( errRec );
        }

        Set<String> uuidSet = new Set<String>();
        for ( FSLWorkProcess.ProcessedWorkStruct goodRec : goodReturnLst ) {
            uuidSet.add( goodRec.uuid );
        }

        Set<String> successfulIdSet = new Set<String>();
        for ( WorkOrderLineItem woli : [ SELECT Id, External_Record_Guid__c FROM WorkOrderLineItem WHERE External_Record_Guid__c IN :uuidSet ]) {
            successfulIdSet.add( JSON.serialize( woli ) );
        }

        HTTPResponse res = new HTTPResponse();
        res.setBody( JSON.serialize( new ACVAPIHelper.SFResponse(
            orReturn,
            new WorkAPIResponse( goodReturnLst, badReturnLst ),
            message,
            responseCode
            ) ) );
        res.setStatusCode( responseCode );

        HTTPRequest req = new HTTPRequest();
        req.setBody( JSON.serialize( orReturn ) );
        req.setMethod( 'POST' );
        req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/WORK' );

        SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND, errorReturnLst, successfulIdSet );
    }
}