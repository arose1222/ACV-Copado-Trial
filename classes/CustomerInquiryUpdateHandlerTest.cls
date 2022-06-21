@isTest
public with sharing class CustomerInquiryUpdateHandlerTest {

    static final String newStatus = 'New';
    static final String working = 'Working';
    static final String amFollowUp = 'AM Follow Up';
    static final String closed = 'Closed';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        List<User> newUsers = new List<User>();
        User titleSpecialist = TestUtility.createUser();
        newUsers.add(titleSpecialist);
        User accOwner = TestUtility.createUser();
        newUsers.add(accOwner);
        insert newUsers;

        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<Case>();
        Account acc = TestUtility.createAccount('Test 1');
        acc.Title_Specialist__c = newUsers[0].Id;
        acc.IST_Account_Owner__c = newUsers[1].Id;
        acctList.add(acc);
        Account acc2 = TestUtility.createAccount('Test 2');
        acctList.add(acc2);
        insert acctList;

        Case sc = TestUtility.createSupportCase(acctList[0]);
        caseList.add(sc);
        Case sc2 = TestUtility.createSupportCase(acctList[1]);
        caseList.add(sc2);
        insert caseList;

        List<Customer_Inquiry__c> ciList = new List<Customer_Inquiry__c>();
        ciList.add(new Customer_Inquiry__c(Support_Case__c = caseList[0].Id, Account__c = acctList[0].Id, Call_Bucket__c = 'Titles', Call_Type__c = 'Buyer Title Status', Status__c = closed));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = caseList[0].Id, Account__c = acctList[0].Id, Call_Bucket__c = 'Sales', Call_Type__c = 'Dealmaker', Status__c = amFollowUp, Priority__c = 'Low'));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = caseList[0].Id, Account__c = acctList[0].Id, Call_Bucket__c = 'Helpdesk', Call_Type__c = 'Ghost Bid', Status__c = amFollowUp, Priority__c = 'Medium'));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = caseList[0].Id, Account__c = acctList[1].Id, Call_Bucket__c = 'Arbitration', Call_Type__c = 'Case Status', Status__c = newStatus));
        ciList.add(new Customer_Inquiry__c(Support_Case__c = caseList[0].Id, Call_Bucket__c = 'ACV Transport', Call_Type__c = 'Cost Inquiry', Status__c = working));
        insert ciList;
    }

    @isTest
    static void testCIStatusChangesThatEffectPriority() {
        Set<String> bucketSet = new Set<String>{'Titles', 'Sales', 'Helpdesk'};
        //test CI going from status Closed to other
        //test CI going from AM Follow Up to New- priority Low
        //test CI going from  AM Follow Up to Working - priority Medium
        List<Customer_Inquiry__c> ciList = [SELECT Id, Status__c, Call_Bucket__c FROM Customer_Inquiry__c WHERE Call_Bucket__c IN :bucketSet];
        for (Customer_Inquiry__c c : ciList) {
            if (c.Status__c != closed) {
                if (c.Call_Bucket__c == 'Sales') {
                    c.Status__c = newStatus;
                }
                else {
                    c.Status__c = working;
                }
            }
            else {
                c.Status__c = newStatus; 
            }
        }
        Test.startTest();
            update ciList;
        Test.stopTest();

        for(Customer_Inquiry__c ci : [SELECT Id, Priority__c, Call_Bucket__c FROM Customer_Inquiry__c WHERE Call_Bucket__c IN :bucketSet]) {
            if(ci.Call_Bucket__c == 'Titles') {
                System.assertEquals('High', ci.Priority__c);
            } 
            else if(ci.Call_Bucket__c == 'Sales') {
                System.assertEquals('Medium', ci.Priority__c);
            }
            else {
                System.assertEquals('High', ci.Priority__c); // helpdesk
            }
        }
    }

    @isTest
    static void testChangingThePriorityOfCaseWhenCICloses() {
        Customer_Inquiry__c ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk'];
        ci.Status__c = closed; 
        Test.startTest();
            update ci;
        Test.stopTest();

        Case sc = [SELECT Id, Priority, Status FROM Case WHERE Account.Name = 'Test 1'];
        System.assertEquals('Low', sc.Priority);
        System.assertNotEquals(closed, sc.Status);
    }

    @isTest
    static void testStatusChangingToWorking() { 
        Customer_Inquiry__c ci = [SELECT Id, Status__c, Support_Case__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Arbitration'];
        Case sc = [SELECT Id FROM Case WHERE Account.Name = 'Test 2'];
        ci.Support_Case__c = sc.Id;
        ci.Status__c = working; 
        Test.startTest();
            update ci;
        Test.stopTest();

        sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 2'];
        System.assertEquals(working, sc.Status);
    }

    @isTest
    static void testStatusChangingToInquiryResolved() { 
        Customer_Inquiry__c ci = [SELECT Id, Status__c, Support_Case__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Arbitration'];
        Case sc = [SELECT Id FROM Case WHERE Account.Name = 'Test 2'];
        ci.Support_Case__c = sc.Id;
        ci.Status__c = amFollowUp; //AM Follow Up
        Test.startTest();
            update ci;
        Test.stopTest();

        sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 2'];
        System.assertEquals('Ready for Response', sc.Status);
    }

    @isTest
    static void testCIChangingToInquiryResolvedButCaseChangingToWorking() {
        List<Customer_Inquiry__c> ciList = [SELECT Id, Status__c, Support_Case__c FROM Customer_Inquiry__c WHERE Call_Bucket__c IN ('Arbitration', 'ACV Transport')];
        Case sc = [SELECT Id FROM Case WHERE Account.Name = 'Test 2'];
        for (Customer_Inquiry__c c : ciList) {
            c.Support_Case__c = sc.Id;
            c.Status__c = newStatus;
        }
        update ciList;

        ciList[0].Status__c = amFollowUp;
        Test.startTest();
            update ciList[0];
        Test.stopTest();
        
        sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 2'];
        System.assertEquals(working, sc.Status);
    }

    @isTest
    static void testStatusChangingToClosed() { 
        Customer_Inquiry__c ci = [SELECT Id, Status__c, Support_Case__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'ACV Transport'];
        Case sc = [SELECT Id FROM Case WHERE Account.Name = 'Test 2'];
        ci.Support_Case__c = sc.Id;
        ci.Status__c = closed; 
        Test.startTest();
            update ci;
        Test.stopTest();

        sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 2'];
        System.assertEquals(closed, sc.Status);
    }

    @isTest
    static void testStatusChangingToNew() { 
        Customer_Inquiry__c ci = [SELECT Id, Status__c, Support_Case__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'ACV Transport'];
        Case sc = [SELECT Id FROM Case WHERE Account.Name = 'Test 2'];
        sc.Status = working;
        update sc;
        ci.Support_Case__c = sc.Id;
        ci.Status__c = newStatus; 
        Test.startTest();
            update ci;
        Test.stopTest();

        sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 2'];
        System.assertEquals(newStatus, sc.Status);
    }

    @isTest
    static void testChangingPriorityMedToHighForSC() {
        List<Customer_Inquiry__c> ciList = [SELECT Id, Priority__c, Support_Case__c, Call_Bucket__c, Status__c FROM Customer_Inquiry__c WHERE Call_Bucket__c IN ('Helpdesk', 'Titles') ORDER BY Call_Bucket__c DESC];
        Case sc = [SELECT Id, Priority FROM Case WHERE Account.Name = 'Test 2'];
        sc.Priority = 'Medium';
        update sc;
        for (Customer_Inquiry__c ci : ciList) {
            if (ci.Call_Bucket__c == 'Helpdesk') {
                ci.Support_Case__c = sc.Id;
                ci.Priority__c = 'High';
            }
            else {
                ci.Support_Case__c = sc.Id;
                ci.Priority__c = 'Low';
                ci.Status__c = amFollowUp;
            }
        }
        Test.startTest();
            update ciList;
        Test.stopTest();

        sc = [SELECT Id, Priority FROM Case WHERE Account.Name = 'Test 2'];
        System.assertEquals('High', sc.Priority);
    }

    @isTest
    static void testMultipleSupportCasesCIsUpdatingAtTheSameTime() {
        List<Customer_Inquiry__c> ciList = [SELECT Id, Status__c, Support_Case__c, Call_Bucket__c FROM Customer_Inquiry__c WHERE Call_Bucket__c IN ('Helpdesk', 'Sales')];
        Case sc = [SELECT Id, Priority FROM Case WHERE Account.Name = 'Test 2'];
        for (Customer_Inquiry__c ci : ciList) {
            if (ci.Call_Bucket__c == 'Helpdesk') {
                ci.Support_Case__c = sc.Id;
            }
        }
        update ciList;

        for (Customer_Inquiry__c ci : ciList) {
            ci.Status__c = closed;
        }
        Test.startTest();
            update ciList;
        Test.stopTest();

        List<Case> caseList = [SELECT Id, Status FROM Case ORDER BY Account.Name ASC];
        System.assertEquals(working, caseList[0].Status);
        System.assertEquals(closed, caseList[1].Status);
    }

    //NEGATIVE TESTS
    @isTest
    static void testNegativeStatusChangingToInquiryResolved() { 
        Customer_Inquiry__c ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'ACV Transport'];
        ci.Status__c = amFollowUp; 
        Test.startTest();
            update ci;
        Test.stopTest();

        Case sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 1'];
        System.assertEquals(working, sc.Status, 'Support Case should be set to Status of Working because one of the CIs moved to AM Follow Up');
    }

    @isTest
    static void testNegativeStatusChangingToClosed() {
        Customer_Inquiry__c ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Sales'];
        ci.Status__c = closed;
        Test.startTest();
            update ci;
        Test.stopTest();

        Case sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 1'];
        System.assertEquals(working, sc.Status, 'Support Case should be set to Status of Working because one of the CIs moved to Closed');
    }

    @isTest
    static void testNegativeStatusChangingToNew() {
        Customer_Inquiry__c ci = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk'];
        ci.Status__c = newStatus;
        Test.startTest();
            update ci;
        Test.stopTest();

        Case sc = [SELECT Id, Status FROM Case WHERE Account.Name = 'Test 1'];
        System.assertEquals(newStatus, sc.Status); //it will not be working because there is no onInsert trigger to update support case status on entry on new CI's that is supposed to happen through the LWC but is impossible in the test context
    }

    @isTest
    static void testCIAssignedToUserResolving() {
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User titlesUser = TestUtility.createUser(p.Id);
        insert titlesUser;

        Customer_Inquiry__c ci= [SELECT Id, Status__c, Call_Bucket__c, Assigned_To__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Arbitration'];
        ci.Assigned_To__c = UserInfo.getUserId();
        update ci;

        System.runAs(titlesUser) {
            Test.startTest();
                ci.Status__c = amFollowUp;
                update ci;
            Test.stopTest();
        }

        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :ci.Id]) {
            System.assertEquals(titlesUser.Id, c.Assigned_To__c); 
        }
    }

    @isTest
    static void testNoUpdateCIAssignedToUserResolving() {
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User titlesUser = TestUtility.createUser(p.Id);
        insert titlesUser;

        Customer_Inquiry__c ci= [SELECT Id, Status__c, Call_Bucket__c, Assigned_To__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Arbitration'];
        ci.Assigned_To__c = titlesUser.Id;
        update ci;

        Test.startTest();
            ci.Status__c = amFollowUp;
            update ci;
        Test.stopTest();
        
        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :ci.Id]) {
            System.assertEquals(titlesUser.Id, c.Assigned_To__c); 
        }
    }

    @isTest
    static void testNoUpdateCIAssignedToUserClosing() {
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Inside Sales - Account Managers'];
        User amUser = TestUtility.createUser(p.Id);
        insert amUser;

        Customer_Inquiry__c ci= [SELECT Id, Status__c, Call_Bucket__c, Assigned_To__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Arbitration'];
        ci.Assigned_To__c = UserInfo.getUserId();
        update ci;

        System.runAs(amUser) {
            Test.startTest();
                ci.Status__c = closed;
                update ci;
            Test.stopTest();
        }

        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :ci.Id]) {
            System.assertEquals(UserInfo.getUserId(), c.Assigned_To__c); 
        }
    }

    @isTest
    static void testCIAssignedToUserClosing() {
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Customer Success Team'];
        User csUser = TestUtility.createUser(p.Id);
        insert csUser;

        Customer_Inquiry__c ci= [SELECT Id, Status__c, Call_Bucket__c, Assigned_To__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Arbitration'];
        ci.Assigned_To__c = UserInfo.getUserId();
        update ci;

        System.runAs(csUser) {
            Test.startTest();
                ci.Status__c = closed;
                update ci;
            Test.stopTest();
        }

        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :ci.Id]) {
            System.assertEquals(csUser.Id, c.Assigned_To__c); 
        }
    }

    @isTest
    static void openMultipleClosedInquiries() {

        Account acc = [SELECT Id, Title_Specialist__c, IST_Account_Owner__c FROM Account WHERE Name = 'Test 1'];
        
        Contact con = TestUtility.createContact(acc);
        insert con;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c auc = TestUtility.createAuction(acc,con,v);
        insert auc;
        Case titleCase = TestUtility.createTitleCase(auc,acc,con);
        titleCase.Status = 'Closed Unwound';
        titleCase.Seller_Dealership__c = acc.Id;
        insert titleCase;

        List<Customer_Inquiry__c> allInquiries = [SELECT Id, Call_Bucket__c FROM Customer_Inquiry__c];
        for (Customer_Inquiry__c ci : allInquiries) { // titles needs a title case with an auction that has the same auction as this CI
            if (ci.Call_Bucket__c == 'Titles') {
                ci.Auction__c = auc.Id;
                ci.Ops_Case__c = titleCase.Id;
                ci.Assigned_To__c = UserInfo.getUserId();
            }
            ci.Status__c = closed;
        }
        update allInquiries;

        for (Customer_Inquiry__c ci : allInquiries) {
            ci.Status__c = newStatus;
        }
        Test.startTest();
        update allInquiries;
        Test.stopTest();

        for (Customer_Inquiry__c ci : [SELECT Id, Call_Bucket__c, Assigned_To__c FROM Customer_Inquiry__c]) {
            if (ci.Call_Bucket__c == 'Titles') {
                system.assertEquals(acc.Title_Specialist__c, ci.Assigned_To__c);
            }
            else if (ci.Call_Bucket__c == 'Arbitration' || ci.Call_Bucket__c == 'ACV Transport') {

                system.assertEquals(UserInfo.getUserId(), ci.Assigned_To__c);
            }
            else {

                system.assertEquals(acc.IST_Account_Owner__c, ci.Assigned_To__c);
            }
        }
    }

    

}