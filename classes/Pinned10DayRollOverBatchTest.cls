@isTest
public class Pinned10DayRollOverBatchTest {

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

        // Create Work Type (needed for Work Order):
        List<WorkType> vciWorkTypeList = new List<WorkType>();

        WorkType vciSIWorkType = new WorkType(
            Name = 'Standard Inspection', 
            EstimatedDuration = 30, 
            ShouldAutoCreateSvcAppt = false
        );
        vciWorkTypeList.add(vciSIWorkType);

        WorkType vciAuctionSiteWorkType = new WorkType(
            Name = 'Auction Site', 
            EstimatedDuration = 60, 
            ShouldAutoCreateSvcAppt = false
        );
        vciWorkTypeList.add(vciAuctionSiteWorkType);

        WorkType vciDealerWorkType = new WorkType(
            Name = 'Dealer', 
            EstimatedDuration = 60, 
            ShouldAutoCreateSvcAppt = false
        );
        vciWorkTypeList.add(vciDealerWorkType);

        WorkType vciAuctionOffLeaseWorkType = new WorkType(
            Name = 'Auction Off-Lease', 
            EstimatedDuration = 60, 
            ShouldAutoCreateSvcAppt = false
        );
        vciWorkTypeList.add(vciAuctionOffLeaseWorkType);

        insert vciWorkTypeList;
        
        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> vciWorkOrderList = new List<WorkOrder>();

        WorkOrder vciNewWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciDealerWorkType.Id, 
            Status = 'New', 
            Priority = 'Low'
        );
        vciWorkOrderList.add(vciNewWorkOrder);

        WorkOrder vciScheduledWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciDealerWorkType.Id, 
            Status = 'Assigned', 
            Priority = 'Low'
        );
        vciWorkOrderList.add(vciScheduledWorkOrder);

        WorkOrder vciCannotCompleteWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciDealerWorkType.Id, 
            Status = 'Cannot Complete', 
            Priority = 'Low'
        );
        vciWorkOrderList.add(vciCannotCompleteWorkOrder);
        insert vciWorkOrderList;

        // Create Service Appointment:
        ServiceAppointment vciServiceAppointment = new ServiceAppointment(
            Description = '1', 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            Work_Order__c = vciNewWorkOrder.Id, 
            ParentRecordId = vciNewWorkOrder.Id,
            Status = 'New',
            Subject = 'vciServiceAppointmentSubject', 
            DueDate = Date.today().addDays(-2), 
            Original_Due_Date__c = Date.today().addDays(-2), 
            EarliestStartTime = DateTime.now().addDays(-5)

            // SchedStartTime = DateTime.now().addHours(10), 
            // SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment;
    }


    @isTest
    static void batchTest() {

        List<ServiceAppointment> testSvcApptList = [ SELECT Id, Status, Original_Due_Date__c, FSL__Pinned__c, Work_Type_Name__c 
                                                       FROM ServiceAppointment 
                                                      WHERE Subject = 'vciServiceAppointmentSubject' ];

        // run batch
        Test.startTest();
            SchedulableContext sc = null;
            Pinned10DayRollOverBatch batch = new Pinned10DayRollOverBatch();
            Batch.execute(sc);
        Test.stopTest();

        // query
        List<ServiceAppointment> checkServiceAppointmentPinned = [SELECT Id, Original_Due_Date__c, FSL__Pinned__c 
                                                                    FROM ServiceAppointment 
                                                                   WHERE Subject = 'vciServiceAppointmentSubject' ];

        // system.asserts
        //System.assertEquals(testSvcApptList[0].Original_Due_Date__c.addDays(10).date(), checkServiceAppointmentPinned[0].Original_Due_Date__c.date());
        //System.assertEquals(true, checkServiceAppointmentPinned[0].FSL__Pinned__c);

    }


    @isTest
    static void errorCheck() {
        // populate errorList
        Pinned10DayRollOverBatch.errorList.add('error');
        //start test
        Test.startTest();
        // run batch
            SchedulableContext sc = null;
            Pinned10DayRollOverBatch batch = new Pinned10DayRollOverBatch();
            Batch.execute(sc);
        // stop test
        Test.stopTest();
    }
}