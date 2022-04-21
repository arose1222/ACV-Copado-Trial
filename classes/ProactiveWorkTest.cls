@isTest
public class ProactiveWorkTest {

    @TestSetup
    public static void makeData() {

        OperatingHours vciOperatingHours = new OperatingHours(Name = 'vciTestOpHours');
        insert vciOperatingHours;

        ServiceTerritory parentServiceTerritory = new ServiceTerritory(
            Name = 'Parent Territory',
            OperatingHoursId = vciOperatingHours.Id,
            IsActive = true
            );
        insert parentServiceTerritory;

        ServiceTerritory vciServiceTerritory = new ServiceTerritory(
            Name = 'Greater Buffalo',
            OperatingHoursId = vciOperatingHours.Id,
            ParentTerritoryId = parentServiceTerritory.Id,
            IsActive = true
            );
        insert vciServiceTerritory;

        List<Account> accountList = new List<Account>();
        Account acc = TestUtility.createAccount('TestAccount');
        acc.Dealer_Type__c = '1';
        acc.Active__c = true;
        acc.Service_Territory__c = vciServiceTerritory.Id;
        acc.FSL_Proactive_Work_Beta__c = true;
        accountList.add(acc);
        insert accountList;

        insert FSLTestUtility.createWorkTypes();
        insert FSLTestUtility.createWorkTypeGroups();
        insert FSLTestUtility.createWorkTypeGroupMembers();

        Auction__c auctionRec = new Auction__c(
            Seller_Dealership__c = acc.Id,
            start_time__c = System.now()
        );

        insert auctionRec;
    }


    @isTest
    static void createProactiveWorkSuccess() {

        Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        system.assert(saList.size() == 1, 'Expected 1 service appointment but actual = ' + saList.size());
    }

    @isTest
    static void optOut() {

        Account accountRec = [SELECT Id, Proactive_Work_Opt_Out__c FROM Account LIMIT 1];
        accountRec.Proactive_Work_Opt_Out__c = true;
        update accountRec;

        Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        system.assert(saList.size() == 0, 'Expected 0 service appointments but actual = ' + saList.size());
    }

    @isTest
    static void noListingsWithinRange() {

        delete [SELECT Id FROM Auction__c];

        Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
        system.assert(saList.size() == 0, 'Expected 0 service appointments but actual = ' + saList.size());
    }

    @isTest
    static void pastSAWithinRange() {

        Account accountRec = [SELECT Id FROM Account LIMIT 1];

        ServiceTerritory stRec = [SELECT Id FROM ServiceTerritory WHERE Name = 'Greater Buffalo' LIMIT 1];

        List<WorkOrder> workOrderList = new List<WorkOrder>();

        WorkType inspectionWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection'];

        WorkOrder workOrder = new WorkOrder(
            AccountId = accountRec.Id,
            ServiceTerritoryId = stRec.Id,
            WorkTypeId = inspectionWorkType.Id,
            Status = 'New',
            Priority = 'Low'
        );
        workOrderList.add(workOrder);

        insert workOrderList;

        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();

        for (WorkOrder woLoop : workOrderList) {
            ServiceAppointment serviceAppointment = new ServiceAppointment(
                DueDate = system.today().addDays(21),
                FSL__Pinned__c = FALSE,
                Subject = woLoop.Subject,
                Work_Order__c = woLoop.Id,
                ParentRecordId = woLoop.Id,
                Status = 'Dispatched',
                ServiceTerritoryId = stRec.Id,
                EarliestStartTime = DateTime.now().addDays(-25),
                SchedStartTime = DateTime.now().addDays(1),
                SchedEndTime = DateTime.now().addHours(25),
                ActualEndTime = DateTime.now().addDays(-3),
                Description = '1'
            );
            serviceAppointmentList.add(serviceAppointment);
        }
        insert serviceAppointmentList;


        Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> woList = [SELECT Id FROM WorkOrder WHERE Proactive_Work__c = true];
        system.assert(woList.size() == 0, 'Expected 0 Work Orders but actual = ' + woList.size());
    }

    @isTest
    static void futureSAWithinRange() {

        Account accountRec = [SELECT Id FROM Account LIMIT 1];

        ServiceTerritory stRec = [SELECT Id FROM ServiceTerritory WHERE Name = 'Greater Buffalo' LIMIT 1];

        List<WorkOrder> workOrderList = new List<WorkOrder>();

        WorkType inspectionWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection'];

        WorkOrder workOrder = new WorkOrder(
            AccountId = accountRec.Id,
            ServiceTerritoryId = stRec.Id,
            WorkTypeId = inspectionWorkType.Id,
            Status = 'New',
            Priority = 'Low'
        );
        workOrderList.add(workOrder);

        insert workOrderList;

        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();

        for (WorkOrder woLoop : workOrderList) {
            ServiceAppointment serviceAppointment = new ServiceAppointment(
                DueDate = system.today().addDays(21),
                FSL__Pinned__c = FALSE,
                Subject = woLoop.Subject,
                Work_Order__c = woLoop.Id,
                ParentRecordId = woLoop.Id,
                Status = 'Dispatched',
                ServiceTerritoryId = stRec.Id,
                EarliestStartTime = DateTime.now().addDays(-25),
                SchedStartTime = DateTime.now().addDays(1),
                SchedEndTime = DateTime.now().addHours(25),
                Description = '1'
            );
            serviceAppointmentList.add(serviceAppointment);
        }
        insert serviceAppointmentList;

        Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> woList = [SELECT Id FROM WorkOrder WHERE Proactive_Work__c = true];
        system.assert(woList.size() == 0, 'Expected 0 Work Orders but actual = ' + woList.size());
    }

    @isTest
    static void expireProactiveWork() {
            FSL.GlobalAPIS.addStatusTransition('New', 'Expired');

            Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
            Test.stopTest();

        Account accountRec = [SELECT Id FROM Account LIMIT 1];

        ServiceTerritory stRec = [SELECT Id FROM ServiceTerritory WHERE Name = 'Greater Buffalo' LIMIT 1];

        List<WorkOrder> workOrderList = new List<WorkOrder>();

        WorkType inspectionWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection'];

        WorkOrder workOrder = new WorkOrder(
            AccountId = accountRec.Id,
            ServiceTerritoryId = stRec.Id,
            WorkTypeId = inspectionWorkType.Id,
            Status = 'New',
            Priority = 'Low'
        );
        workOrderList.add(workOrder);

        insert workOrderList;

        List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE Proactive_Work__c = true];
        system.assert(woList.size() == 1, 'Expected 1 Work Orders but actual = ' + woList.size());
        system.assert(woList[0].Status == 'Expired', 'Expected status to be Expired but actual = ' + woList[0].status);
    }

    @isTest
    static void expireProactiveWorkWorkType() {
            FSL.GlobalAPIS.addStatusTransition('New', 'Expired');

            Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
            Test.stopTest();

        Account accountRec = [SELECT Id FROM Account LIMIT 1];

        ServiceTerritory stRec = [SELECT Id FROM ServiceTerritory WHERE Name = 'Greater Buffalo' LIMIT 1];

        List<WorkOrder> workOrderList = new List<WorkOrder>();

        WorkType cpoWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'CPOBM'];

        WorkOrder workOrder = new WorkOrder(
            AccountId = accountRec.Id,
            ServiceTerritoryId = stRec.Id,
            WorkTypeId = cpoWorkType.Id,
            Status = 'New',
            Priority = 'Low'
        );
        workOrderList.add(workOrder);

        insert workOrderList;

        List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE Proactive_Work__c = true];
        system.assert(woList.size() == 1, 'Expected 1 Work Orders but actual = ' + woList.size());
        system.assert(woList[0].Status == 'New', 'Expected status to be New but actual = ' + woList[0].status);
    }

    @isTest
    static void expireProactiveWorkStatus() {
            FSL.GlobalAPIS.addStatusTransition('New', 'Expired');

            Test.startTest();
            ProactiveWorkCreationBatch batch = new ProactiveWorkCreationBatch();
            batch.executeScheduledLogic();
            Test.stopTest();

        FSL.GlobalAPIS.addStatusTransition('New', 'In Progress');
        ServiceAppointment saRec = [SELECT Id, Status FROM ServiceAppointment WHERE Work_Order__c IN (SELECT Id FROM WorkOrder WHERE Proactive_Work__c = true) LIMIT 1];
        saRec.Status = 'In Progress';
        update saRec;

        Account accountRec = [SELECT Id FROM Account LIMIT 1];

        ServiceTerritory stRec = [SELECT Id FROM ServiceTerritory WHERE Name = 'Greater Buffalo' LIMIT 1];

        List<WorkOrder> workOrderList = new List<WorkOrder>();

        WorkType cpoWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'CPOBM'];

        WorkOrder workOrder = new WorkOrder(
            AccountId = accountRec.Id,
            ServiceTerritoryId = stRec.Id,
            WorkTypeId = cpoWorkType.Id,
            Status = 'New',
            Priority = 'Low'
        );
        workOrderList.add(workOrder);

        insert workOrderList;

        List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE Proactive_Work__c = true];
        system.assert(woList.size() == 1, 'Expected 1 Work Orders but actual = ' + woList.size());
        system.assert(woList[0].Status == 'In Progress', 'Expected status to be In Progress but actual = ' + woList[0].status);
    }
}