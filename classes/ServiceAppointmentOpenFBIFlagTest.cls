@isTest
public class ServiceAppointmentOpenFBIFlagTest {

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

        WorkType vciFBIWorkType = new WorkType(
            Name = 'FBI', 
            EstimatedDuration = 30, 
            ShouldAutoCreateSvcAppt = false
        );
        vciWorkTypeList.add(vciFBIWorkType);

        WorkType vciSIWorkType = new WorkType(
            Name = 'Standard Inspection', 
            EstimatedDuration = 30, 
            ShouldAutoCreateSvcAppt = false
        );
        vciWorkTypeList.add(vciSIWorkType);

        insert vciWorkTypeList;
        
        // Create Work Order (needed for Service Appointment):
        WorkOrder vciWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciFBIWorkType.Id, 
            Status = 'Assigned', 
            Priority = 'Low'
        );
        insert vciWorkOrder;

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

        // Create Service Appointment:
        ServiceAppointment vciServiceAppointment = new ServiceAppointment(
            Description = '1', 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            Work_Order__c = vciWorkOrder.Id, 
            ParentRecordId = vciWorkOrder.Id,
            Status = 'Scheduled',
            Subject = 'vciServiceAppointmentSubject1', 
            DueDate = Date.today().addMonths(1), 
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10), 
            SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment;

    }


    @IsTest
    static void testInsertNewFBIServiceAppointment() {

        List<ServiceTerritory> testSvcTerrList = [ SELECT Id FROM ServiceTerritory WHERE  Name = 'Greater Buffalo' ];
        List<WorkOrder> testWorkOrderList = [ SELECT Id FROM WorkOrder WHERE Status = 'Assigned' ];

        // Create Service Appointment to TEST INSERT:
        ServiceAppointment vciServiceAppointment = new ServiceAppointment(
            Description = '2', 
            ServiceTerritoryId = testSvcTerrList[0].Id, 
            Work_Order__c = testWorkOrderList[0].Id, 
            ParentRecordId = testWorkOrderList[0].Id,
            Status = 'New',
            Subject = 'vciServiceAppointmentSubject2', 
            DueDate = Date.today().addMonths(1), 
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10), 
            SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment;

        // query
        List<ServiceAppointment> checkServiceAppointmentInJeopardyFlag = [SELECT Id, FSL__InJeopardy__c 
                                                                            FROM ServiceAppointment 
                                                                           WHERE Subject = 'vciServiceAppointmentSubject2' ];
        
        // system.asserts
        System.assertEquals(true, checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c, 'Expected InJeopardyFlag = true, but InJeopardyFlag = ' + checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c);
    }


    @IsTest
    static void testInsertScheduledFBIServiceAppointment() {

        List<ServiceTerritory> testSvcTerrList = [ SELECT Id FROM ServiceTerritory WHERE  Name = 'Greater Buffalo' ];
        List<WorkOrder> testWorkOrderList = [ SELECT Id FROM WorkOrder WHERE Status = 'Assigned' ];

        // Create Service Appointment to TEST INSERT:
        ServiceAppointment vciServiceAppointment = new ServiceAppointment(
            Description = '2', 
            ServiceTerritoryId = testSvcTerrList[0].Id, 
            Work_Order__c = testWorkOrderList[0].Id, 
            ParentRecordId = testWorkOrderList[0].Id,
            Status = 'Scheduled',
            Subject = 'vciServiceAppointmentSubject3', 
            DueDate = Date.today().addMonths(1), 
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10), 
            SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment;

        // query
        List<ServiceAppointment> checkServiceAppointmentInJeopardyFlag = [SELECT Id, FSL__InJeopardy__c 
                                                                            FROM ServiceAppointment 
                                                                           WHERE Subject = 'vciServiceAppointmentSubject3' ];
        
        // system.asserts
        System.assertEquals(false, checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c, 'Expected InJeopardyFlag = true, but InJeopardyFlag = ' + checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c);
    }


    @IsTest
    static void testFBIStatusWasNewNowScheduled() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject1' ];

        Test.startTest();
            // Create Assigned Resource:
            AssignedResource vciAssignedResource = new AssignedResource(
                ServiceResourceId = testSvcRsrcList[0].Id, 
                ServiceAppointmentId = testSvcApptList[0].Id
            );
            insert vciAssignedResource;

            // 
            FSL.GlobalAPIS.addStatusTransition('Scheduled', 'New');

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'New';
            }
            update testSvcApptList;

            // 
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Scheduled';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentInJeopardyFlag = [SELECT Id, FSL__InJeopardy__c 
                                                                                FROM ServiceAppointment 
                                                                            WHERE Subject = 'vciServiceAppointmentSubject1' ];
            
            // system.asserts
            System.assertEquals(false, checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c, 'Expected InJeopardyFlag = false, but InJeopardyFlag = ' + checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c);
        Test.stopTest();
    }


    @IsTest
    static void testFBIStatusWasScheduledNowNew() {
        Test.startTest();
            List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
            List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject1' ];

            // Create Assigned Resource:
            AssignedResource vciAssignedResource = new AssignedResource(
                ServiceResourceId = testSvcRsrcList[0].Id, 
                ServiceAppointmentId = testSvcApptList[0].Id
            );
            insert vciAssignedResource;

            // 
            FSL.GlobalAPIS.addStatusTransition('Scheduled', 'New');

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'New';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentInJeopardyFlag = [SELECT Id, FSL__InJeopardy__c 
                                                                                FROM ServiceAppointment 
                                                                            WHERE Subject = 'vciServiceAppointmentSubject1' ];
            
            // system.asserts
            System.assertEquals(true, checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c, 'Expected InJeopardyFlag = true, but InJeopardyFlag = ' + checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c);
        Test.stopTest();
    }


    @IsTest
    static void testFBIStatusWasScheduledNowDispatched() {
		Test.startTest();
            List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
            List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject1' ];
    
            // Create Assigned Resource:
            AssignedResource vciAssignedResource = new AssignedResource(
                ServiceResourceId = testSvcRsrcList[0].Id, 
                ServiceAppointmentId = testSvcApptList[0].Id
            );
            insert vciAssignedResource;
    
            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Dispatched';
            }
            update testSvcApptList;
    
            // query
            List<ServiceAppointment> checkServiceAppointmentInJeopardyFlag = [SELECT Id, FSL__InJeopardy__c 
                                                                                FROM ServiceAppointment 
                                                                               WHERE Subject = 'vciServiceAppointmentSubject1' ];
            
            // system.asserts
            System.assertEquals(false, checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c, 'Expected InJeopardyFlag = false, but InJeopardyFlag = ' + checkServiceAppointmentInJeopardyFlag[0].FSL__InJeopardy__c);
        Test.stopTest();
    }

}