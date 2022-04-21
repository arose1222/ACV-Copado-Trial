@isTest
public class UpdateWOLIStatusFromServiceApptTest {

    @TestSetup
    public static void makeData() {


        // Create Account (needed for Work Order):
        Account acc = TestUtility.createAccount('TestAccount');
        insert acc;

        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );

        List<String> workTypesToProcess = new List<String>{'dealer', 'inspection'};
        ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        List<WorkType> workTypeList = [SELECT Id, Work_Type_Unique_ID__c, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c IN :workTypesToProcess];

        // Create Work Order (needed for Service Appointment):
        List<WorkOrder> workOrderList = new List<WorkOrder>();

        for (WorkType wtLoop : workTypeList) {
            WorkOrder workOrder = new WorkOrder(
                AccountId = acc.Id,
                ServiceTerritoryId = serviceTerritory.Id,
                WorkTypeId = wtLoop.Id,
                Subject = wtLoop.Work_Type_Unique_ID__c,
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
            workOrderLineItemList.add(FSLTestUtility.createWorkOrderLineItem( woLoop, workTypeList[0], 1));
        }
        insert serviceAppointmentList;
        insert workOrderLineItemList;

    }

    @isTest
    static void aSIWoliIsUpdated() {
        test.startTest();
        ServiceAppointment sa = [SELECT Id, Status, Work_Order__c FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c = 'dealer' LIMIT 1];
        WorkOrderLineItem woliPreUpdate = [SELECT Id, Status FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPreUpdate.Status == 'New');

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );
        sa.Status = 'Canceled';
        update sa;

        WorkOrderLineItem woliPostUpdate = [SELECT Id, Status FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPostUpdate.Status == 'Canceled');
        test.stopTest();

    }

    @isTest
    static void nonASIWoliIsNotUpdated() {

        test.startTest();
        ServiceAppointment sa = [SELECT Id, Status, Work_Order__c FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        WorkOrderLineItem woliPreUpdate = [SELECT Id, Status FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPreUpdate.Status == 'New');

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );
        sa.Status = 'Canceled';
        update sa;

        WorkOrderLineItem woliPostUpdate = [SELECT Id, Status FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPostUpdate.Status == 'New');
        test.stopTest();
    }

    @isTest
    static void aSIWoliDatesUpdated() {
        test.startTest();
        DateTime earliestStart = system.now().addDays(10);
        DateTime dueDate = system.now().addDays(20);
        ServiceAppointment sa = [SELECT Id, Status, Work_Order__c, EarliestStartTime, DueDate FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c = 'dealer' LIMIT 1];
        WorkOrderLineItem woliPreUpdate = [SELECT Id, Status, Earliest_Start_Date__c, Due_Date__c  FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPreUpdate.Earliest_Start_Date__c != earliestStart.date());
        system.assert(woliPreUpdate.Due_Date__c != dueDate.date());


        sa.EarliestStartTime = earliestStart;
        sa.DueDate = dueDate;
        update sa;
        test.stopTest();

        WorkOrderLineItem woliPostUpdate = [SELECT Id, Status, Due_Date__c, Earliest_Start_Date__c FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPostUpdate.Earliest_Start_Date__c == earliestStart.date());
        system.assert(woliPostUpdate.Due_Date__c == dueDate.date());

    }

    @isTest
    static void nonASIWoliDatesNotUpdated() {
        test.startTest();
        DateTime earliestStart = system.now().addDays(10);
        DateTime dueDate = system.now().addDays(20);
        ServiceAppointment sa = [SELECT Id, Status, Work_Order__c, EarliestStartTime, DueDate FROM ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        WorkOrderLineItem woliPreUpdate = [SELECT Id, Status, Earliest_Start_Date__c, Due_Date__c  FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPreUpdate.Earliest_Start_Date__c != earliestStart.date());
        system.assert(woliPreUpdate.Due_Date__c != dueDate.date());


        sa.EarliestStartTime = earliestStart;
        sa.DueDate = dueDate;
        update sa;
        test.stopTest();

        WorkOrderLineItem woliPostUpdate = [SELECT Id, Status, Due_Date__c, Earliest_Start_Date__c FROM WorkOrderLineItem WHERE workOrderId = :sa.Work_Order__c LIMIT 1];
        system.assert(woliPostUpdate.Earliest_Start_Date__c != earliestStart.date());
        system.assert(woliPostUpdate.Due_Date__c != dueDate.date());

    }
}