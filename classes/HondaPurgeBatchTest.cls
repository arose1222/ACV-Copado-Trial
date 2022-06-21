@isTest
public class HondaPurgeBatchTest {

    @TestSetup
    public static void makeData() {

        Account acc = TestUtility.createAccount('TestAccount');
        acc.Dealership_Id__c = HondaPurgeBatch.HONDA_DEALER_ID;
        insert acc;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo' , '14209' );

        WorkType dealerWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'dealer'];

        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> workOrderList = new List<WorkOrder>();

        for (Integer i = 0, j = 0; i < 10; i++) {
            WorkOrder workOrder = new WorkOrder(
                AccountId = acc.Id,
                ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id,
                WorkTypeId = dealerWorkType.Id,
                Status = 'New',
                Priority = 'Low'
            );
            workOrderList.add(workOrder);
        }
        insert workOrderList;

        // Create Service Appointments:
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        List<WorkOrderLineItem> workOrderLineItemList = new List<WorkOrderLineItem>();

        for (WorkOrder woLoop : workOrderList) {
            ServiceAppointment serviceAppointment = new ServiceAppointment(
                DueDate = system.today().addDays(21),
                FSL__Pinned__c = FALSE,
                Subject = woLoop.Subject,
                Work_Order__c = woLoop.Id,
                ParentRecordId = woLoop.Id,
                Status = 'Dispatched',
                ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id,
                EarliestStartTime = DateTime.now().addDays(-25),
                SchedStartTime = DateTime.now().addDays(1),
                SchedEndTime = DateTime.now().addHours(25),
                Description = '1'
            );
            serviceAppointmentList.add(serviceAppointment);

            workOrderLineItemList.add(FSLTestUtility.createWorkOrderLineItem( woLoop, dealerWorkType, 1));
        }
        insert serviceAppointmentList;
        insert workOrderLineItemList;

        for ( ServiceAppointment saList : serviceAppointmentList ) {
            Test.setCreatedDate( saList.Id, DateTime.now().addDays( -7 ) );
        }
    }


    @isTest
    static void runBatch() {

        // run batch
        Test.startTest();
            HondaPurgeBatch batch = new HondaPurgeBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> retrievedWorkOrders = [SELECT Id FROM WorkOrder WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrders.size() == 10, 'Expected 10 canceled work orders, but retrieved ' + retrievedWorkOrders.size());

        List<ServiceAppointment> retrievedServiceAppointments = [SELECT Id FROM ServiceAppointment WHERE Status = 'Canceled'];
        system.assert(retrievedServiceAppointments.size() == 10, 'Expected 10 canceled service appointments, but retrieved ' + retrievedServiceAppointments.size());

        List<WorkOrderLineItem> retrievedWorkOrderLineItems = [SELECT Id FROM WorkOrderLineItem WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrderLineItems.size() == 10, 'Expected 10 canceled work orders, but retrieved ' + retrievedWorkOrderLineItems.size());
    }

    @isTest
    static void mustBeTenOrMoreDays() {

        Test.startTest();
            List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, SchedStartTime FROM ServiceAppointment];
            // Need to adjust Scheduled Start Times or else the Earliest Start Time adjustment will auto-clear the record's Scheduled Start Time & Scheduled End Time due to AdjustedDatesOnSA Logic
            //These should not be canceled
            saList[0].EarliestStartTime = system.today().addDays(-4);
            saList[0].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[1].EarliestStartTime = system.today().addDays(-5);
            saList[1].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[2].EarliestStartTime = system.today().addDays(-6);
            saList[2].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[3].EarliestStartTime = system.today().addDays(-7);
            saList[3].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[4].EarliestStartTime = system.today().addDays(-8);
            saList[4].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[5].EarliestStartTime = system.today().addDays(-9);
            saList[5].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            //These should be canceled
            saList[6].EarliestStartTime = system.today().addDays(-10);
            saList[6].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[7].EarliestStartTime = system.today().addDays(-11);
            saList[7].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[8].EarliestStartTime = system.today().addDays(-12);
            saList[8].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);
            saList[9].EarliestStartTime = system.today().addDays(-13);
            saList[9].SchedStartTime = saList[0].SchedStartTime.addMinutes(1);

            update saList;

            // run batch
            HondaPurgeBatch batch = new HondaPurgeBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> retrievedWorkOrders = [SELECT Id FROM WorkOrder WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrders.size() == 4, 'Expected 4 canceled work orders, but retrieved ' + retrievedWorkOrders.size());

        List<ServiceAppointment> retrievedServiceAppointments = [SELECT Id FROM ServiceAppointment WHERE Status = 'Canceled'];
        system.assert(retrievedServiceAppointments.size() == 4, 'Expected 4 canceled service appointments, but retrieved ' + retrievedServiceAppointments.size());

        List<WorkOrderLineItem> retrievedWorkOrderLineItems = [SELECT Id FROM WorkOrderLineItem WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrderLineItems.size() == 4, 'Expected 4 canceled work orders, but retrieved ' + retrievedWorkOrderLineItems.size());
    }

    @isTest
    static void mustBeHonda() {

        Test.startTest();
            Account acc = [SELECT Id, Dealership_Id__c FROM Account WHERE Name = 'TestAccount' LIMIT 1];
            acc.Dealership_Id__c = '-12345';
            update acc;

            // run batch
            HondaPurgeBatch batch = new HondaPurgeBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> retrievedWorkOrders = [SELECT Id FROM WorkOrder WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrders.size() == 0, 'Expected 0 canceled work orders, but retrieved ' + retrievedWorkOrders.size());

        List<ServiceAppointment> retrievedServiceAppointments = [SELECT Id FROM ServiceAppointment WHERE Status = 'Canceled'];
        system.assert(retrievedServiceAppointments.size() == 0, 'Expected 0 canceled service appointments, but retrieved ' + retrievedServiceAppointments.size());

        List<WorkOrderLineItem> retrievedWorkOrderLineItems = [SELECT Id FROM WorkOrderLineItem WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrderLineItems.size() == 0, 'Expected 0 canceled work orders, but retrieved ' + retrievedWorkOrderLineItems.size());
    }

    @isTest
    static void mustBeDealerWorkType() {

        Test.startTest();
        
            Id nonDealerWorkTypeId = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection'].Id;
            WorkOrder wo = [SELECT Id, WorkTypeId FROM WorkOrder LIMIT 1];
            wo.WorkTypeId = nonDealerWorkTypeId;
            update wo;

            // run batch
            HondaPurgeBatch batch = new HondaPurgeBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> retrievedWorkOrders = [SELECT Id FROM WorkOrder WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrders.size() == 9, 'Expected 9 canceled work orders, but retrieved ' + retrievedWorkOrders.size());

        List<ServiceAppointment> retrievedServiceAppointments = [SELECT Id FROM ServiceAppointment WHERE Status = 'Canceled'];
        system.assert(retrievedServiceAppointments.size() == 9, 'Expected 9 canceled service appointments, but retrieved ' + retrievedServiceAppointments.size());

        List<WorkOrderLineItem> retrievedWorkOrderLineItems = [SELECT Id FROM WorkOrderLineItem WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrderLineItems.size() == 9, 'Expected 9 canceled work orders, but retrieved ' + retrievedWorkOrderLineItems.size());
    }

    @isTest
    static void excludeByServiceApptStatus() {
        //Service Appointments must not be in status of Completed or Expired
        List<ServiceAppointment> saList = [SELECT Id, Status, ServiceTerritoryId FROM ServiceAppointment];

        Test.startTest();
            //These should not be canceled
            saList[0].Status = 'In Progress';
            saList[1].Status = 'In Progress';
            saList[0].SchedStartTime = DateTime.now();
            saList[1].SchedStartTime = DateTime.now();
            saList[0].SchedEndTime = DateTime.now().addMinutes( 30 );
            saList[1].SchedEndTime = DateTime.now().addMinutes( 30 );
            update saList;
        
            ServiceResource vciServiceResource = FSLTestUtility.makeResourceData();
    
        	OperatingHours vciOperatingHours = [ SELECT Id from OperatingHours LIMIT 1 ];
        	ServiceTerritory vciServiceTerritory = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        
            // Create Service Territory Member:
            ServiceTerritoryMember stm = new ServiceTerritoryMember(
                OperatingHoursId = vciOperatingHours.Id,
                ServiceTerritoryId = vciServiceTerritory.Id,
                ServiceResourceId = vciServiceResource.Id,
                EffectiveStartDate = Date.today(),
                TerritoryType = 'P'
            );
            insert stm;

            List<AssignedResource> arLst = new List<AssignedResource>();
            for ( Integer index = 0; index < 2; index++ ) {
                ServiceAppointment sa = saList[index];
                arLst.add( new AssignedResource(
                    ServiceAppointmentId = sa.Id,
                    ServiceResourceId = stm.ServiceResourceId
                ) );
            }  
            insert arLst;   

            saList[0].Status = 'Completed';
            saList[1].Status = 'Completed';
            saList[0].ActualStartTime = DateTime.now().addMinutes(-20);
            saList[1].ActualStartTime = DateTime.now().addMinutes(-20);
            saList[0].ActualEndTime = DateTime.now();
            saList[1].ActualEndTime = DateTime.now();
            update saList;

             // run batch
            HondaPurgeBatch batch = new HondaPurgeBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> retrievedWorkOrders = [SELECT Id FROM WorkOrder WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrders.size() == 8, 'Expected 8 canceled work orders, but retrieved ' + retrievedWorkOrders.size());

        List<ServiceAppointment> retrievedServiceAppointments = [SELECT Id FROM ServiceAppointment WHERE Status = 'Canceled'];
        system.assert(retrievedServiceAppointments.size() == 8, 'Expected 8 canceled service appointments, but retrieved ' + retrievedServiceAppointments.size());

        List<WorkOrderLineItem> retrievedWorkOrderLineItems = [SELECT Id FROM WorkOrderLineItem WHERE Status = 'Canceled'];
        system.assert(retrievedWorkOrderLineItems.size() == 8, 'Expected 8 canceled work orders, but retrieved ' + retrievedWorkOrderLineItems.size());
    }


    @isTest
    static void runErrorBatch() {

        Test.startTest();
            HondaPurgeBatch batch = new HondaPurgeBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();
        Test.stopTest();
    }
}