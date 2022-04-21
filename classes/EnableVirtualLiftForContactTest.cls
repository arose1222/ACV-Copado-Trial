@isTest
public class EnableVirtualLiftForContactTest {

    public static String mockMetaDataString = '[{"DeveloperName": "EnableVirtualLiftForContact","Active__c":"true","NamespacePrefix": "","Before_Update__c": "true","sObject__c": "Contact", "Class_Name__c": "EnableVirtualLiftForContact"}]';

    @isTest 
    public static void testSuccessEnableUpdate(){
        //this line allows the test to pass even if we have the metadata record disabled in instance
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Account a = new Account(Name = 'Test');
        insert a;
        Contact c = new Contact(AccountId = a.id, FirstName = 'Bill', LastName = 'Test', id__c = '3223',Successful_Virtual_Lift_Prescreens__c=0);
        insert c;
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        c = [select id, Virtual_Lift_Enabled__c,Successful_Virtual_Lift_Prescreens__c from Contact where id__c = '3223' limit 1];
        c.Virtual_Lift_Enabled__c = true;
        c.Successful_Virtual_Lift_Prescreens__c = 10;
        Test.startTest();
        update c;
        Test.stopTest();

        c = [select id, Virtual_Lift_Enabled__c from contact where id__c = '3223' limit 1];
        System.assert(c.Virtual_Lift_Enabled__c, 'VL Disabled when it shouldnt be');
    }

    @isTest
    public static void testFailureEnableUpdate(){
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Account a = new Account(Name = 'Test');
        insert a;
        Contact c = new Contact(AccountId = a.id, FirstName = 'Bill', LastName = 'Test', id__c = '3223',Successful_Virtual_Lift_Prescreens__c=0);
        insert c;
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        c = [select id, Virtual_Lift_Enabled__c, Successful_Virtual_Lift_Prescreens__c from Contact where id__c = '3223' limit 1];
        c.Virtual_Lift_Enabled__c = true;
        c.Successful_Virtual_Lift_Prescreens__c = 10;
        Test.startTest();
        update c;
        Test.stopTest();

        c = [select id, Virtual_Lift_Enabled__c from contact where id__c = '3223' limit 1];
        System.assert(!c.Virtual_Lift_Enabled__c, 'VL Enabled when it shouldnt be');
    }

    @isTest
    public static void testFailureDisableUpdate(){
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Account a = new Account(Name = 'Test');
        insert a;
        
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes1 = new TestingUtility.SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/deactivate/',uactiveRes1);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Contact c = new Contact(AccountId = a.id, FirstName = 'Bill', LastName = 'Test', id__c = '3223',Virtual_Lift_Enabled__c = true);
        insert c;
        c = [select id, Virtual_Lift_Enabled__c from Contact where id__c = '3223' limit 1];
        c.Virtual_Lift_Enabled__c = false;
        Test.startTest();
        update c;
        Test.stopTest();

        c = [select id, Virtual_Lift_Enabled__c from contact where id__c = '3223' limit 1];
        System.assert(c.Virtual_Lift_Enabled__c, 'VL disabled when it shouldnt be');
    }

    @isTest
    public static void testSuccessDisableUpdate(){
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Account a = new Account(Name = 'Test');
        insert a;
        Contact c = new Contact(AccountId = a.id, FirstName = 'Bill', LastName = 'Test', id__c = '3223');
        insert c;
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes1 = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/deactivate/',uactiveRes1);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        c = [select id, Virtual_Lift_Enabled__c from Contact where id__c = '3223' limit 1];
        c.Virtual_Lift_Enabled__c = true;
        Test.startTest();
        update c;
        c.Virtual_Lift_Enabled__c = false;
        update c;
        Test.stopTest();

        c = [select id, Virtual_Lift_Enabled__c from contact where id__c = '3223' limit 1];
        System.assert(!c.Virtual_Lift_Enabled__c, 'VL Enabled when it shouldnt be');
    }
}