@isTest
public class TimeSheetEntryFieldTriggerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
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
        WorkType vciWorkType = new WorkType(
            Name = 'Standard Inspection', 
            EstimatedDuration = 1, 
            ShouldAutoCreateSvcAppt = false
        );
        insert vciWorkType;

        // Create Work Order (needed for Service Appointment):
        WorkOrder vciWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciWorkType.Id, 
            Priority = 'Low'
        );
        insert vciWorkOrder;

        // Create User
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

        // Create Service Appointment:
        ServiceAppointment vciServiceAppointment = new ServiceAppointment(
            Description = '1', 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            Work_Order__c = vciWorkOrder.Id, 
            ParentRecordId = vciWorkOrder.Id,
            Status = 'None',
            Subject = 'vciServiceAppointmentSubject', 
            DueDate = Date.today().addMonths(1), 
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10), 
            SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment;

        TimeSheet vciTimeSheet = new TimeSheet(
            ServiceResourceId = vciServiceResource.Id,
            StartDate = Date.today(),
            EndDate = Date.today().AddDays(7)
        );
        insert vciTimeSheet;
    }
    
    @isTest
    public static void addressAndAccountPopulationTest(){
        Id woId = [SELECT Id FROM WorkOrder LIMIT 1].id;
        Id tsId = [SELECT Id FROM TimeSheet LIMIT 1].id;
        TimeSheetEntry tse = new TimeSheetEntry(
            Work_Order__c	 = woId,
            TimeSheetId = tsId,
            StartTime = DateTime.now()
        );
        insert tse;
        TimeSheetEntry tseResult = [SELECT Account__c, Address__c, Id, Work_Order__c	, TimeSheetId, StartTime FROM TimeSheetEntry LIMIT 1];
        system.assert(tseResult.Account__c != null && tseResult.Address__c != null);
    }
}