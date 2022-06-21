@isTest
public class ServiceAppointmentUnpinAndCommitTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        // Create Account (needed for Work Order):
        Account acc = TestUtility.createAccount('TestAccount');
        insert acc;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        List<String> workTypesToProcess = new List<String>{'inspection'};
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

    }


    @isTest
    static void pinSA() {
        ServiceAppointment sa = [SELECT Id, FSL__Pinned__c FROM ServiceAppointment LIMIT 1];

        test.startTest();
        sa.FSL__Pinned__c = true;
        update sa;
        test.stopTest();

        ServiceAppointment saPostUpdate = [SELECT Id, FSL__Pinned__c, Committed__c FROM ServiceAppointment WHERE Id = :sa.Id LIMIT 1];
        system.assert(saPostUpdate.FSL__Pinned__c == false);
        system.assert(saPostUpdate.Committed__c == true);
    }
}