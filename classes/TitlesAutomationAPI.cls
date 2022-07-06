//URL /services/apexrest/TitlesAutomation
@RestResource(urlMapping='/TitlesAutomation/*')
global class TitlesAutomationAPI {
    global static EasyPostComponentController.addressWrapper acctAddress;

    public static Time time6pm = Time.newInstance(18,0,0,0);
    
    public static final Datetime today6pmGMT {
        get{
            Datetime dt6pm = Datetime.newInstance(Date.today(), time6pm); // in GMT
            return dt6pm;
        }
        set;
    }

    public static final Datetime yesterday6pmGMT {
        get{
            Datetime dt6pm = Datetime.newInstance(Date.today().addDays(-1), time6pm); // in GMT
            return dt6pm;
        }
        set;
    }

    private static final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();
    
    @TestVisible private static Map<String, Floor_Plan_Setting__mdt> floorPlanMap = null;
    
    @TestVisible private static void loadFloorPlanMap()	{
        if(floorPlanMap == null)	{
            floorPlanMap = new Map<String, Floor_Plan_Setting__mdt>();
            for ( Floor_Plan_Setting__mdt fp :[ SELECT Id, Send_Title_to_Buyer__c, Payment_Method_API_Name__c, Name__c, Company__c, Street1__c, Street2__c,
                                               City__c, State__c, Zip__c, Country__c, Phone__c, Email__c, Internal_Delivery__c, Payment_Method_Group_Name__c
                                               FROM Floor_Plan_Setting__mdt ]) 
            {
                floorPlanMap.put(fp.Payment_Method_API_Name__c, fp);
			}
        }        
    }
    
    private static final List<String> sendToBuyerPaymentMethods {
        get {
            List<String> sendToBuyerPaymentMethods = new List<String>();
            for ( Floor_Plan_Setting__mdt fp : floorPlanMap.values() ) {
                if (fp.Send_Title_to_Buyer__c) {
                    sendToBuyerPaymentMethods.add(fp.Payment_Method_API_Name__c);
                }
            }
            return sendToBuyerPaymentMethods;
        }
        set;
    }
    private static User runningUser;
    private static Case auctionCase;
    private static Datetime timestamp;
    private static String s3url;
    private static String batchId ;


    @HTTPPost
    global static void validateParams( String auctionNumber, String userEmail, Datetime timestamp, String s3url, String batchId ) {
        try{
            loadFloorPlanMap();
            
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            TitlesAutomationAPI.timestamp = timestamp;
            TitlesAutomationAPI.s3url = String.isNotBlank(s3url) ? s3url : null;
            TitlesAutomationAPI.batchId = String.isNotBlank(batchId) ? batchId : null;
            // Return repsonse in JSON format
            res.addHeader( 'Content-Type', 'application/json' );

            if ( String.isBlank(userEmail) ) {
                throw new BadRequestException('A userEmail parameter is required and cannot be left blank');
            }

            //Get user Id
            List<User> userLst = [SELECT Id, Name FROM User WHERE Email = :userEmail];

            if ( userLst.isEmpty() ) {
                throw new ConflictException('The provided userEmail, ' + userEmail + ' could not be matched to a user in Salesforce');
            }
            TitlesAutomationAPI.runningUser = userLst[0];

            // Validate auctionNumber
            if ( String.isBlank(auctionNumber) ) {
                throw new BadRequestException('The auctionNumber parameter is required and cannot be left blank');
            }

            // Query for Case & Associated Account information
            List<Case> associatedCaseLst = [ SELECT Id, CaseNumber, Auction_Number__r.Id, AccountId,
                                                Account.Name, Account.Legal_Street__c, Account.Legal_City__c,
                                                Account.Legal_Country__c, Account.Legal_State__c,
                                                Account.Legal_Zip_Code__c,
                                                Account.BillingStreet, Account.BillingCity,
                                                Account.BillingCountry, Account.BillingState,
                                                Account.BillingPostalCode, Account.Dealership_Notes__c,
                                                Account.Title_Mailing_Street__c, Account.Title_Mailing_City__c,
                                                Account.Title_Mailing_State__c, Account.Title_Mailing_Zip_Code__c,
                                                Account.Title_Mailing_Country__c,
                                                Payment_Status__c, Payment_Method__c,
                                                Seller_Dealership__r.Buyer_Compliance_Required__c,
                                                Account.Out_of_Document_Compliance__c,
                                                Account.Reviewed_By_Compliance__c, Status, IsClosed
                                                FROM Case
                                                WHERE Auction_Number_Searchable__c = :auctionNumber
                                                AND RecordTypeId = :TitlesAutomationAPI.TITLE_CASE_RT
                                                AND ((IsClosed = false AND Status != 'New') OR (IsClosed = true AND Status = 'Closed Unwound'))
                                                ];

            if ( associatedCaseLst.isEmpty() ) {
                throw new ConflictException('There was an issue trying to retrieve a case with the given auction number. This could be due to ' +
                                            'the record lacking the proper recordtype, not being open in the system, or because the auction number isn\'t accurate');
            } else if( associatedCaseLst.size() > 1) {
                throw new ConflictException('When attempting to retrieve a single case with the given auction number, ' +
                                            associatedCaseLst.size() + ' cases were located instead');
            }

            TitlesAutomationAPI.auctionCase = associatedCaseLst[0];

            checkForExceptions(auctionCase);

            // Group shipping labels for Multiple Floor Plans.
        	Floor_Plan_Setting__mdt floorPlan = floorPlanMap.get(auctionCase.Payment_Method__c);
            if(floorPlan != null && floorPlan.Payment_Method_Group_Name__c != null)	{
                processInternalDelivery(floorPlan.Payment_Method_API_Name__c, floorPlan.Payment_Method_Group_Name__c, auctionNumber, userEmail);
                return;
            }
            
            // Group shipping labels for a Single Floor Plan
            if(floorPlan != null && floorPlan.Send_Title_to_Buyer__c == false)	{
                generateNConsolidateFloorPlanShippingLabels(floorPlan.Payment_Method_API_Name__c, auctionNumber, userEmail);
                return;
            }

            // Group shipping labels for a Buyer Account. If the buyer is using floor plan and Send_Title_to_Buyer__c=true 
            // then the shipping label will be grouped together with a Buyer Account.
            if(floorPlan == null || (floorPlan != null && floorPlan.Send_Title_to_Buyer__c))	{
                generateNConsolidateBuyerShippingLabels(auctionNumber, userEmail);
                return;
            }
        }
        catch( BadRequestException exc ) {
            processResponse(400, new EasyPostResponse(auctionNumber, userEmail, exc.getMessage()), null);
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), null, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        }
        catch( ConflictException exc ) {
            processResponse(409, new EasyPostResponse(auctionNumber, userEmail, exc.getMessage()), null);
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), null, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
            if (runningUser != null) {
                insertExc( 'Auction Number: ' + auctionNumber + '. ' + exc.getMessage(), null );
            }
        }
        catch( ValidationException exc ) {
            processResponse(409, new EasyPostResponse(auctionNumber, userEmail, exc.getMessage()), auctionCase.Id);
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        }
        catch( System.DmlException exc) {
            processResponse(409, new EasyPostResponse(auctionNumber, userEmail, (exc.getMessage() + ' ' + exc.getStackTraceString())), null);
            insertExc( exc.getMessage(), auctionCase );
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), null, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        }
        catch( Exception exc) {
            processResponse(500, new EasyPostResponse(auctionNumber, userEmail, (exc.getMessage() + ' ' + exc.getStackTraceString())), null);
            insertExc( exc.getMessage(), auctionCase );
            createSplunkLog(SplunkHelper.LOGLEVEL.ERROR, exc.getMessage(), exc.getStackTraceString(), null, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        }

    }

    static void generateNConsolidateShippingLabels(Internal_Delivery__c internalDelivery, String paymentMethod, String paymentMethodGroupName, String auctionNumber, String userEmail) {
        if(internalDelivery != null && internalDelivery.Shipping_Label_Created_Date__c > yesterday6pmGMT && internalDelivery.Shipping_Label_Created_Date__c < today6pmGMT)	{
            /*
             * The internal delivery shipping label already exist that was created between yesterday6pmGMT & today6pmGMT.
             * 
             * Reuse the existing shipping label that is stored in Internal_Delivery__c object.
             */
            EasyPostReturn existingEasyPostReturn = new EasyPostReturn();
            existingEasyPostReturn.trackingCode = internalDelivery.Easypost_Tracker__c;
            existingEasyPostReturn.link = internalDelivery.Easypost_Postage_Label_URL__c;
            existingEasyPostReturn.isNew = false;
            existingEasyPostReturn.generatedBy = userEmail;
            
            TitlesAutomationAPI.updateAuctionTitleCase(existingEasyPostReturn, TitlesAutomationAPI.runningUser.Id, existingEasyPostReturn.link, false);
            createSplunkLog(SplunkHelper.LOGLEVEL.INFO, 'A label for this Title Case has already been generated today.', '', auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
            processResponse(200, new EasyPostResponse(auctionNumber, userEmail, existingEasyPostReturn,'A label for this Title Case has already been generated today.'), auctionCase.Id );
        }
        else {
            /*
             * The internal delivery shipping label either does not exist or old (i.e. it was created before yesterday6pmGMT).
             * 
             * Generate a new internal delivery shipping label and store it in Internal_Delivery__c object.
             */
            if(paymentMethod != null)	{
                Floor_Plan_Setting__mdt floorPlan = floorPlanMap.get(paymentMethod);
                
                TitlesAutomationAPI.acctAddress = new EasyPostComponentController.addressWrapper();
                TitlesAutomationAPI.acctAddress.name = floorPlan.Name__c;
                TitlesAutomationAPI.acctAddress.company = floorPlan.Company__c;
                TitlesAutomationAPI.acctAddress.street = floorPlan.Street1__c;
                TitlesAutomationAPI.acctAddress.street2 = floorPlan.Street2__c;
                TitlesAutomationAPI.acctAddress.city = floorplan.City__c;
                TitlesAutomationAPI.acctAddress.state = floorplan.State__c;
                TitlesAutomationAPI.acctAddress.country = floorplan.Country__c;
                TitlesAutomationAPI.acctAddress.zip = floorPlan.Zip__c;
            }
            else TitlesAutomationAPI.acctAddress = null; // Get Buyer Account Address info in generateNewLabel method.
            
            generateNewLabel(auctionNumber, userEmail);
            
            if(internalDelivery == null) {
                // Payment method type does not exist in Internal Delivery obj so create a new one i.e. the record is being created the first time.
                Internal_Delivery__c internalDelv = new Internal_Delivery__c(
                    Easypost_Tracker__c = auctionCase.Easypost_Tracker__c,
                    Easypost_Postage_Label_URL__c = auctionCase.Easypost_PostageLabel_Label_URL__c,
                    Shipping_Label_Created_Date__c = DateTime.now()
                );                
				if(paymentMethod == null) internalDelv.Account__c = auctionCase.AccountId;
                if(paymentMethod != null) internalDelv.Payment_Method_API_Name__c = paymentMethod;
                if(paymentMethodGroupName != null) internalDelv.Payment_Method_Group_Name__c = paymentMethodGroupName;
                
                insert internalDelv;
            }
            else {
                // Payment method type already exist in Internal Delivery obj so update it i.e. the internal delivery shipping label is older than yesterday6pmGMT.
                internalDelivery.Easypost_Tracker__c = auctionCase.Easypost_Tracker__c;
                internalDelivery.Easypost_Postage_Label_URL__c = auctionCase.Easypost_PostageLabel_Label_URL__c;
                internalDelivery.Shipping_Label_Created_Date__c = DateTime.now();
                update internalDelivery;
            }                        
        }
    }
    
    static void generateNConsolidateBuyerShippingLabels(String auctionNumber, String userEmail) {
        Internal_Delivery__c internalDelivery = null;
        List<Internal_Delivery__c> internalDeliveryList = [SELECT Shipping_Label_Created_Date__c, Easypost_Tracker__c, Easypost_Postage_Label_URL__c FROM Internal_Delivery__c WHERE Account__c = :auctionCase.AccountId];
        
        if(internalDeliveryList != null && internalDeliveryList.size() > 0) internalDelivery = internalDeliveryList[0];                
		generateNConsolidateShippingLabels(internalDelivery, null, null, auctionNumber, userEmail);
    }
    
    static void generateNConsolidateFloorPlanShippingLabels(String paymentMethod, String auctionNumber, String userEmail) {
        Internal_Delivery__c internalDelivery = null;
        List<Internal_Delivery__c> internalDeliveryList = [SELECT Shipping_Label_Created_Date__c, Easypost_Tracker__c, Easypost_Postage_Label_URL__c FROM Internal_Delivery__c WHERE Payment_Method_API_Name__c = :paymentMethod];
        
        if(internalDeliveryList != null && internalDeliveryList.size() > 0) internalDelivery = internalDeliveryList[0];                
		generateNConsolidateShippingLabels(internalDelivery, paymentMethod, null, auctionNumber, userEmail);
    }
    
    /**
     * @description The will create a dummy shipping label to group togeather Titles to be delieved internally.
     * 
     * Currently, it is only setup for Capital domain where we will create one shipping label per day for all the 
     * different Cases & Auctions i.e. multiple Cases/Auctions will share this one shipping label for the whole day.
     * 
     * We can configure more domains for internal delivery in the Floor_Plan_Setting__mdt by setting Internal_Delivery__c=true.
     * 
     * The shared shipping label is tracked in the Internal_Delivery__c object. This object will have one record per domain/Payment_Method_Group_Name__c.
     * The Payment_Method_Group_Name__c in Floor_Plan_Setting__mdt & Internal_Delivery__c must be the same when the corresponding Floor_Plan_Setting__mdt.Internal_Delivery__c field is set to True.
     * 
     * Payment_Method_Group_Name__c is a unique name that is used to track internal delivery shipping labels.
     * 
     * In the Floor Plan Settings, we can group together mulitiple Payment_Method_API_Name__c using Payment_Method_Group_Name__c so that all the 
     * Payment Methods (i.e. all their Cases & Auctions) share the same shipping label for the whole day. Payment_Method_Group_Name__c should be same for all the
     * Payment Methods to group them together.
     * 
     * A new shipping lable is generated (when requested) each day for all the Payment_Method_Group_Name__c.
     * 
     * Requirements: https://acvauctions.atlassian.net/browse/TDO-791
     */ 
    static void processInternalDelivery(String paymentMethod, String paymentMethodGroupName, String auctionNumber, String userEmail) {
        Internal_Delivery__c internalDelivery = null;
        List<Internal_Delivery__c> internalDeliveryList = [SELECT Shipping_Label_Created_Date__c, Easypost_Tracker__c, Easypost_Postage_Label_URL__c FROM Internal_Delivery__c WHERE Payment_Method_Group_Name__c = :paymentMethodGroupName];
                
        if(internalDeliveryList != null && internalDeliveryList.size() > 0) internalDelivery = internalDeliveryList[0];                
		generateNConsolidateShippingLabels(internalDelivery, paymentMethod, paymentMethodGroupName, auctionNumber, userEmail);
    }
    
    public static Id insertExc( String exceptionsFound, Case auctionCase ) {
        return insertExc(exceptionsFound, auctionCase, TitlesAutomationAPI.runningUser, TitlesAutomationAPI.s3url, TitlesAutomationAPI.batchId, 'Outbound');
    }

    public static Id insertExc( String exceptionsFound, Case auctionCase, User runningUser, String s3url, String batchId, String scanType ) {
        return insertExc( exceptionsFound, auctionCase, runningUser, s3url, batchId, scanType, '' );
    }
    
    public static Id insertExc( String exceptionsFound, Case auctionCase, User runningUser, String s3url, String batchId, String scanType, String titleStateFullname ) {
        Exception__c titleExc = new Exception__c();
        titleExc.RecordTypeId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get( 'Titles' ).getRecordTypeId();
        titleExc.Status__c = 'Open';
        titleExc.Title_Scanned_By__c = runningUser != null ? runningUser.Id : null;
        titleExc.OwnerId = runningUser != null ? runningUser.Id : null;
        titleExc.Exceptions_Found__c = exceptionsFound.length() >= 255 ? exceptionsFound.subString( 0, 254 ) : exceptionsFound;
        titleExc.Related_Case__c = auctionCase != null ? auctionCase.id : null;
        titleExc.Related_Auction__c = auctionCase != null ? auctionCase.Auction_Number__r.Id : null;
        titleExc.Images_Location__c = s3url;
        if (scanType == 'Inbound') {
            titleExc.Batch_Id__c = batchId != null ? batchId : null;
        }
        else if (scanType == 'Outbound') {
            titleExc.Outbound_Batch_Id__c = batchId != null ? batchId : null;
        }
        titleExc.Title_State__c = titleStateFullname;
        insert titleExc;
        return titleExc.Id;
    }

    /**
     * checkForExceptions
     *  Validate if the Case has any excpetions
     * @param  Case auctionCase     Title Case of specific Auction
     */
    private static void checkForExceptions( Case auctionCase) {
        List<String> exceptionList = new List<String>();

        // if ( assignToPayments(auctionCase.Payment_Method__c) ) {
        //     exceptionList.add('Assign to Payments');
        // }

        List<Dealer_Setting__c> dealerSettingList = [SELECT Id FROM Dealer_Setting__c WHERE Titles_Payment_Exception__c = TRUE AND Account__c = :auctionCase.accountId];

        if ( dealerSettingList.isEmpty() && notPaidFor(auctionCase.Payment_Status__c, auctionCase.Payment_Method__c) ) {
            exceptionList.add('Auction Not Paid');
        }

        if ( dealerCompliance(auctionCase) ) {
            exceptionList.add('Dealer Compliance Issue');
        }

        // if ( addressInNotes(auctionCase.Account.Dealership_Notes__c, auctionCase.Payment_Method__c) ) {
        //     exceptionList.add('Address Exception');
        // }

        if ( unwindProblemStatus(auctionCase.Status) ) {
            exceptionList.add('Unwind/Problem Exception');
        }

        // https://acvauctions.atlassian.net/browse/TDO-906
        if(hasUnwindCaseType(auctionCase.Auction_Number__r.Id))	{
            exceptionList.add('Potential pending/approved unwind for this auction');
        }
        
        // Insert Exception with Related Case and Auction Id set
        if ( !exceptionList.isEmpty() ) {
            Id titleExcId = insertExc(String.valueof(exceptionList), auctionCase);
            throw new ValidationException('The following exceptions were found for Title Case ' + auctionCase.CaseNumber +
                                          ' : ' + String.valueOf(exceptionList) + '. Exception ' + titleExcId +
                                          ' has been created and assigned to ' + runningUser.Name + '.');
        }
    }

    /**
     * Check for open Unwind Case Record Type. We will create an Exception record if there is an Unwind Case Record Type associated with the Auction.
     * 
     * https://acvauctions.atlassian.net/browse/TDO-906
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
    
    /**
     * assignToPayments
     *  If the Buyer Payment method is not [AFC | ACH | Check | NextGear | ZipMark | ACH_PUSH] then return true
     * @param  String paymentMethod     payment method for auction
     * @return  Boolean
     */
    private static boolean assignToPayments( String paymentMethod ) {
        List<String> paymentMethodLst = new List<String>{'afc', 'check', 'nextgear', 'zipmark', 'ach', 'ach_push'};
        if ( String.isNotBlank(paymentMethod) && !paymentMethodLst.contains(paymentMethod) ) {
            return true;
        }
        return false;
    }

    /**
     * notPaidFor
     *  Check if the auction is not paid for
     * @param  String paymentStatus     payment status of Auction
     * @param  String paymentMethod     payment method of Auction
     * @return  Boolean
     */
    private static boolean notPaidFor(String paymentStatus, String paymentMethod ) {
        List<String> paymentStatusLst = new List<String>{ 'Paid', 'Approved', 'Deposited' };

        // ach_push payment method ignores this rule but other payment statuses must be in the paymentStatusLst
        if ( String.isNotBlank(paymentStatus) &&  paymentStatusLst.contains(paymentStatus) || (paymentMethod == 'afc' && paymentStatus == 'to_be_floored')) {
            return false;
        }
        return true;
    }

    /**
     * dealerCompliance
     *  Ensure that dealer compliance rules are being met
     * @param  Case auctionCase     Case that relates to auction
     * @return Boolean
     */
    private static boolean dealerCompliance( Case auctionCase ) {
        Boolean sellerestRequiresCompliance = auctionCase.Seller_Dealership__r.Buyer_Compliance_Required__c;
        Boolean buyerOutOfCompliance = auctionCase.Account.Out_of_Document_Compliance__c;
        Boolean buyerReviewedByCompliance = auctionCase.Account.Reviewed_By_Compliance__c;
        if ( sellerestRequiresCompliance && (buyerOutOfCompliance || buyerReviewedByCompliance == false) ) {
            return true;
        }
        return false;
    }

    // /**
    //  * addressInNotes
    //  *  Check if the Buyer Dealership notes contain the keywords [ title | mail | paperwork ]
    //  * @param   String dealerNotes      Buyer Dealership Notes
    //  * @param   String paymentMethod    Payment method for auction
    //  * @return  Boolean
    //  */
    // private static boolean addressInNotes( String dealerNotes, String paymentMethod ) {
    //     // Convert dealerNotes to lowerCase if they are not blank or null
    //     if( String.isNotBlank(dealerNotes) ) {
    //         dealerNotes = dealerNotes.toLowerCase();
    //     } else {
    //         return false;
    //     }

    //     // Create regex pattern and matcher for searching for keywords
    //     Pattern regexPattern = Pattern.compile('(\\btitle+?)(s\\b|\\b)|(\\bmail\\b)|(\\bpaperwork\\b)');
    //     Matcher regexMatcher = regexPattern.Matcher(dealerNotes);

    //     // Payment types that can ignore notes check
    //     List<String> paymentMethodLst = new List<String>{ 'nextgear', 'afc' };
    //     if ( String.isNotBlank(paymentMethod) && !paymentMethodLst.contains(paymentMethod) && regexMatcher.find() ) {
    //         return true;
    //     }
    //     return false;
    // }

    /**
     * unwindProblemStatus Check if the Case status is in an Unwind state
     * @param  String caseStatus    Status of Case
     * @return Boolean
     */
    private static boolean unwindProblemStatus( String caseStatus ) {
        List<String> unwindProblemStatuses = new List<String>{ 'Problem', 'Closed Unwound', 'Title at ACV Unwound', 'Returned to Seller Unwound' };
        if ( String.isNotBlank(caseStatus) && unwindProblemStatuses.contains(caseStatus) ){
            return true;
        }
        return false;
    }

    /**
     * checkForExistingLabel
     * Search for Cases that have been sent today, based on payment method and whether the title is sent to the buyer
     * @param String paymentMethod  Payment method used for Case
     * @param Boolean sendToBuyer   Whether the Buyer will receive the Title or not
     */
    public static List<Case> checkForExistingLabel( String paymentMethod, Boolean sendToBuyer ) {
        if (sendToBuyer) {
            return [SELECT Id, AccountId, ClosedDate, Title_Scanner__c, Title_Scanner__r.Name,
                        Title_Scanner__r.Email, EasyPost_Tracker__c, EasyPost_PostageLabel_Label_URL__c
                    FROM Case
                    WHERE RecordTypeId = :TITLE_CASE_RT
                    AND Status = 'Sent'
                    AND ClosedDate > :yesterday6pmGMT
                    AND ClosedDate < :today6pmGMT
                    AND AccountId = :auctionCase.AccountId
                    AND (Payment_Method__c IN ('ach','check','ach_push') OR Payment_Method__c IN :sendToBuyerPaymentMethods)
                    AND EasyPost_Tracker__c != null
                    AND Title_Scanner__c = :TitlesAutomationAPI.runningUser.Id
                    ORDER BY ClosedDate ASC
                    LIMIT 1];
        }
        return [SELECT Id, AccountId, ClosedDate, Title_Scanner__c, Title_Scanner__r.Name,
                       Title_Scanner__r.Email, EasyPost_Tracker__c, EasyPost_PostageLabel_Label_URL__c
                FROM Case
                WHERE RecordTypeId = :TITLE_CASE_RT
                AND Status = 'Sent'
                AND ClosedDate > :yesterday6pmGMT
                AND ClosedDate < :today6pmGMT
                AND Payment_Method__c = :paymentMethod
                AND EasyPost_Tracker__c != null
                AND Title_Scanner__c = :TitlesAutomationAPI.runningUser.Id
                ORDER BY ClosedDate ASC 
                LIMIT 1];
    }

    private static void processFloorPlan(String auctionNumber, String userEmail, Case auctionCase) {
        Floor_Plan_Setting__mdt floorPlan = floorPlanMap.get(auctionCase.Payment_Method__c);
        List<Case> existingLabelCase = checkForExistingLabel(floorPlan.Payment_Method_API_Name__c, floorPlan.Send_Title_to_Buyer__c);
        if ( !existingLabelCase.isEmpty()) {
            returnExistingLabel(auctionNumber, userEmail, existingLabelCase[0]);
            return;
        }

        if (floorPlan.Send_Title_to_Buyer__c) {
            generateNewLabel(auctionNumber, userEmail);
        } else {
            TitlesAutomationAPI.acctAddress = new EasyPostComponentController.addressWrapper();
            TitlesAutomationAPI.acctAddress.name = floorPlan.Name__c;
            TitlesAutomationAPI.acctAddress.company = floorPlan.Company__c;
            TitlesAutomationAPI.acctAddress.street = floorPlan.Street1__c;
            TitlesAutomationAPI.acctAddress.street2 = floorPlan.Street2__c;
            TitlesAutomationAPI.acctAddress.city = floorplan.City__c;
            TitlesAutomationAPI.acctAddress.state = floorplan.State__c;
            TitlesAutomationAPI.acctAddress.country = floorplan.Country__c;
            TitlesAutomationAPI.acctAddress.zip = floorPlan.Zip__c;
            generateNewLabel(auctionNumber, userEmail);
        }
    }

    private static void returnExistingLabel( String auctionNumber, String userEmail, Case existingLabelCase ) {
        // Build Easypost Respone with existing info
        EasyPostReturn existingEasyPostReturn = new EasyPostReturn();
        existingEasyPostReturn.trackingCode = existingLabelCase.EasyPost_Tracker__c;
        existingEasyPostReturn.link = existingLabelCase.EasyPost_PostageLabel_Label_URL__c;
        existingEasyPostReturn.isNew = false;
        existingEasyPostReturn.generatedBy = existingLabelCase.Title_Scanner__r.Email;

        TitlesAutomationAPI.updateAuctionTitleCase(existingEasyPostReturn, existingLabelCase.Title_Scanner__c, existingEasyPostReturn.link, false);
        createSplunkLog(SplunkHelper.LOGLEVEL.INFO, 'A label for this Title Case has already been generated today by ' + existingLabelCase.Title_Scanner__r.Email, '', auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
        processResponse(200, new EasyPostResponse(auctionNumber, userEmail, existingEasyPostReturn ,
                                                 'A label for this Title Case has already been generated today by ' +
                                                 existingLabelCase.Title_Scanner__r.Email), auctionCase.Id );
    }

    public static EasyPostComponentController.addressWrapper getTitleMailingAddress(Account acc) {
        EasyPostComponentController.addressWrapper titleMailingAddress = new EasyPostComponentController.addressWrapper();
        titleMailingAddress.name = acc.Name;
        if ( !String.isBlank(acc.Title_Mailing_Street__c ) ) {
            titleMailingAddress.street =acc.Title_Mailing_Street__c;
            titleMailingAddress.city =acc.Title_Mailing_City__c;
            titleMailingAddress.state =acc.Title_Mailing_State__c;
            titleMailingAddress.zip =acc.Title_Mailing_Zip_Code__c;
            titleMailingAddress.country =acc.Title_Mailing_Country__c;
        }
        else if ( !String.isBlank(acc.BillingStreet ) ) {
            // If available, use Billing Address on Account
            titleMailingAddress.street =acc.BillingStreet;
            titleMailingAddress.city =acc.BillingCity;
            titleMailingAddress.state =acc.BillingState;
            titleMailingAddress.country = 'US';
            titleMailingAddress.zip =acc.BillingPostalCode;
        }
        else if ( !String.isBlank(acc.Legal_Street__c ) ) {
            // If Billing is not available, use Legal Address on Account
            titleMailingAddress.street =acc.Legal_Street__c;
            titleMailingAddress.city =acc.Legal_City__c;
            titleMailingAddress.state =acc.Legal_State__c;
            titleMailingAddress.country = 'US';
            titleMailingAddress.zip =acc.Legal_Zip_Code__c;
        } else {
            throw new ConflictException('The Buyer Account does not have a valid address on the associated account');
        }
        return titleMailingAddress;

    }

    private static void generateNewLabel(String auctionNumber, String userEmail){
            Boolean acctFlag = false;
            Boolean providedAddress = false;

            if ( TitlesAutomationAPI.acctAddress == null ) {
                TitlesAutomationAPI.acctAddress = getTitleMailingAddress(auctionCase.Account);
                acctFlag = true;
            } else { // acctAddress is already set
                acctFlag = true;
                providedAddress = true;
            }

            if ( acctFlag ) {
                EasyPostComponentController EPgen = new EasyPostComponentController(true);
                String responseMsg = EPgen.generateLabel( System.JSON.serialize( acctAddress ) );
                EasyPostResponse returnResponse = new EasyPostResponse( auctionNumber, userEmail, responseMsg );

                if ( responseMsg.contains( '{"trackingCode":"' ) && responseMsg.contains( '"link":"' ) ) {
                    Map<String, Object> data = (Map<String,Object>)JSON.deserializeUntyped(responseMsg);
                    returnResponse.easyPostReturn = new EasyPostReturn();
                    returnResponse.easyPostReturn.trackingCode = String.valueOf(data.get('trackingCode'));
                    returnResponse.easyPostReturn.link = String.valueOf(data.get('label_zpl_url'));
                    returnResponse.easyPostReturn.isNew = true;
                    returnResponse.easyPostReturn.generatedBy = userEmail;
                    returnResponse.returnMessage = 'Success';

                    TitlesAutomationAPI.updateAuctionTitleCase( returnResponse.easyPostReturn, runningUser.Id, String.valueOf(data.get('link')), true );
                }
                else {
                    throw new ConflictException('No STANDARD_OVERNIGHT or PRIORITY_OVERNIGHT Available. Please generate manually.');
                }

                if ( providedAddress ) {
                    returnResponse.addAddress( TitlesAutomationAPI.acctAddress );
                    processResponse( 200, returnResponse, auctionCase.Id );
                    createSplunkLog(SplunkHelper.LOGLEVEL.INFO, 'Success', '', auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
                } else {
                    processResponse( 200, returnResponse, auctionCase.Id );
                    createSplunkLog(SplunkHelper.LOGLEVEL.INFO, 'Success', '', auctionCase.Id, SplunkHelper.INTEGRATION_DIRECTION.INBOUND);
                }
            }
    }

    /**
     * updateAuctionTitleCase
     *  Update the Title Case with the information that will be returned by the API
     * @param  EasyPostReturn epReturn   Details generated by EasyPost
     * @param  Id userId                 Id of the user who generated the EasyPost Label
     * @param  String label_url          The URL location of the PNG image of the label
     * @param  Boolean isNew             boolean for whether the label is newly generated        
     */
    private static void updateAuctionTitleCase(EasyPostReturn epReturn, Id userId, String label_url, Boolean isNew) {
        auctionCase.Status = 'Sent';
        auctionCase.Easypost_Tracker__c = epReturn.trackingCode;
        auctionCase.Easypost_PostageLabel_Label_URL__c = label_url;
        auctionCase.Title_Scanner__c = runningUser.Id;
        if (!isNew) {
            auctionCase.EP_Label_Generated_By__c = userId;
        }
        auctionCase.Title_Sent_Date__c = date.today();
        auctionCase.Title_Scanned_Time__c = timestamp;
        auctionCase.Image_Location__c = s3url;
        auctionCase.OutBound_Batch_Id__c = batchId;
        FieldHistoryProcess.overwriteUserId = runningUser.Id;
        update auctionCase;
    }

    private class BadRequestException extends Exception{}
    private class ConflictException extends Exception{}
    private class ValidationException extends Exception{}

    global static void processResponse( Integer statusCode, TitlesAutomationAPI.EasyPostResponse easyResponse, String caseId ) {
        RestResponse response = RestContext.response;
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf( JSON.serialize( easyResponse ) );

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

        public EasyPostResponse( String givenAuctionNum, String givenEmail, String msg ) {
            this.originalRequest = new OriginalRequest( givenAuctionNum, givenEmail );
            this.returnMessage = msg;
        }

        // Consctructor override if a label already exists
        public EasyPostResponse( String givenAuctionNum, String givenEmail, EasyPostReturn existingEasyPostReturn, String msg) {
            this.originalRequest = new OriginalRequest( givenAuctionNum, givenEmail);
            this.easyPostReturn = existingEasyPostReturn;
            this.returnMessage = msg;
        }

        public void addAddress( EasyPostComponentController.addressWrapper acctAddress ) {
            this.originalRequest.mailAddress = new originalAddressRequest( acctAddress.name, acctAddress.street, acctAddress.street2, acctAddress.city, acctAddress.state, acctAddress.country, acctAddress.zip );
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
        public String street1;
        public String street2;
        public String city;
        public String state;
        public String country;
        public String postalCode;

        public OriginalAddressRequest( String addName, String street1, String street2, String city, String state, String country, String postalCode ) {
            this.addressName = addName;
            this.street1 = street1;
            this.street2 = street2;
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
        public Boolean isNew;
        public String generatedBy;
    }

    public static Integration_Result__c createIntegrationResult( String caseId, String request, String response, Integer statusCode, String message ) {
        return new Integration_Result__c(
            Integration_Name__c = 'TitlesAutomationAPI',
            Integration_Type__c = 'Inbound',
            RecordId__c = caseId,
            Request_Message__c = request,
            Response_Message__c = response,
            SObject_Name__c = 'Case',
            Status_Code__c = statusCode,
            Status_Message__c = message.length() >= 255 ? message.subString( 0, 254 ) : message
        );
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
        log.componentName = 'Titles Automation API';
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
}