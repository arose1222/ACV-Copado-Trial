@RestResource(urlMapping='/Audit/*')
global class AssetVerificationAuditAPI {

    private static final String ASSET_VERIFY = 'verification';
    private static final WorkType ASSET_VERIFY_WT {
        get {
            if ( ASSET_VERIFY_WT == null ) {
                ASSET_VERIFY_WT = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = :ASSET_VERIFY LIMIT 1 ];
            }
            return ASSET_VERIFY_WT;
        }
        set;
    }

    private final static string CLASS_NAME = 'AssetVerificationAuditAPI';

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

    @HTTPPost
    global static void updateAudit( List<AuditObject> auditLst ) {
        List<AuditObject> originalRequest = auditLst;
        AuditAPIResponse returnRes = new AuditAPIResponse();
        ErrorInfo errorRec;
        String message;
        Map<String, List<String>> errorMap = new Map<String, List<String>>();

        final String MISSING_FIELD = ' is undefined in the structure';

        Set<String> dealershipIdSet = new Set<String>();
        Map<String, AuditObject> auditRefMap = new Map<String, AuditObject>();
        try {
            for ( AuditObject auditRec : auditLst ) {
                if ( !String.isBlank( auditRec.dealerId ) && auditRec.auditDueDate != null && auditRec.earliestStartDate != null ) {
                    dealershipIdSet.add( auditRec.dealerId );
                    auditRefMap.put( auditRec.dealerId, auditRec );
                } else {
                    List<String> missingFieldLst = new List<String>();
                    if ( String.isBlank( auditRec.dealerId )  ) {
                        missingFieldLst.add( 'dealerId' + MISSING_FIELD );
                    }
                    if ( auditRec.auditDueDate == null ) {
                        missingFieldLst.add( 'auditDueDate' + MISSING_FIELD );
                    }
                    if ( auditRec.earliestStartDate == null ) {
                        missingFieldLst.add( 'earliestStartDate' + MISSING_FIELD );
                    }

                    returnRes.errorRecords.add( new AuditProcessedResult( auditRec.dealerId, missingFieldLst ) );
                }
            }

            if ( !dealershipIdSet.isEmpty() ) {
            Map<string, Id> workOrderMatchMap = new Map<string, Id>();
            Set<string> invoiceNumberSet = new Set<string>();

                // Open Pathway - No need to recreate records
                List<WorkOrderLineItem> upsertWoliLst = new List<WorkOrderLineItem>();

                Set<Id> workOrderIdSet = new Set<Id>();
                Map<Id, AuditObject> workAuditMap = new Map<Id, AuditObject>();
                for ( WorkOrderLineItem woliRec : [ SELECT Id, Due_Date__c, Earliest_Start_Date__c, Street, City, State, PostalCode, WorkTypeId, WorkOrderId, 
                                                        WorkOrder.Account.Dealership_ID__c, Invoice__r.Invoice_Id__c
                                                        FROM WorkOrderLineItem WHERE WorkOrder.Account.Dealership_ID__c IN :dealershipIdSet 
                                                                                    AND WorkOrder.isClosed = FALSE AND WorkType.Id = :ASSET_VERIFY_WT.Id 
                                                                                    AND Invoice__r.Status__c = 'Open' ] ) {
                    AuditObject auditRec = auditRefMap.get( woliRec.WorkOrder.Account.Dealership_ID__c );
                    if ( auditRec != null ) {
                        woliRec.Earliest_Start_Date__c = makeESTDate( auditRec.earliestStartDate ).date();
                        woliRec.Due_Date__c = makeESTDate( auditRec.auditDueDate ).date();
                        upsertWoliLst.add( woliRec );

                        workAuditMap.put( woliRec.workOrderId, auditRec );
                        workOrderIdSet.add( woliRec.WorkOrderId );

                        workOrderMatchMap.put( 
                            makeKey( 
                                woliRec.WorkOrder.Account.Dealership_Id__c, 
                                concatAddress( woliRec.Street, woliRec.City, woliRec.State, woliRec.PostalCode ), 
                                FSLWorkProcessUtility.workTypeIdMap.get( woliRec.WorkTypeId ).Work_Type_Unique_ID__c 
                            ), 
                            woliRec.WorkOrderId 
                        );
                        invoiceNumberSet.add( woliRec.Invoice__r.Invoice_Id__c );
                    }
                }

                // Closed Pathway - Need to recreate records, can try to attach to above Work Order Ids
                Map<String, WorkOrder> newWorkOrderMap = new Map<String, WorkOrder>();
                Set<String> invoiceIdSet = new Set<String>();

                // Get Invoices associated with that Dealership that are still open, but remove any invoices we already caught from above
                for ( Invoice__c invoiceRec : [ SELECT Id, Name,
                                                        ( SELECT Id, Make__c, Model__c, Year__c,
                                                        Stock_Number__c, VIN__c, WorkTypeId, State,
                                                        City, Street, PostalCode, Country,
                                                        Color__c, Title_with_Dealer__c, Dealer_Contact__c,
                                                        Residential__c, Add_To_Run_List__c, Floor_Price__c,
                                                        Date_Inspected__c, Duration, DurationType,
                                                        External_Record_guid__c, Due_Date__c, Status,
                                                        Transport_Status__c, Job_Notes__c, Dealership_Name__c,
                                                        Earliest_Start_Date__c, External_Invoice_Id__c,
                                                        // Needed for Work Order Creation
                                                        WorkOrder.Account.Dealership_ID__c, WorkOrder.AccountId,
                                                        WorkOrder.Origin__c, WorkOrder.WorkTypeId, WorkOrder.Subject,
                                                        WorkOrder.ServiceTerritoryId
                                                        FROM Work_Order_Line_Items__r WHERE WorkTypeId = :ASSET_VERIFY_WT.Id
                                                        ORDER BY CreatedDate DESC ) 
                                                    FROM Invoice__c WHERE Status__c = 'Open' AND Account__r.Dealership_Id__c IN :dealershipIdSet 
                                                    AND Invoice_Id__c NOT IN :invoiceNumberSet ] ) 
                {
                    if ( invoiceRec.Work_Order_Line_Items__r.size() > 0 ) {
                        WorkOrderLineItem woli = invoiceRec.Work_Order_Line_Items__r[0]; // Most Recent Work Order created
                        AuditObject auditRec = auditRefMap.get( woli.WorkOrder.Account.Dealership_ID__c );
                        if ( auditRec != null ) {
                            WorkOrderLineItem createWOLI = new WorkOrderLineItem(
                                Make__c = woli.make__c,
                                Model__c = woli.model__c,
                                Year__c = woli.Year__c,
                                Stock_Number__c = woli.Stock_Number__c,
                                VIN__c = woli.vin__c,
                                WorkTypeId = woli.WorkTypeId,
                                State = woli.State,
                                City = woli.city,
                                Street = woli.street,
                                PostalCode = woli.postalCode,
                                Country = woli.country,
                                Color__c = woli.color__c,
                                Title_with_Dealer__c = woli.Title_With_Dealer__c,
                                Dealer_Contact__c = woli.Dealer_Contact__c,
                                Residential__c = woli.Residential__c,
                                Add_To_Run_List__c = woli.Add_To_Run_List__c,
                                Floor_Price__c = woli.Floor_Price__c,
                                Date_Inspected__c = woli.Date_Inspected__c,
                                Duration = woli.Duration,
                                DurationType = woli.DurationType,
                                Status = 'New', // Don't use previous Status, only use new Status
                                External_Invoice_Id__c = woli.External_Invoice_Id__c,
                                Transport_Status__c = woli.Transport_Status__c,
                                Job_Notes__c = woli.Job_Notes__c,
                                Dealership_Name__c = woli.Dealership_Name__c
                            );

                            invoiceIdSet.add( woli.External_Invoice_Id__c );

                            createWOLI.Earliest_Start_Date__c = makeESTDate( auditRec.earliestStartDate ).date();
                            createWOLI.Due_Date__c = makeESTDate( auditRec.auditDueDate ).date();

                            String woliKey = makeKey( 
                                woli.WorkOrder.Account.Dealership_Id__c, 
                                concatAddress( woli.Street, woli.City, woli.State, woli.PostalCode ), 
                                FSLWorkProcessUtility.workTypeIdMap.get( woli.WorkTypeId ).Work_Type_Unique_ID__c 
                            );
                            Id workOrderId = workOrderMatchMap.get( woliKey );
                            if ( workOrderId != null ) { // There is an existing Work Order we can group with
                                createWOLI.WorkOrderId = workOrderId;
                            } else { // A new Work Order needs to be created
                                if ( newWorkOrderMap.get( woliKey ) == null ) { // Ensure we're only doing this once per matching key
                                    newWorkOrderMap.put(
                                        woliKey,
                                        new WorkOrder(
                                            AccountId = woli.WorkOrder.AccountId,
                                            Street = woli.Street,
                                            City = woli.City,
                                            State = woli.State,
                                            Country = woli.Country,
                                            PostalCode = woli.postalCode,
                                            Origin__c = woli.WorkOrder.origin__c,
                                            WorkTypeId = woli.WorkOrder.WorkTypeId,
                                            Subject =  woli.WorkOrder.Subject,
                                            ServiceTerritoryId = woli.WorkOrder.ServiceTerritoryId
                                        )
                                    );
                                }
                            }

                            upsertWoliLst.add( createWOLI );
                        }
                    }
                }

                if ( !newWorkOrderMap.isEmpty() ) {
                    Map<Id, String> acctToDealerIdMap = new Map<Id, String>();
                    Map<String, String> invoiceToDealerIdMap = new Map<String, String>();
                    for ( Invoice__c inv : [ SELECT Id, Invoice_Id__c, Account__c, Account__r.Dealership_Id__c FROM Invoice__c WHERE Invoice_Id__c IN :invoiceIdSet ] ) {
                        acctToDealerIdMap.put( inv.Account__c, inv.Account__r.Dealership_Id__c );
                        invoiceToDealerIdMap.put( inv.Invoice_Id__c, inv.Account__r.Dealership_Id__c );
                    }

                    Set<string> errorKeySet = new Set<string>();
                    // Create New Work Orders and pair back to the Line Items
                    List<Database.SaveResult> dbCreateResultLst = Database.insert( newWorkOrderMap.values(), FALSE );

                    for ( Integer index = 0; index < dbCreateResultLst.size(); index++ ) {
                        Database.SaveResult dbResultRec = dbCreateResultLst[index];                
                        WorkOrder woRec = newWorkOrderMap.values()[index];

                        // Setup error return records
                        if ( !dbResultRec.isSuccess() ) {
                            errorMap = processError( errorMap, acctToDealerIdMap.get( woRec.AccountId ), dbResultRec.getErrors() );
                            errorKeySet.add( makeKey(
                                acctToDealerIdMap.get( woRec.AccountId ), 
                                concatAddress( woRec.Street, woRec.City, woRec.State, woRec.PostalCode ), 
                                FSLWorkProcessUtility.workTypeIdMap.get( woRec.WorkTypeId ).Work_Type_Unique_ID__c
                            ) );
                        }
                    }

                    for ( integer woliIndex = 0; woliIndex < upsertWoliLst.size(); woliIndex++ ) {
                        WorkOrderLineItem woliCheck = upsertWoliLst[woliIndex];
                        string woliCheckKey = makeKey( 
                            invoiceToDealerIdMap.get( woliCheck.External_Invoice_Id__c ), 
                            concatAddress( woliCheck.Street, woliCheck.City, woliCheck.State, woliCheck.PostalCode ), 
                            FSLWorkProcessUtility.workTypeIdMap.get( woliCheck.WorkTypeId ).Work_Type_Unique_ID__c 
                        );
                        if ( woliCheck.WorkOrderId == null ) {
                            if ( errorKeySet.contains( woliCheckKey ) ) { // Error creating WOLI
                                upsertWoliLst.remove( woliIndex );
                                woliIndex--; // Adjust Index to reflect adjustment
                            } else { // No Error
                                Id workOrderId = newWorkOrderMap.get( woliCheckKey ).Id;
                                woliCheck.WorkOrderId = workOrderId;
                            
                                workAuditMap.put( workOrderId, auditRefMap.get( woliCheck.WorkOrder.Account.Dealership_ID__c ) );
                                workOrderIdSet.add( workOrderId );
                            }
                        }
                    }
                }

                if ( !workOrderIdSet.isEmpty() ) { // Process as normal regardless of upstream impact
                    List<ServiceAppointment> updateServiceLst = new List<ServiceAppointment>();
                    for ( ServiceAppointment saRec : [ SELECT Id, ParentRecordId, EarliestStartTime, DueDate FROM ServiceAppointment WHERE ParentRecordId IN :workOrderIdSet ] ) {
                        AuditObject auditRec = workAuditMap.get( saRec.ParentRecordId );
                        if ( auditRec != null ) {
                            saRec.EarliestStartTime = makeESTDate( auditRec.earliestStartDate );
                            saRec.DueDate = makeESTDate( auditRec.auditDueDate );
                            updateServiceLst.add( saRec );
                        }
                    }
                    
                    List<Database.UpsertResult> dbResultLst = Database.upsert( upsertWoliLst, FALSE );

                    for ( Integer index = 0; index < dbResultLst.size(); index++ ) {
                        Database.UpsertResult dbResultRec = dbResultLst[index];                
                        WorkOrderLineItem woliRec = upsertWoliLst[index];              
                        // Setup error return records
                        if ( !dbResultRec.isSuccess() ) {
                            errorMap = processError( errorMap, woliRec.WorkOrder.Account.Dealership_ID__c, woliRec, dbResultRec.getErrors() );
                        }
                    }

                    //update updateServiceLst;
                    List<Database.SaveResult> dbSaveResultLst = Database.update( updateServiceLst, FALSE );
                    for ( Integer index = 0; index < dbSaveResultLst.size(); index++ ) {
                        Database.SaveResult dbResultRec = dbSaveResultLst[index];                
                        ServiceAppointment saRec = updateServiceLst[index];       
                        AuditObject auditRec = workAuditMap.get( saRec.ParentRecordId );       

                        // Setup error return records
                        if ( !dbResultRec.isSuccess() ) {
                            errorMap = processError( errorMap, auditRec.dealerId, saRec, dbResultRec.getErrors() );
                        }
                    }
                }
            }

            if ( !errorMap.isEmpty() ) {
                for ( String errorDealerId : errorMap.keyset() ) {
                    returnRes.errorRecords.add( new AuditProcessedResult(
                        errorDealerId, errorMap.get( errorDealerId )
                    ) );
                }
            }

            // Set return information
            if ( returnRes.errorRecords.isEmpty() ) { // No errors, success
                message = POST_SUCCESS;
            } else if ( !returnRes.errorRecords.isEmpty() && !returnRes.successfulRecords.isEmpty() ) { // Mixed success
                message = POST_MIX_SUCCESS;
            } else { // Otherwise, errors
                message = POST_PROCESS_ERROR;
            }
        } catch ( exception e ) {
            message = POST_ERROR;
            errorRec = new ErrorInfo( e );

            for ( AuditObject auditRec : auditLst ) {
                returnRes.errorRecords.add( new AuditProcessedResult(
                    auditRec.dealerId, new List<String>{ e.getMessage() }
                ) );
            }
        }
        

        // Set REST Return
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse( 
            originalRequest,
            returnRes,
            message,
            POST_RESPONSE_CODE_MAP.get( message )
         );
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );

         makeLog( errorRec, originalRequest, returnRes.successfulRecords, returnRes.errorRecords, message, POST_RESPONSE_CODE_MAP.get( message ) );
    }


    global class AuditObject {
        public String dealerId;
        public Date auditDueDate;
        public Date earliestStartDate;
    }

    global class AuditAPIResponse {
        List<AuditProcessedResult> successfulRecords;
        List<AuditProcessedResult> errorRecords;

        global AuditAPIResponse() {
            this.successfulRecords = new List<AuditProcessedResult>();
            this.errorRecords = new List<AuditProcessedResult>();
        }
    }

    public class AuditProcessedResult {
        public String dealerId;
        public Boolean hasErrors;
        public List<String> errorMessageLst; 

        public AuditProcessedResult( String dealerId ) {
            this.dealerId = dealerId;
            this.hasErrors = FALSE;
        }

        public AuditProcessedResult( String dealerId, List<String> errorMessageLst ) {
            this.dealerId = dealerId;
            this.hasErrors = TRUE;
            this.errorMessageLst = errorMessageLst;
        }
    }

    public static DateTime makeESTDate( Date theDate ) {
        return DateTime.newInstance( theDate.year(), theDate.month(), theDate.day(), 12, 0, 0 ); 
    }

    public static String concatAddress( String street, String city, String state, String postalCode ) {
        return street + ',' + city + ',' + state + ',' + postalCode;
    }

    public static String makeKey( String dealershipId, String addressStrg, String worktypeName ) { // Including Work Type Name just in case more then 1 work type ever uses the API
        return dealershipId + ':' + addressStrg + ':' + worktypeName;
    }

    public static Map<String, List<String>> processError( Map<String, List<String>> errorMap, String dealerId, SObject record, List<Database.Error> errorLst ) {
        if ( errorMap.get( dealerId ) == null ) {
            errorMap.put( dealerId, new List<String>() );
        }

        for ( Database.Error error : errorLst ) {
            errorMap.get( dealerId ).add( record.Id + ': ' + error.getMessage() );
        }

        return errorMap;
    }

    public static Map<String, List<String>> processError( Map<String, List<String>> errorMap, String dealerId, List<Database.Error> errorLst ) {
        if ( errorMap.get( dealerId ) == null ) {
            errorMap.put( dealerId, new List<String>() );
        }

        for ( Database.Error error : errorLst ) {
            errorMap.get( dealerId ).add( error.getMessage() );
        }

        return errorMap;
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

    public static void makeLog( ErrorInfo e, List<AuditObject> orReturnLst, List<AuditProcessedResult> goodReturnLst, List<AuditProcessedResult> badReturnLst, String message, Integer responseCode ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        if ( e != null ) {
            infoLog.logLevel = SplunkHelper.LOGLEVEL.FATAL;
            infoLog.location = CLASS_NAME + ':' + e.lineNumber;
            infoLog.message = e.message;
            infoLog.stackTrace = e.stackTrace;
        } else {
            infoLog.logLevel = badReturnLst.isEmpty() ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR; 
            infoLog.location = CLASS_NAME + ':' + ACVUtility.currentLineNumber();
            infoLog.message = badReturnLst.isEmpty() ? 'AssetVerificationAuditAPI ran without issue to report' : 'AssetVerificationAuditAPI had some issues processing, seeing the results for specifics';
            infoLog.stackTrace = CLASS_NAME + ':' + ACVUtility.currentLineNumber();
        }
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = CLASS_NAME;
        infoLog.sfObject = 'Invoice, WorkOrderLineItem';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.CAPITAL, SplunkHelper.DOMAIN.SCHEDULING_PLATFORM };

        List<SplunkHelper.SFErrorRecord> errorReturnLst = new List<SplunkHelper.SFErrorRecord>();
        for ( AuditProcessedResult badRec : badReturnLst ) {
            SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
            errRec.jsonStruct = badRec.dealerId;
            errRec.errorMessage = badRec.errorMessageLst.isEmpty() ? '' : badRec.errorMessageLst[0]; // Only put an error message in if there is one to select
            errorReturnLst.add( errRec );
        }

        Set<String> idSet = new Set<String>();
        for ( AuditProcessedResult goodRec : goodReturnLst ) {
            idSet.add( goodRec.dealerId );
        }

        AuditAPIResponse returnRes = new AuditAPIResponse();
        returnRes.successfulRecords = goodReturnLst;
        returnRes.errorRecords = badReturnLst;

        HTTPResponse res = new HTTPResponse();
        res.setBody( JSON.serialize( new ACVAPIHelper.SFResponse( 
            orReturnLst,
            returnRes,
            message,
            responseCode
            ) ) );
        res.setStatusCode( responseCode );
        
        HTTPRequest req = new HTTPRequest();
        req.setBody( JSON.serialize( orReturnLst ) );
        req.setMethod( 'POST' );
        req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/InvoiceCancel' );

        SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND, errorReturnLst, idSet );
    }
}