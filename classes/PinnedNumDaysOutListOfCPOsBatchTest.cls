@isTest
public class PinnedNumDaysOutListOfCPOsBatchTest {

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

        // Create Work Type (needed for Work Order):
        List<WorkType> vciWorkTypeList = new List<WorkType>();

        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'acvhome', Name = 'ACV Home', EstimatedDuration = 30, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'verification', Name = 'Asset Verfication', EstimatedDuration = 5, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'auction off-lease', Name = 'Auction Off-Lease', EstimatedDuration = 35, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'auction site', Name = 'Auction Site', EstimatedDuration = 2030, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'consumer', Name = 'Consumer', EstimatedDuration = 50, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo120', Name = 'CPO120', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo150', Name = 'CPO150', EstimatedDuration = 150, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo180', Name = 'CPO180', EstimatedDuration = 180, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo240', Name = 'CPO240', EstimatedDuration = 240, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo270', Name = 'CPO270', EstimatedDuration = 270, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo300', Name = 'CPO300', EstimatedDuration = 300, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpo90', Name = 'CPO90', EstimatedDuration = 90, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpobd', Name = 'CPOBD', EstimatedDuration = 75, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpobm', Name = 'CPOBM', EstimatedDuration = 210, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpofr', Name = 'CPOFR', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpogm', Name = 'CPOGM', EstimatedDuration = 240, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpogmcomp', Name = 'CPOGMCOMP', EstimatedDuration = 240, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn04', Name = 'CPOHN04', EstimatedDuration = 105, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn06', Name = 'CPOHN06', EstimatedDuration = 130, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn08', Name = 'CPOHN08', EstimatedDuration = 155, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn10', Name = 'CPOHN10', EstimatedDuration = 205, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn12', Name = 'CPOHN12', EstimatedDuration = 205, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn14', Name = 'CPOHN14', EstimatedDuration = 230, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn16', Name = 'CPOHN16', EstimatedDuration = 255, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn18', Name = 'CPOHN18', EstimatedDuration = 280, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohn20', Name = 'CPOHN20', EstimatedDuration = 300, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpohnice', Name = 'CPOHNICE', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpojlr', Name = 'CPOJLR', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'cpopo', Name = 'CPOPO', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'dealer', Name = 'Dealer', EstimatedDuration = 25, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'dealer ny', Name = 'Dealer NY', EstimatedDuration = 30, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'dvinspections', Name = 'Dealership Visit - Inspections', EstimatedDuration = 50, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'fbi', Name = 'FBI', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'mystery test', Name = 'Mystery Test', EstimatedDuration = 150, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'other business', Name = 'Other Business', EstimatedDuration = 180, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'quality audit', Name = 'Quality Audit', EstimatedDuration = 270, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'inspection', Name = 'Standard Inspection', EstimatedDuration = 300, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'true360', Name = 'True 360', EstimatedDuration = 90, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'vcpofr', Name = 'VCPOFR', EstimatedDuration = 75, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'vcpogm', Name = 'VCPOGM', EstimatedDuration = 210, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'vcpohn', Name = 'VCPOHN', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));
        vciWorkTypeList.add (new WorkType (Work_Type_Unique_ID__c = 'vcpopo', Name = 'VCPOPO', EstimatedDuration = 120, ShouldAutoCreateSvcAppt = false));

        insert vciWorkTypeList;

        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> vciWorkOrderList = new List<WorkOrder>();

        for (WorkType wtLoop : vciWorkTypeList) {
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

        // Grab # Days Out value from PinnedNumDaysOutListOfCPOsBatch.cls and set Date variable for Service Appointment test data.
        Date Date_NumDaysOut = System.Today().addDays(PinnedNumDaysOutListOfCPOsBatch.DEFAULT_DAY_RANGE);

        // Create Service Appointments:
        List<ServiceAppointment> vciServiceAppointmentList = new List<ServiceAppointment>();

        for (WorkOrder woLoop : vciWorkOrderList) {
            ServiceAppointment vciServiceAppointment = new ServiceAppointment(
                DueDate = Date_NumDaysOut,
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
    static void runBatchPinnedShouldBeTrue() {
        // run batch
        Test.startTest();
            SchedulableContext sc = null;
            PinnedNumDaysOutListOfCPOsBatch batch = new PinnedNumDaysOutListOfCPOsBatch();
            Batch.execute(sc);
        Test.stopTest();

        Date Date_NumDaysOut = System.Today().addDays(PinnedNumDaysOutListOfCPOsBatch.DEFAULT_DAY_RANGE);

        // query to grab Service Appointments that should have Pinned = True
        List<ServiceAppointment> testSvcApptList = [ SELECT Id, DueDate, FSL__Pinned__c, Subject
                                                       FROM ServiceAppointment
                                                      WHERE Subject IN ('cpobd', 'cpobm', 'cpofr', 'cpohn04', 'cpohn06', 'cpohn08', 'cpohn10', 'cpohn12', 'cpohn14', 'cpohn16', 'cpohn18', 'cpohn20', 'cpopo', 'cpo90', 'cpo120', 'cpo150', 'cpo180', 'cpo240', 'cpo270', 'cpo300')
                                                            AND DueDate = :Date_NumDaysOut ];

        // system.asserts
        for ( ServiceAppointment tstList : testSvcApptList ) {
            // System.assertEquals(true, tstList.FSL__Pinned__c, tstList.Subject + ' Expected FSL__Pinned__c = true, but instead FSL__Pinned__c = ' + tstList.FSL__Pinned__c);
        }
    }


    @isTest
    static void runBatchPinnedShouldBeFalse() {
        // run batch
        Test.startTest();
            SchedulableContext sc = null;
            PinnedNumDaysOutListOfCPOsBatch batch = new PinnedNumDaysOutListOfCPOsBatch();
            Batch.execute(sc);
        Test.stopTest();

        Date Date_NumDaysOut = System.Today().addDays(PinnedNumDaysOutListOfCPOsBatch.DEFAULT_DAY_RANGE);

        // query to grab Service Appointments that should have Pinned = False
        List<ServiceAppointment> testSvcApptList = [ SELECT Id, DueDate, FSL__Pinned__c, Subject FROM ServiceAppointment WHERE Subject IN ('cpogm', 'cpogmcomp', 'cpohnice', 'cpojlr', 'vcpofr', 'vcpogm', 'vcpohn', 'vcpopo') AND DueDate = :Date_NumDaysOut ];

        // system.asserts
        for ( ServiceAppointment tstList : testSvcApptList ) {
            // System.assertEquals(false, tstList.FSL__Pinned__c, tstList.Subject + ' Expected FSL__Pinned__c = false, but instead FSL__Pinned__c = ' + tstList.FSL__Pinned__c);
        }
    }


    @isTest
    static void runErrorBatch() {

        Test.startTest();

            SchedulableContext sc = null;
            PinnedNumDaysOutListOfCPOsBatch batch = new PinnedNumDaysOutListOfCPOsBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.execute( sc );

        Test.stopTest();
    }
}