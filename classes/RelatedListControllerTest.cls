@isTest
public with sharing class RelatedListControllerTest {
    public static final Id junctionId = Schema.SObjectType.Inquiry_Comment__c.getRecordTypeInfosByDeveloperName().get('Inquiry_Junction_Object').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account acc = TestUtility.createAccount('Test');
        insert acc;

        List<Contact> conList = new List<Contact>();
        Contact con1 = TestUtility.createContact(acc);
        con1.Department = 'dept1';
        con1.Number_of_Locations__c = 2;
        conList.add(con1);

        Contact con2 = TestUtility.createContact(acc);
        con2.Department = 'dept1';
        con2.Number_of_Locations__c = 3;
        con2.CreatedDate = System.today().addDays(-2);
        conList.add(con2);

        Contact con3 = TestUtility.createContact(acc);
        con3.Department = 'dept2';
        con3.Number_of_Locations__c = 1;
        con3.CreatedDate = System.today().addDays(-4);
        conList.add(con3);

        Contact con4 = TestUtility.createContact(acc);
        con4.Department = 'dept3';
        con4.Number_of_Locations__c = 0;
        con4.CreatedDate = System.today().addDays(-6);
        conList.add(con4);
        insert conList;
    }

    @isTest
    static void testQueryWithNoFiltersOrOrderBy() {
        //test query with no filters
        //test query with no orderby
        Account acc = [SELECT Id FROM Account];
        String jsonString = '{"recordId":"' + acc.Id + '","objectName":"Contact","parentFieldAPIName":"AccountId"}';

        Test.startTest();
            List<Contact> conList = RelatedListController.fetchRecords(jsonString);
        Test.stopTest();

        System.assertEquals(4, conList.size(), 'Should return all four Contacts that are associated with the Account.');
    }

    @isTest
    static void testQueryWith1FilterASC() {
        //test query with 1 filter
        //test query ASC
        Account acc = [SELECT Id FROM Account];
        String jsonString = '{"recordId":"' + acc.Id + '","objectName":"Contact","parentFieldAPIName":"AccountId","fieldName1":"Recordtype.DeveloperName","fieldValue1":"ACV_User","filterType1":"String","operator1":"=","orderField":"CreatedDate","orderDirection":"ASC"}';
        
        Test.startTest();
            List<Contact> consFromLWC = RelatedListController.fetchRecords(jsonString);
        Test.stopTest();

        List<Contact> actualCons = [SELECT Id FROM Contact ORDER BY CreatedDate ASC];

        System.assertEquals(4, consFromLWC.size(), 'Should only return the four Contacts that are the ACV USER record type.');
        System.assertEquals(actualCons[0].Id, consFromLWC[0].Id, 'First contacts should match Ids if ORDER BY is working');
        System.assertEquals(actualCons[1].Id, consFromLWC[1].Id, 'Second contacts should match Ids if ORDER BY is working');
        System.assertEquals(actualCons[2].Id, consFromLWC[2].Id, 'Third contacts should match Ids if ORDER BY is working');
        System.assertEquals(actualCons[3].Id, consFromLWC[3].Id, 'Fourth contacts should match Ids if ORDER BY is working');

    }

    @isTest
    static void testQueryWith2FiltersDESC() {
        //test query with 2 filters
        //test query DESC
        Account acc = [SELECT Id FROM Account];
        String jsonString = '{"recordId":"' + acc.Id + '","objectName":"Contact","parentFieldAPIName":"AccountId","fieldName1":"RecordType.DeveloperName","fieldValue1":"ACV_User","filterType1":"String","operator1":"=","fieldName2":"Department","fieldValue2":"dept1","filterType2":"String","operator2":"!=","orderField":"CreatedDate","orderDirection":"DESC"}';
        
        Test.startTest();
            List<Contact> consFromLWC = RelatedListController.fetchRecords(jsonString);
        Test.stopTest();

        List<Contact> actualCons = [SELECT Id FROM Contact WHERE Department != 'dept1' ORDER BY CreatedDate DESC];

        System.assertEquals(2, consFromLWC.size(), 'Should only return the 2 Contacts that are not dept1.');
        System.assertEquals(actualCons[0].Id, consFromLWC[0].Id, 'First contacts should match Ids if ORDER BY is working');
        System.assertEquals(actualCons[1].Id, consFromLWC[1].Id, 'Second contacts should match Ids if ORDER BY is working');
    }

    @isTest
    static void testQueryWith3Filters() {
        //test query with 3 filters
        Account acc = [SELECT Id FROM Account];
        String jsonString = '{"recordId":"' + acc.Id + '","objectName":"Contact","parentFieldAPIName":"AccountId","fieldName1":"RecordType.DeveloperName","fieldValue1":"ACV_User","filterType1":"String","operator1":"=","fieldName2":"Department","fieldValue2":"dept4","filterType2":"String","operator2":"!=","fieldName3":"Number_of_Locations__c","fieldValue3":"2","filterType3":"Double","operator3":">"}';
        
        Test.startTest();
            List<Contact> consFromLWC = RelatedListController.fetchRecords(jsonString);
        Test.stopTest();

        List<Contact> actualCons = [SELECT Id FROM Contact WHERE Department != 'dept4' AND Number_of_Locations__c > 2 ORDER BY CreatedDate DESC];

        System.assertEquals(1, consFromLWC.size(), 'Should only return the 1 Contacts that are not dept4 and have Number_of_Locations__c > 2.');
        System.assertEquals(actualCons[0].Id, consFromLWC[0].Id, 'Ids should match if correct contact returned');
    }
    
    @isTest
    static void testSibling()	{
        Test.startTest();
                
        String acctUniqueName = 'Test It';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
        newAuction.end_time__c = System.today();
        newAuction.Payment_Status__c='Paid';
        newAuction.Payment_Method__c = 'adi';

        SObject[] newObjs = new SObject[] {newAcct, newContact, newVehicle, newAuction};
        insert newObjs;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Odometer_Reading__c = '123467';
        newTitleCase.AccountId = newAcct.Id;
		newTitleCase.Seller_Contact__c = newContact.Id;
        newTitleCase.Status = 'New';
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;
        
        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;

        Customer_Inquiry__c ci = new Customer_Inquiry__c(Ops_Case__c=newTitleCase.Id, Account__c=newAcct.Id, Call_Bucket__c='Titles', Status__c='New');
        insert ci;        
        
        Test.stopTest();
 
        String jsonString = '{"recordId":"' + qc.Id + '","objectName":"Customer_Inquiry__c","parentFieldAPIName":"Ops_Case__c","siblingObjName":"Quality_Control__c","siblingObjParentFieldName":"Case__c"}';

        List<Customer_Inquiry__c> conList = RelatedListController.fetchRecords(jsonString);
        
        System.assertEquals(1, conList.size(), 'Should return 1 Customer Inquiry record that is associated with the Quality_Control__c.Case__c.');        
    }    
}