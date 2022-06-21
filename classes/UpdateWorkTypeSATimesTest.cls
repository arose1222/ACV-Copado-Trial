@isTest
public class UpdateWorkTypeSATimesTest {
    private final static String WORK_TYPE_UNIQUE_NAME = 'fbi';
    private final static String TIME_ZONE = 'America/New_York';
    private final static Set<String> DAY_OF_WEEK_SET = new Set<String>{ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' };
    private final static Integer STARTING_HOUR = 8;
    private final static Integer ENDING_HOUR = 17;

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        WorkType fbi = [ SELECT Id, Name, EstimatedDuration, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_Id__c = :WORK_TYPE_UNIQUE_NAME LIMIT 1 ];

        Account acct = TestUtility.createAccount();
        insert acct;

        OperatingHours specialFBIHours = new OperatingHours(
            Name = WORK_TYPE_UNIQUE_NAME + ' Special EST Hours', TimeZone = TIME_ZONE,
            Unique_Work_Hours__c = WORK_TYPE_UNIQUE_NAME + ':' + TIME_ZONE
        );
        insert specialFBIHours;

        List<TimeSlot> timeSlotLst = new List<TimeSlot>();
        for ( String dayOfWeek : DAY_OF_WEEK_SET ) {
            timeSlotLst.add( new TimeSlot(
                DayOfWeek = dayOfWeek,
                OperatingHoursId = specialFBIHours.Id,
                StartTime = Time.newInstance( STARTING_HOUR, 0, 0, 0 ),
                EndTime = Time.newInstance( 12, 30, 0, 0 )
            ) );
            timeSlotLst.add( new TimeSlot(
                DayOfWeek = dayOfWeek,
                OperatingHoursId = specialFBIHours.Id,
                StartTime = Time.newInstance( 12, 30, 0, 0 ),
                EndTime = Time.newInstance( ENDING_HOUR, 0, 0, 0 )
            ) );
        }
        insert timeSlotLst;

        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        st.OperatingHoursId = specialFBIHours.Id;
        update st;
    }

    @IsTest
    static void createWork(){
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType fbi = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_Id__c = :WORK_TYPE_UNIQUE_NAME LIMIT 1 ];

        Test.startTest();
            FSLTestUtility.generateWork( fbi, fbi, acct, '14209', st, 1);
        Test.stopTest();

        processResult( FALSE );
    }

    @IsTest
    static void updateWork(){
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType fbi = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_Id__c = :WORK_TYPE_UNIQUE_NAME LIMIT 1 ];

        FSLTestUtility.generateWork( fbi, fbi, acct, '14209', st, 1);

        Test.startTest();
            ServiceAppointment saUpdateRec = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
            saUpdateRec.EarliestStartTime = DateTime.now().addDays( 1 );
            update saUpdateRec;
        Test.stopTest();

        processResult( TRUE );
    }

    private static void processResult( Boolean checkStart ) {
        ServiceAppointment sa = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment LIMIT 1 ];
        if ( checkStart ) {
            system.assertEquals( STARTING_HOUR, sa.EarliestStartTime.Hour(), 'There was an unexpected difference between starting hours' );
        } else if ( !checkStart && DateTime.now().hour() != STARTING_HOUR ) { // If the time is already the starting hour, we can't check if they are different. Needed to avoid deployment issues
            system.assertNotEquals( STARTING_HOUR, sa.EarliestStartTime.Hour(), 'There was an unexpected match between starting hours' ); 
        }
        system.assertEquals( ENDING_HOUR, sa.DueDate.Hour(), 'There was an unexpected difference between ending hours' );
    }
}