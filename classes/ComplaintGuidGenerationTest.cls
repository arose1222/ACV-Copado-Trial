@istest
public with sharing class ComplaintGuidGenerationTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Id arbrecordTypeId = Schema.SObjectType.Complaint__c.getRecordTypeInfosByName().get('Arbitration Complaint').getRecordTypeId();

        Account a = new Account(Name='test account');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact', AccountId = a.id);
        insert c;
        Case ca = new Case(AccountId = a.id, ContactId = c.id);
        insert ca;
        Complaint__c com = new Complaint__c(arbitration_id__c = ca.id, valid__c = 'yes', id__c = '1', RecordTypeId = arbrecordTypeId);
        insert com;
        Complaint__c com2 = new Complaint__c(arbitration_id__c = ca.id, valid__c = 'yes', id__c = '2', RecordTypeId = arbrecordTypeId);
        insert com2;
        Resolution__c r = new Resolution__c(Case__c = ca.id, complaint_id__c = com.id,amount__c = 600.00);
        insert r;
    }
    public static testMethod void TestComplaintGuidGenerationUponInsert(){
        Complaint__c newCom = new Complaint__c();
        newCom = [SELECT ID, Complaint_guid__c FROM Complaint__c Where id__c = '1'];
        System.Debug([SELECT ID, Complaint_guid__c FROM Complaint__c Where id__c = '1']);
        System.assert(newCom.Complaint_guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestResolutionGuidGenerationUponUpdate(){
        Complaint__c newComp = new Complaint__c();
        newComp = [SELECT ID, Complaint_guid__c FROM Complaint__c Where id__c = '2'];
        newComp.Complaint_guid__c = null;
        update newComp;
        newComp = [SELECT ID, Complaint_guid__c, id__c FROM Complaint__c Where id__c = '2' LIMIT 1];
        System.assert(newComp.Complaint_guid__c != null, 'Guid null when it shouldnt be');      
    }
}