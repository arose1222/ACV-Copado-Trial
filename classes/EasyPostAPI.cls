@RestResource(urlMapping='/EasyPost/*')
global class EasyPostAPI {

    /*
    * generateLabel
    *   GIVEN a Case with an Account
    *   AND Account has a valid address
    *   AND Case is of the (Record)Type of Title
    *   WHEN the EasyPost Post API is called
    *   THEN A label is generated for the title case and returned as part of the API with a link
    *
    * @param auctionNumber
    */

    global static EasyPostComponentController.addressWrapper acctAddress;

    @HTTPPost
    global static void generateLabel( String auctionNumber, String userEmail ) {
        generateEasyPost( auctionNumber, userEmail );
    }

    global static void generateEasyPost( String auctionNumber, String userEmail ){
       if ( userEmail != null ) {
            List<User> userLst = [ SELECT Id FROM User WHERE Email = :userEmail ];
        
            if ( userLst != null && !userLst.isEmpty() ) {
                User runningUser = userLst[0];
                
                final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
                // Query for Case & Associated Account information
                List<Case> associatedCaseLst = [ SELECT Id, Auction_Number_Searchable__c, AccountId,
                                                    Account.Name, 
                                                    Account.Legal_Street__c, Account.Legal_City__c,
                                                    Account.Legal_Country__c, Account.Legal_State__c,
                                                    Account.Legal_Zip_Code__c,
                                                    Account.BillingStreet, Account.BillingCity,
                                                    Account.BillingCountry, Account.BillingState,
                                                    Account.BillingPostalCode
                                                    FROM Case
                                                    WHERE Auction_Number_Searchable__c = :auctionNumber 
                                                    AND RecordTypeId = :TITLE_CASE_RT
                                                    AND Case.IsClosed = FALSE ];
    
                // Check that we have found at least one Case, otherwise return an error
                if ( associatedCaseLst != null && associatedCaseLst.size() > 0 ) {
                    // Check that we've found only one Case, otherwise return an error
                    if ( associatedCaseLst.size() == 1 ) { 
                        Case auctionCase = associatedCaseLst[0];
                        Boolean acctFlag = FALSE;
                        Boolean providedAddress = FALSE;
    
                        if ( EasyPostAPI.acctAddress == null ) {
                            EasyPostAPI.acctAddress = new EasyPostComponentController.addressWrapper();
                            // Create Address Wrapper based off Account Data
                            acctAddress.name = auctionCase.Account.Name;
                            if ( !String.isBlank( auctionCase.Account.BillingStreet ) ) {
                                // If Legal is not available, use Billing Address on Account
                                EasyPostAPI.acctAddress.street = auctionCase.Account.BillingStreet;
                                EasyPostAPI.acctAddress.city = auctionCase.Account.BillingCity;
                                EasyPostAPI.acctAddress.state = auctionCase.Account.BillingState;
                                EasyPostAPI.acctAddress.country = 'US'; //auctionCase.Account.BillingCountry;
                                EasyPostAPI.acctAddress.zip = auctionCase.Account.BillingPostalCode;
                                acctFlag = TRUE;
                            } else if ( !String.isBlank( auctionCase.Account.Legal_Street__c ) ) {
                                // If Legal is available, use Legal Address on Account
                                EasyPostAPI.acctAddress.street = auctionCase.Account.Legal_Street__c;
                                EasyPostAPI.acctAddress.city = auctionCase.Account.Legal_City__c;
                                EasyPostAPI.acctAddress.state = auctionCase.Account.Legal_State__c;
                                EasyPostAPI.acctAddress.country = 'US'; //auctionCase.Account.Legal_Country__c;
                                EasyPostAPI.acctAddress.zip = auctionCase.Account.Legal_Zip_Code__c;
                                acctFlag = TRUE;
                            } else {
                                // If neither address is available, return an error
                                EasyPostAPI.processResponse( 409, new EasyPostResponse( auctionNumber, userEmail, 'The given Case does not have a valid address on the associated account' ), auctionCase.Id );
                                acctFlag = FALSE;
                            }
                        } else { // acctAddress is already set
                            acctFlag = TRUE;
                            providedAddress = TRUE;
                        }
    
                        if ( acctFlag ) {
                            String responseMsg = EasyPostComponentController.GenerateShipping( System.JSON.serialize( acctAddress ) );
                            EasyPostResponse returnResponse = new EasyPostResponse( auctionNumber, userEmail, responseMsg );
    
                            Integer statusCode = 409;
                            // Process Success return from EasyPost
    
                            if ( responseMsg.contains( '{"trackingCode":"' ) && responseMsg.contains( '"link":"' ) ) {
                                returnResponse.easyPostReturn = (easyPostReturn) System.JSON.deserialize( responseMsg, easyPostReturn.class );
                                returnResponse.returnMessage = 'Success';
                                statusCode = 200;
    
                                try { 
                                    auctionCase.Status = 'Sent';
                                    auctionCase.Easypost_Tracker__c = returnResponse.easyPostReturn.trackingCode;
                                    auctionCase.Easypost_PostageLabel_Label_URL__c = returnResponse.easyPostReturn.link;
                                    auctionCase.Title_Scanner__c = runningUser.Id;
                                    auctionCase.Title_Sent_Date__c = date.today();
                                    FieldHistoryProcess.overwriteUserId = runningUser.Id;
                                    update auctionCase;
                                } catch ( exception e ) {
                                    statusCode = 409;
                                    returnResponse.returnMessage = 'There was an issue attempting to update the Case in Salesforce: ' + e.getMessage();
                                }
                            }
    
                            if ( providedAddress ) {
                                returnResponse.addAddress( EasyPostAPI.acctAddress );
                                processResponse( statusCode, returnResponse, auctionCase.Id );    
                            } else {
                                processResponse( statusCode, returnResponse, auctionCase.Id );
                            }
                        }
                    } else {
                        processResponse( 409, new EasyPostResponse( auctionNumber, userEmail, 'When attempting to retrieve a single case with the given auction number, '
                                                    + associatedCaseLst.size() + ' cases were located instead' ), null );
                    }
                } else {
                    processResponse( 400, new EasyPostResponse( auctionNumber, userEmail, 'There was an issue trying to retrieve a case with the given auction number. This could be due to the record lacking the proper recordtype, not being open in the system, or because the auction number isn\'t accurate' ), null );
                }
            } else {
                processResponse( 400, new EasyPostResponse( auctionNumber, userEmail, 'The provided userEmail parameter could not be matched to a user in Salesforce' ), null );
            }
         } else {
            processResponse( 400, new EasyPostResponse( auctionNumber, userEmail, 'The userEmail parameter is required and cannot be left blank' ), null );
        }
    }

    global static void processResponse( Integer statusCode, EasyPostAPI.EasyPostResponse easyResponse, String caseId ) {
        RestResponse response = RestContext.response;
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf( JSON.serialize( new List<EasyPostResponse>{ easyResponse } ) );
        if ( statusCode != 200 ) {
            insert new List<Integration_Result__c>{ createIntegrationResult( 
                caseId, JSON.serialize( easyResponse.originalRequest ), JSON.serialize( easyResponse ), statusCode, easyResponse.returnMessage
            ) };
        }
    }

    // Return Response class
    global class EasyPostResponse {
        public String returnMessage;
        public EasyPostReturn easyPostReturn;
        public OriginalRequest originalRequest;

        public easyPostResponse( String givenAuctionNum, String givenEmail, String msg ) {
            this.originalRequest = new OriginalRequest( givenAuctionNum, givenEmail );
            this.returnMessage = msg;
        }
        
        public void addAddress( EasyPostComponentController.addressWrapper acctAddress ) {
            this.originalRequest.mailAddress = new originalAddressRequest( acctAddress.name, acctAddress.street, acctAddress.city, acctAddress.state, acctAddress.country, acctAddress.zip );
        }
    }

    global class OriginalRequest {
        public String auctionNumber;
        public String userEmail;
        public OriginalAddressRequest mailAddress;

        public OriginalRequest ( String givenAuctionNum, String email ) {
            this.auctionNumber = givenAuctionNum;
            this.userEmail = email;
        }
    }

    global class OriginalAddressRequest {
        public String addressName;
        public String street;
        public String city;
        public String state;
        public String country;
        public String postalCode;

        public OriginalAddressRequest( String addName, String street, String city, String state, String country, String postalCode ) {
            this.addressName = addName;
            this.street = street;
            this.city = city;
            this.state = state;
            this.country = country;
            this.postalCode = postalCode;
        }
    }

    // Utility class for easy JSON conversion from successful EasyPost API Call
    global class EasyPostReturn {
        public String trackingCode;
        public String link;
    }

    public static Integration_Result__c createIntegrationResult( String caseId, String request, String response, Integer statusCode, String message ) {
        return new Integration_Result__c(
            Integration_Name__c = 'EasyPostAPI',
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