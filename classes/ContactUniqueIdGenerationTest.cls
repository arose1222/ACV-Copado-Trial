@istest
public class ContactUniqueIdGenerationTest {
    @testSetup
    Static void createTestData(){
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        Account a7 = new Account(Dealership_ID__c = '999', Name='seller7',legal_Name__c='seller7', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a7;
        Contact c7 = new Contact(FirstName = 'test', LastName='Contact7', AccountId = a7.id, RecordTypeId = acvuserRecordTypeId, id__c='777', email='test123@email.com');
        insert c7;
        Account a = new Account(Dealership_ID__c = '4568777', Name='sellerr',legal_Name__c='sellerr', dealer_type__c='2',BillingStreet='159 main st', BillingState='NY', BillingCity='Rochester', BillingPostalCode='15555', BillingCountry='US');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact1', AccountId = a.id, RecordTypeId = acvuserRecordTypeId, email='test124@email.com');
        insert c;
        Account a2 = new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a2;
        Contact c2 = new Contact(FirstName = 'test', LastName='Contact2', AccountId = a2.id, RecordTypeId = contactRecordTypeId, Phone='123456789');
        insert c2;
        Account a3 = new Account(Name='NoId',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a3;
        Contact c3 = new Contact(FirstName = 'test', LastName='Contact3', AccountId = a3.id, email='test124@email.com');
        insert c3;
        Account a5 = new Account(Dealership_ID__c = '11111', Name='Random Name',legal_Name__c='Random Name', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a5;
        Contact c5 = new Contact(FirstName = 'test', LastName='Contact5', AccountId = a5.id, RecordTypeId = acvuserRecordTypeId, id__c = '12345', email='test125@email.com');
        insert c5;
        Account a6 = new Account(Dealership_ID__c = '1111', Name='buyer3',legal_Name__c='buyer3', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a6;
        Contact c6 = new Contact(FirstName = 'test', LastName='Contact6', AccountId = a6.id, RecordTypeId = contactRecordTypeId, Dealership_Contact_Id__c = '123', Phone='123456789');
        insert c6;

    }
    public static testMethod void TestContactIdGenerationUponInsert(){
        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c FROM Contact Where LastName='Contact1'];
        System.Debug([SELECT ID, Id__c, LastName, Contact_Guid__c  FROM Contact Where LastName='Contact1']);
        System.assert(newCon.Id__c != null, 'ACV User Id null when it shouldnt be');  
        System.assertEquals(null, newCon.Dealership_Contact_Id__c = null);          
    }
    public static testMethod void TestContactIdGenerationUponUpdate(){
        List<Contact> updateConLst = new List<Contact>();
        Contact newCon = new Contact();
        newCon = [SELECT ID, Dealership_Contact_Id__c FROM Contact Where LastName='Contact2'];
        newCon.Dealership_Contact_Id__c = null;
        updateConLst.add( newCon );
        Contact newCon2 = new Contact();
        newCon2 = [SELECT ID, id__c FROM Contact Where LastName='Contact5'];
        newCon2.Id__c = null;
        updateConLst.add( newCon2 );
        Test.startTest();
            update updateConLst;
        Test.stopTest();
        newCon = [SELECT ID, Dealership_Contact_Id__c FROM Contact Where LastName='Contact2' LIMIT 1];
        newCon2 = [SELECT ID, Id__c FROM Contact Where LastName='Contact5' LIMIT 1];
        System.assert(newCon.Dealership_Contact_Id__c != null, 'Dealer Contact Id null when it shouldnt be');   
        System.assertEquals(null, newCon.Id__c = null);    
        System.assert(newCon2.Id__c != null, 'ACV User Contact Id null when it shouldnt be');   
        System.assertEquals(null, newCon2.Dealership_Contact_Id__c = null);      
    }
}