/**
 * This is the Controller for the Private Lane Layout LWC
 * @author James Andre LaCour
 */
@isTest
public class PrivateLaneLayoutContTest {
    /**
     * Test Email for Contact and User
     */
    public final static String USER_CONTACT_EMAIL = 'PrivateLaneTest@TestUser.acvtest';
    /**
     * Test Acv User Id for Contact and User
     */
    public final static String USER_CONTACT_ACV_ID = '992292';
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     * @return void
     */
    @TestSetup
    public static void makeData(){
        Fee__c buyFee = TestUtility.createFee();
        buyFee.Name = 'Buy Fee';
        buyFee.Type__c = 'Buyer Fee';
        Fee__c sellFee = TestUtility.createFee();
        sellFee.Name = 'Sell Fee';
        sellFee.Type__c = 'Seller Fee';
        Fee__c packFee = TestUtility.createFee();
        sellFee.Name = 'Pack Fee';
        sellFee.Type__c = 'Seller Fee';
        Fee__c vciLaunchFee = TestUtility.createFee();
        sellFee.Name = 'VCI Launch Fee';
        sellFee.Type__c = 'Seller Fee';
        Fee__c goGreenFee = TestUtility.createFee();
        sellFee.Name = 'Go Green Fee';
        sellFee.Type__c = 'Seller Fee';
        insert new List<Fee__c>{ buyFee, sellFee, goGreenFee, vciLaunchFee, packFee };
        Private_Lane__c pl = TestUtility.createPrivateLane();
        insert pl;
        Assigned_Fee__c afBuy = TestUtility.createAssignedFee( buyFee, pl );
        Assigned_Fee__c afSell = TestUtility.createAssignedFee( sellFee, pl );
        Assigned_Fee__c afGoGreen = TestUtility.createAssignedFee( goGreenFee, pl );
        Assigned_Fee__c afVciLaunch = TestUtility.createAssignedFee( vciLaunchFee, pl );
        Assigned_Fee__c afPack = TestUtility.createAssignedFee( packFee, pl );
        insert new List<Assigned_Fee__c>{ afBuy, afSell, afGoGreen, afVciLaunch, afPack };
        Group__c orgGroup = TestUtility.createGroup( 'Test Dealership Group' );
        insert orgGroup;
        Private_Lane_Access__c pla = TestUtility.createPrivateLaneAccess( pl, orgGroup );
        insert pla;
        S3_Reference__c ref = TestUtility.createS3Reference();
        ref.Type__c = PrivateLaneAPI.BRANDING_TYPE_NAME;
        ref.Name = 'Test Brand';
        insert ref;
        S3_Association__c assoc = TestUtility.createS3Association( ref );
        assoc.Private_Lane__c = pl.Id;
        insert assoc;
        Account acct = TestUtility.createAccount('Test Dealership');
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        acct.Dealership_Id__c = '4324';
        acct.Dealer_Type__c = InventoryLifeCycleHelper.DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.values()[0];
        insert acct;
        Contact con = TestUtility.createContact( acct );
        con.Email = USER_CONTACT_EMAIL;
        con.Id__c = USER_CONTACT_ACV_ID;
        insert con;
        User u = TestUtility.createUser();
        u.Email = USER_CONTACT_EMAIL;
        u.Id__c = USER_CONTACT_ACV_ID;
        insert u;
    }
    /********************Test Methods****************************/
    /**
     * Tests getBrandingREference method used for the branding lookup field
     * on the UI
     * @return void
     */
    public static testMethod void getBrandingReferencesTest(){
        List<S3_Reference__c> s3RefsList = [ SELECT Id FROM S3_Reference__c ];
        List<Id> s3IdList = new List<Id>();
        for( S3_Reference__c s3 : s3RefsList ){
            s3IdList.add(s3.Id);
        }
        Test.setFixedSearchResults( s3IdList );
        Test.startTest();
            List<LookupSearchResult> results = PrivateLaneLayoutCont.getBrandingReferences( 'Test' );
        Test.stopTest();
        System.assertEquals( 1, results.size() );
        System.assertEquals( 'Test Brand', results[0].getTitle() );
    }
    /**
     * Test the getRecord method which is used on intialization
     * @return void
     */
    public static testMethod void getRecordTest(){
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c ];
        System.assertEquals( 1, plList.size() );
        Test.startTest();
            PrivateLaneLayoutCont.ReturnWrapper rw = (PrivateLaneLayoutCont.ReturnWrapper)JSON.deserialize(PrivateLaneLayoutCont.getRecord( '"' + plList[0].Id + '"' ), PrivateLaneLayoutCont.ReturnWrapper.class );
        Test.stopTest();
        System.assertEquals(plList[0].Id, rw.pl.Id);
        System.assertEquals(plList[0].Id, rw.Plw.recordId);
    }
    /**
     * Runs test for a Successful Submit to create a new Private Lane
     * @return void
     */
    public static testMethod void submitSuccessTest(){
        List<Private_Lane__c> alreadyCreatedPlList = [ SELECT Id FROM Private_Lane__c ];
        List<User> userList = [ SELECT Id, Id__c, Email FROM User WHERE Email = :USER_CONTACT_EMAIL ];
        PrivateLaneLayoutCont.PrivateLaneWrapper plw = createWrapperHelper();
        Test.setMock( HttpCalloutMock.class, new MockCalloutSubmitSuccess() );
        Test.startTest();
            PrivateLaneLayoutCont.ReturnWrapper rw = null;
            System.runAs(userList[0]){
                rw = (PrivateLaneLayoutCont.ReturnWrapper)JSON.deserialize( PrivateLaneLayoutCont.submit(JSON.serialize(plw)),PrivateLaneLayoutCont.ReturnWrapper.class );
            }
        Test.stopTest();
        System.assertEquals( false, rw.hasError, rw.message );
        System.assertEquals( '', rw.message );
        System.assertEquals( '', rw.messageTitle );
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c WHERE Id != :alreadyCreatedPlList[0].Id ];
        System.assertEquals( 1, plList.size() );
        List<Assigned_Fee__c> afList = [ SELECT Id, Override_Amount__c FROM Assigned_Fee__c WHERE Id = :plList[0].Id ];
        for( Assigned_Fee__c af : afList ){
            System.assertEquals( 9999, af.Override_Amount__c );
        }
    }
    /**
     * Runs test for a Failed Submit to create a new Private Lane
     * due to an endpoint error
     * @return void
     */
    public static testMethod void submitFailureTest(){
        PrivateLaneLayoutCont.PrivateLaneWrapper plw = createWrapperHelper();
        List<User> userList = [ SELECT Id, Id__c, Email FROM User WHERE Email = :USER_CONTACT_EMAIL ];
        Test.setMock( HttpCalloutMock.class, new MockCalloutSubmitFailure() );
        Test.startTest();
            PrivateLaneLayoutCont.ReturnWrapper rw = null;
            System.runAs(userList[0]){
                rw = (PrivateLaneLayoutCont.ReturnWrapper)JSON.deserialize( PrivateLaneLayoutCont.submit(JSON.serialize(plw)),PrivateLaneLayoutCont.ReturnWrapper.class );
            }
        Test.stopTest();
        System.assertEquals( true, rw.hasError );
        System.assertEquals( 'Test Error\n', rw.message );
        System.assertEquals( 'There was a problem saving the Private Lane. Please contact a Salesforce Admin.', rw.messageTitle );
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c ];
        System.assertEquals( 1, plList.size() );    // A new one shouldn't be created. Should only have the one created in TestSetup
    }
    /**
     * Tests createPrivateLaneFromPLW method which takes the info
     * from the UI and creates a Private_Lane__c record
     * @return void
     */
    public static testMethod void createPrivateLaneFromPLWTest(){
        PrivateLaneLayoutCont.PrivateLaneWrapper plw = createWrapperHelper();
        Test.startTest();
            Private_Lane__c pl = PrivateLaneLayoutCont.createPrivateLaneFromPLW( plw );
        Test.stopTest();
        System.assertEquals( null, pl.Id );
        System.assertEquals( 'Test Name', pl.Name );
        System.assertEquals( 'Open', pl.Status__c );
        System.assertEquals( 86400, pl.Auction_Duration__c );
        System.assertEquals( 'Weekly', pl.Frequency__c );
        System.assertEquals( 'Monday;Tuesday', pl.Days_Of_The_Week__c );
        System.assertEquals( Date.newInstance(2020, 11, 11), pl.Start_Date__c );
        System.assertEquals( Time.newInstance(12, 0, 0, 0), pl.Start_Time__c );
        System.assertEquals( 1200, pl.Make_Offer_Duration__c );
        System.assertEquals( plw.laneId, pl.Lane_Id__c );
        System.assertEquals( 3600, pl.Preview_Duration__c );
        System.assertEquals( true, pl.Preview_Start_Price__c );
        System.assertEquals( true, pl.Preview_Proxy_Bidding__c );
    }
    /**
     * Tests the conversion of Day Text Values to Day Int Values
     * @return void
     */
    public static testMethod void convertDayToCronValueTest(){
        List<String> daysTextValueList = new List<String>{ 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' };
        Test.startTest();
            List<String> dayIntValuesList = PrivateLaneLayoutCont.convertDayToCronValue(daysTextValueList);
        Test.stopTest();
        System.assert( dayIntValuesList.contains('1') ); // Sunday
        System.assert( dayIntValuesList.contains('2') ); // Monday
        System.assert( dayIntValuesList.contains('3') ); // Tuesday
        System.assert( dayIntValuesList.contains('4') ); // Wednesday
        System.assert( dayIntValuesList.contains('5') ); // Thursday
        System.assert( dayIntValuesList.contains('6') ); // Friday
        System.assert( dayIntValuesList.contains('7') ); // Saturday
    }
    /**
     * Tests Set Return Message and Log Helper method
     * @return void
     */
    public static testMethod void createCronExpressionTest(){
        List<Private_Lane__c> plList = [ SELECT Id, Timezone__c FROM Private_Lane__c ];
        System.assertEquals( 1, plList.size() );
        Private_Lane__c pl = plList[0];
        Test.startTest();
            pl.Frequency__c = 'Perpetual';
            String expression = PrivateLaneLayoutCont.createCronExpression(pl);
            System.assertEquals( '* * * * * *', expression );
            pl.Frequency__c = 'One-Time';
            pl.Timezone__c = 'America/New_York';
            pl.Start_Date__c = Date.newInstance(2021, 11, 11);
            pl.Start_Time__c = Time.newInstance(11, 12, 13, 14);
            DateTime thisdatetime = Datetime.newInstance( pl.Start_Date__c, pl.Start_Time__c );
            expression = PrivateLaneLayoutCont.createCronExpression(pl);
            System.assertEquals( String.valueOf(thisdatetime.secondGmt()) + ' '+ String.valueOf(thisdatetime.minuteGmt()) + ' ' + String.valueOf(thisdatetime.hourGmt()) + ' 11 11 *', expression );
            pl.Frequency__c = 'Daily';
            expression = PrivateLaneLayoutCont.createCronExpression(pl);
            thisDateTime = DateTime.newInstance( Date.today(), pl.Start_Time__c );
            System.assertEquals( String.valueOf(thisdatetime.secondGmt()) + ' '+ String.valueOf(thisdatetime.minuteGmt()) + ' ' + String.valueOf(thisdatetime.hourGmt()) + ' * * *', expression );
            pl.Frequency__c = 'Weekly';
            pl.Days_Of_The_Week__c = 'Wednesday;Saturday';
            expression = PrivateLaneLayoutCont.createCronExpression(pl);
            System.assertEquals( String.valueOf(thisdatetime.secondGmt()) + ' '+ String.valueOf(thisdatetime.minuteGmt()) + ' ' + String.valueOf(thisdatetime.hourGmt()) + ' * * 4,7', expression );
        Test.stopTest();
    }
    /**
     * Tests Set Return Message and Log Helper method
     * @return void
     */
    public static testMethod void setReturnMessageAndLogTest(){
        List<Private_Lane__c> plList = [ SELECT Id FROM Private_Lane__c ];
        System.assertEquals( 1, plList.size() );
        PrivateLaneLayoutCont.ReturnWrapper rw = new PrivateLaneLayoutCont.ReturnWrapper();
        Test.setMock( HttpCalloutMock.class, new MockCalloutSplunkSuccess() );
        Test.startTest();
            PrivateLaneLayoutCont.setReturnMessageAndLog( rw, SplunkHelper.LOGLEVEL.INFO, 'Test Message', 'Test Title', 'Test Stack Trace', 123, String.valueOf(plList[0].Id), false, null, null );
        Test.stopTest();
        System.assertEquals( rw.message, 'Test Message' );
        System.assertEquals( rw.messageTitle, 'Test Title' );
        System.assertEquals( rw.hasError, false );
    }
    /**
     * Tests getting the ACV Id value from the SF User Id
     * @return void
     */
    public static testMethod void getRunningUserInfoFromId(){
        List<User> userList = [ SELECT Id, Id__c, Email FROM User WHERE Email = :USER_CONTACT_EMAIL ];
        Test.startTest();
            Contact contactToCheck = PrivateLaneLayoutCont.getACVIdFromUser( userList[0].Email );
        Test.stopTest();
        System.assertEquals( USER_CONTACT_ACV_ID, contactToCheck.Id__c);
    }
    /**
     * Tests the helper method to create a Log works properly
     * @return void
     */
    public static testMethod void createLogTest(){
        SplunkHelper.LOGLEVEL logLevel = SplunkHelper.LOGLEVEL.INFO;
        String message = 'Test Log Message';
        String stackTrace = 'Test Stack Trace';
        Integer lineNumber = 11;
        String recordId = UserInfo.getUserId();
        Test.startTest();
            SplunkHelper.Log log = PrivateLaneLayoutCont.createLog( loglevel, message, stackTrace, lineNumber, recordId );
        Test.stopTest();
        System.assertEquals( logLevel, log?.logLevel );
        System.assertEquals( message, log?.message );
        System.assertEquals( stackTrace, log?.stackTrace );
        System.assertEquals( recordId , log?.sfRecordId );
        System.assertEquals( 'Private Lane', log?.sfObject );
        System.assertEquals( 'v1', log?.version );
        System.assertEquals( 'LWC - Private Lane Layout', log?.componentName );
        System.assertEquals( 'PrivateLaneLayoutCont Line #' + String.valueOf(lineNumber), log?.location);
    }
    /**
     * Tests that timezones are correctly being sent based on Daylight Savings times and the Timezone field
     */
    public static testMethod void timezoneTest(){
        List<Private_Lane__c> plList = [ SELECT Id, Start_Time__c, Start_Date__c, Timezone__c FROM Private_Lane__c LIMIT 1 ];
        System.assertEquals( 1, plList.size() );
        Private_Lane__c pl = plList[0];
        Date stDate = Date.newInstance( Date.today().year(), 1, 1 );
        Date dtDate = Date.newInstance( Date.today().year(), 6, 1 );
        pl.Frequency__c = 'One-Time';
        pl.Start_Time__c = Time.newInstance(8, 0, 0, 0);   // 8 AM 
        String cronExpression = '';
        Test.startTest();
            // ET - Test Eastern Standard (+5)/Daylight(+4) Time based on America/New_York
            pl.Timezone__c = 'America/New_York';
            pl.Start_Date__c = stDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 5, Integer.valueOf(cronExpression.split(' ')[2]), 'Standard is +5 hours' );
            pl.Start_Date__c = dtDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 4, Integer.valueOf(cronExpression.split(' ')[2]), 'Daylight is +4 hours' );
            // CT - Test Central Standard/Daylight Time based on America/Chicago
            pl.Timezone__c = 'America/Chicago';
            pl.Start_Date__c = stDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 6, Integer.valueOf(cronExpression.split(' ')[2]), 'Standard is +6 hours' );
            pl.Start_Date__c = dtDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 5, Integer.valueOf(cronExpression.split(' ')[2]), 'Daylight is +5 hours' );
            // MT - Test Mountain Standard/Daylight Time based on America/Denver
            pl.Timezone__c = 'America/Denver';
            pl.Start_Date__c = stDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 7, Integer.valueOf(cronExpression.split(' ')[2]), 'Standard is +7 hours' );
            pl.Start_Date__c = dtDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 6, Integer.valueOf(cronExpression.split(' ')[2]), 'Daylight is +6 hours' );
            // PT - Test Pacific Standard/Daylight Time based on America/Los_Angelas
            pl.Timezone__c = 'America/Los_Angeles';
            pl.Start_Date__c = stDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 8, Integer.valueOf(cronExpression.split(' ')[2]), 'Standard is +8 hours' );
            pl.Start_Date__c = dtDate;
            cronExpression = PrivateLaneLayoutCont.createCronExpression( pl );
            System.assertEquals( pl.Start_Time__c.hour() + 7, Integer.valueOf(cronExpression.split(' ')[2]), 'Daylight is +7 hours' );
        Test.stopTest();
    }
    /********************Helper Methods**************************/
    /**
     * A Helper method to create a test PrivateLaneWrapper for test methods
     * @return PrivateLaneLAyoutCont.PrivateLaneWrapper test example
     */
    private static PrivateLaneLayoutCont.PrivateLaneWrapper createWrapperHelper(){
        PrivateLaneLayoutCont.PrivateLaneWrapper plw = new PrivateLaneLayoutCont.PrivateLaneWrapper();
        plw.recordId = 'New';
        plw.nameOfLane = 'Test Name';
        plw.status = 'Open';
        plw.auctionDurationType = 'Days';
        plw.auctionDuration = 1;
        plw.frequency = 'Recurring';
        plw.frequencyType = 'Weekly';
        plw.daysOfTheWeek = 'Monday;Tuesday';
        plw.startDate = '2020-11-11';
        plw.startTime = '12:00:00.000';
        plw.makeOfferDuration = 20;
        plw.makeOfferDurationType = 'Minutes';
        plw.buyFee = 9999;
        plw.sellFee = 9999;
        plw.timezone = 'America/New_York';
        List<S3_Reference__c> s3RefList = [ SELECT Id FROM S3_Reference__c ];
        List<LookupSearchResult> lsrList = new List<LookupSearchResult>{ new LookupSearchResult(s3RefList[0].Id, 'S3_Reference__c', '','','')};
        plw.brandReference = lsrList;
        String laneId = ACVUtility.newGuid();
        plw.laneId = laneId;
        plw.previewStartPrice = true;
        plw.previewProxyBidding = true;
        plw.previewDuration = 60;
        plw.previewDurationType = 'Minutes';
        return plw;
    }
    /********************Mock Callout Class**********************/
    /**
     * Data stucture for mock success callout for Splunk
     * @Author James Andre LaCour
     */
    private class MockCalloutSplunkSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }  
    }
    /**
     * Data stucture for mock success callout for Submit endpoint
     * @Author James Andre LaCour
     */
    private class MockCalloutSubmitSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            PrivateLaneAPI.PrivateLaneResponse plr = new PrivateLaneAPI.PrivateLaneResponse();
            plr.lane_id = ACVUtility.NewGuid();
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody( JSON.serialize(plr) );
            res.setStatus('OK');
            return res;
        }  
    }
    /**
     * Data stucture for mock failure callout for the submit endpoint
     * @Author James Andre LaCour
     */
    private class MockCalloutSubmitFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            PrivateLaneAPI.PrivateLaneResponse plr = new PrivateLaneAPI.PrivateLaneResponse();
            PrivateLaneAPI.ErrorDetail ed = new PrivateLaneAPI.ErrorDetail();
            ed.type = 'Error';
            ed.msg = 'Test Error';
            ed.loc = new List<String>{'Test Line'};
            plr.detail = new List<PrivateLaneApi.ErrorDetail>{ed};
            HttpResponse res = new HttpResponse();
            res.setStatusCode(422);
            res.setStatus('Failed');
            res.setBody( JSON.serialize(plr) );
            return res;
        }  
    }
}