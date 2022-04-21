global class BatchUtilityClass {
    @TestVisible global static Boolean testingFlag = FALSE; // Utilize to hit edge cases in batches for testing

    global class BatchReturn {
        global Boolean hasErrors;
        global Set<String> successfulReturnSet;
        global List<String> errorReturnLst; // This & errorMessageLst are 1 to 1 in order
        global List<String> errorMessageLst;

        global BatchReturn( Boolean hasErrorsToStart ) {
            hasErrors = hasErrorsToStart;
            successfulReturnSet = new Set<String>();
            errorReturnLst = new List<String>();
            errorMessageLst = new List<String>();
        }

        global void combine( BatchReturn victim ) { // Utility method to combine as necessary
            this.hasErrors = !this.hasErrors ? victim.hasErrors : this.hasErrors;
            this.successfulReturnSet.addAll( victim.successfulReturnSet );
            this.errorReturnLst.addAll( victim.errorReturnLst );
            this.errorMessageLst.addAll( victim.errorMessageLst );
        }
    }

    global static void createBatchLog( BatchReturn processedInfo, Id batchJobId, String batchName, Integer lineNumber, String stackTrace, Set<String> objectSet ) {    
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
        infoLog.location = batchName + ':' + lineNumber;
        
        String message = 'The Batch has processed with ';
        if ( processedInfo.hasErrors ) {
            if ( processedInfo.successfulReturnSet != null && !processedInfo.successfulReturnSet.isEmpty() ) {
                message += 'mixed results';
            } else {
                message += 'errors to report';
            }
        } else {
            message += 'no issues to report';
        }

        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = batchJobId;
        infoLog.componentName = batchName;
        infoLog.sfObject = String.join( new List<String>( objectSet ), ', ' );
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES };
        
        List<SplunkHelper.SFErrorRecord> errorRecLst = new List<SplunkHelper.SFErrorRecord>();
        for ( Integer index = 0; index < processedInfo.errorReturnLst.size(); index++ ) {
            String errorStruct = processedInfo.errorReturnLst[index];
            String errorMsg; // seperated due to test code
            if ( !processedInfo.errorMessageLst.isEmpty() ) { errorMsg = processedInfo.errorMessageLst[index]; }
            errorRecLst.add( new SplunkHelper.SFErrorRecord(
                errorStruct, errorMsg
            ) );
        }        

        SplunkHelper.processBatchLog( infoLog, errorRecLst, processedInfo.successfulReturnSet );
    }
}