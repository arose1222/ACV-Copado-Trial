@isTest
public class SetFollowUpDatesTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c au = TestUtility.createAuction(v);
        insert au;

        List<Case> titleCases = new List<Case>();
        List<Case> allCases = new List<Case>();
        Case titleCase = TestUtility.createTitleCase(au, a, c);
        allCases.add(titleCase);
        Case openSupportCase = TestUtility.createSupportCase(a);
        allCases.add(openSupportCase);
        Case closedSupportCase = TestUtility.createSupportCase(a);
        closedSupportCase.Status = 'Closed';
        allCases.add(closedSupportCase);
        Case arbCase = TestUtility.createCase(au,v,a,c);
        allCases.add(arbCase);
        insert allCases;

        titleCases.add(titleCase);
        List<Customer_Inquiry__c> inquiries = new List<Customer_Inquiry__c>();
        inquiries.addAll(TestUtility.createRelatedCasesCaseContext(titleCases,openSupportCase));
        inquiries.addAll(TestUtility.createRelatedCasesCaseContext(titleCases,closedSupportCase));
        insert inquiries;
    }

    @isTest
    static void testNextFollowLoggedOnTitleCaseByTitleUser(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Titles'];
        User titleUser = TestUtility.createUser(p.Id);

        Case titleCase = [SELECT Id FROM Case WHERE Subject = 'Title Testing'];
        Test.startTest();
        System.runAs(titleUser){
            Task loggedCall = new Task();
            loggedCall.Call_On_Title_Case__c = true;
            loggedCall.WhatId = titleCase.Id;
            loggedCall.Reason_for_Outreach__c = 'Aged Title';
            loggedCall.Reason_For_Title_Delay__c = 'DMV Delay';
            loggedCall.Follow_Up_Date__c = System.today().addDays(2);
            insert loggedCall;
        }
        Test.stopTest();

        titleCase = [SELECT Id, Next_Follow_Up__c, Ops_Last_Call_Date__c FROM Case WHERE Subject = 'Title Testing'];
        System.assertEquals(System.today().addDays(2),titleCase.Next_Follow_Up__c, 'Next follow up date should equal follow up date on logged call');
        System.assertEquals(System.today(),titleCase.Ops_Last_Call_Date__c, 'Ops Last Call up date should be set to today');
    }

    @isTest
    static void testNextFollowLoggedOnTitleCaseByNonTitleUser(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Territory Manager'];
        User territoryManager = TestUtility.createUser(p.Id);

        Case titleCase = [SELECT Id FROM Case WHERE Subject = 'Title Testing'];
        Test.startTest();
        System.runAs(territoryManager){
            Task loggedCall = new Task();
            loggedCall.Call_On_Title_Case__c = true;
            loggedCall.WhatId = titleCase.Id;
            loggedCall.Reason_for_Outreach__c = 'Other';
            insert loggedCall;
        }
        Test.stopTest();

        titleCase = [SELECT Id, Next_Follow_Up__c, Ops_Last_Call_Date__c FROM Case WHERE Subject = 'Title Testing'];
        System.assertEquals(null,titleCase.Next_Follow_Up__c, 'Next follow up date should equal follow up date on logged call');
        System.assertEquals(null,titleCase.Ops_Last_Call_Date__c, 'Ops Last Call up date should be set to today');
    }

    @isTest
    static void testLastFollowOnRelatedSupportCase(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Title Manager'];
        User titleUser = TestUtility.createUser(p.Id);

        Case titleCase = [SELECT Id FROM Case WHERE Subject = 'Title Testing'];
        Test.startTest();
        System.runAs(titleUser){
            Task loggedCall = new Task();
            loggedCall.Call_On_Title_Case__c = true;
            loggedCall.WhatId = titleCase.Id;
            loggedCall.Description = 'Here are the comments';
            loggedCall.Follow_Up_Date__c = System.Today().addDays(3);
            loggedCall.Reason_For_Title_Delay__c = 'Unable to Reach';
            loggedCall.Reason_for_Outreach__c = 'Other';
            insert loggedCall;
        }
        Test.stopTest();

        Task callLogged = [SELECT Id, Description, Reason_For_Title_Delay__c FROM Task WHERE WhatId = :titleCase.Id];
        List<Inquiry_Comment__c> comments = [SELECT Id, Feed_Task_Created__c, Inquiry_Notes__c FROM Inquiry_Comment__c WHERE Customer_Inquiry__r.Ops_Case__c = :titleCase.Id];
        for(Inquiry_Comment__c ic : comments){
            System.assertEquals(true,ic.Feed_Task_Created__c, 'When Inquiry comment is created by log a call on ops case, Feed_Task_Created__c should set to true');
            System.assert(ic.Inquiry_Notes__c.contains(callLogged.Description), 'When Inquiry comment is created by log a call description should populate in Inquiry Notes');
            System.assert(ic.Inquiry_Notes__c.contains(callLogged.Reason_For_Title_Delay__c), 'When Inquiry comment is created by log a call reason for title delay should populate in Inquiry Notes');
        }
    }

    @isTest
    static void testCallLoggedNoUpdateToClosedInquiry(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Title Manager'];
        User titleUser = TestUtility.createUser(p.Id);

        Case titleCase = [SELECT Id FROM Case WHERE Subject = 'Title Testing'];
        List<Customer_Inquiry__c> ciList = [SELECT Id, Status__c FROM Customer_Inquiry__c];
        for (Customer_Inquiry__c ci : ciList) {
            ci.Status__c = 'Closed';
        }
        update ciList;

        Test.startTest();
        System.runAs(titleUser){
            Task loggedCall = new Task();
            loggedCall.Call_On_Title_Case__c = true;
            loggedCall.WhatId = titleCase.Id;
            loggedCall.Description = 'Here are the comments';
            loggedCall.Follow_Up_Date__c = System.Today().addDays(3);
            loggedCall.Reason_For_Title_Delay__c = 'Unable to Reach';
            loggedCall.Reason_for_Outreach__c = 'Other';
            insert loggedCall;
        }
        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Inquiry_Comment__c], 'Inquiry comments should only be logged on open Customer Inquries');
    }

    @isTest
    static void testNonTitleCallLogged(){ 
        Case titleCase = [SELECT Id FROM Case WHERE Subject = 'Title Testing'];
        Test.startTest();
        Task loggedCall = new Task();
        loggedCall.WhatId = titleCase.Id;
        loggedCall.Follow_Up_Date__c = System.today().addDays(3);
        insert loggedCall;
        Test.stopTest();

        titleCase = [SELECT Id, Next_Follow_Up__c, Ops_Last_Call_Date__c FROM Case WHERE Subject = 'Title Testing'];
        System.assertEquals(null,titleCase.Next_Follow_Up__c, 'Next follow up date should not be populated if Task is not created with Call On Title Case set to true');
        System.assertEquals(null,titleCase.Ops_Last_Call_Date__c, 'Ops Last Call up date should not be populated if Task is not created with Call On Title Case set to true');
    }

    @isTest
    static void testCallLoggedOnSupportCaseWithISTUser(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Inside Sales - Activation'];
        User istUser = TestUtility.createUser(p.Id);

        Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case supportCase = [SELECT Id FROM Case WHERE RecordTypeId = :supportRecordTypeId limit 1];
        Test.startTest();
        System.runAs(istUser){
            Task loggedCall = new Task();
            loggedCall.WhatId = supportCase.Id;
            insert loggedCall;
        }
        Test.stopTest();

        supportCase = [SELECT Id, IST_Last_Call_Date__c FROM Case WHERE Id = :supportCase.Id];
        System.assertEquals(System.today(),supportCase.IST_Last_Call_Date__c, 'IST Last Call should be updated to today when on a support case that has a call logged on it');
    }

    @isTest
    static void testCallLoggedOnSupportCaseWithOutISTUser(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Territory Manager'];
        User territoryManager = TestUtility.createUser(p.Id);

        Id supportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Case supportCase = [SELECT Id FROM Case WHERE RecordTypeId = :supportRecordTypeId limit 1];
        Test.startTest();
        System.runAs(territoryManager){
            Task loggedCall = new Task();
            loggedCall.WhatId = supportCase.Id;
            insert loggedCall;
        }
        Test.stopTest();

        supportCase = [SELECT Id, IST_Last_Call_Date__c FROM Case WHERE Id = :supportCase.Id];
        System.assertEquals(null,supportCase.IST_Last_Call_Date__c, 'IST Last Call should not be updated when not done by IST User profile');
    }

    @isTest
    static void testCallLoggedWithWhoId(){ 
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        Task loggedCall = new Task();
        loggedCall.WhoId = con.Id;
        insert loggedCall;
        Test.stopTest();

        System.assertEquals(1,[SELECT COUNT() FROM Task LIMIT 1], 'Task should create without WhatId and with a WhoId');
    }

    @isTest
    static void testCallLoggedWithOutWhatId(){ 
        Test.startTest();
        Task loggedCall = new Task();
        insert loggedCall;
        Test.stopTest();

        System.assertEquals(1,[SELECT COUNT() FROM Task LIMIT 1], 'Task should create without WhatId');
    }

    @isTest
    static void testCallLoggedOnArbitrationCase(){ 
        Id arbitrationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Case arbCase = [SELECT Id FROM Case WHERE RecordTypeId = :arbitrationRecordTypeId limit 1];
        Test.startTest();
        Task loggedCall = new Task();
        loggedCall.WhatId = arbCase.Id;
        insert loggedCall;
        Test.stopTest();

        arbCase = [SELECT Id, IST_Last_Call_Date__c FROM Case WHERE Id = :arbCase.Id];
        System.assertEquals(null,arbCase.IST_Last_Call_Date__c, 'IST Last Call should not be updated on arbitration Case');
    }
}