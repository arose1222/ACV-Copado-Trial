@isTest
public class ServiceAppointmentNotificationTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Completed' );
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Expired' );

        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createData( a, 1 );

    }

    @IsTest
    static void statusCompletedTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector' ];

        User vciTestUser = TestUtility.createUser( p.Id );
        insert vciTestUser;

        ServiceAppointment testSA = [ SELECT Id, Status FROM ServiceAppointment LIMIT 1];

        Email_Notification_Subscription__c ens = new Email_Notification_Subscription__c();
        ens.Service_Appointment__c = testSA.Id;
        ens.Email_on_Request_Inspection_Fulfillment__c = true;
        ens.User__c = vciTestUser.Id;
        insert ens;

        test.startTest();
        testSA.SchedStartTime = system.Now().addMinutes(-10);
        testSA.SchedEndTime = system.Now();
        testSA.ActualStartTime = system.Now().addMinutes(-10);
        testSA.ActualEndTime = system.Now();
        testSA.Status = 'Completed';
        update testSA;
        test.stopTest();

        System.assert([SELECT Id FROM Email_Notification__c].size() == 1, '1 email notification should have been created');

    }

    @IsTest
    static void statusCanceledTest(){
        ServiceAppointment testSA = [ SELECT Id, Status FROM ServiceAppointment LIMIT 1];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector' ];

        User vciTestUser = TestUtility.createUser( p.Id );
        insert vciTestUser;

        Email_Notification_Subscription__c ens = new Email_Notification_Subscription__c();
        ens.Service_Appointment__c = testSA.Id;
        ens.Email_on_Request_Inspection_Fulfillment__c = true;
        ens.User__c = vciTestUser.Id;
        insert ens;

        test.startTest();
        testSA.Status = 'Canceled';
        update testSA;
        test.stopTest();

        System.assert([SELECT Id FROM Email_Notification__c].size() == 1, '1 email notification should have been created');

    }

    @IsTest
    static void statusExpiredTest(){
        ServiceAppointment testSA = [ SELECT Id, Status FROM ServiceAppointment LIMIT 1];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector' ];

        User vciTestUser = TestUtility.createUser( p.Id );
        insert vciTestUser;

        Email_Notification_Subscription__c ens = new Email_Notification_Subscription__c();
        ens.Service_Appointment__c = testSA.Id;
        ens.Email_on_Request_Inspection_Fulfillment__c = true;
        ens.User__c = vciTestUser.Id;
        insert ens;

        test.startTest();
        testSA.Status = 'Expired';
        update testSA;
        test.stopTest();

        System.assert([SELECT Id FROM Email_Notification__c].size() == 0, 'No email notification should have been created');

    }

    @IsTest
    static void existingEmailNotificationTest(){
        ServiceAppointment testSA = [ SELECT Id, Status, Work_Order__c FROM ServiceAppointment LIMIT 1];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector' ];

        User vciTestUser = TestUtility.createUser( p.Id );
        insert vciTestUser;

        Email_Notification_Subscription__c ens = new Email_Notification_Subscription__c();
        ens.Service_Appointment__c = testSA.Id;
        ens.Email_on_Request_Inspection_Fulfillment__c = true;
        ens.User__c = vciTestUser.Id;
        insert ens;

        Email_Notification__c notification = new Email_Notification__c();
        notification.User_WorkOrder_Key__c = vciTestUser.Id + '' + testSA.Work_Order__c;
        notification.Send_Work_Order_Completed_Email__c = true;
        insert notification;

        test.startTest();
        testSA.SchedStartTime = system.Now().addMinutes(-10);
        testSA.SchedEndTime = system.Now();
        testSA.ActualStartTime = system.Now().addMinutes(-10);
        testSA.ActualEndTime = system.Now();
        testSA.Status = 'Completed';
        update testSA;
        test.stopTest();

        List<Email_Notification__c> notificationList = [SELECT Id, Send_Request_Inspection_Fullfillment__c FROM Email_Notification__c];
        System.assert(notificationList.size() == 1, '1 email notification should have been created');
        System.assert(notificationList[0].Send_Request_Inspection_Fullfillment__c == true, 'Send_Request_Inspection_Fullfillment__c should be set to true');

    }

}