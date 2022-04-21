@isTest
public class PolicyArbTimeframeAlertFieldTest {
    @TestSetup
    static void makeData(){
        //account
        Account a = TestUtility.createAccount('Test 1');
        insert a;
        //contact
        Contact c = TestUtility.createContact(a);
        insert c;
        //affiliation?
        //vehicle
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        //auction
        Auction__c au = TestUtility.createAuction(a, c, v);
        DateTime endTime = DateTime.newInstance(2021, 04, 01, 12, 00, 00);
        au.end_time__c = endTime;
        au.Arbitration_Plan__c = 10;
        insert au;
        //arb case
        Case ca = TestUtility.createCase(au, v, a, c);
        insert ca;
    }

    @isTest
    static void testNoACVTranspo10Days() { //arb plan is already 10 and acv transpo purchased is already false
        Case c = [SELECT Id, Claim_Manually_Submitted_Date__c FROM Case];
        //test if the claim date is 10 days out it is valid
        Date d = Date.newInstance(2021, 04, 10);
        c.Claim_Manually_Submitted_Date__c = d;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test if the claim is 11 days out that it is invalid
        Date d2 = Date.newInstance(2021, 04, 11);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testNoACVTranspo20Days() {
        //query auction
        Auction__c a = [SELECT Id, Arbitration_Plan__c FROM Auction__c];
        a.Arbitration_Plan__c = 20;
        update a;
        //query case
        Case c = [SELECT Id, Claim_Manually_Submitted_Date__c FROM Case];
        //test if the claim date is 10 days out it is valid
        Date d = Date.newInstance(2021, 04, 20);
        c.Claim_Manually_Submitted_Date__c = d;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test if the claim is 11 days out that it is invalid
        Date d2 = Date.newInstance(2021, 04, 21);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    @isTest
    static void testNoACVTranspo30Days() {
        //query auction
        Auction__c a = [SELECT Id, Arbitration_Plan__c FROM Auction__c];
        a.Arbitration_Plan__c = 30;
        update a;
        //query case
        Case c = [SELECT Id, Claim_Manually_Submitted_Date__c FROM Case];
        //test if the claim date is 10 days out it is valid
        Date d = Date.newInstance(2021, 04, 30);
        c.Claim_Manually_Submitted_Date__c = d;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test if the claim is 11 days out that it is invalid
        Date d2 = Date.newInstance(2021, 05, 01);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    @isTest
    static void test10DayArbPlanWithACVTranspoPart1() { //arb plan is already 10
        //query auction
        Auction__c a = [SELECT Id, Transportation_Date_Delivered__c FROM Auction__c];
        Date d = Date.newInstance(2021, 04, 05);
        a.Transportation_Date_Delivered__c = d;
        update a;
        //query case
        Case c = [SELECT Id, ACV_Transport_Purchased_at_Checkout__c, Claim_Manually_Submitted_Date__c, Date_Delivered_Actual__c FROM Case];
        //test that with the delivery date inside the 10 days that they have all 10
        c.ACV_Transport_Purchased_at_Checkout__c = true;
        Date d1 = Date.newInstance(2021, 04, 05);
        c.Date_Delivered_Actual__c = d1;
        Date d2 = Date.newInstance(2021, 04, 10);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d3 = Date.newInstance(2021, 04, 11);
        c.Claim_Manually_Submitted_Date__c = d3;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Date_Delivered_Actual__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test that with the delivery date outside the 10 on a monday they have until wednesday
        Date d4 = date.newInstance(2021, 04, 12);
        c.Date_Delivered_Actual__c = d4;
        Date d5 = Date.newInstance(2021, 04, 14);
        c.Claim_Manually_Submitted_Date__c = d5;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d6 = date.newInstance(2021, 04, 15);
        c.Claim_Manually_Submitted_Date__c = d6;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    @isTest
    static void test10DayArbPlanWithACVTranspoPart2() { //arb plan is already 10
        //query auction
        Auction__c a = [SELECT Id, Transportation_Date_Delivered__c FROM Auction__c];
        Date d = Date.newInstance(2021, 04, 05);
        a.Transportation_Date_Delivered__c = d;
        update a;
        //query case
        Case c = [SELECT Id, ACV_Transport_Purchased_at_Checkout__c, Claim_Manually_Submitted_Date__c, Date_Delivered_Actual__c FROM Case];
        //test that with the delivery date outside the 10 on a friday they have until monday
        c.ACV_Transport_Purchased_at_Checkout__c = true;
        Date d1 = Date.newInstance(2021, 04, 16);
        c.Date_Delivered_Actual__c = d1;
        Date d2 = Date.newInstance(2021, 04, 19);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d3 = Date.newInstance(2021, 04, 20);
        c.Claim_Manually_Submitted_Date__c = d3;
        update c;
        c = [SELECT Id, Date_Delivered_Actual__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test that with the delivery date outside the 10 on a saturday they have until tuesday
        Date d4 = Date.newInstance(2021, 04, 17);
        c.Date_Delivered_Actual__c = d4;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d5 = Date.newInstance(2021, 04, 21);
        c.Claim_Manually_Submitted_Date__c = d5;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Date_Delivered_Actual__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //run at least one of these tests with no actual delivery date, just the estimated
        c.Claim_Manually_Submitted_Date__c = d2;
        c.Date_Delivered_Actual__c = null;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    @isTest
    static void test20DayArbPlanWithACVTranspo() {
        //query auction
        Auction__c a = [SELECT Id, Arbitration_Plan__c, Transportation_Date_Delivered__c FROM Auction__c];
        a.Arbitration_Plan__c = 20;
        Date d = Date.newInstance(2021, 04, 05);
        a.Transportation_Date_Delivered__c = d;
        update a;
        //query case
        Case c = [SELECT Id, ACV_Transport_Purchased_at_Checkout__c, Claim_Manually_Submitted_Date__c, Date_Delivered_Actual__c FROM Case];
        //test that with the delivery date inside the 20 days that they have all 20
        c.ACV_Transport_Purchased_at_Checkout__c = true;
        Date d1 = Date.newInstance(2021, 04, 05);
        c.Date_Delivered_Actual__c = d1;
        Date d2 = Date.newInstance(2021, 04, 20);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d3 = Date.newInstance(2021, 04, 21);
        c.Claim_Manually_Submitted_Date__c = d3;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c, Date_Delivered_Actual__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test that with the delivery date outside the first 10 they have 10 extra days after delivery
        Date d4 = Date.newInstance(2021, 04, 15);
        c.Date_Delivered_Actual__c = d4;
        Date d5 = Date.newInstance(2021, 04, 25);
        c.Claim_Manually_Submitted_Date__c = d5;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d6 = Date.newInstance(2021, 04, 26);
        c.Claim_Manually_Submitted_Date__c = d6;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c, Date_Delivered_Actual__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //run at least one of these tests with no actual delivery date, just the estimated
        c.Claim_Manually_Submitted_Date__c = d5;
        c.Date_Delivered_Actual__c = null;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    @isTest
    static void test30DayArbPlanWithACVTranspo() {
        //query auction
        Auction__c a = [SELECT Id, Arbitration_Plan__c, Transportation_Date_Delivered__c FROM Auction__c];
        a.Arbitration_Plan__c = 30;
        Date d = Date.newInstance(2021, 04, 05);
        a.Transportation_Date_Delivered__c = d;
        update a;
        //query case
        Case c = [SELECT Id, ACV_Transport_Purchased_at_Checkout__c, Claim_Manually_Submitted_Date__c, Date_Delivered_Actual__c FROM Case];
        //test that with the delivery date inside the 30 days that they have all 30
        c.ACV_Transport_Purchased_at_Checkout__c = true;
        Date d1 = Date.newInstance(2021, 04, 05);
        c.Date_Delivered_Actual__c = d1;
        Date d2 = Date.newInstance(2021, 04, 30);
        c.Claim_Manually_Submitted_Date__c = d2;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d3 = Date.newInstance(2021, 05, 01);
        c.Claim_Manually_Submitted_Date__c = d3;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c, Date_Delivered_Actual__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //test that with the delivery date outside the first 10 they have 20 extra days after delivery
        Date d4 = Date.newInstance(2021, 04, 15);
        c.Date_Delivered_Actual__c = d4;
        Date d5 = Date.newInstance(2021, 05, 05);
        c.Claim_Manually_Submitted_Date__c = d5;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        Date d6 = Date.newInstance(2021, 05, 06);
        c.Claim_Manually_Submitted_Date__c = d6;
        update c;
        c = [SELECT Id, Claim_Manually_Submitted_Date__c, Policy_Arb_Timeframe_Alert__c, Date_Delivered_Actual__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
        //run at least one of these tests with no actual delivery date, just the estimated
        c.Claim_Manually_Submitted_Date__c = d5;
        c.Date_Delivered_Actual__c = null;
        update c;
        c = [SELECT Id, Policy_Arb_Timeframe_Alert__c FROM Case];
        System.assertNotEquals(null, c.Policy_Arb_Timeframe_Alert__c);
    }

    //FIELDS:
    //Auction:
    //Arbitration_Plan__c
    //Transportation_Date_Delivered__c
    //end_time__c - date/time - might be annoying
    //Case:
    //ACV_Transport_Purchased_at_Checkout__c
    //Claim_Manually_Submitted_Date__c - date
    //Date_Delivered_Actual__c
    //Delivery_Date__c

    //Date name = Date.newInstance(2021, 04, 10);
}