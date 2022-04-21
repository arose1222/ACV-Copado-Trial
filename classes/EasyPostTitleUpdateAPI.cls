@RestResource(urlMapping='/EasyPostTitleUpdate/*')
global class EasyPostTitleUpdateAPI {


    // Auction ID, EasyPost URL, Tracking Number, Title Scanner Email ID
    @HTTPPost
    global static void updateTitle( String auctionNumber, String userEmail, String easyPostURL, String trackingNumber ){
        if ( userEmail != null ) {
            List<User> userLst = [ SELECT Id FROM User WHERE Email = :userEmail ];
        
            if ( userLst != null && !userLst.isEmpty() ) {
                User runningUser = userLst[0];
                
                final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
    
                List<Case> associatedCaseLst = [ SELECT Id, Auction_Number_Searchable__c, Easypost_Tracker__c, Easypost_PostageLabel_Label_URL__c
                                                FROM Case
                                                WHERE Auction_Number_Searchable__c = :auctionNumber 
                                                AND RecordTypeId = :TITLE_CASE_RT
                                                AND Case.IsClosed = FALSE ];
    
                // Check that we have found at least one Case, otherwise return an error
                if ( associatedCaseLst != null && associatedCaseLst.size() > 0 ) {
                    // Check that we've found only one Case, otherwise return an error
                    if ( associatedCaseLst.size() == 1 ) { 
                        Case auctionCase = associatedCaseLst[0];
                        TitleUpdateResponse returnResponse = new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, '');
                        Integer statusCode = 409;

                        if ( easyPostURL != null ) {
                            if ( trackingNumber != null ) {
                                returnResponse.returnMessage = 'Success';
                                statusCode = 200;

                                try {
                                    auctionCase.Status = 'Sent';
                                    auctionCase.Easypost_PostageLabel_Label_URL__c = easyPostURL;
                                    auctionCase.Easypost_Tracker__c = trackingNumber;
                                    auctionCase.Title_Scanner__c = runningUser.Id;
                                    auctionCase.Title_Sent_Date__c = date.today();
                                    FieldHistoryProcess.overwriteUserId = runningUser.Id;
                                    update auctionCase;
                                } catch ( Exception e ) {
                                    statusCode = 409;
                                    returnResponse.returnMessage = 'There was an issue attempting to update the Case in Salesforce: ' + e.getMessage();
                                }
                                processResponse(statusCode, returnResponse, auctionCase.Id);
                            } else {
                                processResponse( 400, new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, 'The trackingNumber parameter is required and cannot be left blank' ), null );
                            }
                        } else {
                                processResponse( 400, new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, 'The easyPostURL parameter is required and cannot be left blank' ), null );
                        }
                    } else {
                        processResponse( 409, new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, 'When attempting to retrieve a single case with the given auction number, '
                                                    + associatedCaseLst.size() + ' cases were located instead' ), null );
                    }
                } else {
                    processResponse( 400, new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, 'There was an issue trying to retrieve a case with the given auction number. This could be due to the record lacking the proper recordtype, not being open in the system, or because the auction number isn\'t accurate' ), null );
                }
            } else {
                processResponse( 400, new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, 'The provided userEmail parameter could not be matched to a user in Salesforce' ), null );
            }
        } else {
            processResponse( 400, new TitleUpdateResponse( auctionNumber, userEmail, easyPostURL, trackingNumber, 'The userEmail parameter is required and cannot be left blank' ), null );
        }
    }

    global static void processResponse( Integer statusCode, TitleUpdateResponse responseObj, String caseId ) {
        RestResponse response = RestContext.response;
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf( JSON.serialize( new List<TitleUpdateResponse>{ responseObj } ) );
        if ( statusCode != 200 ) {
            insert new List<Integration_Result__c>{ createIntegrationResult( 
                caseId, JSON.serialize( responseObj.originalRequest ), JSON.serialize( responseObj ), statusCode, responseObj.returnMessage
            ) };
        }
    }

    // Return Response class
    global class TitleUpdateResponse {
        public String returnMessage;
        public OriginalRequest originalRequest;

        public titleUpdateResponse( String givenAuctionNum, String givenEmail, String givenURL, String givenTrackingNumber, String msg ) {
            this.originalRequest = new OriginalRequest( givenAuctionNum, givenEmail, givenURL, givenTrackingNumber );
            this.returnMessage = msg;
        }
    }

    global class OriginalRequest {
        public String auctionNumber;
        public String userEmail;
        public String easyPostURL;
        public String trackingNumber;

        public OriginalRequest ( String givenAuctionNum, String givenEmail, String givenURL, String givenTrackingNumber ) {
            this.auctionNumber = givenAuctionNum;
            this.userEmail = givenEmail;
            this.easyPostURL = givenURL;
            this.trackingNumber = givenTrackingNumber;
        }
    }

    public static Integration_Result__c createIntegrationResult( String caseId, String request, String response, Integer statusCode, String message ) {
        return new Integration_Result__c(
            Integration_Name__c = 'EasyPostTitleUpdateAPI',
            Integration_Type__c = 'Inbound',
            RecordId__c = caseId,
            Request_Message__c = request,
            Response_Message__c = response,
            SObject_Name__c = 'Case',
            Status_Code__c = statusCode,
            Status_Message__c = message.length() >= 255 ? message.subString( 0, 254 ) : message
        );
    }
}