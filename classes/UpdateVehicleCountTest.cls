@isTest
public class UpdateVehicleCountTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        // Create Account (needed for Work Order):
        Account acc = TestUtility.createAccount('TestAccount');
        insert acc;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        List<String> workTypesToProcess = new List<String>{'inspection', 'true360', 'siriusxm', 'verification'};
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

        //Set DueDate for all Service Appointments to a time within the retrieval window
        List<ServiceAppointment> saList = [SELECT Id, DueDate FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            sa.DueDate = system.now().addDays(1);
        }
        update saList;



    }

    @isTest
    static void testWorkType() {

        Id accId = [SELECT Id FROM Account LIMIT 1]?.Id;

        test.startTest();
        List<ServiceAppointment> retrievedSAList = UpdateVehicleCountFromAccountController.getEligibleServiceAppointments(accId);
        test.stopTest();

        //Assert that only the Service Appointments with a work type of 'inspection', 'true360', 'siriusxm' are returned
        system.assert(retrievedSAList.size() == 3, 'Expected to retrieve 3 but retrieved ' + retrievedSAList.size());

    }

    @isTest
    static void testStatus() {
        FSL.GlobalAPIS.addStatusTransition('New', 'Arrived');
        //Set Status all service appointments to Arrived
        List<ServiceAppointment> saList = [SELECT Id, Status FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            sa.Status = 'Arrived';
        }
        update saList;

        Id accId = [SELECT Id FROM Account LIMIT 1]?.Id;

        test.startTest();
        List<ServiceAppointment> retrievedSAList = UpdateVehicleCountFromAccountController.getEligibleServiceAppointments(accId);
        test.stopTest();

        //Assert that no Service Appointments are returned
        system.assert(retrievedSAList.size() == 0, 'Expected to retrieve 0 but retrieved ' + retrievedSAList.size());

    }

    @isTest
    static void testDueDateInPast() {
        FSL.GlobalAPIS.addStatusTransition('New', 'Arrived');
        //Set Status all service appointments to Arrived
        List<ServiceAppointment> saList = [SELECT Id, DueDate, EarliestStartTime FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            sa.DueDate = system.now().addDays(-1);
            sa.EarliestStartTime = system.now().addDays(-2);
        }
        update saList;

        Id accId = [SELECT Id FROM Account LIMIT 1]?.Id;

        test.startTest();
        List<ServiceAppointment> retrievedSAList = UpdateVehicleCountFromAccountController.getEligibleServiceAppointments(accId);
        test.stopTest();

        //Assert that no Service Appointments are returned
        system.assert(retrievedSAList.size() == 0, 'Expected to retrieve 0 but retrieved ' + retrievedSAList.size());

    }

    @isTest
    static void testDueDateFutureMoreThanFour() {
        FSL.GlobalAPIS.addStatusTransition('New', 'Arrived');
        //Set Status all service appointments to Arrived
        List<ServiceAppointment> saList = [SELECT Id, DueDate FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            sa.DueDate = system.now().addDays(5);
        }
        update saList;

        Id accId = [SELECT Id FROM Account LIMIT 1]?.Id;

        test.startTest();
        List<ServiceAppointment> retrievedSAList = UpdateVehicleCountFromAccountController.getEligibleServiceAppointments(accId);
        test.stopTest();

        //Assert that no Service Appointments are returned
        system.assert(retrievedSAList.size() == 0, 'Expected to retrieve 0 but retrieved ' + retrievedSAList.size());

    }
}