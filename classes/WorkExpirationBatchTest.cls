/**
 * @description       : Test class for WorkExpirationBatch
 * @author            : v-dchaves@acvauctions.com
 * @group             : Scheduling
 * @last modified on  : 05-11-2022
 * @last modified by  : v-dchaves@acvauctions.com
**/
@IsTest
public with sharing class WorkExpirationBatchTest {
    @TestSetup
    public static Void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acc = TestUtility.createAccount();
        insert acc;

        WorkType inspectionWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];

        WorkOrder workOrder = new WorkOrder(AccountId = acc.Id,
                                            ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id,
                                            WorkTypeId = inspectionWorkType.Id,
                                            Status = 'New',
                                            Priority = 'Low');
        insert workOrder;

        ServiceAppointment serviceAppointment = new ServiceAppointment(DueDate = system.today().addDays(-1),
                                                                       FSL__Pinned__c = false,
                                                                       Subject = workOrder.Subject,
                                                                       Work_Order__c = workOrder.Id,
                                                                       ParentRecordId = workOrder.Id,
                                                                       Status = 'New',
                                                                       ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id,
                                                                       EarliestStartTime = DateTime.now().addDays(-25),
                                                                       SchedStartTime = DateTime.now().addDays(1),
                                                                       SchedEndTime = DateTime.now().addHours(25),
                                                                       Dry_Run__c = false,
                                                                       Cannot_Complete_Reason__c = 'Other',
                                                                       ActualStartTime = DateTime.now().addDays(1),
                                                                       ActualEndTime = DateTime.now().addDays(1).addHours(2));
        insert serviceAppointment;

        FSL.GlobalAPIS.addStatusTransition('New', 'Expired');
    }

    /**
     * Test that the service appointments that the user creates is 
     * changed (general test)
     */
    @IsTest
    public static Void withUsersTest(){
        List<ServiceAppointment> serviceAppointments = [SELECT Id, CreatedById 
                                                        FROM ServiceAppointment 
                                                        WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' AND
                                                              Status = 'New' AND
                                                              DueDate <= TODAY AND
                                                              Work_Order__r.Occurrence__c = null];
        
        System.assert(!serviceAppointments.isEmpty());

        ServiceAppointment serviceAppointment = serviceAppointments[0];
        
        Id userId = serviceAppointment.CreatedById;

        // set the user id for test purpouses
        WorkExpirationBatch.USERS_MTDT = new List<FSL_Users_to_Expire_Appointment__mdt>{new FSL_Users_to_Expire_Appointment__mdt(Label = 'deelan', User_Id__c = userId)};
        WorkExpirationBatch.STATUS_CHANGE = 'Expired';

        Test.startTest();
            WorkExpirationBatch b = new WorkExpirationBatch();
            b.executeScheduledLogic();
        Test.stopTest();

        serviceAppointment = [SELECT Id, Status, ParentRecordId FROM ServiceAppointment WHERE Id = :serviceAppointment.Id];

        System.assertEquals('Expired', serviceAppointment.Status);

        WorkOrder wrkOrder = [SELECT Id, Status FROM WorkOrder WHERE Id = :serviceAppointment.ParentRecordId];

        System.assertEquals('Expired', wrkOrder.Status);
    }

    /**
     * Test that if the user is no described in the metadata should not
     * affect the records
     */
    @IsTest
    public static Void withoutUsersTest(){
        List<ServiceAppointment> serviceAppointments = [SELECT Id, CreatedById 
                                                        FROM ServiceAppointment 
                                                        WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' AND
                                                              Status = 'New' AND
                                                              DueDate <= TODAY AND
                                                              Work_Order__r.Occurrence__c = null];
        
        System.assert(!serviceAppointments.isEmpty());

        ServiceAppointment serviceAppointment = serviceAppointments[0];
        
        Id userId = serviceAppointment.CreatedById;

        // set the user id for test purpouses
        WorkExpirationBatch.USERS_MTDT = new List<FSL_Users_to_Expire_Appointment__mdt>();
        WorkExpirationBatch.STATUS_CHANGE = 'Expired';

        Test.startTest();
            WorkExpirationBatch b = new WorkExpirationBatch();
            b.executeScheduledLogic();
        Test.stopTest();

        serviceAppointment = [SELECT Id, Status, ParentRecordId FROM ServiceAppointment WHERE Id = :serviceAppointment.Id];

        System.assertEquals('New', serviceAppointment.Status);

        WorkOrder wrkOrder = [SELECT Id, Status FROM WorkOrder WHERE Id = :serviceAppointment.ParentRecordId];

        System.assertEquals('New', wrkOrder.Status);
    }
}