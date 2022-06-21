@isTest
public class ServiceAppointmentFeedTriggerHandlerTest {

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

        ServiceResource servResource = FSLTestUtility.makeResourceData();

        FSL.GlobalAPIS.addStatusTransition('New', 'Dispatched');
        List<ServiceAppointment> serviceApptList = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment];
        for(ServiceAppointment sa : serviceApptList){
            sa.Current_Service_Resource__c = servResource.Id;
            sa.Status = 'Dispatched';
            sa.SchedStartTime = DateTime.now().addDays(1);
            sa.SchedEndTime = DateTime.now().addHours(25);
        }
        update serviceApptList;
    }

    @isTest
    static void removeCurrentSeviceResource() {
        ServiceAppointment sa = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment LIMIT 1];
        system.assert(sa.Current_Service_Resource__c  != null);

        FSL.GlobalAPIS.addStatusTransition('Dispatched', 'New');
        test.startTest();
        sa.Status = 'New';
        update sa;
        test.stopTest();

        ServiceAppointment saPostUpdate = [SELECT Id, Current_Service_Resource__c FROM ServiceAppointment WHERE Id = :sa.Id LIMIT 1];
        system.assert(saPostUpdate.Current_Service_Resource__c == null);

    }

    @isTest
    static void confirmEntitySubCreation() {
        ServiceAppointment sa = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment LIMIT 1];
        List<EntitySubscription> entSubList = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
        system.assert(entSubList.size() == 1);
    }

    @isTest
    static void statusChangeFromDispatched() {
        ServiceAppointment sa = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment LIMIT 1];
        List<EntitySubscription> entSubList = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
        system.assert(entSubList.size() == 1);

        FSL.GlobalAPIS.addStatusTransition('Dispatched', 'New');
        test.startTest();
        sa.Status = 'New';
        update sa;
        test.stopTest();

        List<EntitySubscription> entSubPostUpdate = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
        system.assert(entSubPostUpdate.size() == 0);

    }

    @isTest
    static void removeCurrentServiceResource() {
        ServiceAppointment sa = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment LIMIT 1];
        List<EntitySubscription> entSubList = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
        system.assert(entSubList.size() == 1);

        test.startTest();
        sa.Current_Service_Resource__c = null;
        update sa;
        test.stopTest();

        List<EntitySubscription> entSubPostUpdate = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
        system.assert(entSubPostUpdate.size() == 0);

    }

    @isTest
    static void changeCurrentServiceResource() {
        Test.startTest();
            ServiceAppointment sa = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment LIMIT 1];
            List<EntitySubscription> entSubList = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
            system.assert(entSubList.size() == 1);
    
            ServiceResource servResource2 = FSLTestUtility.makeResourceData();
    
            
            sa.Current_Service_Resource__c = servResource2.Id;
            update sa;
        Test.stopTest();

        List<EntitySubscription> entSubPostUpdate = [SELECT Id FROM EntitySubscription WHERE ParentId = :sa.Id];
        system.assert(entSubPostUpdate.size() == 1);

    }
}