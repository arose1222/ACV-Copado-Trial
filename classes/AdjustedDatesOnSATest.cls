@isTest
public class AdjustedDatesOnSATest {

    /*@TestSetup
    static void makeData(){
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        FSL.GlobalAPIS.addStatusTransition( 'Scheduled', 'Cannot Complete' );

        Account acct = TestUtility.createAccount();
        insert acct;

        FSLTestUtility.createData( acct, 1 );

        ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
        DateTime now = Datetime.now();

        sa.SchedStartTime = now.addMinutes(60);
        sa.SchedEndTime = now.addMinutes(90);
        sa.ArrivalWindowStartTime = now;
        sa.ArrivalWindowEndTime = now.addMinutes(300);

        update sa;
    }

    @IsTest
    static void cancelSA() {
        ServiceAppointment sa = [ SELECT Id, Status FROM ServiceAppointment LIMIT 1 ];

        Test.startTest();
            sa.Status = 'Canceled';
            update sa;
        Test.stopTest();
        
        sa = [ SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment LIMIT 1 ];
        system.assertEquals( null, sa.ArrivalWindowStartTime, 'The Arrival Window Start Time was not cleared out as expected' );
        system.assertEquals( null, sa.ArrivalWindowEndTime, 'The Arrival Window End Time was not cleared out as expected' );
    }

    @IsTest
    static void cannotCompleteSA() {
        ServiceAppointment sa = [ SELECT Id, Status, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

        Test.startTest();
            FSLTestUtility.makeAR( sa ); // Assign Resource to the SA

            sa.Status = 'Cannot Complete';
            sa.Completed_Canceled_Notes__c = 'Testing';
            sa.Cannot_Complete_Reason__c = 'Insufficient time to complete';
            sa.ActualStartTime = DateTime.now();
            sa.ActualEndTime = DateTime.now().addMinutes(30);
            update sa;
        Test.stopTest();
        
        sa = [ SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment LIMIT 1 ];
        system.assertEquals( null, sa.ArrivalWindowStartTime, 'The Arrival Window Start Time was not cleared out as expected' );
        system.assertEquals( null, sa.ArrivalWindowEndTime, 'The Arrival Window End Time was not cleared out as expected' );
    }

    @IsTest
    static void adjustSAEarliestStart() {
        ServiceAppointment sa = [ SELECT Id, EarliestStartTime FROM ServiceAppointment LIMIT 1 ];

        Test.startTest();
            sa.EarliestStartTime = DateTime.now().addMinutes( 75 ); // Purposefully try to trip-up validation rule to prevent Arrival Window & Scheduled Start from being before Earliest Start Date
            update sa;
        Test.stopTest();
        
        sa = [ SELECT Id, SchedStartTime, SchedEndTime, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment LIMIT 1 ];
        system.assertEquals( null, sa.SchedStartTime, 'The Scheduled Start Time was not cleared out as expected' );
        system.assertEquals( null, sa.SchedEndTime, 'The Scheduled End Time was not cleared out as expected' );
        system.assertEquals( null, sa.ArrivalWindowStartTime, 'The Arrival Window Start Time was not cleared out as expected' );
        system.assertEquals( null, sa.ArrivalWindowEndTime, 'The Arrival Window End Time was not cleared out as expected' );
    }

    @IsTest
    static void adjustSAEarliestStartAndScheduled() {
        ServiceAppointment sa = [ SELECT Id, EarliestStartTime FROM ServiceAppointment LIMIT 1 ];

        Test.startTest();
            sa.EarliestStartTime = DateTime.now().addMinutes( 75 ); // Purposefully try to trip-up validation rule to prevent Arrival Window & Scheduled Start from being before Earliest Start Date
            sa.SchedStartTime = DateTime.now().addMinutes( 80 );
            sa.SchedEndTime = DateTime.now().addMinutes( 110 );
            update sa;
        Test.stopTest();
        
        sa = [ SELECT Id, SchedStartTime, SchedEndTime, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment LIMIT 1 ];
        system.assertNotEquals( null, sa.SchedStartTime, 'The Scheduled Start Time was unexpectedly cleared out' );
        system.assertNotEquals( null, sa.SchedEndTime, 'The Scheduled End Time was unexpectedly cleared out' );
        system.assertEquals( null, sa.ArrivalWindowStartTime, 'The Arrival Window Start Time was not cleared out as expected' );
        system.assertEquals( null, sa.ArrivalWindowEndTime, 'The Arrival Window End Time was not cleared out as expected' );
    }

    @IsTest
    static void adjustSAEarliestStartAndArrival() {
        ServiceAppointment sa = [ SELECT Id, EarliestStartTime FROM ServiceAppointment LIMIT 1 ];

        Test.startTest();
            sa.EarliestStartTime = DateTime.now().addMinutes( 75 ); // Purposefully try to trip-up validation rule to prevent Arrival Window & Scheduled Start from being before Earliest Start Date
            sa.ArrivalWindowStartTime = DateTime.now().addMinutes( 80 );
            sa.ArrivalWindowEndTime = DateTime.now().addMinutes( 380 );
            update sa;
        Test.stopTest();
        
        sa = [ SELECT Id, SchedStartTime, SchedEndTime, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment LIMIT 1 ];
        system.assertEquals( null, sa.SchedStartTime, 'The Scheduled Start Time was not cleared out as expected' );
        system.assertEquals( null, sa.SchedEndTime, 'The Scheduled End Time was not cleared out as expected' );
        system.assertNotEquals( null, sa.ArrivalWindowStartTime, 'The Arrival Window Start Time was unexpectedly cleared out' );
        system.assertNotEquals( null, sa.ArrivalWindowEndTime, 'The Arrival Window End Time was unexpectedly cleared out' );
    }*/
}