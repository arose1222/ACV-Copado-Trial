/**
 * @description       : Test class for DryRunFromServiceAppointmentController
 * @author            : v-dchaves@acvauctions.com
 * @group             : Scheduling
 * @last modified on  : 05-13-2022
 * @last modified by  : v-dchaves@acvauctions.com
**/
@IsTest
public with sharing class DryRunFromServiceAppointmentCtlrTest {
    @TestSetup
    static Void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acc = TestUtility.createAccount();
        insert acc;

        WorkType dealerWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'dealer'];

        WorkOrder workOrder = new WorkOrder(AccountId = acc.Id,
                                            ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id,
                                            WorkTypeId = dealerWorkType.Id,
                                            Status = 'New',
                                            Priority = 'Low');
        insert workOrder;

        ServiceAppointment serviceAppointment = new ServiceAppointment(DueDate = system.today().addDays(21),
                                                                       FSL__Pinned__c = false,
                                                                       Subject = workOrder.Subject,
                                                                       Work_Order__c = workOrder.Id,
                                                                       ParentRecordId = workOrder.Id,
                                                                       Status = 'Dispatched',
                                                                       ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id,
                                                                       EarliestStartTime = DateTime.now().addDays(-25),
                                                                       SchedStartTime = DateTime.now().addDays(1),
                                                                       SchedEndTime = DateTime.now().addHours(25),
                                                                       Dry_Run__c = false,
                                                                       Cannot_Complete_Reason__c = 'Other',
                                                                       ActualStartTime = DateTime.now().addDays(1),
                                                                       ActualEndTime = DateTime.now().addDays(1).addHours(2));
        insert serviceAppointment;

        FSL.GlobalAPIS.addStatusTransition('Dispatched', 'Completed');
    }

    @IsTest
    public static Void generalTest(){
        ServiceAppointment serviceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];

        // test getServiceAppointment method
        String jsonResponse = DryRunFromServiceAppointmentController.getServiceAppointment(serviceAppointment.Id);

        Map<String, String> response = (Map<String, String>) JSON.deserialize(jsonResponse, Map<String, String>.class);
        System.assertEquals(response.get('Status'), 'SUCCESS', 'Status: ' + response.get('Status'));

        DryRunFromServiceAppointmentController.ServiceAppointmentWrapper wrapperObj = (DryRunFromServiceAppointmentController.ServiceAppointmentWrapper) JSON.deserialize(response.get('Record'), DryRunFromServiceAppointmentController.ServiceAppointmentWrapper.class);
        System.assertEquals(wrapperObj.recordId, serviceAppointment.Id);
        System.assertEquals(wrapperObj.dryRun, false);
        System.assertEquals(wrapperObj.cannotCompleteReason, 'Other');

        // test markAsDryRun method
        wrapperObj.cannotCompleteReason = 'Insufficient time to complete';
        jsonResponse = DryRunFromServiceAppointmentController.markAsDryRun(JSON.serialize(wrapperObj));

        serviceAppointment = [SELECT Id, Dry_Run__c, Cannot_Complete_Reason__c, Status, Work_Order__r.Status FROM ServiceAppointment WHERE Id = :wrapperObj.recordId];
        System.assertEquals(serviceAppointment.Dry_Run__c, true);
        System.assertEquals(serviceAppointment.Cannot_Complete_Reason__c, 'Insufficient time to complete');
        System.assertEquals(serviceAppointment.Status, 'Completed');
        System.assertEquals(serviceAppointment.Work_Order__r.Status, 'Completed');
    }

    @IsTest
    public static Void errorTest(){
        String jsonResponse = DryRunFromServiceAppointmentController.getServiceAppointment('NOT_AN_ID');

        Map<String, String> response = (Map<String, String>) JSON.deserialize(jsonResponse, Map<String, String>.class);
        System.assertEquals(response.get('Status'), 'ERROR', 'Status: ' + response.get('Status'));

        jsonResponse = DryRunFromServiceAppointmentController.markAsDryRun('NOT_A_JSON');
        
        response = (Map<String, String>) JSON.deserialize(jsonResponse, Map<String, String>.class);
        System.assertEquals(response.get('Status'), 'ERROR', 'Status: ' + response.get('Status'));
    }
}