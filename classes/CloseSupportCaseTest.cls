@isTest
public with sharing class CloseSupportCaseTest {

    static final String closed = 'Closed';

    @TestSetup
    static void makeData() {
        Account acc = TestUtility.createAccount('Test 1');
        insert acc;

        Case sc = TestUtility.createSupportCase(acc);
        insert sc;

        List<Customer_Inquiry__c> ciList = new List<Customer_Inquiry__c>();
        ciList.add(new Customer_Inquiry__c(Support_Case__c = sc.Id, Call_Bucket__c = 'Titles', Status__c = closed));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = sc.Id, Call_Bucket__c = 'Sales', Status__c = 'AM Follow Up'));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = sc.Id, Call_Bucket__c = 'Arbitration', Status__c = 'New'));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = sc.Id, Call_Bucket__c = 'ACV Transport', Status__c = 'Working'));
        insert ciList;
    }

    @isTest
    static void testGetOpenInquiries() {
        Id supportCaseId = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Support'].Id;

        Test.startTest();
            List<Customer_Inquiry__c> ciList = CloseSupportCase.getOpenChildInquiries(supportCaseId);
        Test.stopTest();

        System.assertEquals(3, ciList.size(), 'Only non closed customer inquiries should be returned');
        for (Customer_Inquiry__c ci : ciList) {
            System.assertNotEquals(closed, ci.Status__c, 'Returned inquiries should not be closed');
        }
    }

    @isTest
    static void testCloseOpenInquiries() {
        Id supportCaseId = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Support'].Id;
        List<Customer_Inquiry__c> ciList = CloseSupportCase.getOpenChildInquiries(supportCaseId);

        Test.startTest();
            CloseSupportCase.closeChildInquiries(ciList);
        Test.stopTest();

        ciList = [SELECT Id, Status__c FROM Customer_Inquiry__c];

        for (Customer_Inquiry__c ci : ciList) {
            System.assertEquals(closed, ci.Status__c, 'All Inquiries should be closed');
        }
    }
}