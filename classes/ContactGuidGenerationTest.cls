@istest
public class ContactGuidGenerationTest {

    @testSetup
    Static void createTestData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        
        Account a = new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact1', AccountId = a.id, id__c='123', RecordTypeId = contactRecordTypeId, phone='7894561230');
        insert c;
        Account a2 = new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a2;
        Contact c2 = new Contact(FirstName = 'test', LastName='Contact2', AccountId = a2.id, id__c='456', RecordTypeId = acvuserRecordTypeId, email='test@email.com');
        insert c2;
        Account a3 = new Account(Name='NoId',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a3;
        Contact c3 = new Contact(FirstName = 'test', LastName='Contact3', AccountId = a3.id, email='test@email.com');
        insert c3;

    }
    public static testMethod void TestContactGuidGenerationUponInsert(){
        Contact newCon = new Contact();
        newCon = [SELECT ID, Contact_Guid__c FROM Contact Where id__c = '123'];
        System.Debug([SELECT ID, Contact_Guid__c FROM Contact Where id__c = '123']);
        System.assert(newCon.Contact_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestContactGuidGenerationUponUpdate(){
        Contact newCon = new Contact();
        newCon = [SELECT ID, Contact_Guid__c FROM Contact Where id__c = '456'];
        System.Debug([SELECT ID, Contact_Guid__c, id__c, LastName FROM Contact Where id__c = '456']);
        newCon.Contact_Guid__c = null;
        update newCon;
        newCon = [SELECT ID, Contact_Guid__c FROM Contact Where id__c = '456' LIMIT 1];
        System.Debug([SELECT ID, Contact_Guid__c, id__c, LastName FROM Contact Where id__c = '456']);
        System.assert(newCon.Contact_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestContactGuidGenerationFailUponInsertNonId(){
        Contact newCon = new Contact();
        newCon = [SELECT ID, Contact_Guid__c FROM Contact Where LastName='Contact3'];
        System.assertEquals(null, newCon.Contact_Guid__c = null);      
    }
}