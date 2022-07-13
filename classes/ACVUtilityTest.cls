@isTest
public class ACVUtilityTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //set spesific dates in time so we can use them for steady testing instead of using system.now/today
        Date saturdayHoliday = Date.newInstance(2019, 09, 21);
        Date sundayHoliday = Date.newInstance(2019, 09, 22);
        Date tuesdayHoliday = Date.newInstance(2019, 09, 17);
        Date xMasHoliday = Date.newInstance(2019, 12, 25);
        Date NYHoliday = Date.newInstance(2021, 01, 01);
        List<Holiday> newHolidayList = new List<Holiday>();
        newHolidayList.add(new Holiday(ActivityDate = saturdayHoliday, Name = 'saturdayTest'));
        newHolidayList.add(new Holiday(ActivityDate = sundayHoliday, Name = 'sundayTest'));
        newHolidayList.add(new Holiday(ActivityDate = tuesdayHoliday, Name = 'tuesdayTest'));
        newHolidayList.add(new Holiday(ActivityDate = xMasHoliday, Name = 'Christmas'));
        newHolidayList.add(new Holiday(ActivityDate = NYHoliday, Name = 'New Years'));
        insert newHolidayList;
    }

    @isTest
    public static void testGettingLineNumber(){
        //this will fail if we add to the make data or add tests above this test
        //System.Assert(ACVUtility.currentLineNumber() == 24, 'Wrong line number returned');
    }
    
    // There was an issue that if a method ended in caps, the currentLineNumber method wouldn't work. This fixes that
    @isTest
    public static void testGettingLineNumberCAPS(){
        //this will fail if we add to the make data or add tests above this test
        //System.Assert(ACVUtility.currentLineNumber() == 31, 'Wrong line number returned');
    }

    @isTest
    public static void testSched(){
        System.Assert(ACVUtility.scheduleJob(System.now().addDays(1), 'ACVUtilityTest.testSchdClass') != null,'No id returned for job, this is bad');
    }
    
        @isTest
    public static void testSchedError(){
        TestingUtility.SingleRequestMock splunkRes = new TestingUtility.SingleRequestMock(200,'OK','{ success }',null);
		Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
		multiCall.put('callout:Splunk/services/collector/event',splunkRes);
        Test.setMock(HttpCalloutMock.class, splunkRes);
        System.AssertEquals('ERROR',ACVUtility.scheduleJob(System.now().addDays(1), 'ACVUtilityTest.testSchdClass!!!'),'ID Returned, this is no good');
    }


    @isTest
    public static void testGetEnvName(){
        String ENV_CONFIG_NAME = 'acvauctions--';
        String SF_DOMAIN = '.my.salesforce.com';
        String testCase;
        if(!ACVUtility.isProd()){
            // Get base URL
            String urlStr = URL.getSalesforceBaseUrl().toExternalForm();
            // Cut off the beginning of the URL, universeal across sandboxes
            Integer indexNum = urlStr.indexOf( ENV_CONFIG_NAME ) + ENV_CONFIG_NAME.length();
            urlStr = urlStr.subString( indexNum, urlStr.length() );
            // Cut off the end of the URL to get the specific sandbox name
            Integer indexNum2 = urlStr.indexOf( SF_DOMAIN );
            urlStr = urlStr.subString( 0, indexNum2 );
            // Return as caps, cause it's cool
            testCase = urlStr.toUpperCase();
        }
        else{
            testCase = 'PROD';
        }

        System.Assert(ACVUtility.getEnvironmentName() == testCase, 'Org Names Dont Match');
    }

    @isTest
    public static void testIsProd(){
        List<Organization> orgList = [ SELECT IsSandbox, InstanceName, Name FROM Organization WHERE Id = :UserInfo.getOrganizationId() ];
        System.Assert(ACVUtility.isProd() == !orgList[0].IsSandbox, 'Is prod broken');
    }

    @isTest
    public static void testGetFieldList(){
        System.Assert(ACVUtility.getFieldList('Account').contains('name'), 'Account Doesnt Have Name');
    }

    @isTest
    public static void testGetFieldValue(){
        Account a = TestUtility.createAccount('Bill Dealer');
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;

        List<Contact> cList = [Select Id, Account.Name, AccountId from Contact];

        System.Assert(ACVUtility.getFieldValue('Account.Name', cList[0]) == 'Bill Dealer', 'Bad Name Returned');
        System.Assert(ACVUtility.getFieldValue('AccountId', cList[0]) == a.Id, 'Bad Id Returned');

    }

    @isTest
    static void testObjectTypes(){
        System.Assert(ACVUtility.getType(null) == '','Null did not return empty string');
        System.Assert(ACVUtility.getType(TRUE) == 'Boolean', 'True did not return Boolean');
        System.Assert(ACVUtility.getType(new Account()) == 'Account','Account SObject Did not return Account');
        System.Assert(ACVUtility.getType('Bill Is Testing') == 'String', 'String did not return String');
        System.Assert(ACVUtility.getType([Select Id from Holiday limit 1].Id) == 'Id','Id did not return Id');
        System.Assert(ACVUtility.getType(Blob.valueOf('Bill String To Blob'))=='Blob','Blob did not return Blob');
        System.Assert(ACVUtility.getType(System.today())=='Date','System.Today did not reutn Date');
        System.Assert(ACVUtility.getType(System.now())=='Datetime','System.now did not return DateTime');
        System.Assert(ACVUtility.getType(System.now().time())=='Time','Time did not return Time');
        System.Assert(ACVUtility.getType(1)=='Integer', '1 did not return Integer');
        System.Assert(ACVUtility.getType(1.23)=='Decimal', '1.23 did not return Decimal');
    }

    @isTest
    static void testSobjectType(){
        Account a = new Account();

        System.assert(ACVUtility.getSObjectName(a) == 'Account', 'Bad Name Provided');
    }

    @isTest
    static void testGettingIntegrationUsers(){
        List<Integration_User_Name__mdt> intUserList = [SELECT MasterLabel FROM Integration_User_Name__mdt ];

        System.assert(ACVUtility.userNameSet.contains(intUserList[0].MasterLabel), 'User Not Found in MDT Records');
    }

    @isTest
    static void recordTypeCheck(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();

        System.Assert(ACVUtility.recordTypeCheck('Support', 'Case', caseRecordTypeId), 'ACVUtility Should Return Return True');
    }

    @isTest
    static void recordTypeCheckGettingTwoRTsFromSameObject(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Id caseRecordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();

        System.Assert(ACVUtility.recordTypeCheck('Support', 'Case', caseRecordTypeId), 'ACVUtility Should Return Return True');
        System.Assert(ACVUtility.recordTypeCheck('Arbitration_Claim', 'Case', caseRecordTypeId2), 'ACVUtility Should Return Return True');
    }

    @isTest
    static void recordTypeCheckGettingTwoRTsFromDifferentObjects(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Id caseRecordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();

        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        Id accountRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();

        System.Assert(ACVUtility.recordTypeCheck('Support', 'Case', caseRecordTypeId), 'ACVUtility Should Return Return True');
        System.Assert(ACVUtility.recordTypeCheck('Arbitration_Claim', 'Case', caseRecordTypeId2), 'ACVUtility Should Return Return True');

        System.Assert(ACVUtility.recordTypeCheck('Standard', 'Account', accountRecordTypeId), 'ACVUtility Should Return Return True');
        System.Assert(ACVUtility.recordTypeCheck('Transporters', 'Account', accountRecordTypeId2), 'ACVUtility Should Return Return True');
    }

    @isTest
    static void recordTypeCheckNegativeTest(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();

        System.Assert(!ACVUtility.recordTypeCheck('THINGTHATISNTREAL', 'SOBJECTTOTHEMAX', caseRecordTypeId), 'ACVUtility Should Return Return False');
    }
    
    @isTest
    static void runArb(){
        List<Account> accountLst = New List<Account>();
        accountLst.add(new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountLst;
        
        Account acct2 = accountLst[0];
        acct2.Name = 'Seller Dealership';
        
        List<Account> newAccountLst = New List<Account>();
        newAccountLst.add( acct2 );
        
        Test.startTest();
            ACVUtility.getChangedFields(
                new Map<Id, SObject>( accountLst ),
                new Map<Id, SObject>( newAccountLst ),
                'Account'
            );
        Test.stopTest();
        
    }

    @isTest
    static void getProfileMap(){
        Map<String, Id> profileMap = ACVUtility.profileIdMap;
    }
    
    @isTest
    private static void isGUIDv4() {
        Pattern p = Pattern.compile( '[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}' );
        // Update to validation of guid generation
        // Pattern p = Pattern.compile( '[\\w]{8}-[\\w]{4}-4[\\w]{3}-[89ab][\\w]{3}-[\\w]{12}' );
        for( Integer x = 0; x < 100; x++ ) {
            Matcher m = p.matcher( ACVUtility.NewGuid() );
            System.assert( m.matches() == true, 'Issue with UUID Generation Method matching' );
        }
    }

    @isTest
    static void standardHolidayTest(){
        DateTime saturdayHoliday = DateTime.newInstance(2019, 09, 20,0,0,0);
        DateTime sundayHoliday = DateTime.newInstance(2019, 09, 23,0,0,0);
        DateTime tuesdayHoliday = DateTime.newInstance(2019, 09, 17,0,0,0);
       
        System.Assert(ACVUtility.isStandardHolidayWithinRange(saturdayHoliday, saturdayHoliday.addDays( -7 ).date(), saturdayHoliday.addDays( 7 ).date() ), 'Saturday Holiday is not today :(');
        System.Assert(ACVUtility.isStandardHolidayWithinRange(sundayHoliday, sundayHoliday.addDays( -7 ).date(), sundayHoliday.addDays( 7 ).date() ), 'Sunday Holiday is not today :(');
        System.Assert(ACVUtility.isStandardHolidayWithinRange(tuesdayHoliday, tuesdayHoliday.addDays( -7 ).date(), tuesdayHoliday.addDays( 7 ).date() ), 'Tuesday Holiday is not today :(');
    }

    @isTest
    static void standardHolidayNegativeTest(){
        DateTime saturdayHoliday = DateTime.newInstance(2019, 09, 12,0,0,0);
        System.Assert(!ACVUtility.isStandardHolidayWithinRange(saturdayHoliday, saturdayHoliday.addDays( -7 ).date(), saturdayHoliday.addDays( 7 ).date() ), 'Holiday When It Should Not Be');
    }

    //deprecated as of Nov 2021
    // @isTest
    // static void fieldHolidayTest(){
    //     Date xMasHoliday = Date.newInstance(2019, 12, 25);
    //     Date NYHoliday = Date.newInstance(2021, 01, 01);
    //     System.Assert(ACVUtility.isFieldHolidayWithinRange(xMasHoliday, xMasHoliday.addDays( -7 ), xMasHoliday.addDays( 7 ) ), 'Christmas is not today :(');
    //     System.Assert(ACVUtility.isFieldHolidayWithinRange(NYHoliday, NYHoliday.addDays( -7 ), NYHoliday.addDays( 7 ) ), 'New Years is not today :(');
    // }

    // @isTest
    // static void fieldHolidayNegativeTest(){
    //     Date xMasHoliday = Date.newInstance(2019, 12, 20);
    //     System.Assert(!ACVUtility.isFieldHolidayWithinRange(xMasHoliday, xMasHoliday.addDays( -7 ), xMasHoliday.addDays( 7 ) ), 'Christmas is today :(');
    // }

    @isTest
    static void isWeekendTest(){
        Datetime WeekendDate = Datetime.newInstance(2019, 09, 21,0,0,0);
        System.Assert(ACVUtility.isWeekend(WeekendDate), 'Not Weekend When It Shouldnt Be');
    }

    @isTest
    static void isWeekdayTest(){
        Datetime WeekendDate = Datetime.newInstance(2019, 09, 24,0,0,0);
        System.Assert(ACVUtility.isWeekday(WeekendDate), 'Weekend When It Shouldnt Be');
    }

    @isTest
    static void getDayNameTest(){
        Datetime WeekendDate = Datetime.newInstance(2019, 09, 24,0,0,0);
        System.Assert(ACVUtility.getDayName(WeekendDate) == 'Tuesday', 'Not Tuesday When It Should Be');
    }

    @isTest
    static void getDayShortNameTest(){
        Datetime WeekendDate = Datetime.newInstance(2019, 09, 24,0,0,0);
        System.Assert(ACVUtility.getDayShortName(WeekendDate) == 'Tue', 'Not Tuesday When It Should Be');
    }

    @isTest
    static void getDate(){
        System.Assert( ACVUtility.newESTInstance( date.today() ) == date.today(), 'Incorrect Date was returned');
    }

    @isTest
    static void getDateTime(){
        System.Assert( ACVUtility.newESTInstance( dateTime.now() ) == date.today(), 'Incorrect Date was returned');
    }
    @isTest
    static void createSlackPost(){
        String webhook = 'testWebhook.com';
        String body = '{"bodyTest":"Im a testString"}';
        HttpRequest req = ACVUtility.createSlackPost(webhook, body);
        System.assertEquals(webhook, req.getEndpoint(), 'Incorrect Endpoint');
        System.assertEquals(body, req.getBody(), 'Incorrect Body');
        System.assertEquals('POST', req.getMethod(), 'Method is not POST');
        System.assertEquals('application/json', req.getHeader('Content-Type'));
    }

    @isTest
    static void formatPhonePositiveTest1(){
        String phone = '8145744389';
        System.assertEquals(4, ACVUtility.generatePhoneFormatSet(phone).size(), 'Incorrect number of Phone formats generated');
    }

    @isTest
    static void formatPhonePositiveTest2(){
        String phone = '5744389';
        System.assertEquals(1, ACVUtility.generatePhoneFormatSet(phone).size(), 'Incorrect number of Phone formats generated');
    }

    @isTest
    static void formatPhoneNegativeTest(){
        String phone = '';
        System.assertEquals(0, ACVUtility.generatePhoneFormatSet(phone).size(), 'Incorrect number of Phone formats generated');
    }
    /**
     * Tests the helper method of converting a string to a Time object
     * @return void
     */
    @isTest
    static void createTimeFromString(){
        String hour = '12';
        String minute = '45';
        String second = '22';
        String millisecond = '123';
        Test.startTest();
            Time fullTest = ACVUtility.createTimeFromString( hour + ':' + minute + ':' + second + '.' + millisecond + 'Z' );
            Time noMilliSecondTest = ACVUtility.createTimeFromString( hour + ':' + minute + ':' + second );
            Time noSecondTest = ACVUtility.createTimeFromString( hour + ':' + minute );
            String lessThan2ParameterTest = '';
            try{
                ACVUtility.createTimeFromString( hour );
            }catch( Exception ex ){
                lessThan2ParameterTest = ex.getMessage();
            }
            String blankTest = '';
            try{
                ACVUtility.createTimeFromString( '' );
            }catch( Exception ex ){
                blankTest = ex.getMessage();
            }
            String invalidParameterTest = '';
            try{
                ACVUtility.createTimeFromString( hour + ':' + '3g' );
            }catch( Exception ex ){
                invalidParameterTest = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals( Time.newInstance( Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second), Integer.valueOf(millisecond) ), fullTest );
        System.assertEquals( Time.newInstance( Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second), 000 ), noMilliSecondTest );
        System.assertEquals( Time.newInstance( Integer.valueOf(hour), Integer.valueOf(minute), 00, 000 ), noSecondTest );
        System.assertEquals( 'At least hour and minutes are required', lessThan2ParameterTest );
        System.assertEquals( 'Null or Blank is not a valid option', blankTest );
        System.assertEquals( 'All parameters should be valid integer values', invalidParameterTest );
    }
    /**
     * Test the generic function to get Picklist values dyanamically
     * by passing in a SObjectName and a CustomField API name
     */
    @isTest
    static void getActivePicklistValuesTest(){
        String sObjectName = 'Case';
        String customField = 'Language';
        Test.startTest();
            Map<String, String> picklistOptionsMap = ACVUtility.getPicklistValues( sObjectName, customField, true );
            Map<String, String> badTestCaseMap = ACVUtility.getPicklistValues( '', '', true );
        Test.stopTest();
        System.assert( picklistOptionsMap.size() > 0 );
        System.assert( picklistOptionsMap.get('en_US') != null );
        System.assert( badTestCaseMap == null );
    }
    public class testSchdClass implements Schedulable{
        //need this to test scheduling a class method
        public void execute(SchedulableContext sc) {
            system.debug('test');
        }
    }
    /**
     * Tests that the Downloadable Link function
     * returns null for incorrect Id's and a url for correct CV's passed in
     */
    @isTest
    static void getContentVersionDownloadableLinkTest(){
        ContentVersion cv = TestUtility.createContentVersion('Template Test');
        insert cv;
        Test.startTest();
            String downloadableLink = ACVUtility.getContentVersionDownloadableLink(cv.Id);
            String wrongId = ACVUtility.getContentVersionDownloadableLink(UserInfo.getUserId());
        Test.stopTest();
        System.assertEquals(null, wrongId);
        System.assert(downloadableLink.endsWithIgnoreCase(cv.Id));
    }
    
     @isTest
    static void isDstActiveInEstTest(){
        Test.startTest();
        DateTime dt = DateTime.newInstanceGMT(2020, 11, 1, 5, 59, 59);  //2020 November, 1:59:59AM EST
        System.assertEquals(false, ACVUtility.isDSTActiveInEST(dt));

        dt = DateTime.newInstanceGMT(2020, 11, 1, 6, 00, 00);  //2020 November 1, 2:00:00AM EST
        System.assertEquals(true, ACVUtility.isDSTActiveInEST(dt));

        // During Daylight Savings time on Saturday
        dt = DateTime.newInstanceGMT(2021, 3, 14, 5, 59, 59);  //2021 March 14, 1:59:59AM EST
        System.assertEquals(true, ACVUtility.isDSTActiveInEST(dt));

        dt = DateTime.newInstanceGMT(2021, 3, 14, 7, 00, 00);  //2021 March 14, 3:00:00AM EST
        System.assertEquals(false, ACVUtility.isDSTActiveInEST(dt));

        Test.stopTest();
    }
    
    /**
     * Test the ACVUtility method to Get a map of Salesforce Settings
     */
    @isTest
    static void getSalseforceSettingTest(){
        Map<String, Salesforce_Setting__mdt> sfSettingMap = new Map<String, Salesforce_Setting__mdt>();
        Test.startTest();
            sfSettingMap = ACVUtility.getSalesforceSettings( new Set<String>() );
        Test.stoptest();
        System.assertEquals( 1, sfSettingMap.size() );
    }
    /**
     * Test that passing in a set of Emails returns the Contact record
     * with the two acv id values
     */
    @isTest
    static void getAcvUserIdTest(){
        String acvId = '1234';
        String identityId = '1234-5678-90';
        String email = 'testing1234testing@acvtest.test';
        Account acct = TestUtility.createAccount();
        insert acct;
        Contact c = TestUtility.createContact(acct);
        c.Email = email;
        c.Id__c = acvId;
        c.Identity_Id__c = identityId;
        c.Active__c = true;
        c.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        insert c;
        Test.startTest();
            Map<String, Contact> emailToConMap = ACVUtility.getAcvUserId( new Set<String>{c.Email} );
        Test.stopTest();
        System.debug(emailToConMap);
        System.debug(email);
        System.debug(emailToConMap.get(email));
        System.assertEquals( 1, emailToConMap.size() );
        System.assert( emailToConMap.get(c.Email) != null, emailToConMap );
        System.assertEquals( acvId, emailToConMap.get(email).Id__c );
        System.assertEquals( identityId, emailToConMap.get(email).Identity_Id__c );
    }

    @isTest
    static void getStaticResources(){
        //make static resource data

        List<String> resourceNames = new List<String>();
        resourceNames.add('Test1');
        ACVUtility.getStaticResourceURLByName(resourceNames);
        Integer soqlCount1 = Limits.getQueries();
        resourceNames.add('Test2');
        resourceNames.add('Test3');

        Integer soqlCount2 = Limits.getQueries();
        System.assert(soqlCount1 == soqlCount2);



        //get first static resource
    }

    @isTest
    static void testBusinessDays(){
        BusinessHours busHours = [SELECT Id FROM BusinessHours WHERE Name = '48 Hour Expiration Date Hours' LIMIT 1];

        Map<DateTime, DateTime> startEndMap = new Map<DateTime, DateTime>();
        DateTime startDateWithinWeek = DateTime.newInstance(2022, 1, 17, 12, 0, 0);
        startEndMap.put(startDateWithinWeek, DateTime.newInstance(2022, 1, 19, 12, 0, 0));

        DateTime startDateWithWeekend = DateTime.newInstance(2022, 1, 14, 12, 0, 0);
        startEndMap.put(startDateWithWeekend, DateTime.newInstance(2022, 1, 18, 12, 0, 0));

        DateTime startDateWithNewYears = DateTime.newInstance(2020, 12, 30, 12, 0, 0);
        startEndMap.put(startDateWithNewYears, DateTime.newInstance(2021, 1, 4, 12, 0, 0));

        DateTime startDateWithMemorialDay = DateTime.newInstance(2022, 5, 27, 12, 0, 0);
        startEndMap.put(startDateWithMemorialDay, DateTime.newInstance(2022, 6, 1, 12, 0, 0));

        DateTime startDateWithIntependenceDay = DateTime.newInstance(2022, 7, 1, 12, 0, 0);
        startEndMap.put(startDateWithIntependenceDay, DateTime.newInstance(2022, 7, 6, 12, 0, 0));

        DateTime startDateWithLaborDay = DateTime.newInstance(2022, 9, 2, 12, 0, 0);
        startEndMap.put(startDateWithLaborDay, DateTime.newInstance(2022, 9, 7, 12, 0, 0));

        DateTime startDateWithThanksgiving = DateTime.newInstance(2022, 11, 22, 12, 0, 0);
        startEndMap.put(startDateWithThanksgiving, DateTime.newInstance(2022, 11, 25, 12, 0, 0));

        DateTime startDateWithChristmas = DateTime.newInstance(2020, 12, 24, 12, 0, 0);
        startEndMap.put(startDateWithChristmas, DateTime.newInstance(2020, 12, 29, 12, 0, 0));

        for(DateTime startDate : startEndMap.keySet()) {
            DateTime endDateTime = ACVUtility.addBusinessDays(startDate, 2, busHours);
            System.assertEquals(endDateTime, startEndMap.get(startDate));
        }
    }
}