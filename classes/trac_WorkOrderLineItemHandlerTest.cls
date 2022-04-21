/**
 * Created by icummins on 9/19/2019.
 */

@IsTest
private class trac_WorkOrderLineItemHandlerTest {

    @TestSetup
    static void setup() {
        Account acct = TestUtility.createAccount('vciTest');
        acct.Dealer_Type__c = '5';
        insert acct;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo' , '14209' );
        ServiceTerritory ServiceTerritory1 = [ SELECT Id, OperatingHoursId FROM ServiceTerritory LIMIT 1 ];
        WorkType workType =[ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        WorkOrder workOrder = new WorkOrder(
                AccountId = acct.Id, ServiceTerritoryId = serviceTerritory1.Id, Priority = 'Low',
                Status = 'New',
                WorkTypeId = workType.Id,
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US'
        );
        insert workOrder;

        List<String> profiles = new List<String>{trac_AssignedResourceValidationHelper.VEHICLE_CONDITION_INSPECTOR_PROFILE,'System Administrator'};
        List<Profile> vciProfiles = new List<Profile>([SELECT Id,Name FROM Profile WHERE Name in :profiles]);
        Id systemAdministratorProfileId;
        Id vehicleConditionInspectorProfileId;

        for(Profile profile : vciProfiles) {
            if (profile.Name == trac_AssignedResourceValidationHelper.VEHICLE_CONDITION_INSPECTOR_PROFILE) {
                vehicleConditionInspectorProfileId = profile.Id;
            }

            if (profile.Name == 'System Administrator') {
                systemAdministratorProfileId = profile.Id;
            }
        }

        ServiceResource resource = FSLTestUtility.makeResourceData();

        ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
                ServiceTerritoryId = serviceTerritory1.Id, ServiceResourceId = resource.Id,
                OperatingHoursId = serviceTerritory1.OperatingHoursId, EffectiveStartDate = Date.today(), TerritoryType = 'P');
        insert vciServiceTerritoryMember;

        ServiceAppointment serviceAppointment1 = new ServiceAppointment(
                Description='1', Work_Order__c = workOrder.Id, ParentRecordId = workOrder.Id,
                ServiceTerritoryId = serviceTerritory1.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = DateTime.now(),
                SchedStartTime = DateTime.now().addHours(1), SchedEndTime = DateTime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US' );
        insert serviceAppointment1;
    }

    @IsTest
    static void testInsertWOLI() {
        WorkOrder workOrder = [SELECT Id, Duration, DurationType FROM WorkOrder][0];
        ServiceAppointment serviceAppointment = [SELECT Duration, DurationType FROM ServiceAppointment WHERE SchedStartTime != null ][0];
        WorkType workType = [ SELECT Id FROM WorkType WHERE Name = 'Asset Verification' LIMIT 1 ];

        Test.startTest();
        WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(
                WorkOrderId = WorkOrder.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = workType.Id);
        insert workOrderLineItem;
        Test.stopTest();

    }

    @IsTest
    static void testDeleteWOLI() {
        Test.startTest();
                WorkOrder workOrder = [SELECT Id, Duration, DurationType FROM WorkOrder][0];
                ServiceAppointment serviceAppointment = [SELECT Duration, DurationType FROM ServiceAppointment WHERE SchedStartTime != null ][0];
                /*WorkType workType = new WorkType(
                        Name='Standard Inspection', EstimatedDuration = 1, DurationType = 'Hours', ShouldAutoCreateSvcAppt = true);
                insert workType;*/

                WorkType workType = [ SELECT Id FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1 ];


                WorkOrderLineItem workOrderLineItem = new WorkOrderLineItem(
                        WorkOrderId = WorkOrder.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = workType.Id);
                insert workOrderLineItem;

                workOrder = [SELECT Id, Duration, DurationType, Inspection_Number_of_Vehicles__c FROM WorkOrder][0];
                serviceAppointment = [SELECT Duration, DurationType FROM ServiceAppointment WHERE SchedStartTime != null ][0];

                delete workOrderLineItem;
        Test.stopTest();
    }

}