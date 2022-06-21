@isTest
public class OffersAPITest {
    private final static String WORK_TYPE_UNIQUE_NAME = 'inspection';
    private final static String TIME_ZONE = 'America/New_York';
    private final static Set<String> DAY_OF_WEEK_SET = new Set<String>{ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' };
    private final static Integer STARTING_HOUR = 8;
    private final static Integer ENDING_HOUR = 17;
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '1';
        insert a;

        FSL__Scheduling_Policy__c newPolicy = new FSL__Scheduling_Policy__c(
            Name = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Main Scheduling Policy Name' LIMIT 1 ][0].Value__c
        );
        insert newPolicy;

        FSLTestUtility.createData( a, 1 );

        OperatingHours specialHours = new OperatingHours(
            Name = WORK_TYPE_UNIQUE_NAME + ' Special EST Hours', TimeZone = TIME_ZONE,
            Unique_Work_Hours__c = WORK_TYPE_UNIQUE_NAME + ':' + TIME_ZONE
        );
        insert specialHours;

        List<TimeSlot> timeSlotLst = new List<TimeSlot>();
        for ( String dayOfWeek : DAY_OF_WEEK_SET ) {
            timeSlotLst.add( new TimeSlot(
                DayOfWeek = dayOfWeek,
                OperatingHoursId = specialHours.Id,
                StartTime = Time.newInstance( STARTING_HOUR, 0, 0, 0 ),
                EndTime = Time.newInstance( 12, 30, 0, 0 )
            ) );
            timeSlotLst.add( new TimeSlot(
                DayOfWeek = dayOfWeek,
                OperatingHoursId = specialHours.Id,
                StartTime = Time.newInstance( 12, 30, 0, 0 ),
                EndTime = Time.newInstance( ENDING_HOUR, 0, 0, 0 )
            ) );
        }
        insert timeSlotLst;

        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        st.OperatingHoursId = specialHours.Id;
        update st;

        ServiceResource testSR = FSLTestUtility.makeResourceData();

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            OperatingHoursId = st.OperatingHoursId, 
            ServiceTerritoryId = st.Id, 
            ServiceResourceId = testSR.Id,
            EffectiveStartDate = Date.today().addDays(-1), 
            TerritoryType = 'P'
        );
        insert stm;
    }

    private static void debug( String restBody ) {
        Integer index = 0;
        system.debug( '----------------------------- Start of Current REST Body -----------------------------' );
        do {
            if ( index + 250 >= restBody.length() ) {
                system.debug( restBody.subString( index, restBody.length() ) );
            } else { 
                system.debug( restBody.subString( index, index + 250 ) );
            }
            index += 250;       
        } while ( index < restBody.length() );
        system.debug( '----------------------------- End of Current REST Body -----------------------------' );
    }

    @IsTest
    static void getOffer() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Offers';

        WorkOrderLineItem woliTestRec = [ SELECT Id, External_Record_Guid__c FROM WorkOrderLineItem LIMIT 1 ];

        Date futureDate = Date.today().addDays( 3 );
        Date furtherFutureDate = futureDate.addDays( 6 );
        req.addParameter( 'startDateTime', '' + futureDate.month() + '/' + futureDate.day() + '/' + futureDate.year() + ' 12:00 PM' );
        req.addParameter( 'endDateTime', '' + furtherFutureDate.month() + '/' + furtherFutureDate.day() + '/' + furtherFutureDate.year() + ' 12:00 PM' );
        req.addParameter( 'externalUUID', woliTestRec.External_Record_Guid__c );

        RestContext.request = req;

        Test.startTest();
            OffersAPI.getOffers();
        Test.stopTest();
        
        debug( res.responseBody.toString() );
    }

    @IsTest
    static void setOfferInJeopardy() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = 'WorkAPITest_SingleValidRequest' LIMIT 1 ];
        WorkObject workReq = ((List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class ))[0];
        workReq.workDetail.isInJeopardy = String.valueOf( TRUE );
        
        DateTime startTime = DateTime.now().addDays( 1 );
        DateTime endTime = DateTime.now().addDays( 1 ).addMinutes( 60 );

        Test.startTest();
            OfferedAppointment offerAppt = new OfferedAppointment();
            offerAppt.workRec = workReq;
            offerAppt.startTime = startTime;
            offerAppt.endTime = endTime;

            OffersAPI.saveOffer( offerAppt );
        Test.stopTest();

        debug( res.responseBody.toString() );
    }

    @IsTest
    static void setOffer() {
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        RestResponse res = new RestResponse();
        RestContext.response = res;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = 'WorkAPITest_SingleValidRequest' LIMIT 1 ];
        WorkObject workReq = ((List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class ))[0];
        workReq.workDetail.isInJeopardy = String.valueOf( FALSE );
        
        DateTime startTime = DateTime.now().addDays( 1 );
        DateTime endTime = DateTime.now().addDays( 1 ).addMinutes( 60 );

        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
        insert OffersAPI.createSavedOffer( sr.Id, startTime, endTime, 100.0, sa, startTime, startTime, endTime );

        Test.startTest();
            OfferedAppointment offerAppt = new OfferedAppointment();
            offerAppt.workRec = workReq;
            offerAppt.startTime = startTime;
            offerAppt.endTime = endTime;

            OffersAPI.saveOffer( offerAppt );
        Test.stopTest();

        debug( res.responseBody.toString() );
    }

    @IsTest
    static void setOfferWithNoGivenOffers() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = 'WorkAPITest_SingleValidRequest' LIMIT 1 ];
        WorkObject workReq = ((List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class ))[0];
        workReq.workDetail.isInJeopardy = String.valueOf( FALSE );
        
        DateTime startTime = DateTime.now().addDays( 1 );
        DateTime endTime = DateTime.now().addDays( 1 ).addMinutes( 60 );

        Test.startTest();
            OfferedAppointment offerAppt = new OfferedAppointment();
            offerAppt.workRec = workReq;
            offerAppt.startTime = startTime;
            offerAppt.endTime = endTime;

            OffersAPI.saveOffer( offerAppt );
        Test.stopTest();

        debug( res.responseBody.toString() );
    }

    @IsTest
    static void setOfferWithBadID() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = 'WorkAPITest_SingleValidRequest' LIMIT 1 ];
        WorkObject workReq = ((List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class ))[0];
        
        DateTime startTime = DateTime.now().addDays( 1 );
        DateTime endTime = DateTime.now().addDays( 1 ).addMinutes( 60 );

        Test.startTest();
            OfferedAppointment offerAppt = new OfferedAppointment();
            offerAppt.workRec = workReq;
            offerAppt.startTime = startTime;
            offerAppt.endTime = endTime;

            OffersAPI.saveOffer( offerAppt );
        Test.stopTest();

        debug( res.responseBody.toString() );
    }

    @IsTest
    static void setOfferWithMissingFields() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = 'WorkAPITest_SingleInvalidRequest' LIMIT 1 ];
        WorkObject workReq = ((List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class ))[0];

        DateTime startTime = DateTime.now().addDays( 1 );
        DateTime endTime = DateTime.now().addDays( 1 ).addMinutes( 60 );

        Test.startTest();
            OfferedAppointment offerAppt = new OfferedAppointment();
            offerAppt.workRec = workReq;
            offerAppt.startTime = startTime;
            offerAppt.endTime = endTime;

            OffersAPI.saveOffer( offerAppt );
        Test.stopTest();

        debug( res.responseBody.toString() );
    }

    @isTest
    static void createSavedOffer() {
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
        DateTime now = DateTime.now();
        DateTime afterNow = now.addMinutes(60);
        Test.startTest();
            OffersAPI.createSavedOffer( sr.Id, now, afterNow, 100.0, sa, now, now, afterNow );
        Test.stopTest();
    }

    @IsTest
    static void checkForNewOffer(){
        OfferSlotObject oso = new OfferSlotObject( 100, DateTime.now().addHours(1), DateTime.now().addHours(2) );

        Test.startTest();
            String key = OffersAPI.makeSlotMapKey( oso.startTime, oso.endTime );
            Map<String, OfferSlotObject> testMap = new Map<String, OfferSlotObject>();
            testMap.put( key, oso );

            System.assertEquals( FALSE, OffersAPI.isNewOffer( testMap, oso ), 'The offer was incorrectly identified' );

            OfferSlotObject oso2 = new OfferSlotObject( 100, DateTime.now().addHours(2), DateTime.now().addHours(3) );
            System.assertEquals( TRUE, OffersAPI.isNewOffer( testMap, oso2 ), 'The offer was incorrectly identified' );
        Test.stopTest();
    }

    @IsTest
    static void processNormalSlot(){
        ServiceAppointment sa = [ SELECT Id,
                                        WorkType.Work_Type_Unique_Id__c,
                                        ServiceTerritory.OperatingHours.TimeZone,
                                        WorkType.EstimatedDuration
                                        FROM ServiceAppointment LIMIT 1 ];

        Date tomorrow = Date.today().addDays(1);

        FSLWorkProcessUtility.setupUniqueWorkHourStructs();
        OffersAPI.SlotProcessData processSlotData = new OffersAPI.SlotProcessData();
        processSlotData.savedOfferLst = new List<Appointment_Offer__c>();
        processSlotData.slotReturnMap = new Map<String, OfferSlotObject>();
        Timezone localUserTZ = UserInfo.getTimeZone();
        Integer offSet = ( localUserTZ.getOffset( DateTime.now() ) / 1000 ); // In Seconds

        Test.startTest();
            processSlotData = OffersAPI.processSlotData(
                localUserTZ,
                100,
                [ SELECT Id FROM ServiceResource LIMIT 1 ].Id,
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( STARTING_HOUR, 0, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),  
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( 12, 30, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),
                sa,
                processSlotData
            );
        Test.stopTest();

        system.assertEquals( TRUE, !processSlotData.savedOfferLst.isEmpty(), 'An offer was provided' );
        system.assertEquals( TRUE, !processSlotData.slotReturnMap.isEmpty(), 'A slot was provided' );
    }

    @IsTest
    static void processLargeSlot(){
        ServiceAppointment sa = [ SELECT Id,
                                        WorkType.Work_Type_Unique_Id__c,
                                        ServiceTerritory.OperatingHours.TimeZone,
                                        WorkType.EstimatedDuration
                                        FROM ServiceAppointment LIMIT 1 ];

        Date tomorrow = Date.today().addDays(1);

        FSLWorkProcessUtility.setupUniqueWorkHourStructs();
        OffersAPI.SlotProcessData processSlotData = new OffersAPI.SlotProcessData();
        processSlotData.savedOfferLst = new List<Appointment_Offer__c>();
        processSlotData.slotReturnMap = new Map<String, OfferSlotObject>();
        Timezone localUserTZ = UserInfo.getTimeZone();
        Integer offSet = ( localUserTZ.getOffset( DateTime.now() ) / 1000 ); // In Seconds

        Test.startTest();
            processSlotData = OffersAPI.processSlotData(
                localUserTZ,
                100,
                [ SELECT Id FROM ServiceResource LIMIT 1 ].Id,
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( ( STARTING_HOUR - 1 ), 0, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),  
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( ( 12 + 1 ), 30, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),
                sa,
                processSlotData
            );
        Test.stopTest();

        system.assertEquals( TRUE, !processSlotData.savedOfferLst.isEmpty(), 'An offer was provided' );
        system.assertEquals( TRUE, !processSlotData.slotReturnMap.isEmpty(), 'A slot was provided' );
    }

    @IsTest
    static void processSmallSlot(){
        ServiceAppointment sa = [ SELECT Id,
                                        WorkType.Work_Type_Unique_Id__c,
                                        ServiceTerritory.OperatingHours.TimeZone,
                                        WorkType.EstimatedDuration
                                        FROM ServiceAppointment LIMIT 1 ];

        Date tomorrow = Date.today().addDays(1);

        FSLWorkProcessUtility.setupUniqueWorkHourStructs();
        OffersAPI.SlotProcessData processSlotData = new OffersAPI.SlotProcessData();
        processSlotData.savedOfferLst = new List<Appointment_Offer__c>();
        processSlotData.slotReturnMap = new Map<String, OfferSlotObject>();
        Timezone localUserTZ = UserInfo.getTimeZone();
        Integer offSet = ( localUserTZ.getOffset( DateTime.now() ) / 1000 ); // In Seconds

        Test.startTest();
            processSlotData = OffersAPI.processSlotData(
                localUserTZ,
                100,
                [ SELECT Id FROM ServiceResource LIMIT 1 ].Id,
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( ( STARTING_HOUR + 1 ), 0, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),  
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( ( 12 - 1 ), 30, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),
                sa,
                processSlotData
            );
        Test.stopTest();

        system.assertEquals( TRUE, !processSlotData.savedOfferLst.isEmpty(), 'An offer was provided' );
        system.assertEquals( TRUE, !processSlotData.slotReturnMap.isEmpty(), 'A slot was provided' );
    }

    @IsTest
    static void processOverlapStartSlot(){
        ServiceAppointment sa = [ SELECT Id,
                                        WorkType.Work_Type_Unique_Id__c,
                                        ServiceTerritory.OperatingHours.TimeZone,
                                        WorkType.EstimatedDuration
                                        FROM ServiceAppointment LIMIT 1 ];

        Date tomorrow = Date.today().addDays(1);

        FSLWorkProcessUtility.setupUniqueWorkHourStructs();
        OffersAPI.SlotProcessData processSlotData = new OffersAPI.SlotProcessData();
        processSlotData.savedOfferLst = new List<Appointment_Offer__c>();
        processSlotData.slotReturnMap = new Map<String, OfferSlotObject>();
        Timezone localUserTZ = UserInfo.getTimeZone();
        Integer offSet = ( localUserTZ.getOffset( DateTime.now() ) / 1000 ); // In Seconds

        Test.startTest();
            processSlotData = OffersAPI.processSlotData(
                localUserTZ,
                100,
                [ SELECT Id FROM ServiceResource LIMIT 1 ].Id,
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( ( STARTING_HOUR - 1 ), 0, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),  
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( 12, 30, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),
                sa,
                processSlotData
            );
        Test.stopTest();

        system.assertEquals( TRUE, !processSlotData.savedOfferLst.isEmpty(), 'An offer was provided' );
        system.assertEquals( TRUE, !processSlotData.slotReturnMap.isEmpty(), 'A slot was provided' );
    }

    @IsTest
    static void processOverlapEndSlot(){
        ServiceAppointment sa = [ SELECT Id,
                                        WorkType.Work_Type_Unique_Id__c,
                                        ServiceTerritory.OperatingHours.TimeZone,
                                        WorkType.EstimatedDuration
                                        FROM ServiceAppointment LIMIT 1 ];

        Date tomorrow = Date.today().addDays(1);

        FSLWorkProcessUtility.setupUniqueWorkHourStructs();
        OffersAPI.SlotProcessData processSlotData = new OffersAPI.SlotProcessData();
        processSlotData.savedOfferLst = new List<Appointment_Offer__c>();
        processSlotData.slotReturnMap = new Map<String, OfferSlotObject>();
        Timezone localUserTZ = UserInfo.getTimeZone();
        Integer offSet = ( localUserTZ.getOffset( DateTime.now() ) / 1000 ); // In Seconds

        Test.startTest();
            processSlotData = OffersAPI.processSlotData(
                localUserTZ,
                100,
                [ SELECT Id FROM ServiceResource LIMIT 1 ].Id,
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( STARTING_HOUR, 0, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),  
                DateTime.newInstanceGMT( tomorrow, Time.newInstance( ( 12 + 1 ), 30, 0, 0 ).addSeconds( ((-1) * offSet ) ) ),
                sa,
                processSlotData
            );
        Test.stopTest();

        system.assertEquals( TRUE, !processSlotData.savedOfferLst.isEmpty(), 'An offer was provided' );
        system.assertEquals( TRUE, !processSlotData.slotReturnMap.isEmpty(), 'A slot was provided' );
    }
}