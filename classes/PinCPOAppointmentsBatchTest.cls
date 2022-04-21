@isTest
public class PinCPOAppointmentsBatchTest {

    @TestSetup
    public static void makeData() {

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
                DueDate = system.today().addDays(1),
                Committed__c = FALSE,
                Subject = woLoop.Subject,
                Work_Order__c = woLoop.Id,
                ParentRecordId = woLoop.Id,
                Status = 'Dispatched',
                ServiceTerritoryId = vciServiceTerritory.Id,
                EarliestStartTime = DateTime.now().addDays(-5),
                Description = '1',
                SchedStartTime = DateTime.now().addHours(1),
                SchedEndTime = DateTime.now().addHours(25)
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
            PinCPOAppointmentsBatch batch = new PinCPOAppointmentsBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();

        //Confirm that CPO appointments have been pinned
        List<ServiceAppointment> pinnedSvcApptList = [ SELECT Id, Committed__c FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c IN ('cpobd', 'cpobm', 'cpofr', 'cpogm', 'cpogmcomp', 'cpohnice', 'cpojlr', 'cpohn04', 'cpohn06', 'cpohn08', 'cpohn10', 'cpohn12', 'cpohn14', 'cpohn16', 'cpohn18', 'cpohn20', 'cpopo', 'cpo90', 'cpo120', 'cpo150', 'cpo180', 'cpo240', 'cpo270', 'cpo300', 'vcpofr', 'vcpogm', 'vcpohn', 'vcpopo', 'cpolnc', 'gmfia' ) AND Status IN ('Scheduled','Dispatched') ];

        system.assert(pinnedSvcApptList.size() > 0);

        for ( ServiceAppointment serviceAppt : pinnedSvcApptList ) {
            System.assertEquals(true, serviceAppt.Committed__c, 'Expected Committed__c = true, but instead Committed__c = ' + serviceAppt.Committed__c);
        }

        //Confirm that non-CPO appointments have not been pinned
        List<ServiceAppointment> notPinnedSvcApptList = [ SELECT Id, Committed__c FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c NOT IN ('cpobd', 'cpobm', 'cpofr', 'cpogm', 'cpogmcomp', 'cpohnice', 'cpojlr', 'cpohn04', 'cpohn06', 'cpohn08', 'cpohn10', 'cpohn12', 'cpohn14', 'cpohn16', 'cpohn18', 'cpohn20', 'cpopo', 'cpo90', 'cpo120', 'cpo150', 'cpo180', 'cpo240', 'cpo270', 'cpo300', 'vcpofr', 'vcpogm', 'vcpohn', 'vcpopo', 'cpolnc', 'gmfia' ) AND Status IN ('Scheduled','Dispatched') ];

        system.assert(notPinnedSvcApptList.size() > 0);

        for ( ServiceAppointment serviceAppt : notPinnedSvcApptList ) {
            System.assertEquals(false, serviceAppt.Committed__c, 'Expected Committed__c = false, but instead Committed__c = ' + serviceAppt.Committed__c);
        }
    }


    @isTest
    static void runErrorBatch() {

        Test.startTest();

            PinCPOAppointmentsBatch batch = new PinCPOAppointmentsBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}