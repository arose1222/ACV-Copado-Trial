@isTest
public class UpdateArbSpecialInstructionsTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

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
    }

    @isTest
    static void successfulUpdate() {

        FSL_Import_Manager_Special_Instructions__mdt imsiRec = [SELECT User_Id__c FROM FSL_Import_Manager_Special_Instructions__mdt WHERE Active__c = true LIMIT 1];
        User userWithRule = [SELECT Id FROM User WHERE Id = :imsiRec.User_Id__c];

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

        system.runAs(userWithRule){
            insert workOrder;


            WorkOrderLineItem woli = new WorkOrderLineItem(
                WorkTypeId = inspectionWorkType.Id,
                WorkOrderId = workOrder.Id,
                Description = 'Test Description'
            );


            insert woli;
        }


        WorkOrder updatedWorkOrder = [SELECT Id, Special_Instructions__c FROM WorkOrder WHERE Id = :workOrder.Id];
        system.assert(updatedWorkOrder.Special_Instructions__c == 'Test Description');
    }

    @isTest
    static void doNotUpdate() {

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
        insert workOrder;


        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkTypeId = inspectionWorkType.Id,
            WorkOrderId = workOrder.Id,
            Description = 'Test Description'
        );

        insert woli;


        WorkOrder updatedWorkOrder = [SELECT Id, Special_Instructions__c FROM WorkOrder WHERE Id = :workOrder.Id];
        system.assert(String.isBlank(updatedWorkOrder.Special_Instructions__c));
    }

}