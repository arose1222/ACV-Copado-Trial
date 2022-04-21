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
            } else if( associatedCaseLst.size() == 1 && associatedCaseLst[0].Status != 'New') {
                auctionCase = associatedCaseLst[0];
                throw new ConflictException('The case status is "' + associatedCaseLst[0].Status +'" instead of "New"');
            }

            auctionCase = associatedCaseLst[0];
            auctionCase.Title_Scanner__c = runningUser.Id;
            auctionCase.Status = 'Received';
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
        } catch( ConflictException exc ) {
            processResponse(409, new APIResponse(auctionNumber, userEmail, exc.getMessage() ,s3url), null);
            if (auctionCase != null) {
                TitlesAutomationAPI.insertExc( 'Auction Number: ' + auctionNumber + '. ' + exc.getMessage() , auctionCase, runningUser, s3url, batchId, 'Inbound', titleStateFullname );
            }
        } catch( ValidationException exc ) {
            processResponse(500, new APIResponse(auctionNumber, userEmail, exc.getMessage() ,s3url), auctionCase.Id);
        }catch( Exception exc) {
            processResponse(500, new APIResponse(auctionNumber, userEmail, (exc.getMessage() + ' ' + exc.getStackTraceString()), s3url), null);
            TitlesAutomationAPI.insertExc( exc.getMessage(), auctionCase, runningUser, s3url, batchId, 'Inbound', titleStateFullname );
        }
    }

    
    private static void processResponse(Integer statusCode, TitlesReceivedAPI.APIResponse apiResponse, String caseId) {
        RestResponse response = RestContext.response;
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf( JSON.serialize(apiResponse));
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