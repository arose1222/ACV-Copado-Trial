@RestResource(urlMapping='/TitlesReceived/*')
global class TitlesReceivedAPI {
    
    private static Case auctionCase;
    private static User runningUser;

    @HTTPPost
    global static void validateParams(String auctionNumber, String userEmail, Datetime timeStamp, String s3url, String batchId, String titleStateFullname) {
        TitlesAutomationAPI automation = new TitlesAutomationAPI();
        try {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            s3url = String.isNotBlank(s3url) ? s3url : null;
            batchId = String.isNotBlank(batchId) ? batchId : null;

            // Set Return to be in JSON
            res.addHeader('Content-Type', 'application/json');
            final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();

            if (String.isBlank(userEmail)) {
                throw new BadRequestException('A userEmail parameter is required and cannot be left blank');
            }

            //Get user Id
            List<User> userLst = [SELECT Id, Name FROM User WHERE Email = :userEmail];

            if ( userLst.isEmpty() ) {
                runningUser = null;
                throw new ConflictException('The provided userEmail, ' + userEmail + ' could not be matched to a user in Salesforce');
            } else {
                runningUser = userLst[0];
            }

            if ( String.isBlank(auctionNumber) ) {
                throw new BadRequestException('The auctionNumber parameter is required and cannot be left blank');
            }

            // Query for the Associated Title Case
            List<Case> associatedCaseLst = [SELECT Id, Status, Auction_Number__r.Id
                                            FROM Case
                                            WHERE Auction_Number_Searchable__c = :auctionNumber
                                            AND RecordTypeId = :TITLE_CASE_RT];

            if ( associatedCaseLst.isEmpty() ) {
                throw new ConflictException('There was an issue trying to retrieve a case with the given auction number. This could be due to ' +
                                            'the record lacking the proper recordtype, not being open in the system, or because the auction number isn\'t accurate');
            } else if( associatedCaseLst.size() > 1 ) {
                throw new ConflictException('When attempting to retrieve a single case with the given auction number, ' +
                                            associatedCaseLst.size() + ' cases were located instead');
            } else if( associatedCaseLst.size() == 1 && associatedCaseLst[0].Status != 'New' && associatedCaseLst[0].Status != 'Closed Unwound') {
                auctionCase = associatedCaseLst[0];
                throw new ConflictException('The case status is "' + associatedCaseLst[0].Status +'" instead of "New" or "Closed Unwound"');
            }

            auctionCase = associatedCaseLst[0];
            
            checkForExceptions(auctionCase, s3url, batchId);

            auctionCase.Title_Scanner__c = runningUser.Id;
            if(associatedCaseLst[0].Status == 'New') auctionCase.Status = 'Received';
            auctionCase.Image_Location__c = s3url;
            auctionCase.Title_Scanned_Time__c = timeStamp;
            auctionCase.Title_Received_Date__c = Date.today();
            auctionCase.Batch_Id__c = batchId;
            FieldHistoryProcess.overwriteUserId = runningUser.Id;
            auctionCase.Title_State__c = titleStateFullname;
            update auctionCase;

            processResponse(200, new APIResponse(auctionNumber, userEmail, 'Success', s3url), auctionCase.Id);
        } catch( BadRequestException exc ) {
            processResponse(400, new APIResponse(auctionNumber, userEmail, exc.getMessage(), s3url), null);
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        } catch( ConflictException exc ) {
            processResponse(409, new APIResponse(auctionNumber, userEmail, exc.getMessage() ,s3url), null);
            if (auctionCase != null) {
                TitlesAutomationAPI.insertExc( 'Auction Number: ' + auctionNumber + '. ' + exc.getMessage() , auctionCase, runningUser, s3url, batchId, 'Inbound', titleStateFullname );
            }
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        } catch( ValidationException exc ) {
            processResponse(500, new APIResponse(auctionNumber, userEmail, exc.getMessage() ,s3url), auctionCase.Id);
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        }catch( Exception exc) {
            processResponse(500, new APIResponse(auctionNumber, userEmail, (exc.getMessage() + ' ' + exc.getStackTraceString()), s3url), null);
            TitlesAutomationAPI.insertExc( exc.getMessage(), auctionCase, runningUser, s3url, batchId, 'Inbound', titleStateFullname );
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        }
    }

    /**
     * checkForExceptions
     *  Validate if the Case has any excpetions
     * @param  Case auctionCase     Title Case of specific Auction
     */
    private static void checkForExceptions(Case auctionCase, String s3url, String batchId) {
        List<String> exceptionList = new List<String>();

        // https://acvauctions.atlassian.net/browse/TDO-907
        if(hasUnwindCaseType(auctionCase.Auction_Number__r.Id))	{
            exceptionList.add('Potential pending/approved unwind for this auction');
        }
        
        // Insert Exception with Related Case and Auction Id set
        if ( !exceptionList.isEmpty() ) {
            TitlesAutomationAPI.insertExc(String.valueof(exceptionList), auctionCase, runningUser, s3url, batchId, 'Inbound', null );
        }
    }

    /**
     * Check for open Unwind Case Record Type. We will create an Exception record if there is an Unwind Case Record Type associated with the Auction.
     * 
     * https://acvauctions.atlassian.net/browse/TDO-907
     */
    private static boolean hasUnwindCaseType(String auctionNumber)	{
     	List<Case> cases = [SELECT Id, CaseNumber FROM Case
                                                WHERE Auction_Number__c = :auctionNumber
                                                AND RecordType.DeveloperName = 'Unwind'
                            					AND Unwind_Type__c IN ('Return_to_Seller', 'Scrap', 'ACV_Relaunch')
                                                AND Status IN (null, '', 'Awaiting Approval', 'Unwound', 'Inspection', 'Closed', 'Closed (Resold)', 'Parked', 'Sold')
        ];
        
        if(cases != null && cases.size() > 0) return true;
        
        return false;
    }
        
    private static void processResponse(Integer statusCode, TitlesReceivedAPI.APIResponse apiResponse, String caseId) {
        RestResponse response = RestContext.response;
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf( JSON.serialize(apiResponse));
    }

    public static void createSplunkLog(SplunkHelper.LOGLEVEL logLevel, string logMessage, string stackTrace, Id recordId, SplunkHelper.INTEGRATION_DIRECTION direction){
        SplunkHelper.Log log = new SplunkHelper.Log();

        log.setContext(SplunkHelper.CONTEXT_TYPE.INTEGRATION);
        log.version = 'v1';
        log.logLevel = logLevel;
        log.message = logMessage;
        log.stackTrace =  stackTrace;
        log.sfRecordId = recordId;
        log.sfObject = 'Case';
        log.componentName = 'TitlesReceivedAPI';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);

        HttpRequest httpReq = new HttpRequest();
        RestRequest restReq = RestContext.request;

        if(restReq.requestBody != null){
            //system.debug('Request Body: ' + restReq.requestBody);
            httpReq.setBodyAsBlob(restReq.requestBody);
        }
        if(restReq.httpMethod != null){
            httpReq.setMethod(restReq.httpMethod);
        }
        if(restReq.requestURI != null){
            httpReq.setEndpoint(restReq.requestURI);
        }


        HttpResponse httpRes = new HttpResponse();
        RestResponse restRes = RestContext.response;

        if(restRes.responseBody != null){
            httpRes.setBodyAsBlob(restRes.responseBody);
        }
        if(restRes.statusCode != null){
            httpRes.setStatusCode(restRes.statusCode);
        }

        if(!Test.isRunningTest()){
            SplunkHelper.buildAndProcessIntegrationLog(log, httpReq, httpRes, direction);
        }
    }
    
    global class APIResponse{
        public OriginalRequest originalRequest;
        public String returnMessage;

        public APIResponse(String auctionNumber, String userEmail, String message, String s3url) {
            this.originalRequest = new originalRequest(auctionNumber, userEmail, s3url);
            this.returnMessage = message;
        }
    }
    global class OriginalRequest {
        public String auctionNumber;
        public String userEmail;
        public String s3url;
        public OriginalRequest( String auctionNumber, String userEmail, String s3url ) {
            this.auctionNumber = auctionNumber;
            this.userEmail = userEmail;
            this.s3url = s3url;
        }
    }
    private class BadRequestException extends Exception{}
    private class ConflictException extends Exception{}
    private class ValidationException extends Exception{}
}