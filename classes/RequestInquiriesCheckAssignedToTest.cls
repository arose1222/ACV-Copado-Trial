@isTest
public class RequestInquiriesCheckAssignedToTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //create 2 users
        String uniqueUserName1 = 'testuser1' + DateTime.now().getTime() + '@testorg.com';
        String uniqueUserName2 = 'testuser2' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Recommended Pricing User'];
        List<User> newUsers = new List<User>();
        newUsers.add(new User(Alias = 'test1', Email = 'testuser1@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'test1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName1));
        newUsers.add(new User(Alias = 'test2', Email = 'testuser2@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'test2', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName2));
        insert newUsers;

        //create and insert Request & Inquiries record
        Id recordTypeId = Schema.SObjectType.Salesforce_Request__c.getRecordTypeInfosByDeveloperName().get('Ops_Help').getRecordTypeId();
        List<Salesforce_Request__c> reqInqList = new List<Salesforce_Request__c>();
        reqInqList.add(new Salesforce_Request__c(Assigned_To_Flag__c = false, Name = 'TEST rerun', Request_Reasons__c = 'Recommended Pricing', My_Request_Is_Related_To__c = 'Re-Run, Pricing or Trim', Additional_Details_Regarding_My_Request__c = 'Test Additional Details', Status__c = 'Submitted', Assigned_To__c = UserInfo.getUserId(), OwnerId = UserInfo.getUserId(), RecordTypeId = recordTypeId));
        insert reqInqList;
    }
    @isTest
    static void runTest() {
        List<Salesforce_Request__c> updateListUser1 = [SELECT Name, Assigned_To__c, Assigned_To_Flag__c FROM Salesforce_Request__c];
        List<User> users = [SELECT Id FROM User];
        String estring = '';

        for (Salesforce_Request__c sr1 : updateListUser1) {
            // make sure assigned to flag is false
            sr1.Assigned_To_Flag__c = false;
            update updateListUser1;
            //set new Assigned_To variable
            sr1.Assigned_To__c = users[0].Id;
            update updateListUser1;

            //try to set Assigned_To to something else
            try {
                sr1.Assigned_To__c = users[1].Id;
                update updateListUser1; //should never hit this (this would be a test failure)
            } catch (Exception e) {
                estring = e.getMessage();
            }
        }

        //query
        List<Salesforce_Request__c> checkAssignedTo = [SELECT Name, Assigned_To__c, Assigned_To_Flag__c FROM Salesforce_Request__c];

        String expectedDebugMessage = 'Assigned To field was modified during your edit session.  Refresh your page.';

        //system.asserts
        System.assertEquals(users[0].Id, checkAssignedTo[0].Assigned_To__c);
        System.assertEquals(true, checkAssignedTo[0].Assigned_To_Flag__c);
        System.assertEquals(expectedDebugMessage.contains('Assigned To field was modified during your edit session.  Refresh your page.'), estring.contains('Assigned To field was modified during your edit session.  Refresh your page.'));
    }
}