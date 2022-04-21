@isTest
public class CreateServiceAppointmentTest {

    final static String TERRITORY_NAME = 'Buffalo';
    final static String ZIPCODE = '14209';
    final static String INSPECTION = 'Standard Inspection';
    final static String UNWIND = 'Unwind Inspection';
    final static String ARBITRATION = 'Arbitration Inspection';

    @TestSetup
    static void createTerritory() {
        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = new Affiliation__c(
            Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true, 
            Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
            type__c='rep'
        );
        insert aff;

        FSLTestUtility.createAllStructureWithParentST( TERRITORY_NAME, ZIPCODE );
    }

    @IsTest
    static void createStandardWorkOrder(){
        Service_Appt_Date_Range_by_Work_Type__mdt dateRangeRec = [SELECT Label, Date_Range__c FROM Service_Appt_Date_Range_by_Work_Type__mdt WHERE Label = 'Default' LIMIT 1];
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        WorkType wtRec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ];
        
        Test.StartTest();
            FSLTestUtility.WorkStruct workReturn = FSLTestUtility.generateWork( wtRec, wtRec, testAcct, ZIPCODE, stRec, 1 );
        Test.StopTest();

        System.assert( workReturn.wo.Id != null, 'The Id of the Work Order was not set' );

        List<ServiceAppointment> serApptList = new List<ServiceAppointment>([ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment WHERE ParentRecordId = :workReturn.wo.Id ]);
        System.assertEquals( 1, serApptList.size(), 'There was an unexpected amount of Service Appointments in the system' );
        System.assertEquals(serApptList[0].DueDate, serApptList[0].EarliestStartTime.addDays((Integer) dateRangeRec.Date_Range__c), 'DueDate is 7 days from start date.');
    }

    @IsTest
    static void createUnwindWorkOrder(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        WorkType wtRec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = :UNWIND LIMIT 1 ];
        CreateServiceAppointment.currentDT = DateTime.newInstance(2022, 1, 14, 12, 0, 0);
        
        Test.StartTest();
            FSLTestUtility.WorkStruct workReturn = FSLTestUtility.generateWork( wtRec, wtRec, testAcct, ZIPCODE, stRec, 1 );
        Test.StopTest();

        System.assert( workReturn.wo.Id != null, 'The Id of the Work Order was not set' );

        List<ServiceAppointment> serApptList = new List<ServiceAppointment>([ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment WHERE ParentRecordId = :workReturn.wo.Id ]);
        System.assertEquals( 1, serApptList.size(), 'There was an unexpected amount of Service Appointments in the system' );
        System.assert(serApptList[0].DueDate.Date() == Date.newInstance(2022, 1, 18), 'DueDate is not 2 business days from start date.');
        System.assert(serApptList[0].DueDate.time() == serApptList[0].EarliestStartTime.time(), 'DueDate time is not the same as the EarliestStartDates time.');
    }

    @IsTest
    static void createArbitrationWorkOrder(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        WorkType wtRec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = :ARBITRATION LIMIT 1 ];
        CreateServiceAppointment.currentDT = DateTime.newInstance(2022, 1, 14, 12, 0, 0);
        
        Test.StartTest();
            FSLTestUtility.WorkStruct workReturn = FSLTestUtility.generateWork( wtRec, wtRec, testAcct, ZIPCODE, stRec, 1 );
        Test.StopTest();

        System.assert( workReturn.wo.Id != null, 'The Id of the Work Order was not set' );

        List<ServiceAppointment> serApptList = new List<ServiceAppointment>([ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment WHERE ParentRecordId = :workReturn.wo.Id ]);
        System.assertEquals( 1, serApptList.size(), 'There was an unexpected amount of Service Appointments in the system' );
        System.assert(serApptList[0].DueDate.Date() == Date.newInstance(2022, 1, 18), 'DueDate is not 2 business days from start date.');
        System.assert(serApptList[0].DueDate.time() == serApptList[0].EarliestStartTime.time(), 'DueDate time is not the same as the EarliestStartDates time.');
    }
}