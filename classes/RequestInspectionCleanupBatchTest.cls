@isTest
public class RequestInspectionCleanupBatchTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        Account acc = TestUtility.createAccount('TestAccount');
        insert acc;

        List<WorkType> workTypeList = FSLTestUtility.createWorkTypes();
        insert workTypeList;

        List<WorkOrder> workOrderList = new List<WorkOrder>();

        for(WorkType workType : [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' OR Work_Type_Unique_ID__c = 'true360' OR Work_Type_Unique_ID__c = 'siriusxm' OR Work_Type_Unique_ID__c = 'buyer signup']) {
            WorkOrder workOrder = new WorkOrder(
                AccountId = acc.Id,
                WorkTypeId = workType.Id,
                Status = 'New',
                Priority = 'Low',
                Processing_Offers__c = true
            );
            workOrderList.add(workOrder);
        }
        insert workOrderList;

        for(WorkOrder insertedWorkOrder : workOrderList){
            test.setCreatedDate(insertedWorkOrder.Id, system.now().addDays(-1));
        }
    }

    @isTest
    static void testProcessOffersTrue() {

        List<WorkOrder> insertedWOList = [SELECT Id FROM WorkOrder];
        system.assert(insertedWOList.size() == 4, 'Expected 4 work orders, actual = ' + insertedWOList.size());

        Test.startTest();
            RequestInspectionCleanupBatch batch = new RequestInspectionCleanupBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> updatedWOList = [SELECT Id, WorkType.Work_Type_Unique_ID__c FROM WorkOrder];
        system.assert(updatedWOList.size() == 1, 'Expected 1 work order, actual = ' + updatedWOList.size());
        system.assert(updatedWOList[0].WorkType.Work_Type_Unique_ID__c == 'buyer signup', 'Expected buyer signup, actual = ' + updatedWOList[0].WorkType.Work_Type_Unique_ID__c);
    }

    @isTest
    static void testProcessOffersFalse() {

        List<WorkOrder> insertedWOList = [SELECT Id, WorkType.Work_Type_Unique_ID__c FROM WorkOrder];
        for(WorkOrder woRec : insertedWOList){
            woRec.Processing_Offers__c = false;
        }
        update insertedWOList;

        Test.startTest();
            RequestInspectionCleanupBatch batch = new RequestInspectionCleanupBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> updatedWOList = [SELECT Id, WorkType.Work_Type_Unique_ID__c FROM WorkOrder];
        system.assert(updatedWOList.size() == 4, 'Expected 4 work orders, actual = ' + updatedWOList.size());
    }

    @isTest
    static void testCreatedDateNow() {

        List<WorkOrder> insertedWOList = [SELECT Id, WorkType.Work_Type_Unique_ID__c FROM WorkOrder];
        for(WorkOrder woRec : insertedWOList){
            test.setCreatedDate(woRec.Id, system.now());
        }

        Test.startTest();
            RequestInspectionCleanupBatch batch = new RequestInspectionCleanupBatch();
            batch.executeScheduledLogic();
        Test.stopTest();

        List<WorkOrder> updatedWOList = [SELECT Id, WorkType.Work_Type_Unique_ID__c FROM WorkOrder];
        system.assert(updatedWOList.size() == 4, 'Expected 4 work orders, actual = ' + updatedWOList.size());
    }
}