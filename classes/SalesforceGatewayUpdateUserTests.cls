@isTest
public class SalesforceGatewayUpdateUserTests {

    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        c.email = 'bill@test.com';
        c.Identity_Id__c = '123';
        insert c;
    }

    @isTest
    public static void testContactUpdateWithNoLoginHistory(){
        User u = TestUtility.createUser();
        Contact c = [SELECT Id, Email FROM Contact Limit 1];
        Test.startTest();
        System.runAs(u){
            update c;
        }
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Email = 'bill@test.com'] == 1, 'Email Was Updated when it shouldnt have');
    }

    @isTest
    public static void testBasicContactUpdate(){
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/identity/username',uactiveRes);
        Contact c = [SELECT Id, Email FROM Contact Limit 1];
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.enableGatewayLogic();
        c.Email = 'Bill2@email.com';
        update c;
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Email = 'bill@test.com'] == 0, 'Email Was Updated when it shouldnt have');
    }

    @isTest
    public static void testBasicContactUpdateBadRunningUser(){
        Contact c = [SELECT Id, Email FROM Contact Limit 1];
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        Boolean errorHit = false;
        Boolean errorMessageFound = false;
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.startTest();
        try{
            c.Email = 'Bill2@email.com';
            update c;
        }
        catch(Exception e){
            errorHit = true;
            errorMessageFound = e.getMessage().contains('You do not have an active Identity Id');
        }
        Test.stopTest();
        System.assert(errorHit, 'Error not triggered when it should');
        System.assert(errorMessageFound, 'Bad Error Message');
    }
}