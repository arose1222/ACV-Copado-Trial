@istest
public class OrganizationUniqueIdGenerationTest {
    @testSetup
    Static void createTestData(){
        Id transporterAccountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transporters').getRecordTypeId();

        Account a4 = new Account(Name='Test',legal_Name__c='Test',Dealership_ID__c='100', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a4;
        Account a = new Account(Name='seller123',legal_Name__c='seller123', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        System.debug(a);
        Account a2 = new Account(Name='buyer123',legal_Name__c='buyer123', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Rochester', BillingPostalCode='15123', BillingCountry='US');
        insert a2;
        System.debug(a2);
        Account a3 = new Account(Name='NoId',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', No_DOT__c = true, RecordTypeId = transporterAccountRecordId);
        insert a3;

    }
    public static testMethod void TestOrganizationdealerIDGenerationUponInsert(){
        Account newAcc = new Account();
        newAcc = [SELECT ID, Dealership_Id__c FROM Account Where Name = 'seller123'];
        System.Debug([SELECT ID, Dealership_Id__c, RecordType.DeveloperName FROM Account Where Name = 'seller123']);
        System.assert(newAcc.Dealership_Id__c != null, 'dealerId null when it shouldnt be');      
    }
    public static testMethod void TestOrganizationdealerIDGenerationUponUpdate(){
        Account newAcc = new Account();
        newAcc = [SELECT ID, Dealership_Id__c FROM Account Where Name = 'buyer123'];
        newAcc.Dealership_Id__c = null;
        update newAcc;
        newAcc = [SELECT ID, Dealership_Id__c FROM Account Where Name = 'buyer123' LIMIT 1];
        System.assert(newAcc.Dealership_Id__c != null, 'dealerId null when it shouldnt be');      
    }
    public static testMethod void TestOrganizationdealerIDGenerationFailUponInsertNonDealerId(){
        Account newAcc = new Account();
        newAcc = [SELECT ID, Dealership_Id__c FROM Account Where Name = 'NoId'];
        System.assertEquals(null, newAcc.Dealership_Id__c = null);      
    }
}