@isTest
public class ResourcePrefsAccountToWorkOrderTest {

    @TestSetup
    public static void makeData() {

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

        ServiceResource sr = FSLTestUtility.makeResourceData();

        insert FSLTestUtility.createPreference('Preferred', sr.Id, acc.Id);
    }

    @isTest
    static void insertToAllWorkOrders() {
        for(WorkOrder wo : [SELECT Id, (SELECT Id FROM ResourcePreferences) FROM WorkOrder]){
            system.assert(wo.ResourcePreferences.size() == 1);
        }
    }

    @isTest
    static void updateToAllWorkOrders() {
        Account acc = [SELECT Id, (SELECT Id FROM ResourcePreferences LIMIT 1) FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        acc.ResourcePreferences[0].PreferenceType = 'Required';

        test.startTest();
        update acc.ResourcePreferences;
        test.stopTest();

        for(WorkOrder wo : [SELECT Id, (SELECT Id, PreferenceType FROM ResourcePreferences) FROM WorkOrder]){
            system.assert(wo.ResourcePreferences[0].PreferenceType == 'Required');
        }
    }

    @isTest
    static void deleteToAllWorkOrders() {
        Account acc = [SELECT Id, (SELECT Id FROM ResourcePreferences LIMIT 1) FROM Account WHERE Name = 'TestAccount' LIMIT 1];

        test.startTest();
        delete acc.ResourcePreferences;
        test.stopTest();

        for(WorkOrder wo : [SELECT Id, (SELECT Id, PreferenceType FROM ResourcePreferences) FROM WorkOrder]){
            system.assert(wo.ResourcePreferences.size() == 0);
        }

    }

    @isTest
    static void doNotUpdateByStatus() {
        FSL.GlobalAPIS.addStatusTransition('New', 'Expired');
        List<ServiceAppointment> saToUpdateList = [SELECT Id, Status FROM ServiceAppointment];
        for(ServiceAppointment sa : saToUpdateList){
            sa.Status = 'Expired';
        }
        update saToUpdateList;

        Account acc = [SELECT Id, (SELECT Id FROM ResourcePreferences LIMIT 1) FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        acc.ResourcePreferences[0].PreferenceType = 'Required';

        test.startTest();
        update acc.ResourcePreferences;
        test.stopTest();

        for(WorkOrder wo : [SELECT Id, (SELECT Id, PreferenceType FROM ResourcePreferences) FROM WorkOrder]){
            system.assert(wo.ResourcePreferences[0].PreferenceType == 'Preferred');
        }
    }
}