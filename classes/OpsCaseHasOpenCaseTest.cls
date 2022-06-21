@isTest
public class OpsCaseHasOpenCaseTest {

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
        Case tc = TestUtility.createTitleCase(au, a, c);
        insert tc;
    }

    @isTest
    static void testInsertofCIUpdatesTitle(){ 
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case titleCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :a.Id];
        Case supportCase = TestUtility.createSupportCase(a);
        insert supportCase;
        
        Test.startTest();
            Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(supportCase, a);
            ci.Ops_Case__c = titleCase.Id;
            insert ci;
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :titleCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should Be True');
        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :supportCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should Be True');
    }

    @isTest
    static void testInsertofCINoTitleUpdate(){ 
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case titleCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :a.Id];
        titleCase.Open_Customer_Inquiry__c = true;
        update titleCase;
        Case supportCase = TestUtility.createSupportCase(a);
        insert supportCase;
        
        Test.startTest();
            Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(supportCase, a);
            ci.Ops_Case__c = titleCase.Id;
            insert ci;
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :titleCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should Be True and unchanged');
    }

    @isTest
    static void testUpdateCIToOpen(){ 
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case titleCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :a.Id];
        titleCase.Open_Customer_Inquiry__c = false;
        update titleCase;

        Case supportCase = TestUtility.createSupportCase(a);
        insert supportCase;
        
        Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(supportCase, a);
        ci.Ops_Case__c = titleCase.Id;
        ci.Status__c = 'Closed';
        insert ci;

        Test.startTest();
            ci.Status__c = 'Working';
            update ci;
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :titleCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should Be set to true when child ci goes from closed to open');
        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :supportCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should Be set to true when child ci goes from closed to open');
    }

    @isTest
    static void testUpdateCIToClosed(){ 
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case titleCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :a.Id];
        titleCase.Open_Customer_Inquiry__c = true;
        update titleCase;

        Case supportCase = TestUtility.createSupportCase(a);
        insert supportCase;
        
        Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(supportCase, a);
        ci.Ops_Case__c = titleCase.Id;
        ci.Status__c = 'New';
        insert ci;

        Test.startTest();
            ci.Status__c = 'Closed';
            update ci;
        Test.stopTest();

        System.assertEquals(false, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :titleCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should Be set to false when child ci goes from open to closed');
    }

    @isTest
    static void testCloseOneOfMultipleCIs(){ 
        List<Customer_Inquiry__c> ciList = new List<Customer_Inquiry__c>();
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case titleCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :a.Id];
        titleCase.Open_Customer_Inquiry__c = true;
        update titleCase;

        Case supportCase = TestUtility.createSupportCase(a);
        insert supportCase;
        
        Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(supportCase, a);
        ci.Ops_Case__c = titleCase.Id;
        ci.Status__c = 'New';
        ciList.add(ci);
        Customer_Inquiry__c ci2 = TestUtility.createCustomerInquiry(supportCase, a);
        ci2.Ops_Case__c = titleCase.Id;
        ci2.Status__c = 'New';
        ciList.add(ci2);
        insert ciList;

        Test.startTest();
            ci2.Status__c = 'Closed';
            update ci2;
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :titleCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should stay true as one of its children are still open');
    }

    @isTest
    static void testUpdateCINoTitleChange(){ 
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case titleCase = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :a.Id];
        titleCase.Open_Customer_Inquiry__c = true;
        update titleCase;

        Case supportCase = TestUtility.createSupportCase(a);
        insert supportCase;
        
        Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(supportCase, a);
        ci.Ops_Case__c = titleCase.Id;
        ci.Status__c = 'New';
        insert ci;

        Test.startTest();
            ci.Status__c = 'Working';
            update ci;
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :titleCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should not be changed when status goes from open to open');
        System.assertEquals(true, [SELECT Id, Open_Customer_Inquiry__c FROM Case WHERE Id = :supportCase.Id].Open_Customer_Inquiry__c, 'Open Customer Inquiry Should not be changed when status goes from open to open');
    }
}