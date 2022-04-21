@isTest
public class AdjustCPOTimelineBatchTest {

    @TestSetup
    public static void makeData() {

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Offer Attempted' );

        // Create Account (needed for Work Order):
        Account vciAccount = TestUtility.createAccount('vciTestAccount');
        insert vciAccount;

        // Create Operating Hours (needed for Service Service Territory & Service Territory Member):
        OperatingHours vciOperatingHours = new OperatingHours(Name = 'vciTestOpHours');
        insert vciOperatingHours;

        // Create Service Territory (needed for Work Order, Service Territory Member & Service Appointment):
        ServiceTerritory vciServiceTerritory = new ServiceTerritory(
            Name = 'Greater Buffalo',
            OperatingHoursId = vciOperatingHours.Id,
            IsActive = true
            );
        insert vciServiceTerritory;

        //Create worktypes
        List<WorkType> workTypeList = FSLTestUtility.createWorkTypes();
        insert workTypeList;

        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> vciWorkOrderList = new List<WorkOrder>();

        for (WorkType wtLoop : workTypeList) {
            WorkOrder vciWorkOrder = new WorkOrder(
                AccountId = vciAccount.Id,
                ServiceTerritoryId = vciServiceTerritory.Id,
                WorkTypeId = wtLoop.Id,
                Subject = wtLoop.Work_Type_Unique_ID__c,
                Status = 'New',
                Priority = 'Low'
            );
            vciWorkOrderList.add(vciWorkOrder);
        }
        insert vciWorkOrderList;

        List<ServiceAppointment> saLst = [ SELECT Id FROM ServiceAppointment ];
        Boolean alternateStatus = TRUE;
        for ( ServiceAppointment sa : saLst ) {
            if ( alternateStatus ) { // Set some records (half roughly) to be Offer Attempted to test both statuses in Batch
                sa.Status = 'Offer Attempted';
            }
            alternateStatus = !alternateStatus;
            sa.DueDate = Datetime.now().addDays(30);
        }
        update saLst;
    }


    @isTest
    static void runBatch() {
        // run batch
        Test.startTest();
            AdjustCPOTimelineBatch batch = new AdjustCPOTimelineBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();

        //Confirm that CPO appointments have been pinned
        List<ServiceAppointment> svcApptList = [ SELECT Id, FSL__InJeopardy__c, EarliestStartTime FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c IN ('cpobm', 'cpofr', 'cpogm', 'cpogmcomp', 'cpohnice', 'cpohn04', 'cpohn06', 'cpohn08', 'cpohn10', 'cpohn12', 'cpohn14', 'cpohn16', 'cpohn18', 'cpohn20', 'cpopo', 'vcpofr', 'vcpogm', 'vcpohn', 'vcpopo', 'cpolnc', 'gmfia') ];

        system.assert(svcApptList.size() > 0);

        for ( ServiceAppointment serviceAppt : svcApptList ) {
            System.assertEquals(true, serviceAppt.FSL__InJeopardy__c, 'Expected FSL__InJeopardy__c = true, but instead FSL__InJeopardy__c = ' + serviceAppt.FSL__InJeopardy__c);
            System.assertNotEquals( Date.today(), serviceAppt.EarliestStartTime.date(), 'Service Appointment Earlist Start Time was not correctly moved forward');
        }

        //Confirm that non-CPO appointments have not been pinned
        List<ServiceAppointment> notSvcApptList = [ SELECT Id, FSL__InJeopardy__c, EarliestStartTime FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c NOT IN ('cpobm', 'cpofr', 'cpogm', 'cpogmcomp', 'cpohnice', 'cpohn04', 'cpohn06', 'cpohn08', 'cpohn10', 'cpohn12', 'cpohn14', 'cpohn16', 'cpohn18', 'cpohn20', 'cpopo', 'vcpofr', 'vcpogm', 'vcpohn', 'vcpopo', 'cpolnc', 'gmfia') ];

        system.assert(notSvcApptList.size() > 0);

        for ( ServiceAppointment serviceAppt : notSvcApptList ) {
            System.assertEquals( Date.today(), serviceAppt.EarliestStartTime.date(), 'Service Appointment Earlist Start Time was incorrectly moved forward' );
        }
    }


    @isTest
    static void runErrorBatch() {

        Test.startTest();

            AdjustCPOTimelineBatch batch = new AdjustCPOTimelineBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}