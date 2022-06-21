@isTest
public class ExtendAppointmentDueDateBatchTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

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

        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData();

        // Create Service Territory Member:
        ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
            OperatingHoursId = vciOperatingHours.Id,
            ServiceTerritoryId = vciServiceTerritory.Id,
            ServiceResourceId = vciServiceResource.Id,
            EffectiveStartDate = Date.today(),
            TerritoryType = 'P'
        );
        insert vciServiceTerritoryMember;

        // Create Service Appointments:
        List<ServiceAppointment> vciServiceAppointmentList = new List<ServiceAppointment>();

        for (WorkOrder woLoop : vciWorkOrderList) {
            ServiceAppointment vciServiceAppointment = new ServiceAppointment(
                DueDate = system.today().addDays(-1),
                FSL__Pinned__c = FALSE,
                Subject = woLoop.Subject,
                Work_Order__c = woLoop.Id,
                ParentRecordId = woLoop.Id,
                Status = 'New',
                ServiceTerritoryId = vciServiceTerritory.Id,
                EarliestStartTime = DateTime.now().addDays(-5),
                Description = '1'
            );
            vciServiceAppointmentList.add(vciServiceAppointment);
        }
        insert vciServiceAppointmentList;

        for ( ServiceAppointment saList : vciServiceAppointmentList ) {
            Test.setCreatedDate( saList.Id, DateTime.now().addDays( -7 ) );
        }
    }


    @isTest
    static void runBatch() {
        // run batch
        Test.startTest();
            ExtendAppointmentDueDateBatch batch = new ExtendAppointmentDueDateBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();

        Date REASSIGN_DUE_DATE = ExtendAppointmentDueDateBatch.REASSIGN_DUE_DATE;

        //Confirm that auction site, dealer, and auction off-lease appointments that are New, Scheduled, or Dispatched have had their due date extended and are marked as In Jeopardy
        List<ServiceAppointment> dueDateExtendedApptList = [ SELECT Id, DueDate, FSL__InJeopardy__c, FSL__InJeopardyReason__c, Original_Due_Date__c FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c IN ('auction site', 'dealer', 'auction off-lease') AND Status = 'New' ];

        system.assert(dueDateExtendedApptList.size() > 0);
        for ( ServiceAppointment serviceAppt : dueDateExtendedApptList ) {
            System.assertEquals(REASSIGN_DUE_DATE, serviceAppt.DueDate, 'Expected DueDate = ' + REASSIGN_DUE_DATE + ', but instead DueDate = ' + serviceAppt.DueDate);
            System.assertEquals(true, serviceAppt.FSL__InJeopardy__c, 'Expected FSL__InJeopardy__c = true, but instead FSL__InJeopardy__c = ' + serviceAppt.FSL__InJeopardy__c);
        }

        //Confirm that appointments that are NOT auction site, dealer, or auction off-lease have NOT had their due date extended
        List<ServiceAppointment> dueDateNotExtendedApptList = [ SELECT Id, DueDate, FSL__InJeopardy__c, FSL__InJeopardyReason__c FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c NOT IN ('auction site', 'dealer', 'auction off-lease') AND Status = 'New' ];

        system.assert(dueDateNotExtendedApptList.size() > 0);
        for ( ServiceAppointment serviceAppt : dueDateNotExtendedApptList ) {
            System.assertEquals(system.today().addDays(-1), serviceAppt.DueDate, 'Expected DueDate = ' + system.today().addDays(-1) + ', but instead DueDate = ' + serviceAppt.DueDate);
        }
    }

    @isTest
    static void runErrorBatch() {

        Test.startTest();

            ExtendAppointmentDueDateBatch batch = new ExtendAppointmentDueDateBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}