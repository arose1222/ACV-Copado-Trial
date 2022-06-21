/**
 * Created by icummins on 9/18/2019.
 */
@IsTest
private class trac_AssignedResourceTriggerHandlerTest {

    static final String SENIOR_VEHICLE_CONDITION_INSPECTOR_PERMISSION_SET = 'Senior_VCI';
    static final String ON_HOLD_STATUS = 'On Hold';

    // WorkType Names
    private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
    private final static String TRUE_360 = 'True 360';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<WorkType> wtLst = new List<WorkType>();
        wtLst.add( new workType( Name = INSPECTION, EstimatedDuration = 30 ) );
        wtLst.add( new workType( Name = ASSET, EstimatedDuration = 5 ) );
        wtLst.add( new workType( Name = TRUE_360, EstimatedDuration = 25 ) );
        insert wtLst;

        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory parentST = new ServiceTerritory(
            Name = 'Great Lakes', OperatingHoursId = oh.Id, 
            isActive = TRUE
        );
        insert parentST;

        ServiceTerritory childST = new ServiceTerritory(
            Name = 'Buffalo', OperatingHoursId = oh.Id, 
            isActive = TRUE//, ParentTerritoryId = parentST.Id
        );
        insert childST;
    }

    @IsTest
    static void testInsertAndCreateSubscription() {
        OperatingHours operatingHours = new OperatingHours(Name = 'vciTest');
        insert operatingHours;

        ServiceTerritory serviceTerritory1 = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];

        Account account = TestUtility.createAccount('vciTest');
        insert account;

        WorkOrder workOrder = new WorkOrder(
                AccountId = account.Id, ServiceTerritoryId = serviceTerritory1.Id, Priority = 'Low'
        );
        insert workOrder;

        ServiceResource resource = FSLTestUtility.makeResourceData();

        ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
                ServiceTerritoryId = serviceTerritory1.Id, ServiceResourceId = resource.Id,
                OperatingHoursId = operatingHours.Id, EffectiveStartDate = Date.today(), TerritoryType = 'P');
        insert vciServiceTerritoryMember;

        ServiceAppointment serviceAppointment1 = new ServiceAppointment(
                Description='1', Work_Order__c = workOrder.Id, ParentRecordId = workOrder.Id,
                ServiceTerritoryId = serviceTerritory1.Id, Status='None',
                DueDate = Date.today().addMonths(1), EarliestStartTime = DateTime.now(),
                SchedStartTime = DateTime.now().addHours(1), SchedEndTime = DateTime.now().addHours(12));
        insert serviceAppointment1;

        ServiceAppointment serviceAppointment = [SELECT Id, Work_Order__c FROM ServiceAppointment WHERE Id = :serviceAppointment1.Id];

        Test.startTest();
        AssignedResource assignedResource = new AssignedResource(
                ServiceResourceId = resource.Id, ServiceAppointmentId = serviceAppointment.Id
        );
        insert assignedResource;
        Test.stopTest();

        List<EntitySubscription> subscriptions = [SELECT Id FROM EntitySubscription WHERE ParentId = :serviceAppointment.Work_Order__c];
        System.Debug(subscriptions);
        System.assert(!subscriptions.isEmpty(), 'Subscription was not created');
    }

    @IsTest
    static void testDeleteSubscription() {
        OperatingHours operatingHours = new OperatingHours(Name = 'vciTest');
        insert operatingHours;

        ServiceTerritory serviceTerritory1 = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];

        Account account = TestUtility.createAccount('vciTest');
        insert account;

        WorkOrder workOrder = new WorkOrder(
            AccountId = account.Id, ServiceTerritoryId = serviceTerritory1.Id, Priority = 'Low'
        );
        insert workOrder;
        
        ServiceResource resource = FSLTestUtility.makeResourceData();
        
        Test.startTest();
            ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
                    ServiceTerritoryId = serviceTerritory1.Id, ServiceResourceId = resource.Id,
                    OperatingHoursId = operatingHours.Id, EffectiveStartDate = Date.today(), TerritoryType = 'P');
            insert vciServiceTerritoryMember;
    
            ServiceAppointment serviceAppointment1 = new ServiceAppointment(
                    Description='1', Work_Order__c = workOrder.Id, ParentRecordId = workOrder.Id,
                    ServiceTerritoryId = serviceTerritory1.Id, Status='None',
                    DueDate = Date.today().addMonths(1), EarliestStartTime = DateTime.now(),
                    SchedStartTime = DateTime.now().addHours(1), SchedEndTime = DateTime.now().addHours(12));
            insert serviceAppointment1;
    
            ServiceAppointment serviceAppointment = [SELECT Id, Work_Order__c FROM ServiceAppointment WHERE Id = :serviceAppointment1.Id];
    
            AssignedResource assignedResource = new AssignedResource(
                    ServiceResourceId = resource.Id, ServiceAppointmentId = serviceAppointment.Id
            );
            insert assignedResource;
    
            delete assignedResource;
        Test.stopTest();

        List<EntitySubscription> subscriptions = [ SELECT Id FROM EntitySubscription WHERE ParentId = :serviceAppointment.Work_Order__c];
        System.assert(subscriptions.isEmpty(), 'Subscription was not deleted');

    }

}