@istest
public with sharing class CaseGuidGenerationTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Id arbrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Id unwindRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();


        Account a = new Account(Name='test account');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact', AccountId = a.id);
        insert c;
        Case ca = new Case(AccountId = a.id, ContactId = c.id, id__c = '1', RecordTypeId = arbrecordTypeId);
        insert ca;
        Case ca2 = new Case(AccountId = a.id, ContactId = c.id, id__c = '2', ACV_Titles_External_ID__c = '123', RecordTypeId = titlerecordTypeId);
        insert ca2;
        Case ca3 = new Case(AccountId = a.id, ContactId = c.id, id__c = '3', RecordTypeId = unwindrecordTypeId);
        insert ca3;
        Complaint__c com = new Complaint__c(arbitration_id__c = ca.id, valid__c = 'yes');
        insert com;
        Resolution__c r = new Resolution__c(Case__c = ca.id, complaint_id__c = com.id,amount__c = 600.00);
        insert r;
    }
    public static testMethod void TestCaseGuidGenerationUponInsert(){
        Case newCas = [SELECT ID, Case_guid__c FROM Case Where id__c = '1'];
        System.Debug([SELECT ID, Case_guid__c FROM Case Where id__c = '1']);
        System.assert(newCas.Case_guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestCaseGuidGenerationUponUpdate(){
        Case newCase = [SELECT ID, Case_guid__c FROM Case Where id__c = '2'];
        newCase.Case_guid__c = null;
        update newCase;
        newCase = [SELECT ID, Case_guid__c, id__c FROM Case Where id__c = '2' LIMIT 1];
        System.assert(newCase.Case_guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestBADCaseGuidGenerationUponInsert(){
        Case newCa = [SELECT ID, Case_guid__c FROM Case Where id__c = '3'];
        System.Debug([SELECT ID, Case_guid__c FROM Case Where id__c = '3']);
        System.assertEquals(null, newCa.Case_guid__c);     
    }
    public static testMethod void TestCaseGuidUponUpdate(){
        Case oldCase = [SELECT id__c, ID, Case_guid__c FROM Case Where id__c = '2'];        
        update oldCase;
        Case updatedCase = [SELECT id__c, ID, Case_guid__c FROM Case Where id__c = '2' LIMIT 1];        
        System.assert(oldCase.Case_guid__c == updatedCase.Case_guid__c, 'Guid is not the same after update');      
    }
}