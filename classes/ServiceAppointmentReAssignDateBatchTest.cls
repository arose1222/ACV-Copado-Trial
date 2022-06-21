@isTest
public class ServiceAppointmentReAssignDateBatchTest {

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

        WorkType vciStandardInspectionWorkType = new WorkType(Work_Type_Unique_ID__c = 'standard inspection', Name = 'Standard Inspection', EstimatedDuration = 30, ShouldAutoCreateSvcAppt = false);
        vciWorkTypeList.add(vciStandardInspectionWorkType);

        WorkType vciAuctionSiteWorkType = new WorkType(Work_Type_Unique_ID__c = 'auction site', Name = 'Auction Site', EstimatedDuration = 20, ShouldAutoCreateSvcAppt = false);
        vciWorkTypeList.add(vciAuctionSiteWorkType);

        WorkType vciDealerWorkType = new WorkType(Work_Type_Unique_ID__c = 'dealer', Name = 'Dealer', EstimatedDuration = 25, ShouldAutoCreateSvcAppt = false);
        vciWorkTypeList.add(vciDealerWorkType);

        WorkType vciAuctionOffLeaseWorkType = new WorkType(Work_Type_Unique_ID__c = 'auction off-lease', Name = 'Auction Off-Lease', EstimatedDuration = 35, ShouldAutoCreateSvcAppt = false);
        vciWorkTypeList.add(vciAuctionOffLeaseWorkType);

        insert vciWorkTypeList;
        
        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> vciWorkOrderList = new List<WorkOrder>();

        WorkOrder vciNewWorkOrder = new WorkOrder(AccountId = vciAccount.Id, ServiceTerritoryId = vciServiceTerritory.Id, WorkTypeId = vciAuctionSiteWorkType.Id, Status = 'New', Priority = 'Low');
        vciWorkOrderList.add(vciNewWorkOrder);

        WorkOrder vciAssignedWorkOrder = new WorkOrder(AccountId = vciAccount.Id, ServiceTerritoryId = vciServiceTerritory.Id, WorkTypeId = vciDealerWorkType.Id, Status = 'Assigned', Priority = 'Low');
        vciWorkOrderList.add(vciAssignedWorkOrder);

        WorkOrder vciCannotCompleteWorkOrder = new WorkOrder(AccountId = vciAccount.Id, ServiceTerritoryId = vciServiceTerritory.Id, WorkTypeId = vciAuctionOffLeaseWorkType.Id, Status = 'Cannot Complete', Priority = 'Low');
        vciWorkOrderList.add(vciCannotCompleteWorkOrder);

        insert vciWorkOrderList;

        // Create User:
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

        vciServiceAppointmentList.add ( new ServiceAppointment( Description = '1', ServiceTerritoryId = vciServiceTerritory.Id, Work_Order__c = vciNewWorkOrder.Id, 
            ParentRecordId = vciNewWorkOrder.Id, Status = 'New', Subject = 'vciServiceAppointmentNew', DueDate = Date.today().addDays(-2), EarliestStartTime = DateTime.now().addDays(-5) ) );

        vciServiceAppointmentList.add ( new ServiceAppointment( Description = '1', ServiceTerritoryId = vciServiceTerritory.Id, Work_Order__c = vciAssignedWorkOrder.Id, 
            ParentRecordId = vciAssignedWorkOrder.Id, Status = 'Scheduled', Subject = 'vciServiceAppointmentAssignedScheduled', DueDate = Date.today().addDays(-2), EarliestStartTime = DateTime.now().addDays(-5) ) );

        vciServiceAppointmentList.add ( new ServiceAppointment( Description = '1', ServiceTerritoryId = vciServiceTerritory.Id, Work_Order__c = vciCannotCompleteWorkOrder.Id, 
            ParentRecordId = vciCannotCompleteWorkOrder.Id, Status = 'Cannot Complete', Subject = 'vciServiceAppointmentCannotComplete', DueDate = Date.today().addDays(-2), EarliestStartTime = DateTime.now().addDays(-5) ) );

        insert vciServiceAppointmentList;

        for ( ServiceAppointment saList : vciServiceAppointmentList ) {
            Test.setCreatedDate( saList.Id, DateTime.now().addDays( -7 ) );
        }
    }


    @isTest
    static void runBatch() {

        List<ServiceAppointment> testSvcApptList = [ SELECT Id, DueDate, Subject, FSL__InJeopardy__c FROM ServiceAppointment WHERE Subject LIKE '%vciServiceAppointment%' ];

        // run batch
        Test.startTest();
            SchedulableContext sc = null;
            ServiceAppointmentReAssignDateBatch batch = new ServiceAppointmentReAssignDateBatch();
            Batch.execute(sc);
        Test.stopTest();

        // query
        List<ServiceAppointment> checkServiceAppointmentDueDate = [SELECT Id, DueDate, Subject, FSL__InJeopardy__c FROM ServiceAppointment WHERE Subject LIKE '%vciServiceAppointment%' ];

        // system.asserts
        System.assertEquals(testSvcApptList[0].DueDate.addDays(ServiceAppointmentReAssignDateBatch.DEFAULT_DAY_RANGE), checkServiceAppointmentDueDate[0].DueDate, 'Expected Due Date = ' + testSvcApptList[0].DueDate.addDays(ServiceAppointmentReAssignDateBatch.DEFAULT_DAY_RANGE) + ' but instead Due Date = ' + checkServiceAppointmentDueDate[0].DueDate);
        System.assertEquals(true, checkServiceAppointmentDueDate[0].FSL__InJeopardy__c, ' Expected FSL__InJeopardy__c = true, but instead FSL__InJeopardy__c = ' + checkServiceAppointmentDueDate[0].FSL__InJeopardy__c);

        System.assertEquals(testSvcApptList[1].DueDate.addDays(ServiceAppointmentReAssignDateBatch.DEFAULT_DAY_RANGE), checkServiceAppointmentDueDate[1].DueDate, 'Expected Due Date = ' + testSvcApptList[1].DueDate.addDays(ServiceAppointmentReAssignDateBatch.DEFAULT_DAY_RANGE) + ' but instead Due Date = ' + checkServiceAppointmentDueDate[1].DueDate);
        System.assertEquals(true, checkServiceAppointmentDueDate[1].FSL__InJeopardy__c, ' Expected FSL__InJeopardy__c = true, but instead FSL__InJeopardy__c = ' + checkServiceAppointmentDueDate[1].FSL__InJeopardy__c);

        System.assertEquals(testSvcApptList[2].DueDate.addDays(ServiceAppointmentReAssignDateBatch.DEFAULT_DAY_RANGE), checkServiceAppointmentDueDate[2].DueDate, 'Expected Due Date = ' + testSvcApptList[2].DueDate.addDays(ServiceAppointmentReAssignDateBatch.DEFAULT_DAY_RANGE) + ' but instead Due Date = ' + checkServiceAppointmentDueDate[2].DueDate);
        System.assertEquals(true, checkServiceAppointmentDueDate[2].FSL__InJeopardy__c, ' Expected FSL__InJeopardy__c = true, but instead FSL__InJeopardy__c = ' + checkServiceAppointmentDueDate[2].FSL__InJeopardy__c);
    }


    @isTest
    static void runErrorBatch() {

        Test.startTest();

            SchedulableContext sc = null;
            ServiceAppointmentReAssignDateBatch batch = new ServiceAppointmentReAssignDateBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.execute( sc );

        Test.stopTest();
    }
}