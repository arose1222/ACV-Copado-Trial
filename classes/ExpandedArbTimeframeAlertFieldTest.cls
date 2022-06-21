@isTest
public class ExpandedArbTimeframeAlertFieldTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //account
        Account a = TestUtility.createAccount('Test 1');
        insert a;
        //contact
        Contact c = TestUtility.createContact(a);
        insert c;
        //vehicle
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
    }

    @isTest
    static void testOriginalFunctionPreserved() {
        //query for the account, contact, and vehicle records
        Account a = [SELECT Id FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //create two auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2019, 09, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2019, 09, 09);
            au.ACV_Transportation_Requested__c = true;
            au.Arbitration_Plan__c = 10;
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2019, 09, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2019, 09, 09);
            au2.ACV_Transportation_Requested__c = false;
            au2.Arbitration_Plan__c = 10;
        aucList.add(au2);
        insert aucList;
        //and three cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c);
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
        caseList.add(ca3);
        insert caseList;

        DateTime dt = DateTime.newInstance(2019, 09, 11, 12, 00, 00); //1
        Test.setCreatedDate(caseList[0].Id, dt);
        DateTime dt2 = DateTime.newInstance(2019, 09, 12, 12, 00, 00); //3
        Test.setCreatedDate(caseList[1].Id, dt2);
        DateTime dt3 = DateTime.newInstance(2019, 09, 11, 12, 30, 00); //2
        Test.setCreatedDate(caseList[2].Id, dt3);

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testPandemicFunctionPreservedWithTranspo() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2020, 07, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2020, 07, 11);
            au.ACV_Transportation_Requested__c = true;
            au.Arbitration_Plan__c = 10;
            au.payment_method__c = 'ach';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2020, 07, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2020, 07, 11);
            au2.ACV_Transportation_Requested__c = true;
            au2.Arbitration_Plan__c = 20;
            au2.payment_method__c = 'ach';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2020, 07, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2020, 07, 11);
            au3.ACV_Transportation_Requested__c = true;
            au3.Arbitration_Plan__c = 20;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c); //realease datetime should be null
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2020, 07, 05, 12, 00, 00);
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2020, 07, 05, 12, 00, 00);
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2020, 07, 05, 12, 00, 00);
        caseList.add(ca4);
        insert caseList;

        DateTime dt = DateTime.newInstance(2020, 07, 16, 12, 00, 00); //1
        Test.setCreatedDate(caseList[0].Id, dt);
        DateTime dt2 = DateTime.newInstance(2020, 07, 16, 12, 30, 00); //2
        Test.setCreatedDate(caseList[1].Id, dt2);
        DateTime dt3 = DateTime.newInstance(2020, 07, 22, 12, 00, 00); //3
        Test.setCreatedDate(caseList[2].Id, dt3);
        DateTime dt4 = DateTime.newInstance(2020, 07, 22, 12, 30, 00); //4
        Test.setCreatedDate(caseList[3].Id, dt4);

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testPandemicFunctionPreservedWithoutTranspo() { //make sure that the pandemic function of the field is still working so if old records are pulled up they display the right data
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2020, 07, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2020, 07, 11);
            au.ACV_Transportation_Requested__c = false;
            au.Arbitration_Plan__c = 10;
            au.payment_method__c = 'ach';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2020, 07, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2020, 07, 11);
            au2.ACV_Transportation_Requested__c = false;
            au2.Arbitration_Plan__c = 20;
            au2.payment_method__c = 'ach';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2020, 07, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2020, 07, 11);
            au3.ACV_Transportation_Requested__c = false;
            au3.Arbitration_Plan__c = 20;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c); //realease datetime should be null
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2020, 07, 05, 12, 00, 00);
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2020, 07, 05, 12, 00, 00);
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2020, 07, 05, 12, 00, 00);
        caseList.add(ca4);
        insert caseList;

        DateTime dt = DateTime.newInstance(2020, 07, 16, 12, 00, 00); //1
        Test.setCreatedDate(caseList[0].Id, dt);
        DateTime dt2 = DateTime.newInstance(2020, 07, 16, 12, 30, 00); //2
        Test.setCreatedDate(caseList[1].Id, dt2);
        DateTime dt3 = DateTime.newInstance(2020, 07, 22, 12, 00, 00); //3
        Test.setCreatedDate(caseList[2].Id, dt3);
        DateTime dt4 = DateTime.newInstance(2020, 07, 22, 12, 30, 00); //4
        Test.setCreatedDate(caseList[3].Id, dt4);

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testCurrentFunction10DaysWithTransport() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //test the current 10 days arb plan function
        List<Auction__c> aucList = new List<Auction__c>();

        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v); //might want to have a test where the claim date is over 15, but because the car was delivered late it's still in timeframe
            au.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 13);
            au.Arbitration_Plan__c = 10;
            au.payment_method__c = 'ach';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 13);
            au2.Arbitration_Plan__c = 10;
            au2.payment_method__c = 'ebill';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au3.Arbitration_Plan__c = 10;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;

        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c); //might want to have a test where the claim date is over 15, but because the car was delivered late it's still in timeframe (in the transport = true section)
            ca.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 17);
            ca.Date_Delivered_Actual__c = Date.newInstance(2021, 06, 15);
            ca.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca2.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 17);
            ca2.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca3.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 17);
            ca3.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca4.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 17);
            ca4.Date_Delivered_Actual__c = Date.newInstance(2021, 06, 13); //make sure this is set to a date that will still make sense
            ca4.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca4);
        insert caseList;

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testCurrentFunction10DaysWithoutTransport() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //test the current 10 days arb plan function
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au.Arbitration_Plan__c = 10;
            au.payment_method__c = 'ach';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au2.Arbitration_Plan__c = 10;
            au2.payment_method__c = 'ebill';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au3.Arbitration_Plan__c = 10;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c);
            ca.Release_Datetime__c = DateTime.newInstance(2021, 06, 05, 12, 00, 00);
            ca.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 13);
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca2.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 17);
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca3.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 13);
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2021, 06, 03, 12, 00, 00);
            ca4.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 13);
        caseList.add(ca4);
        insert caseList;

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testCurrentFunction20DaysWithTransport() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //test the current 20 days arb plan function
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au.Arbitration_Plan__c = 20;
            au.payment_method__c = 'ach';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au2.Arbitration_Plan__c = 20;
            au2.payment_method__c = 'ebill';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au3.Arbitration_Plan__c = 20;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c);
            ca.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
            ca.Date_Delivered_Actual__c = Date.newInstance(2021, 06, 15);
            ca.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca2.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
            ca2.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca3.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
            ca3.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca4.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
            ca4.Date_Delivered_Actual__c = Date.newInstance(2021, 06, 11); //this one can just be the same as the other date
            ca4.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca4);
        insert caseList;

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testCurrentFunction20DaysWithoutTransport() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //test the current 20 days arb plan function
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au.Arbitration_Plan__c = 20;
            au.payment_method__c = 'ebill';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au2.Arbitration_Plan__c = 20;
            au2.payment_method__c = 'ach';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au3.Arbitration_Plan__c = 20;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c);
            ca.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 18);
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca2.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca3.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca4.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 22);
        caseList.add(ca4);
        insert caseList;

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testCurrentFunction30DaysWithTransport() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //test the current 30 days arb plan function
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au.Arbitration_Plan__c = 30;
            au.payment_method__c = 'ach';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au2.Arbitration_Plan__c = 30;
            au2.payment_method__c = 'ebill';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au3.Arbitration_Plan__c = 30;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c);
            ca.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
            ca.Date_Delivered_Actual__c = Date.newInstance(2021, 06, 15); //needs to be less than 20 days before claim date
            ca.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca2.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
            ca2.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca3.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
            ca3.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca4.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
            ca4.Date_Delivered_Actual__c = Date.newInstance(2021, 06, 11); //needs to be more than 20 days before claim date
            ca4.ACV_Transport_Purchased_at_Checkout__c = true;
        caseList.add(ca4);
        insert caseList;

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testCurrentFunction30DaysWithoutTransport() {
        //query for account, contact, and vehicle
        Account a = [SELECT Id, Preferred_Buyer__c FROM Account];
        Contact c = [SELECT Id FROM Contact];
        Vehicle__c v = [SELECT Id FROM Vehicle__c];
        //test the current 30 days arb plan function
        //create 3? auctions
        List<Auction__c> aucList = new List<Auction__c>();
        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
            au.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au.Arbitration_Plan__c = 30;
            au.payment_method__c = 'ebill';
        aucList.add(au);
        Auction__c au2 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au2.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au2.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au2.Arbitration_Plan__c = 30;
            au2.payment_method__c = 'ach';
        aucList.add(au2);
        Auction__c au3 = TestUtility.createAuctionWithUniqueId(a, c, v);
            au3.end_time__c = DateTime.newInstance(2021, 06, 01, 12, 00, 00);
            au3.Transportation_Date_Delivered__c = Date.newInstance(2021, 06, 11);
            au3.Arbitration_Plan__c = 30;
            au3.payment_method__c = 'check';
        aucList.add(au3);
        insert aucList;
        //and 4? cases
        List<Case> caseList = new List<Case>();
        Case ca = TestUtility.createCase(aucList[0], v, a, c);
            ca.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 06, 30);
        caseList.add(ca);
        Case ca2 = TestUtility.createCase(aucList[0], v, a, c);
            ca2.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca2.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
        caseList.add(ca2);
        Case ca3 = TestUtility.createCase(aucList[1], v, a, c);
            ca3.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca3.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
        caseList.add(ca3);
        Case ca4 = TestUtility.createCase(aucList[2], v, a, c);
            ca4.Release_Datetime__c = DateTime.newInstance(2021, 06, 08, 12, 00, 00);
            ca4.Claim_Manually_Submitted_Date__c = Date.newInstance(2021, 07, 02);
        caseList.add(ca4);
        insert caseList;

        List<Case> caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];

        System.assertEquals(null, caseListResult[0].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[1].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
        System.assertNotEquals(null, caseListResult[3].Arb_Timeframe_Alert__c);

        // a.Preferred_buyer__c = true;
        // update a;

        // caseListResult = [SELECT Id, Arb_Timeframe_Alert__c FROM Case ORDER BY CreatedDate ASC];
        // System.assertNotEquals(null, caseListResult[2].Arb_Timeframe_Alert__c);
    }
}