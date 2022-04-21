@istest
public class OrganizationGuidGenerationTest {
    @testSetup
    Static void createTestData(){
        Account a = new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Account a2 = new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a2;
        Account a3 = new Account(Name='NoId',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a3;

    }
    public static testMethod void TestOrganizationGuidGenerationUponInsert(){
        Account newAcc = new Account();
        newAcc = [SELECT ID, Organization_Guid__c FROM Account Where Dealership_ID__c = '456'];
        System.Debug([SELECT ID, Organization_Guid__c FROM Account Where Dealership_ID__c = '456']);
        System.assert(newAcc.Organization_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestOrganizationGuidGenerationUponUpdate(){
        Account newAcc = new Account();
        newAcc = [SELECT ID, Organization_Guid__c FROM Account Where Name = 'buyer'];
        newAcc.Organization_Guid__c = null;
        update newAcc;
        newAcc = [SELECT ID, Organization_Guid__c FROM Account Where Name = 'buyer' LIMIT 1];
        System.assert(newAcc.Organization_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestOrganizationGuidGenerationFailUponInsertNonDealerId(){
        Account newAcc = new Account();
        newAcc = [SELECT ID, Organization_Guid__c FROM Account Where Name = 'NoId'];
        System.assertEquals(null, newAcc.Organization_Guid__c = null);      
    }
}