@isTest
public with sharing class SearchTitleClerkApexHandlerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        List<Account> acctList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        Date createdDate = system.today().addDays(-5);
        //make an account
        acctList.add(new Account(Name = 'Test', legal_name__c='Test', Dealer_Type__c='1', phone='1234567890', Dealership_ID__c = '1234', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        acctList.add(new Account(Name = 'Test2', legal_name__c='Test2', Dealer_Type__c='1', phone='1234567890', Dealership_ID__c = '12345', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert acctList;
        //make two contacts that are title clerks
        Contact contact1 = new Contact(FirstName = 'Test 1', LastName = 'Test', Title_Picklist__c = 'Title Clerk', AccountId = acctList[0].Id, Active__c = true, email='test@email.com');
        contactList.add(contact1);
        Contact contact2 = new Contact(FirstName = 'Test 2', LastName = 'Test', Title_Picklist__c = 'Title Clerk', AccountId = acctList[0].Id, Active__c = true, email='test@email.com2');
        contactList.add(contact2);
        Contact contact3 = new Contact(FirstName = 'Test 3', LastName = 'Test', Phone = '(716) 765-4321', Title_Picklist__c = 'Title Clerk', AccountId = acctList[1].Id, Active__c = true, email='test@email.com3');
        contactList.add(contact3);
        insert contactList;
        //set one of the created dates back a few days
        Test.setCreatedDate(contact2.Id, createdDate);

        Case newCase = new Case(Status = 'New', Origin = 'Phone', RecordTypeId = recordTypeId, AccountId = acctList[0].Id, Seller_Dealership__c = acctList[1].Id, ACV_Titles_External_ID__c='123');
        insert newCase;
    }

    @isTest
    public static void testClerkSearch() {
        List<Case> caseIdGet = [SELECT Id FROM Case WHERE Account.Name = 'Test'];

        String results = SearchTitleClerkApexHandler.getTitleClerkBuyerInfo(caseIdGet[0].Id);
        String results2 = SearchTitleClerkApexHandler.getTitleClerkSellerInfo(caseIdGet[0].Id);
        //make sure only one result is being returned
        //System.assertEquals(1, results.size());
        //System.assertEquals('David Test', results);
        System.assertEquals('Test 1 Test - no phone number', results);
        System.assertEquals('Test 3 Test - (716) 765-4321', results2);
        //and that the name returned is the name of the earlier clerk
    }
}