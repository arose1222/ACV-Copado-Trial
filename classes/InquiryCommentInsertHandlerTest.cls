@isTest
public with sharing class InquiryCommentInsertHandlerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Customer_Inquiry__c> ciList = new List<Customer_Inquiry__c>();
        ciList.add(new Customer_Inquiry__c(Call_Bucket__c = 'Titles', Call_Type__c = 'Seller Title Status'));
        ciList.add(new Customer_Inquiry__c(Call_Bucket__c = 'Helpdesk', Call_Type__c = 'Ghost Bid'));
        insert ciList;
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ciList[1].Id, Inquiry_Notes__c = 'this is a comment');
        insert comm;
    }

    @isTest
    static void testInitialInquiryCommentPopulation() {
        //test where we check that init inq comment is populated
        Customer_Inquiry__c ci = [SELECT Id FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Titles'];
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = 'test notes');
        Test.startTest();
            insert comm;
        Test.stopTest();

        ci = [SELECT Id, Initial_Inquiry_Comment__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Titles'];
        System.assertEquals('test notes', ci.Initial_Inquiry_Comment__c, 'Initial Inquiry Comment should be populated with \'test notes\' and should not be null.');
    }

    @isTest
    static void testMostRecentCommentPopulation() {
        //test where we check that most recent comment is populated
        Customer_Inquiry__c ci = [SELECT Id FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk'];
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = 'this is a recent comment');
        Test.startTest();
            insert comm;
        Test.stopTest();

        ci = [SELECT Id, Most_Recent_Inquiry_Comment__c, Initial_Inquiry_Comment__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk'];
        System.assertEquals('this is a recent comment', ci.Most_Recent_Inquiry_Comment__c, 'Most Recent Inquiry Comment should be populated \'this is a recent comment\' and should not be null.');
        System.assertNotEquals(ci.Most_Recent_Inquiry_Comment__c, ci.Initial_Inquiry_Comment__c, 'The most recent comment and the initial comment should not have the same value.');
    }

    @isTest
    static void testMostRecentCommentNotNull() {
        //test where we check that most recent comment is not made null if they enter a blank note
        Customer_Inquiry__c ci = [SELECT Id FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk'];
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = 'test notes');
        insert comm;
        Inquiry_Comment__c comm2 = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = '');
        Test.startTest();
            insert comm2;
        Test.stopTest();

        ci = [SELECT Id, Most_Recent_Inquiry_Comment__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk'];
        System.assertEquals('test notes', ci.Most_Recent_Inquiry_Comment__c, 'The most recent notes should not be nulled out if the latest comment is blank. It should maintain the newest non null comment.');
    }

    @isTest
    static void testFirstCommentWithoutNotes() {
        Customer_Inquiry__c ci = new Customer_Inquiry__c(Call_Bucket__c = 'Helpdesk', Call_Type__c = 'Other');
        insert ci;
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id);

        Test.startTest();
            insert comm;
        Test.stopTest();

        ci = [SELECT Id, Most_Recent_Inquiry_Comment__c, Initial_Inquiry_Comment__c FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Helpdesk' AND Call_Type__c = 'Other'];
        System.assertEquals(null, ci.Most_Recent_Inquiry_Comment__c, 'If the first logged inquiry comment has Inquiry_Notes__c null, then dont populate Most_Recent_Inquiry_Comment__c');
        System.assertEquals(null, ci.Initial_Inquiry_Comment__c, 'If the first logged inquiry comment has Inquiry_Notes__c null, then dont populate Initial_Inquiry_Comment__c');
    }

    @isTest
    static void testFeedTaskIsCreated() {
        //test where we check that a feed item is being created if there is an ops case - also have a null version
        Account acc = TestUtility.createAccount('Test');
        insert acc;
        Contact con = TestUtility.createContact(acc);
        insert con;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c auc = TestUtility.createAuction(acc,con,v);
        insert auc;

        Case titleCase = TestUtility.createTitleCase(auc,acc,con);
        insert titleCase;

        List<Customer_Inquiry__c> ciList = [SELECT Id, Ops_Case__c FROM Customer_Inquiry__c ORDER BY Call_Type__c ASC];
        for (Customer_Inquiry__c ci : ciList) {
            ci.Ops_Case__c = titleCase.Id;
        }
        update ciList;

        List<Inquiry_Comment__c> commList = new List<Inquiry_Comment__c>();
        commList.add(new Inquiry_Comment__c(Customer_Inquiry__c = ciList[0].Id, Inquiry_Notes__c = 'added notes'));
        commList.add(new Inquiry_Comment__c(Customer_Inquiry__c = ciList[1].Id, Inquiry_Notes__c = ''));
        Test.startTest();
            insert commList;
        Test.stopTest();

        List<Task> taskList = [SELECT Id, Description, Subject, WhatId, From_Inquiry_Comment__c, Inquiry_Status__c, Inquiry_Call_Type__c, Inquiry_Call_Bucket__c FROM Task ORDER BY Subject ASC];
        System.assertEquals(2, taskList.size(), 'The taskList should contain no more or less than two Tasks.');
        System.assertEquals('added notes', taskList[0].Description, 'The description should contain \'added notes\' and should not be null.');
        System.assertEquals('Customer Inquiry - Ghost Bid', taskList[0].Subject, 'The subject of the Task should be set to the Call Type of the CI.');
        System.assertEquals(null, taskList[1].Description, 'The description should be null and should not contain any text.');
        System.assertEquals('Customer Inquiry - Seller Title Status', taskList[1].Subject, 'The subject of the Task should be set to the Call Type of the CI.');
        System.assertEquals(titleCase.Id, taskList[0].WhatId, 'The title case should be listed as the WhatId of the Task.');
        System.assertEquals(true, taskList[0].From_Inquiry_Comment__c, 'When task is created from inquiry comment From inquiry comment should be set to true');

        System.assertEquals('New', taskList[1].Inquiry_Status__c, 'The Inquiry status of the Task should be set to the status of the CI.');
        System.assertEquals('Seller Title Status', taskList[1].Inquiry_Call_Type__c, 'The Inquiry Call Type of the Task should be set to the Call Type of the CI.');
        System.assertEquals('Titles', taskList[1].Inquiry_Call_Bucket__c, 'The Inquiry Call Bucket of the Task should be set to the Call Bucket of the CI.');
    }

    @isTest
    static void testFeedTaskAlreadyLogged() {
        //test where we check that a feed item is not being created if call was logged on ops case
        Account acc = TestUtility.createAccount('Test');
        insert acc;
        Contact con = TestUtility.createContact(acc);
        insert con;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c auc = TestUtility.createAuction(acc,con,v);
        insert auc;

        Case titleCase = TestUtility.createTitleCase(auc,acc,con);
        insert titleCase;

        List<Customer_Inquiry__c> ciList = [SELECT Id, Ops_Case__c FROM Customer_Inquiry__c ORDER BY Call_Type__c ASC];
        for (Customer_Inquiry__c ci : ciList) {
            ci.Ops_Case__c = titleCase.Id;
        }
        update ciList;

        Inquiry_Comment__c comment = new Inquiry_Comment__c(Customer_Inquiry__c = ciList[0].Id, Inquiry_Notes__c = 'added notes', Feed_Task_Created__c = true);
        Test.startTest();
            insert comment;
        Test.stopTest();

        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(0, taskList.size(), 'There should not be any Tasks created when Feed Task Created = true.');
    }

    @isTest
    static void testFeedTaskNotCreated() {
        //test where we check that a feed item is not being created if there is no ops case
        Customer_Inquiry__c ci = [SELECT Id FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Titles'];
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = 'some notes');
        Test.startTest();
            insert comm;
        Test.stopTest();

        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(0, taskList.size(), 'There should not be any Tasks created when Ops Case is null.');
    }
    
    @isTest
    static void testFeedTaskPreviouslyCreated() {
        //test where we check that a feed item is not being created if there is no ops case
        Customer_Inquiry__c ci = [SELECT Id FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Titles'];
        Inquiry_Comment__c comm = new Inquiry_Comment__c(Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = 'some notes', Feed_Task_Created__c = true);
        Test.startTest();
            insert comm;
        Test.stopTest();

        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(0, taskList.size(), 'There should not be any Tasks created when Feed_Task_Created__c = true.');
    }
}