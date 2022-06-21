@istest
public with sharing class ResolutionGuidGenerationTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = new Account(Name='test account');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact', AccountId = a.id);
        insert c;
        Case ca = new Case(AccountId = a.id, ContactId = c.id);
        insert ca;
        Complaint__c com = new Complaint__c(arbitration_id__c = ca.id, valid__c = 'yes');
        insert com;
        Resolution__c r = new Resolution__c(Case__c = ca.id, complaint_id__c = com.id,amount__c = 600.00, id__c = '1');
        insert r;
        Resolution__c r2 = new Resolution__c(Case__c = ca.id, complaint_id__c = com.id,amount__c = 666.00, id__c = '2');
        insert r2;
    }
    public static testMethod void TestResolutionGuidGenerationUponInsert(){
        Resolution__c newRes = new Resolution__c();
        newRes = [SELECT ID, Resolution_guid__c FROM Resolution__c Where id__c = '1'];
        System.Debug([SELECT ID, Resolution_guid__c FROM Resolution__c Where id__c = '1']);
        System.assert(newRes.Resolution_guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestResolutionGuidGenerationUponUpdate(){
        Resolution__c newReso = new Resolution__c();
        newReso = [SELECT ID, Resolution_guid__c, amount__c FROM Resolution__c Where id__c = '2'];
        newReso.Resolution_guid__c = null;
        update newReso;
        newReso = [SELECT ID, Resolution_guid__c, amount__c, id__c FROM Resolution__c Where id__c = '2' LIMIT 1];
        System.assert(newReso.Resolution_guid__c != null, 'Guid null when it shouldnt be');      
    }
}