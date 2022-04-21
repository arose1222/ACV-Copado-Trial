@isTest
public class DealerOutreachControllerTest {
    
    @isTest
    static void testCreateRetention() {
        Account acc = TestUtility.createAccount('Test');
        acc.Last_30_Days_Bought__c = 5;
        acc.Purchases_All_Time__c = 5;
        acc.Date_of_Last_Sale__c = System.today().addDays(-3);
        acc.CreatedDate = System.today().addDays(-70);
        insert acc;
        Contact con = TestUtility.createContact(acc);
        insert con;

        String jsonString = '{"account":"' + acc.Id + '","contact":"' + con.Id + '","comments":"test comments","direction":"Outbound","noAnswer":"No answer","callType":"Retention","experience":"Arbitration;Payments","nextSteps":"test"}';
        
        Test.startTest();
        DealerOutreachController.createRetention(jsonString);
        Test.stopTest();

        Retention_Ignition__c retentionRecord = [SELECT Id, AccountName__c, ContactName__c, Dealer_Comments__c, Call_Direction__c, No_Answer__c, Type__c, Latest_ACV_Experience__c, Next_Steps__c, Account_Activity_Status__c FROM Retention_Ignition__c];
        System.assertEquals(acc.Id, retentionRecord.AccountName__c);
        System.assertEquals(con.Id, retentionRecord.ContactName__c);
        System.assertEquals('test comments', retentionRecord.Dealer_Comments__c);
        System.assertEquals('Outbound', retentionRecord.Call_Direction__c);
        System.assertEquals('No answer', retentionRecord.No_Answer__c);
        System.assertEquals('Retention', retentionRecord.Type__c);
        System.assertEquals('Arbitration;Payments', retentionRecord.Latest_ACV_Experience__c);
        System.assertEquals('test', retentionRecord.Next_Steps__c);
        System.assertEquals('Normal', retentionRecord.Account_Activity_Status__c);

        acc = [SELECT Id, Account_Management_Next_Steps__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('test', acc.Account_Management_Next_Steps__c);
    }

    @isTest
    static void testErrorOnCreate() {

        TestingUtility.SingleRequestMock splunkRes = new TestingUtility.SingleRequestMock(200,'OK','{ success }',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Splunk/services/collector/event',splunkRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));

        String jsonString = '{"accountId":"00111000025bz0fAAA","contactId":"0031100001noYw0AAE","comments":"test comments","direction":"Outbound","noAnswer":"No answer","callType":"Retention","experience":["Arbitration","Payments"]}';
        
        Test.startTest();
        DealerOutreachController.createRetention(jsonString);
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Retention_Ignition__c]);
    }

    @isTest
    static void testRetentionCreateAccessCustomerSuccessUser(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Success Team'];
        User customerSuccessUser = TestUtility.createUser(p.Id);
        Boolean hasAccess;

        Test.startTest();
        System.runAs(customerSuccessUser){
            hasAccess = DealerOutreachController.checkRetentionCreateAccess();
        }
        Test.stopTest();

        System.assertEquals(false,hasAccess, 'Customer Success users do not have access to create Retention_Ignition__c records');
    }

    @isTest
    static void testCheckAffiliationCreateAccessAdmin(){ 
        Test.startTest();
            Boolean hasAccess = DealerOutreachController.checkRetentionCreateAccess();
        Test.stopTest();

        System.assertEquals(true,hasAccess, 'System Admin should have access to create Retention_Ignition__c records');
    }

    @isTest
    static void testLockedAccount(){
        Test.startTest();
            Account acc = TestUtility.createAccount();
            insert acc;
        Test.stopTest();

        System.assertEquals(false, DealerOutreachController.checkForLockedAccount(acc.Id));


    }

    @isTest
    static void getISTTaskRecordTypeId() {
        Id istRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Inside_Sales').getRecordTypeId();
        System.assertEquals(istRecordTypeId, DealerOutreachController.getInsideSalesRecordTypeId());
    }
}