/**
 * @description Test class for Work Order Handler
 * @author Isaiah Cummins, Traction on Demand
 * @date 9/16/2019
 */

@IsTest
private class trac_WorkOrderTriggerHandlerTest {
    @TestSetup
    static void setup() {
        Group gr;
        try {
            gr = [SELECT Id, DeveloperName, Type FROM Group WHERE Name = 'Great Lakes' AND Type = 'Queue' LIMIT 1];
        }
        catch (Exception e) {
            gr = new Group(Name='Great Lakes', Type='Queue');
            insert gr;
        }

        QueueSobject mappingObject = new QueueSobject(QueueId = gr.Id, SobjectType = 'WorkOrder');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;}

        OperatingHours operatingHours = new OperatingHours(Name = 'vciTest');
        insert operatingHours;

        insert FSLTestUtility.createWorkTypes();

        ServiceTerritory serviceTerritory1 = new ServiceTerritory(
                Name = 'Great Lakes', IsActive = true, OperatingHoursId = operatingHours.Id);
        insert serviceTerritory1;
    }

    @IsTest
    static void testVehicleDuration(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        ServiceTerritory serviceTerritory1 = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes' LIMIT 1];
        WorkType Standar_Inspection = [SELECT Id,EstimatedDuration,DurationType FROM WorkType WHERE Name=:  tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION];
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        u1.FSL_Beta__c = TRUE;
        insert u1;

        Account acc = TestUtility.createAccount('vciTest');
        insert acc;

        WorkOrder workOrder = new WorkOrder(AccountId = acc.Id, ServiceTerritoryId = serviceTerritory1.Id, Priority = 'Low', Status = 'New', WorkTypeId=Standar_Inspection.Id);
        insert workOrder;

        workOrder.Inspection_Number_of_Vehicles__c = 10;
        update  workOrder;

        ServiceAppointment testServiceAppointment = [SELECT Id, DurationType, Duration FROM ServiceAppointment WHERE Work_Order__c=:workOrder.Id];

        System.assertEquals(testServiceAppointment.DurationType,'Minutes');
        System.assertEquals(10 * Standar_Inspection.EstimatedDuration,testServiceAppointment.Duration);

        workOrder.Inspection_Number_of_Vehicles__c = null;
        update  workOrder;

         testServiceAppointment = [SELECT Id, DurationType, Duration FROM ServiceAppointment WHERE Work_Order__c=:workOrder.Id];

        System.assertEquals(testServiceAppointment.DurationType,Standar_Inspection.DurationType);
        System.assertEquals(testServiceAppointment.Duration,Standar_Inspection.EstimatedDuration);

        workOrder.Inspection_Number_of_Vehicles__c = 0;
        update  workOrder;
        testServiceAppointment = [SELECT Id, DurationType, Duration FROM ServiceAppointment WHERE Work_Order__c=:workOrder.Id];

        System.assertEquals(testServiceAppointment.DurationType,'Minutes');
        System.assertEquals(testServiceAppointment.Duration,30);

    }

    @IsTest
    static void testInsertWorkOrderAndAssignToQueue() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        u1.FSL_Beta__c = TRUE;
        insert u1;

        Account account = TestUtility.createAccount('vciTest');
        insert account;

        System.runAs( u1 ) {

            ServiceTerritory serviceTerritory = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes' LIMIT 1];
            Group queue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'Great_Lakes' LIMIT 1];

            Test.startTest();
            WorkOrder workOrder = new WorkOrder(AccountId = account.Id, ServiceTerritoryId = serviceTerritory.Id, Priority = 'Low');
            insert workOrder;
            Test.stopTest();

            System.assert(workOrder.OwnerId != queue.Id, 'OwnerId was originally assigned to the Queue');

            WorkOrder updatedWorkOrder = [SELECT Id, OwnerId FROM WorkOrder WHERE Id = :workOrder.Id];
            System.assert(updatedWorkOrder.OwnerId == queue.Id, 'Work order was not reassigned');
        }
    }


    @IsTest
    static void testUpdateAssignedTimeStamp() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        u1.FSL_Beta__c = TRUE;
        insert u1;

        Account account = TestUtility.createAccount('vciTest');
        insert account;

        System.runAs( u1 ) {

            ServiceTerritory serviceTerritory = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'][0];
            Group queue = [SELECT Id, Name FROM Group WHERE Name = 'Great Lakes'][0];

            WorkOrder workOrder = new WorkOrder(AccountId = account.Id, ServiceTerritoryId = serviceTerritory.Id, Priority = 'Low');
            insert workOrder;
            System.assert(workOrder.Assigned_Date_Time__c == null);

            Test.startTest();
            workOrder.Status = 'Assigned';
            update workOrder;
            Test.stopTest();

            workOrder = [SELECT Assigned_Date_Time__c FROM WorkOrder][0];
            System.assert(workOrder.Assigned_Date_Time__c != null, 'Assigned time was not populated');
        }
    }

    @IsTest
    static void testDurationOnInsert(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        ServiceTerritory serviceTerritory1 = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes' LIMIT 1];
        WorkType Standar_Inspection = [SELECT Id,EstimatedDuration,DurationType FROM WorkType WHERE Name=:  tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION];
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        u1.FSL_Beta__c = TRUE;
        insert u1;

        Account acc = TestUtility.createAccount('vciTest');
        insert acc;

        WorkOrder workOrder = new WorkOrder(Inspection_Number_of_Vehicles__c = 10, AccountId = acc.Id, ServiceTerritoryId = serviceTerritory1.Id, Priority = 'Opportunity', Status = 'New', WorkTypeId=Standar_Inspection.Id);
        insert workOrder;

        workOrder = [SELECT duration FROM WorkOrder WHERE Id = :workOrder.Id ];
        System.assert(workOrder.duration == 300, 'Expected: 100, Actual: ' + workOrder.duration);
    }


    @IsTest
    static void testUpdateCompletedTimeStamp() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        u1.FSL_Beta__c = TRUE;
        insert u1;

        Account account = TestUtility.createAccount('vciTest');
        insert account;

        System.runAs( u1 ) {

            ServiceTerritory serviceTerritory = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'][0];
            Group queue = [SELECT Id, Name FROM Group WHERE Name = 'Great Lakes'][0];

            WorkOrder workOrder = new WorkOrder(AccountId = account.Id, ServiceTerritoryId = serviceTerritory.Id, Priority = 'Low');
            insert workOrder;
            System.assert(WorkOrder.Completed_Date_Time__c == null);

            Test.startTest();
            workOrder.Status = 'Completed';
            update workOrder;
            Test.stopTest();

            workOrder = [SELECT Completed_Date_Time__c FROM WorkOrder][0];
            System.assert(workOrder.Completed_Date_Time__c != null, 'Assigned time was not populated');
        }
    }


    /*@IsTest
    static void testAssignWorkTypeFromQuickction(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        u1.FSL_Beta__c = TRUE;
        insert u1;

        System.runAs( u1 ) {
            ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory WHERE Name = 'Great Lakes'];
            WorkOrder wo = new WorkOrder( Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US' );
            wo.ServiceTerritoryId = serviceTerritory.Id;
            wo.Created_From_Quick_Action__c = true;

            Test.startTest();
            insert wo;
            Test.stopTest();

            wo = [SELECT WorkType.Name FROM WorkOrder WHERE Id = :wo.Id];
            System.assertEquals(wo.WorkType.Name, tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION);
        }
    }*/
}