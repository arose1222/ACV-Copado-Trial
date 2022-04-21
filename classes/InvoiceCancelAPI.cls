@RestResource(urlMapping='/InvoiceCancel/*')
global class InvoiceCancelAPI {

    // Post Variables
    private final static string POST_ERROR = 'There was an error attempting to process the return';
    private final static string POST_MIX_SUCCESS = 'Mixed success and failures, please look at the processedReturns for individual results by provided id';
    private final static string POST_SUCCESS = 'All records have been successfully processed';

    private final static Map<String, Integer> POST_RESPONSE_CODE_MAP = new Map<String, Integer>{ 
        POST_ERROR => 400,
        POST_MIX_SUCCESS => 207,
        POST_SUCCESS => 200
    };

    // Specific Error Variables
    private final static string MISSING_REQUIRED_FIELD = 'Some required fields are missing from the API call: ';
    private final static string INVOICE_NOT_FOUND = 'There was an issue locating an Invoice with the provided Id';
    private final static string INVOICE_UPDATE_ERROR = 'There was an issue with marking the Invoice as Closed: ';
    private final static string WOLI_UPDATE_ERROR = 'There was an issue with marking the Work as Closed: ';

    // Utility Variables
    private final static string CLASS_NAME = 'InvoiceCancelAPI';
    private final static string ASSET_VERIFICATION_WT_ID = FSLWorkProcessUtility.availableWTMap.get( 'verification' ).Id;
    private final static Set<string> WOLI_STATUS_CATEGORY_CHECK_SET = new Set<string>{ 'Completed', 'CannotComplete', 'Closed', 'Canceled' };

    @HTTPPost
    global static void cancelInvoice( List<CancelStruct> invoiceCancelLst ) {
        OriginalRequest orReturn = new OriginalRequest( new List<CancelStruct>( invoiceCancelLst ) );
        List<ProcessedInvoiceStruct> goodReturnLst = new List<ProcessedInvoiceStruct>();
        List<ProcessedInvoiceStruct> badReturnLst = new List<ProcessedInvoiceStruct>();
        String message;
        ErrorInfo errorRec;

        try {
            Set<string> invoiceIdSet = new Set<string>();

            for ( CancelStruct cancelRec : invoiceCancelLst ) {
                if ( String.isBlank( cancelRec.invoiceId ) ) { // Missing Required Field
                    badReturnLst.add( new ProcessedInvoiceStruct(
                        cancelRec.invoiceId, new List<String>{ MISSING_REQUIRED_FIELD + 'invoiceId' }
                    ) );
                } else {
                    invoiceIdSet.add( cancelRec.invoiceId );
                }
            }

            // Update Invoice - Only if there are records still without error
            if ( !invoiceIdSet.isEmpty() ) {
                List<Invoice__c> invoiceProcessLst = [ SELECT Id, Invoice_Id__c, Status__c FROM Invoice__c WHERE Invoice_Id__c IN :invoiceIdSet ];
                if ( !invoiceProcessLst.isEmpty() ) {
                    Set<string> invoiceQuerySet = new Set<string>();

                    // Cancel all open WOLI with Invoice Id that are Asset Verification
                    for ( Invoice__c invoiceToCancel : invoiceProcessLst ) {
                        invoiceToCancel.Status__c = 'Closed';
                    }

                    List<Database.SaveResult> updateInvoiceResultList = Database.update( invoiceProcessLst, FALSE );
                    for( Integer i=0; i< updateInvoiceResultList.size(); i++ ){
                        Database.SaveResult updateResult = updateInvoiceResultList[i];
                        Invoice__c invoiceUpdateRec = invoiceProcessLst[i];

                        if( !updateResult.isSuccess() ) {
                            badReturnLst.add( new ProcessedInvoiceStruct( 
                                invoiceUpdateRec.Invoice_Id__c, new List<String>{ INVOICE_UPDATE_ERROR + updateResult.getErrors()[0]?.getMessage() } 
                            ) );
                        } else {
                            invoiceIdSet.remove( invoiceUpdateRec.Invoice_Id__c );
                            invoiceQuerySet.add( invoiceUpdateRec.Invoice_Id__c );
                        }
                    }

                    if ( !invoiceIdSet.isEmpty() ) { // Any lingering Ids weren't found, mark as errors, but don't stop
                        for ( string missingId : invoiceIdSet ) {
                            badReturnLst.add( new ProcessedInvoiceStruct( 
                                missingId, new List<String>{ INVOICE_NOT_FOUND } 
                            ) );
                        }
                    }

                    // Add back for later processing
                    invoiceIdSet.addAll( invoiceQuerySet );

                    if ( !invoiceQuerySet.isEmpty() ) { // Continue to update WOLI - Only if there are records still without error
                        Set<string> invoiceFoundSet = new Set<string>();

                        List<WorkOrderLineItem> woliProcessLst = [ SELECT Id, Status, External_Invoice_Id__c FROM WorkOrderLineItem 
                                                                        WHERE WorkTypeId = :ASSET_VERIFICATION_WT_ID AND External_Invoice_Id__c IN :invoiceQuerySet
                                                                        AND StatusCategory NOT IN :WOLI_STATUS_CATEGORY_CHECK_SET ];

                        for ( WorkOrderLineItem woliToProcess : woliProcessLst ) {
                            woliToProcess.Status = 'Canceled';
                            invoiceFoundSet.add( woliToProcess.External_Invoice_Id__c );
                        }

                        List<Database.SaveResult> updateWOLIResultList = Database.update( woliProcessLst, FALSE );

                        Map<string, ProcessedInvoiceStruct> badStructMap = new Map<string, ProcessedInvoiceStruct>();
                        for( Integer i=0; i< updateWOLIResultList.size(); i++ ){
                            Database.SaveResult updateResult = updateWOLIResultList[i];
                            WorkOrderLineItem woliUpdateRec = woliProcessLst[i];

                            if( !updateResult.isSuccess() ) {
                                ProcessedInvoiceStruct processedResultRec = badStructMap.get( woliUpdateRec.External_Invoice_Id__c );
                                if ( processedResultRec == null ) {
                                    badStructMap.put( woliUpdateRec.External_Invoice_Id__c, new ProcessedInvoiceStruct( 
                                        woliUpdateRec.External_Invoice_Id__c, new List<String>{ WOLI_UPDATE_ERROR + updateResult.getErrors()[0]?.getMessage() } 
                                    ) );
                                } else {
                                    processedResultRec.errorMessageLst.add( WOLI_UPDATE_ERROR + updateResult.getErrors()[0]?.getMessage() );
                                }
                            }
                        }
                        // Now, confirm the successes and finalize errors
                        for ( string requestedInvoiceId : invoiceIdSet ) {
                            ProcessedInvoiceStruct finalizedBadResultRec = badStructMap.get( requestedInvoiceId );
                            if ( finalizedBadResultRec != null ) { // If an error record exists, port over to main error return
                                badReturnLst.add( finalizedBadResultRec );
                            } else if ( invoiceFoundSet.contains( requestedInvoiceId ) ) { // If found and no errors, mark as successful
                                goodReturnLst.add( new ProcessedInvoiceStruct( requestedInvoiceId ) );
                            } else { // Technically there is a case of if no WOLIs are found for the invoice, but currently this is not cause for error - Record success?
                                goodReturnLst.add( new ProcessedInvoiceStruct( requestedInvoiceId ) );
                            }
                        }
                    }

                    if ( !goodReturnLst.isEmpty() && !badReturnLst.isEmpty() ) { message = POST_MIX_SUCCESS; } 
                    else if ( !goodReturnLst.isEmpty() ) { message = POST_SUCCESS; } 
                    else { message = POST_ERROR; }
                } else {
                    message = POST_ERROR;

                    for ( string invoiceId : invoiceIdSet ) {
                        badReturnLst.add( new ProcessedInvoiceStruct(
                            invoiceId, new List<String>{ INVOICE_NOT_FOUND }
                        ) );
                    }
                }
            }
        } catch ( exception e ) {
            system.debug( e.getStackTraceString() );
            system.debug( e.getMessage() );            

            message = POST_ERROR;
            errorRec = new ErrorInfo( e );

            for ( CancelStruct errorResult : invoiceCancelLst ) {
                badReturnLst.add( new ProcessedInvoiceStruct(
                    errorResult.invoiceId, new List<String>{ e.getMessage() }
                ) );
            }
        }

        // Set REST Return
        ACVAPIHelper.SFResponse returnResponse = new ACVAPIHelper.SFResponse( 
            orReturn,
            new InvoiceCancelResponse( goodReturnLst, badReturnLst ),
            message,
            POST_RESPONSE_CODE_MAP.get( message )
         );
         
         Map<String, String> headerMap = new Map<String, String>();
         headerMap.put( 'Content-Type', 'application/json' );
         returnResponse.generateResponse( headerMap );

         // Call Splunk
         makeLog( errorRec, orReturn, goodReturnLst, badReturnLst, message, POST_RESPONSE_CODE_MAP.get( message ) );
    }

    global class CancelStruct {
        global string invoiceId;
    }

    public class InvoiceCancelResponse {
        public List<ProcessedInvoiceStruct> successfulRecords;
        public List<ProcessedInvoiceStruct> errorRecords;

        public InvoiceCancelResponse( List<ProcessedInvoiceStruct> returnLst, List<ProcessedInvoiceStruct> badReturnlst ) {
            this.successfulRecords = returnLst;
            this.errorRecords = badReturnlst;
        }
    }

    public class ProcessedInvoiceStruct {
        public String invoiceId;
        public Boolean hasErrors;
        public List<String> errorMessageLst;

        public ProcessedInvoiceStruct( String invoiceId ) {
            this.invoiceId = invoiceId;
            this.hasErrors = FALSE;
        }

        public ProcessedInvoiceStruct( String invoiceId, List<String> errorMessageLst ) {
            this.invoiceId = invoiceId;
            this.hasErrors = TRUE;
            this.errorMessageLst = errorMessageLst;
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

    public static void makeLog( ErrorInfo e, OriginalRequest orReturn, List<ProcessedInvoiceStruct> goodReturnLst, List<ProcessedInvoiceStruct> badReturnLst, String message, Integer responseCode ) {
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
            infoLog.message = badReturnLst.isEmpty() ? 'InvoiceCancelAPI ran without issue to report' : 'InvoiceCancelAPI had some issues processing, seeing the results for specifics';
            infoLog.stackTrace = CLASS_NAME + ':' + ACVUtility.currentLineNumber();
        }
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = CLASS_NAME;
        infoLog.sfObject = 'Invoice, WorkOrderLineItem';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN> { SplunkHelper.DOMAIN.CAPITAL, SplunkHelper.DOMAIN.SCHEDULING_PLATFORM };

        List<SplunkHelper.SFErrorRecord> errorReturnLst = new List<SplunkHelper.SFErrorRecord>();
        for ( ProcessedInvoiceStruct badRec : badReturnLst ) {
            SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
            errRec.jsonStruct = badRec.invoiceId;
            errRec.errorMessage = badRec.errorMessageLst.isEmpty() ? '' : badRec.errorMessageLst[0]; // Only put an error message in if there is one to select
            errorReturnLst.add( errRec );
        }

        Set<String> idSet = new Set<String>();
        for ( ProcessedInvoiceStruct goodRec : goodReturnLst ) {
            idSet.add( goodRec.invoiceId );
        }

        HTTPResponse res = new HTTPResponse();
        res.setBody( JSON.serialize( new ACVAPIHelper.SFResponse( 
            orReturn,
            new InvoiceCancelResponse( goodReturnLst, badReturnLst ),
            message,
            responseCode
            ) ) );
        res.setStatusCode( responseCode );
        
        HTTPRequest req = new HTTPRequest();
        req.setBody( JSON.serialize( orReturn ) );
        req.setMethod( 'POST' );
        req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/InvoiceCancel' );

        SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND, errorReturnLst, idSet );
    }
}