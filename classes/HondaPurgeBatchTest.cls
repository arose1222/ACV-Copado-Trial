/**
 * @description Test class for HondaPurgeBatch that creates work orders, service appointments, and work order line items and tests to make sure that after purging records, expected results occur 
 * @author Adam Richbart
 * @since 03/18/2022
 * @group Inspector Dispatch
 */
@isTest
public class HondaPurgeBatchTest {

    public static Integer RECORD_COUNT = 10;

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        Account acc = TestUtility.createAccount('TestAccount');
        acc.Dealership_Id__c = HondaPurgeBatch.HONDA_DEALER_ID;
        insert acc;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo' , '14209' );

        WorkType dealerWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'dealer'];

        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> workOrderList = new List<WorkOrder>();

        for (Integer i = 0, j = 0; i < RECORD_COUNT; i++) {
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

    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-541
     */
    @isTest
    static void testCancelAndSeparateAllRecords(){
        String HONDA_DEALER_ID = HondaPurgeBatch.HONDA_DEALER_ID;
        DateTime DATE_NUMDAYSOUT = HondaPurgeBatch.DATE_NUMDAYSOUT;

        List<WorkOrder> woList = Database.query(HondaPurgeBatch.QUERY);
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        
        HondaPurgeBatch.cancelAndSeparateAllRecords(saList, woliList, woList);

        Boolean allRecordsCanceled = true;
        for(ServiceAppointment sa : saList){
            if(sa.Status != 'Canceled'){
                allRecordsCanceled = false;
                break;
            }
        }

        if(allRecordsCanceled) {
            for(WorkOrder wo : woList) {
                if(wo.Status != 'Canceled') {
                    allRecordsCanceled = false;
                    break;
                }
            }
        }
        
        if(allRecordsCanceled){
            for(WorkOrderLineItem woli : woliList){
                if(woli.Status != 'Canceled'){
                    allRecordsCanceled = false;
                    break;
                }
            }
        }

        System.assertEquals(RECORD_COUNT, saList.size(), 'There was an incorrect number of service appointments in the returned list');
        System.assertEquals(RECORD_COUNT, woList.size(), 'There was an incorrect number of work orders in the returned list');
        System.assertEquals(RECORD_COUNT, woliList.size(), 'There was an incorrect number of work order line items in the returned list');
        System.assert(allRecordsCanceled, 'Not all records were in a status of Canceled');
    }

    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-541
     */
    @isTest
    static void testStoreSaveResults() {
        BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

        string query = 'SELECT Id, Status FROM WorkOrder LIMIT 2';
        List<WorkOrder> woList = Database.query(query);

        Database.SaveResult[] mockSaveResults = new Database.SaveResult[] {
            (Database.SaveResult) JSON.deserialize('{"success":true,"id":"' + woList[0].id + '"}', Database.SaveResult.class),
            (Database.SaveResult) JSON.deserialize('{"success":false, "id":"' + woList[1].id + '", "errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class)
        };

        HondaPurgeBatch.storeSaveResults(returnInfo, mockSaveResults, woList);

        System.assertEquals(1, returnInfo.successfulReturnSet.size(), 'Successful return set did not have exactly 1 successful save result record');
        System.assertEquals(1, returnInfo.errorReturnLst.size(), 'Error return list did not have exactly 1 error save result record');
    }
    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-541
     */
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

    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-526
     */
    @isTest
    static void excludeByServiceApptStatus() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        List<ServiceAppointment> saList = [SELECT Id, Status, ServiceTerritoryId FROM ServiceAppointment LIMIT 2];
        
        saList[0].Status = 'In Progress';
        saList[1].Status = 'In Progress';
        saList[0].SchedStartTime = DateTime.now();
        saList[1].SchedStartTime = DateTime.now();
        saList[0].SchedEndTime = DateTime.now().addMinutes( 30 );
        saList[1].SchedEndTime = DateTime.now().addMinutes( 30 );
        update saList;

        saList[0].Status = 'Completed';
        saList[1].Status = 'Completed';
        saList[0].ActualStartTime = DateTime.now().addMinutes(-20);
        saList[1].ActualStartTime = DateTime.now().addMinutes(-20);
        saList[0].ActualEndTime = DateTime.now();
        saList[1].ActualEndTime = DateTime.now();
        update saList;

        String HONDA_DEALER_ID = HondaPurgeBatch.HONDA_DEALER_ID;
        DateTime DATE_NUMDAYSOUT = HondaPurgeBatch.DATE_NUMDAYSOUT;

        List<WorkOrder> woList = Database.query(HondaPurgeBatch.QUERY);
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();

        HondaPurgeBatch.cancelAndSeparateAllRecords(saList, woliList, woList);

        Integer numberOfCanceledWorkOrders = 0;
        Integer numberOfCanceledServiceAppointments = 0;
        Integer numberOfCanceledWorkOrderLineItems = 0;

        for(WorkOrder wo : woList) {
            if(wo.Status == 'Canceled') {
                numberOfCanceledWorkOrders++;
            }
        }

        for(ServiceAppointment sa : saList) {
            if(sa.Status == 'Canceled') {
                numberOfCanceledServiceAppointments++;
            }
        }

        for(WorkOrderLineItem woli : woliList) {
            if(woli.Status == 'Canceled') {
                numberOfCanceledWorkOrderLineItems++;
            }
        }

        System.assertEquals(8, numberOfCanceledWorkOrders, 'Expected 8 canceled work orders but retrieved ' + numberOfCanceledWorkOrders);
        System.assertEquals(8, numberOfCanceledServiceAppointments, 'Expected 8 canceled service appointments but retrieved ' + numberOfCanceledServiceAppointments);
        System.assertEquals(8, numberOfCanceledWorkOrderLineItems, 'Expected 8 canceled work order line items but retrieved ' + numberOfCanceledWorkOrderLineItems);
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