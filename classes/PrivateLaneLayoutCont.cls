/**
 * This is the Controller for the Private Lane Layout LWC
 * @author James Andre LaCour
 */
public without sharing class PrivateLaneLayoutCont {
    /****************Class Variables**********************/
    /**
     * The type of fees used in Private Lanes
     */
    public static final Set<String> FEES_FOR_PRIVATE_LANE_SET = new Set<String>{'Buy Fee', 'Sell Fee', 'Go Green Fee', 'VCI Launch Fee', 'Pack Fee'};
    /**
     * The Standard Fee record type for the Fee object
     */
    public static final Id STANDARD_FEE_RT_ID = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Standard_Fee').getRecordTypeId();
    /**
     * Translator for changing Sunday-Monday to their numerical values
     */
    public static final Map<String, String> DAY_CRON_VALUE_TRANSLATION_MAP = new Map<String,String>{'Sunday'=>'1','Monday'=>'2','Tuesday'=>'3','Wednesday'=>'4','Thursday'=>'5','Friday'=>'6','Saturday'=>'7'};
    /**
     * The type of Recurring frequencies that can be set
     */
    public static final Set<String> RECURRING_TYPES_SET = new Set<String>{ 'Weekly', 'Monthly', 'BiWeekly', 'Daily' };
    /**
     * Days as a string
     */
    private static final String DAYS = 'Days';
    /**
     * Minutes as a string
     */
    private static final String MINUTES = 'Minutes';
    /**
     * Hours as a string
     */
    private static final String HOURS = 'Hours';
    /*************Aura Enabled Methods********************/
    /**
     * Used in the Lookup field population for the branding field. Queries to get the S3 Records
     * @param searchTerm - Used in query to serach
     * @return JSON String of a Return Wrapper
     */
    @AuraEnabled
    public static List<LookupSearchResult> getBrandingReferences( String searchTerm ){
        // Prepare query paramters
        searchTerm += '*';
        // Execute search query - Only looking for Private Lane - Branding types of S3 References
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
        S3_Reference__c (Id, S3_URL__c, Name WHERE Type__c = :PrivateLaneApi.BRANDING_TYPE_NAME)
        LIMIT 10];
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Extract S3 References & convert them into LookupSearchResult       
        S3_Reference__c [] brandList = ((List<S3_Reference__c>) searchResults[0]);
        for (S3_Reference__c brand : brandList) {
            results.add(new LookupSearchResult(brand.Id, 'S3_Reference__c', 'standard:brand', brand.Name, brand.S3_URL__c ));
        }
      return results;
    }
    /**
     * Gets the record information on load. If new, created an empty template with defaults.
     * @param recordId - RecordId of the Private Lane - On create, this is 'New'
     * @return JSON String of a Return Wrapper
     */
    @AuraEnabled
    public static string getRecord( String recordId ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            String thisRecordId = (String)JSON.deserializeUntyped(recordId);
            // If thisRecordId = no need to query, we just intialize.
            if( thisRecordId != 'New' ){
                List<Private_Lane__c> thisPrivateLane = [ SELECT Id, Lane_Id__c, Status__c, Name, Auction_Duration__c, Frequency__c, Make_Offer_Type__c, Title_Option__c, Preview_Start_Price__c, Preview_Proxy_Bidding__c, Preview_Duration__c,
                                                            Start_Date__c, Start_Time__c, Make_Offer_Duration__c, Days_Of_The_Week__c, Payment_Options__c, Custom_Start_Price_Value__c, Custom_Start_Price_Type__c, CreatedById, CreatedBy.Id__c, Timezone__c, Sale_Format__c,
                                                        ( SELECT Id, Fee__c, Fee__r.Name, Amount__c, Override_Amount__c FROM Assigned_Fees__r ),
                                                        ( SELECT Id, S3_Reference__c, S3_File_Name__c, S3_URL__c, S3_File_Type__c FROM S3_Associations__r )
                                                    FROM Private_Lane__c 
                                                    WHERE Id = :thisRecordId LIMIT 1 ];
                if( thisPrivateLane.size() > 0 ){
                    rw.pl = thisPrivateLane[0];
                    rw.plw.setPrivateLaneWrapperFromPL( thisPrivateLane[0] );
                }else{
                    setReturnMessageAndLog(rw, SplunkHelper.LOGLEVEL.ERROR, 'Could not find your Private Lane Record', 'Please contact a Salesforce Admin to assist with your issue', 'thisPrivateLane.size was 0 or less', ACVUtility.currentLineNumber(), UserInfo.getUserId(), false, null, null);
                }
            }else{
                // Passes back the 'New' Id to the javascript controller to properly set intiailzation values
                rw.plw.recordId = 'New';
            }
        }catch( Exception ex ){
            setReturnMessageAndLog(rw, SplunkHelper.LOGLEVEL.FATAL, 'Issue Loading Get Private Lane record', 'Please contact a Salesforce Admin to assist with your issue', ex.getStackTraceString(), ACVUtility.currentLineNumber(), UserInfo.getUserId(), false, null, null );
        }
        return JSON.serialize(rw);
    }
    /**
     * Runs on save. Submits updates to the Private Lane creation/update api
     * @param plwToUpdateJson - the PrivateLaneWrapper to update/create
     * @return JSON String of a Return Wrapper
     */
    @AuraEnabled
    public static string submit( String plwToUpdateJson ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            rw.plw = (PrivateLaneWrapper)JSON.deserialize(plwToUpdateJson, PrivateLaneWrapper.class);
            rw.pl = createPrivateLaneFromPLW(rw.plw);       //Creates Private_Lane__c from page values
            Map<String,Assigned_Fee__c> assignedFeeMap = new Map<String,Assigned_Fee__c>();
            Map<String,Integer> feeNameToAmountMap = new Map<String,Integer>();
            Map<String,S3_Association__c> s3TypeTos3AssociationMap = new Map<String,S3_Association__c>();
            List<S3_Association__c> s3AssociationsToDelete = new List<S3_Association__c>();
            Map<String,String> s3TypeToUrlMap = new Map<String,String>();
            Contact runningUser = getACVIdFromUser( UserInfo.getUserEmail() );
            Boolean isNew = false;      // if new, we use the new endpoint rather than the update endpoint
            PrivateLaneAPI.PrivateLaneRequest plReq;
            if( rw.pl.Id == null ){         // If Id is null, this means new 
                // New Private Lane means we need to:
                // - Create Fees
                // - Create S3 Associations
                // - After we hit endpoint, update the record with the laneId
                isNew = true;
                // Create Fees
                List<Fee__c> feesToLink = new List<Fee__c>();    
                feesToLink = [ SELECT Id, Name FROM Fee__c WHERE Name IN :FEES_FOR_PRIVATE_LANE_SET ];
                for( Fee__c fee : feesToLink ){
                    Assigned_Fee__c thisFee = new Assigned_Fee__c( Fee__c = fee.Id, RecordTypeId = STANDARD_FEE_RT_ID );
                    setAssignedFeeAmountFromPlw( thisFee, fee.Name, rw.plw );
                    thisFee.Fee__c = fee.Id;
                    thisFee.RecordTypeId = STANDARD_FEE_RT_ID;
                    assignedFeeMap.put( fee.Name, thisFee );
                    feeNameToAmountMap.put( fee.Name, Integer.valueOf(thisFee.Override_Amount__c) );
                }
                // Create S3 Association
                // Currently Branding is our only one for a while. When we add more (like EULA), this will be moved out to something more generic
                if( rw.plw.brandingName != 'No Branding' ){
                    S3_Association__c brandAssociation = new S3_Association__c( S3_Reference__c = rw.plw.brandReference[0].getId() );
                    List<S3_Reference__c> brandS3 = [ SELECT Id, S3_URL__c FROM S3_Reference__c WHERE Id = :brandAssociation.S3_Reference__c LIMIT 1 ];
                    s3TypeTos3AssociationMap.put( PrivateLaneAPI.BRANDING_TYPE_NAME, brandAssociation );
                    s3TypeToUrlMap.put( PrivateLaneAPI.BRANDING_TYPE_NAME, String.isBlank(brandS3[0].S3_URL__c) ? '' : brandS3[0].S3_URL__c );
                }
                plReq = PrivateLaneAPI.createPrivateLaneRequestObj( rw.pl, Integer.valueOf(runningUser.Id__c), s3TypeToUrlMap, feeNameToAmountMap, createCronExpression( rw.pl ) );
            }else{
                // Updating Private Lane means we need to
                // - Update Fee amounts on the Assigned Fee
                // - Update Branding changes on the S3 Association
                for( Assigned_Fee__c af : rw.plw.assignedFeeMap.values() ){
                    setAssignedFeeAmountFromPlw( af, af.Fee__r.Name, rw.plw );
                    feeNameToAmountMap.put( af.Fee__r.Name, Integer.valueOf(af.Override_Amount__c) );
                }
                // If a new fee is created and this Lane doesn't have a record for it, will handle creating it
                if( rw.plw.assignedFeeMap.size() < FEES_FOR_PRIVATE_LANE_SET.size() ){
                    Map<String, Fee__c> feeNameToFeeMap = new Map<String,Fee__c>();
                    for( Fee__c fee : [ SELECT Id, Name FROM Fee__c WHERE Name IN :FEES_FOR_PRIVATE_LANE_SET ] ){
                        if( rw.plw.assignedFeeMap.get(fee.Name) == null ){
                            Assigned_Fee__c newAF = new Assigned_Fee__c( Fee__c = fee.Id, RecordTypeId = STANDARD_FEE_RT_ID );
                            setAssignedFeeAmountFromPlw(newAf, fee.Name, rw.plw);
                            feeNameToAmountMap.put( fee.Name, Integer.valueOf(newAF.Override_Amount__c) );
                            rw.plw.assignedFeeMap.put( fee.Name, newAf );
                        }
                    }
                }
                assignedFeeMap = rw.plw.assignedFeeMap;
                // Update S3 Association or Delete
                s3TypeTos3AssociationMap = rw.plw.s3TypeTos3AssociationMap;
                if( rw.plw.brandingName != 'No Branding' ){
                    List<S3_Reference__c> s3Reference = [ SELECT Id, S3_URL__c, Type__c FROM S3_Reference__c WHERE Id = :rw.plw.brandReference[0].getId() LIMIT 1];
                    if( s3TypeTos3AssociationMap.get(PrivateLaneAPI.BRANDING_TYPE_NAME) == null ) s3TypeTos3AssociationMap.put(PrivateLaneAPI.BRANDING_TYPE_NAME, new S3_Association__c(Private_Lane__c = rw.plw.recordId) );
                    s3TypeTos3AssociationMap.get(PrivateLaneAPI.BRANDING_TYPE_NAME).S3_Reference__c = rw.plw.brandReference[0].getId();
                    s3TypeToUrlMap.put(PrivateLaneAPI.BRANDING_TYPE_NAME, String.isBlank(s3Reference[0].S3_URL__c) ? '' : s3Reference[0].S3_URL__c );
                }else{
                    if( s3TypeTos3AssociationMap.get(PrivateLaneAPI.BRANDING_TYPE_NAME) != null ){
                        s3AssociationsToDelete.add( s3TypeTos3AssociationMap.get(PrivateLaneAPI.BRANDING_TYPE_NAME) );
                        s3TypeTos3AssociationMap.remove(PrivateLaneAPI.BRANDING_TYPE_NAME);
                    }
                }
                plReq = PrivateLaneAPI.createPrivateLaneRequestObj( rw.pl, Integer.valueOf(runningUser.Id__c), s3TypeToUrlMap, feeNameToAmountMap, createCronExpression( rw.pl ) );
            }
            HttpRequest req = String.isBlank(rw.plw.laneId) ? PrivateLaneAPI.createPrivateLaneNewRequest( plReq ) : PrivateLaneAPI.createPrivateLaneUpdateRequest( plReq, rw.plw.laneId );
            HttpResponse res = new Http().send(req);
            // Success
            if( res.getStatusCode() == 200 ){
                try{
                    if( String.isBlank(rw.plw.laneId) ){
                        // New Private Lane
                        PrivateLaneAPI.PrivateLaneResponse plRes = (PrivateLaneAPI.PrivateLaneResponse)JSON.deserialize(res.getBody(), PrivateLaneAPI.PrivateLaneResponse.class);
                        rw.pl.Lane_Id__c = plRes.lane_id;
                    }
                    // Updating Private Lane does not require anything
                    rw.pl.CreatedBy = null;
                    upsert rw.pl;
                    // Populate Private Lane Id on new related objects
                    for( Assigned_Fee__c af : assignedFeeMap.values() ){
                        if( af.Private_Lane__c != rw.pl.Id ) af.Private_Lane__c = rw.pl.Id;
                    }
                    for( S3_Association__c s3 : s3TypeTos3AssociationMap.values() ){
                        if( s3.Private_Lane__c != rw.pl.Id ) s3.Private_Lane__c = rw.pl.Id;
                    }
                    // Update Private Lane does not require anything
                    if( !assignedFeeMap.values().isEmpty() ) upsert assignedFeeMap.values();
                    if( !s3TypeTos3AssociationMap.isEmpty() ) upsert s3TypeTos3AssociationMap.values();
                    if( !s3AssociationsToDelete.isEmpty() ) delete s3AssociationsToDelete;
                    String recordId = String.isNotBlank(rw.plw.recordId) && rw.plw.recordId != 'New' ? rw.plw.recordId : UserInfo.getUserId();
                    setReturnMessageAndLog(rw, SplunkHelper.LOGLEVEL.INFO, '', '', 'Successfully Updated', ACVUtility.currentLineNumber(), recordId, true, req, res);
                }catch( Exception ex ){
                    String recordId = String.isNotBlank(rw.plw.recordId) && rw.plw.recordId != 'New' ? rw.plw.recordId : UserInfo.getUserId();
                    setReturnMessageAndLog(rw, SplunkHelper.LOGLEVEL.FATAL, ex.getMessage(), 'Updates have not happened in Salesforce but your changes are made. Please wait for the updates to happen in Salesforce', ex.getStackTraceString(), ACVUtility.currentLineNumber(), recordId, true, req, res);
                }
            }else{
                // Error from callout
                PrivateLaneAPI.PrivateLaneResponse plRes = (PrivateLaneAPI.PrivateLaneResponse)JSON.deserialize(res.getBody(), PrivateLaneAPI.PrivateLaneResponse.class);
                String message = '';
                for( PrivateLaneAPI.ErrorDetail thisError : plRes.detail ){
                    message = message + thisError.msg + '\n';
                }
                String recordId = String.isNotBlank(rw.plw.recordId) && rw.plw.recordId != 'New' ? rw.plw.recordId : UserInfo.getUserId();
                setReturnMessageAndLog(rw, SplunkHelper.LOGLEVEL.ERROR, message, 'There was a problem saving the Private Lane. Please contact a Salesforce Admin.', 'Callout returned failure', ACVUtility.currentLineNumber(), recordId, true, req, res);
            }
        }catch( Exception ex ){
            String recordId = String.isNotBlank(rw.plw.recordId) && rw.plw.recordId != 'New' ? rw.plw.recordId : UserInfo.getUserId();
            setReturnMessageAndLog(rw, SplunkHelper.LOGLEVEL.ERROR, ex.getMessage(), 'There was a problem saving the Private Lane. Please contact a Salesforce Admin.', ex.getStackTraceString(), ACVUtility.currentLineNumber(), recordId, false, null, null);
        }
        return JSON.serialize(rw);
    }
    
    /****************Helper Methods***********************/
    /**
     * Creates Private Lane from the UI values in the PrivateLaneWrapper
     * @param plw - Private LAne Wrapper
     * @return Private_Lane__c
     */
    public static Private_Lane__c createPrivateLaneFromPLW( PrivateLaneWrapper plw ){
        Private_Lane__c pl = new Private_Lane__c();
        if( plw.recordId != 'New' ){
            pl.Id = Id.valueOf(plw.recordId);
        }
        pl.Name = plw.nameOfLane;
        pl.Status__c = plw.status;
        pl.Auction_Duration__c = plw.auctionDurationType == DAYS ? plw.auctionDuration * 86400 : plw.auctionDurationType == HOURS ? plw.auctionDuration * 3600 : plw.auctionDuration * 60;
        pl.Frequency__c = plw.frequencyType == '' ? plw.frequency : plw.frequencyType;
        pl.Days_of_the_Week__c = plw.daysOfTheWeek;
        pl.Start_Date__c = String.isNotBlank(plw.startDate) ? Date.valueOf(plw.startDate) : null;
        pl.Start_Time__c = String.isNotBlank(plw.startTime) ? ACVUtility.createTimeFromString(plw.startTime) : null;
        pl.Timezone__c = plw.timezone;
        pl.Make_Offer_Duration__c = plw.makeOfferDurationType == DAYS ? plw.makeOfferDuration * 86400 : plw.makeOfferDurationType == HOURS ? plw.makeOfferDuration * 3600 : plw.makeOfferDuration * 60;
        pl.Preview_Duration__c = plw.previewDurationType == DAYS ? plw.previewDuration * 86400 : plw.previewDurationType == HOURS ? plw.previewDuration * 3600 : plw.previewDuration * 60;
        pl.Make_Offer_Type__c = plw.makeOfferType;
        pl.Lane_Id__c = plw.laneId;
        pl.Payment_Options__c = plw.paymentOption;
        pl.Custom_Start_Price_Value__c = plw.customStartPriceValue;
        pl.Custom_Start_Price_Type__c = plw.customStartPriceType;
        pl.Sale_Format__c = plw.saleFormat;
        pl.CreatedBy = new User();
        pl.CreatedBy.Id__c = plw.creatorACVId;
        pl.Title_Option__c = plw.titleOption;
        pl.Preview_Start_Price__c = plw.previewStartPrice;
        pl.Preview_Proxy_Bidding__c = plw.previewProxyBidding;
        return pl;
    }
    /**
     * Converts Sunday, Monday, Tuesday, ... To 1, 2, 3, ...
     * @param days - A list of the days selected
     * @return List<String> of numerical value
     */
    public static List<String> convertDayToCronValue( List<String> days ){
        List<String> dayCronValues = new List<String>();
        for( String day : days ){
            dayCronValues.add( DAY_CRON_VALUE_TRANSLATION_MAP.get(day) );
        }
        return dayCronValues;
    }
    /**
     * Switch statement based on the Frequency to create a Cron Expression
     * @param pl - the Private Lane to get frequency values from
     * @return running User record
     */
    public static String createCronExpression( Private_Lane__c pl ){
        String cronExpression = null;
        Timezone tz = String.isNotBlank(pl.Timezone__c) ? Timezone.getTimeZone(pl.Timezone__c) : null;
        // This is -1 because the offset gives us the amount to convert it. the negate of this is saying "we have the original time zone and we just want to add the offset to get GMT of what we set"
        Integer timezoneOffset = -1;    
        switch on pl.Frequency__c {
            when 'Perpetual' {
                cronExpression = CronGenerator.createPerpetualExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX );
            }
            when 'One-Time' {
                timezoneOffset = timezoneOffset * tz.getOffset( DateTime.newInstanceGMT(pl.Start_Date__c, pl.Start_Time__c) ) / 1000;
                cronExpression = CronGenerator.createOneTimeExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX, DateTime.newInstanceGMT(pl.Start_Date__c, pl.Start_Time__c).addSeconds(timezoneOffset) );
            }
            when 'Daily' {
                timezoneOffset = timezoneOffset * tz.getOffset( DateTime.newInstanceGMT(Date.today(), pl.Start_Time__c) ) / 1000;
                cronExpression = CronGenerator.createDailyExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX, DateTime.newInstanceGMT(Date.today(), pl.Start_Time__c).addSeconds(timezoneOffset) );
            }
            when 'Weekly' {
                timezoneOffset = timezoneOffset * tz.getOffset( DateTime.newInstanceGMT(Date.today(), pl.Start_Time__c) ) / 1000;
                cronExpression = CronGenerator.createWeeklyExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX, DateTime.newInstanceGMT(Date.today(), pl.Start_Time__c).addSeconds(timezoneOffset), convertDayToCronValue( pl.Days_Of_The_Week__c.split(';') ) );
            }
        }
        return cronExpression;
    }
    /**
     * Sets message for the return wrapper and sends a log to Splunk
     * @param plw - Private LAne Wrapper
     * @return void
     */
    public static void setReturnMessageAndLog( ReturnWrapper rw, SplunkHelper.LOGLEVEL logLevel, String message, String title, String stackTrace, Integer lineNumber, String recordId, Boolean isIntegrationLog, HttpRequest req, HttpResponse res ){
        rw.hasError = logLevel != SplunkHelper.LOGLEVEL.INFO;
        rw.message = message;
        rw.messageTitle = title;
        if( isIntegrationLog ){
            SplunkHelper.buildAndProcessIntegrationLog( createLog( loglevel, message, stackTrace, lineNumber, recordId), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
        }else{
            SplunkHelper.buildAndProcessLog( createLog( loglevel, message, stackTrace, lineNumber, recordId) );
        }
    }
    /**
     * Sets the Amount field on Assigend Fee based on the passed in Fee name
     * @param af - assigned fee to update
     * @param feeName - name of the current Fee
     * @param plw - the PrivateLaneWrapper to get amount from ui
     * @return null
     */
    public static void setAssignedFeeAmountFromPlw( Assigned_Fee__c af, String feeName, PrivateLaneWrapper plw ){
        switch on feeName {
            when 'Buy Fee'{
                af.Override_Amount__c = plw?.buyFee;
            }
            when 'Sell Fee'{
                af.Override_Amount__c = plw?.sellFee;
            }
            when 'Go Green Fee'{
                af.Override_Amount__c = plw?.goGreenFee;
            }
            when 'VCI Launch Fee'{
                af.Override_Amount__c = plw?.vciFee;
            }
            when 'Pack Fee'{
                af.Override_Amount__c = plw?.packFee;
            }
        }
    }
    /**
     * Gets the ACV Id from the Running User's Contact Record
     * @param userEmail - The Salesforce User Email
     * @return running User record
     */
    public static Contact getACVIdFromUser( String userEmail ){
        Map<String,Contact> contactEmailToContactMap = ACVUtility.getAcvUserId( new Set<String>{userEmail} );
        if( contactEmailToContactMap.size() > 0 ){
            return contactEmailToContactMap.get( userEmail );
        }else{
            return null;
        }
    }
    /**
     * Creates SplunkHelper Log
     * @param loglevel - ERROR, FATAL, INFO, DEBUG, WARN, or PERFORMANCE
     * @param message - error message
     * @param stackTrace - Full Detailed Stack Trace
     * @param lineNumber - Line Number that the error has happened on
     * @param record - record ids
     * @return SplunkHelper.log
     */
    public static SplunkHelper.Log createLog( SplunkHelper.LOGLEVEL loglevel, String message, String stackTrace, Integer lineNumber, String recordId ){
        SplunkHelper.Log log = new SplunkHelper.log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.PRIVATE_AUCTIONS};
        log.sfObject = 'Private Lane';
        log.version = 'v1';
        log.componentName = 'LWC - Private Lane Layout';
        log.location = 'PrivateLaneLayoutCont Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.sfRecordId = recordId;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
    /****************Inner Classes************************/
    /**
     * The return wrapper to the UI
     * @author James Andre LaCour
     */
    public class ReturnWrapper{
        public String message;
        public String messageTitle;
        public Boolean hasError;
        public PrivateLaneWrapper plw;
        public Private_Lane__c pl;
        public Map<String,String> paymentOptionPicklistOptionsList;
        public Map<String,String> customStartPricePicklistOptionsList;
        public Map<String,String> timezonePicklistOptionsMap;
        public Map<String,String> saleFormatPicklistOptionsList;
        public Map<String,String> makeOfferTypePicklistOptionsMap;
        public Map<String,String> toPicklistOptionsList;
        public ReturnWrapper(){
            message = '';
            messageTitle = '';
            hasError = false;
            plw = new PrivateLaneWrapper();
            pl = new Private_Lane__c();
            paymentOptionPicklistOptionsList = ACVUtility.getPicklistValues( 'Private_Lane__c', 'Payment_Options__c', true );
            customStartPricePicklistOptionsList = ACVUtility.getPicklistValues( 'Private_Lane__c', 'Custom_Start_Price_Type__c', true );
            timezonePicklistOptionsMap = ACVUtility.getPicklistValues( 'Private_Lane__c', 'Timezone__c', true );
            saleFormatPicklistOptionsList = ACVUtility.getPicklistValues( 'Private_Lane__c', 'Sale_Format__c', true );
            makeOfferTypePicklistOptionsMap = ACVUtility.getPicklistValues( 'Private_Lane__c', 'Make_Offer_Type__c', true );
            toPicklistOptionsList = ACVUtility.getPicklistValues( 'Private_Lane__c', 'Title_Option__c', true );
        }
    }
    /**
     * The PrivateLaneWrapper used to combine the data for the UI element
     * @author James Andre LaCour
     */
    public class PrivateLaneWrapper{
        public String recordId;
        public String laneId;
        public String status;
        // Lane Detail Variables
        public String nameOfLane;
        public String brandingName;
        public List<LookupSearchResult> brandReference;
        // Lane Schedule Variables
        public String frequency;
        public String frequencyType;
        public String startDate;
        public String startTime;
        public String timezone;
        public Decimal auctionDuration;
        public String auctionDurationType;
        public String daysOfTheWeek;
        // Auction Rules
        public Decimal makeOfferDuration;
        public String makeOfferDurationType;
        public String makeOfferType;
        public String paymentOption;
        public Integer customStartPriceValue;
        public String customStartPriceType;
        public String saleFormat;
        public String titleOption;
        public Boolean previewStartPrice;
        public Boolean previewProxyBidding;
        public Decimal previewDuration;
        public String previewDurationType;
        // Checkout Fees
        public Integer buyFee;
        public Integer sellFee;
        public Integer vciFee;
        public Integer packFee;
        public Integer goGreenFee;
        // Related Records Maps
        public Map<String, Assigned_Fee__c> assignedFeeMap;
        public Map<String, S3_Association__c> s3TypeTos3AssociationMap;
        // Background variabels
        private String creatorACVId;
        /**
         * Defaults object Values
         * @author James Andre LaCour
         */
        public PrivateLaneWrapper(){
            creatorACVId = null;
            recordId = '';
            laneId = '';
            status = '';
            nameOfLane = '';
            brandingName = 'No Branding';
            brandReference = new List<LookupSearchResult>();
            frequency = '';
            frequencyType = '';
            startDate = '';
            startTime = '';
            timezone = '';
            auctionDuration = 4;
            auctionDurationType = HOURS;
            daysOfTheWeek = '';
            buyFee = null;
            sellFee = null;
            goGreenFee = null;
            packFee = null;
            vciFee = null;
            makeOfferDuration = 0;
            makeOfferDurationType = HOURS;
            makeOfferType = 'SHOW_RESERVE';
            paymentOption = 'Default';
            customStartPriceType = 'Default';
            customStartPriceValue = null;
            assignedFeeMap = new Map<String, Assigned_Fee__c>();
            s3TypeTos3AssociationMap = new Map<String, S3_Association__c>();
            saleFormat = '';
            titleOption = 'Default';
            previewDuration = 0;
            previewDurationType = HOURS;
            previewStartPrice = true;
            previewProxyBidding = false;
        }
        /**
         * Sets the PrivateLaneWrapper values from a Private Lane
         * @param pl - The Private Lane we will get the values from
         * @param plw - The Private Lane Wrapper we will set the values to
         * @return void
         */
        public void setPrivateLaneWrapperFromPL( Private_Lane__c pl ){
            creatorACVId = pl?.CreatedBy?.Id__c;
            recordId = pl.Id;
            laneId = pl.Lane_Id__c;
            saleFormat = pl.Sale_Format__c;
            nameOfLane = pl.Name;
            status = pl.Status__c;
            // If value is one of the recurring values, the frequency will just say recurring and the fequency type will say the actual value
            frequency = RECURRING_TYPES_SET.contains( pl.Frequency__c ) ? 'Recurring': pl.Frequency__c;
            frequencyType = RECURRING_TYPES_SET.contains( pl.Frequency__c ) ? pl.Frequency__c : '';
            startDate = String.valueOf(pl.Start_Date__c);
            startTime = String.valueOf(pl.Start_Time__c);
            timezone = pl.Timezone__c;
            setDurationAndType( pl.Auction_Duration__c,pl.Make_Offer_Duration__c, pl.Preview_Duration__c );
            paymentOption = pl.Payment_Options__c;
            customStartPriceValue = Integer.valueOf(pl.Custom_Start_Price_Value__c);
            customStartPriceType = pl.Custom_Start_Price_Type__c;
            daysOfTheWeek = String.isBlank(pl.Days_Of_The_Week__c) ? '' : pl.Days_Of_The_Week__c;
            makeOfferType = pl.Make_Offer_Type__c;
            titleOption = pl.Title_Option__c;
            previewStartPrice = pl.Preview_Start_Price__c;
            previewProxyBidding = pl.Preview_Proxy_Bidding__c;
            // Sets the Buy Fee and Sell Fee map values
            Map<String, Assigned_Fee__c> assignFeeMap = new Map<String, Assigned_Fee__c>();
            if( !pl.Assigned_Fees__r.isEmpty() ){
                for( Assigned_Fee__c af : pl.Assigned_Fees__r ){
                    assignFeeMap.put( af.Fee__r.Name, af );
                }
                buyFee = assignFeeMap.get( 'Buy Fee' ) != null ? Integer.valueOf(assignFeeMap.get( 'Buy Fee' ).Override_Amount__c) : null;
                sellFee = assignFeeMap.get( 'Sell Fee' ) != null ? Integer.valueOf(assignFeeMap.get( 'Sell Fee' ).Override_Amount__c) : null;
                goGreenFee = assignFeeMap.get( 'Go Green Fee' ) != null ? Integer.valueOf(assignFeeMap.get( 'Go Green Fee' ).Override_Amount__c) : null;
                packFee = assignFeeMap.get( 'Pack Fee' ) != null ? Integer.valueOf(assignFeeMap.get( 'Pack Fee' ).Override_Amount__c) : null;
                vciFee = assignFeeMap.get( 'VCI Launch Fee' ) != null ? Integer.valueOf(assignFeeMap.get( 'VCI Launch Fee' ).Override_Amount__c) : null;
                assignedFeeMap = assignFeeMap;
            }
            // Sets the Logo map values
            Map<String, S3_Association__c> s3TypeTos3AssociationMap = new Map<String, S3_Association__c>();
            if( !pl.S3_Associations__r.isEmpty() ){
                for( S3_Association__c s3File : pl.S3_Associations__r ){
                    s3TypeTos3AssociationMap.put( s3File.S3_File_Type__c, s3File );
                }
                S3_Association__c brand = s3TypeTos3AssociationMap.get( PrivateLaneApi.BRANDING_TYPE_NAME );
                brandingName = brand.S3_File_Name__c;
                brandReference.add( new LookupSearchResult(brand.S3_Reference__c, 'S3_Reference__c', 'standard:brand', brand.S3_File_Name__c, brand.S3_URL__c) );
                s3TypeTos3AssociationMap = s3TypeTos3AssociationMap;
            }
        }
        /**
         * We only store the Seconds in salesforce field. This method updates the duration to a
         * visually better value and sets the type
         * @param auctionDurationValue - The seconds value for Auction Duration Value
         * @param makeOfferDurationValue - The seconds value for Make Offer Duration Value
         * @param previewDurationValue - The seconds value for Preview Duration Value
         * @return void
         */
        public void setDurationAndType( Decimal auctionDurationValue, Decimal makeOfferDurationValue, Decimal previewDurationValue){
            auctionDurationValue = auctionDurationValue != null ? auctionDurationValue : 0;
            makeOfferDurationValue = makeOfferDurationValue != null ? makeOfferDurationValue : 0;
            previewDurationValue = previewDurationValue != null ? previewDurationValue : 0;
            if( (auctionDurationValue / 86400).intValue() == (auctionDurationValue / 86400) ){
                auctionDuration = auctionDurationValue / 86400;
                auctionDurationType = DAYS;
            }else if( (auctionDurationValue / 3600).intValue() == (auctionDurationValue / 3600) ){
                auctionDuration = auctionDurationValue / 3600;
                auctionDurationType = HOURS;
            }else{
                auctionDuration = auctionDurationValue / 60;
                auctionDurationType = MINUTES;
            }
            if( (makeOfferDurationValue / 86400).intValue() == (makeOfferDurationValue / 86400) ){
                makeOfferDuration = makeOfferDurationValue / 86400;
                makeOfferDurationType = DAYS;
            }else if( (makeOfferDurationValue / 3600).intValue() == (makeOfferDurationValue / 3600) ){
                makeOfferDuration = makeOfferDurationValue / 3600;
                makeOfferDurationType = HOURS;
            }else{
                makeOfferDuration = makeOfferDurationValue / 60;
                makeOfferDurationType = MINUTES;
            }
            if( (previewDurationValue / 86400).intValue() == (previewDurationValue / 86400) ){
                previewDuration = previewDurationValue / 86400;
                previewDurationType = DAYS;
            }else if( (previewDurationValue / 3600).intValue() == (previewDurationValue / 3600) ){
                previewDuration = previewDurationValue / 3600;
                previewDurationType = HOURS;
            }else{
                previewDuration = previewDurationValue / 60;
                previewDurationType = MINUTES;
            }
        }
    }
}