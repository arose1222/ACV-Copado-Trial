@isTest
public class CustomerInquiryReportAProblemHandlerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //need two accounts (one with specialist and CSA populated, one without) - think i will set the running user as both of these fields. instead of creating a new user
        List<Account> acctList = new List<Account>();
        acctList.add(TestUtility.createAccount('Test 1'));
        Account a = TestUtility.createAccount('Test 2');
            a.Title_Specialist__c = UserInfo.getUserId();
            a.Customer_Success_Advocate__c = UserInfo.getUserId();
        acctList.add(a);
        insert acctList;
        //need two contacts
        List<Contact> conList = new List<Contact>();
        conList.add(TestUtility.createContact(acctList[0]));
        conList.add(TestUtility.createContact(acctList[1]));
        insert conList;
        //need a vehicle
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        //need two auctions - switch which account is the buyer and seller
        List<Auction__c> aucList = new List<Auction__c>();
        aucList.add(TestUtility.createAuctionWithUniqueId(acctList[0], conList[0], v));
        aucList.add(TestUtility.createAuctionWithUniqueId(acctList[1], conList[1], v));
        insert aucList;
        //need two title cases - status' should be different
        List<Case> caseList = new List<Case>();
        Case no1 = TestUtility.createTitleCase(aucList[0], acctList[0], conList[0]);
            no1.Status = 'New';
        caseList.add(no1);
        Case no2 = TestUtility.createTitleCase(aucList[1], acctList[1], conList[1]);
            no2.Status = 'Problem';
        caseList.add(no2);
        insert caseList;
    }

    //normal functionality - correct information is provided and CI is created and assigned to the correct people
    @isTest
    static void testNormalBeforeInsertFunction() {
        Account a = [SELECT Id, Title_Specialist__c FROM Account WHERE Title_Specialist__c != null];
        Auction__c au = [SELECT Id FROM Auction__c WHERE Buyer_Dealership__c = :a.Id];
        Contact c = [SELECT Id FROM Contact WHERE AccountId = :a.Id];
        Case ca = [SELECT Id FROM Case WHERE Auction_Number__c = :au.Id];
        Customer_Inquiry__c ci = new Customer_Inquiry__c(
            Account__c = a.Id,
            Auction__c = au.Id,
            Contact__c = c.Id,
            External_Id__c = '1234_1234',
            Origin__c = 'Report a Problem',
            Priority__c = 'Low',
            Call_Count__c = 1,
            Call_Bucket__c = 'Titles',
            Call_Type__c = 'Buyer Title Status',
            Call_Notes__c = 'test notes'
        );
        Test.startTest();
            insert ci;
        Test.stopTest();

        ci = [SELECT Id, Ops_Case__c, Assigned_To__c, Initial_Inquiry_Comment__c FROM Customer_Inquiry__c WHERE Account__c = :a.Id];
        System.assert(ci != null);
        System.assertEquals(ca.Id, ci.Ops_Case__c);
        //System.assertEquals(a.Title_Specialist__c, ci.Assigned_To__c);
        System.assertEquals('test notes', ci.Initial_Inquiry_Comment__c);
    }

    //test assigned to if certain information is missing
    // @isTest
    // static void testMissingSpcialistAndConsultant() {
    //     Account a = [SELECT Id, Title_Specialist__c FROM Account WHERE Title_Specialist__c = null];
    //     Auction__c au = [SELECT Id FROM Auction__c WHERE Buyer_Dealership__c = :a.Id];
    //     Contact co = [SELECT Id FROM Contact WHERE AccountId = :a.Id];
    //     Customer_Inquiry__c ci = new Customer_Inquiry__c(
    //         Account__c = a.Id,
    //         Auction__c = au.Id,
    //         Contact__c = co.Id,
    //         External_Id__c = '1234_1234',
    //         Origin__c = 'Report a Problem',
    //         Priority__c = 'Low',
    //         Call_Count__c = 1,
    //         Call_Bucket__c = 'Titles',
    //         Call_Type__c = 'Buyer Reported Problem',
    //         Call_Notes__c = 'test notes'
    //     );
    //     Test.startTest();
    //         insert ci;
    //     Test.stopTest();

    //     ci = [SELECT Id, Assigned_To__c, Should_Assign_To__c FROM Customer_Inquiry__c WHERE Account__c = :a.Id];
    //     System.assert(ci != null);
    //     System.assertEquals(null, ci.Assigned_To__c);
    //     System.assertEquals('Specialist', ci.Should_Assign_To__c);
    // }

    //test no errors thrown if there are multiple title cases - creates a CI with the most recent case record - can add another case in the beginning of the test
    @isTest
    static void testMultipleTitleCases() {
        //add a new titles case - have to query for the other records first
        Account a = [SELECT Id, Title_Specialist__c FROM Account WHERE Title_Specialist__c = null];
        Auction__c au = [SELECT Id FROM Auction__c WHERE Buyer_Dealership__c = :a.Id];
        Contact co = [SELECT Id FROM Contact WHERE AccountId = :a.Id];
        Case c1 = TestUtility.createTitleCase(au, a, co);
            c1.CreatedDate = System.Today().addDays(-5);
        insert c1;
        
        Customer_Inquiry__c ci = new Customer_Inquiry__c(
            Account__c = a.Id,
            Auction__c = au.Id,
            Contact__c = co.Id,
            External_Id__c = '1234_1234',
            Origin__c = 'Report a Problem',
            Priority__c = 'Low',
            Call_Count__c = 1,
            Call_Bucket__c = 'Titles',
            Call_Type__c = 'Buyer Title Status',
            Call_Notes__c = 'test notes'
        );
        Test.startTest();
            insert ci;
        Test.stopTest();

        Case c2 = [SELECT Id FROM Case WHERE CreatedDate = TODAY AND AccountId = :a.Id]; //should get the other one, hopefully
        ci = [SELECT Id, Ops_Case__c FROM Customer_Inquiry__c WHERE Account__c = :a.Id];
        System.assert(ci != null);
        System.assertEquals(c2.Id, ci.Ops_Case__c);
    }

    //normal functionality - correct information is provided and IC is created
    @isTest
    static void testNormalAfterInsertFunction() {
        Account a = [SELECT Id, Title_Specialist__c FROM Account WHERE Title_Specialist__c != null];
        Auction__c au = [SELECT Id FROM Auction__c WHERE Buyer_Dealership__c = :a.Id];
        Contact co = [SELECT Id FROM Contact WHERE AccountId = :a.Id];
        Customer_Inquiry__c ci = new Customer_Inquiry__c(
            Account__c = a.Id,
            Auction__c = au.Id,
            Contact__c = co.Id,
            External_Id__c = '1234_1234',
            Origin__c = 'Report a Problem',
            Priority__c = 'Low',
            Call_Count__c = 1,
            Call_Bucket__c = 'Titles',
            Call_Type__c = '48 Hour Notice Request', //48 Hour Submit
            Call_Notes__c = 'this is a test note'
        );
        Test.startTest();
            insert ci;
        Test.stopTest();

        ci = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Account__c = :a.Id];
        System.assertEquals(null, ci.Assigned_To__c);
        Inquiry_Comment__c ic = [SELECT Id, Customer_Inquiry__c, Inquiry_Notes__c FROM Inquiry_Comment__c]; //maybe i should add a where clause here? but should only be one
        System.assert(ic != null);
        System.assertEquals(ci.Id, ic.Customer_Inquiry__c);
        System.assertEquals('this is a test note', ic.Inquiry_Notes__c);
    }
}