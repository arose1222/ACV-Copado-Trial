@istest
public with sharing class GroupGuidGenerationTest {
    @testSetup
    Static void createTestData(){
        // Account a = new Account(Name='test account');
        // insert a;
        // Contact c = new Contact(FirstName = 'test', LastName='Contact', AccountId = a.id);
        // insert c;
        // Case ca = new Case(AccountId = a.id, ContactId = c.id);
        // insert ca;
        //  com = new Complaint__c(arbitration_id__c = ca.id, valid__c = 'yes');
        // insert com;
        Group__c g = new Group__c(Name = 'The New Group');
        insert g;
        Group__c g2 = new Group__c(Name = 'The Old Group');
        insert g2;
    }
    public static testMethod void TestGroupGuidGenerationUponInsert(){
        Group__c newGrp = new Group__c();
        newGrp = [SELECT ID, Group_Guid__c FROM Group__c Where Name = 'The New Group'];
        System.Debug([SELECT ID, Group_Guid__c FROM Group__c Where Name = 'The New Group']);
        System.assert(newGrp.Group_Guid__c != null, 'Guid null when it shouldnt be');      
    }
    public static testMethod void TestGroupGuidGenerationUponUpdate(){
        Group__c newGrup = new Group__c();
        newGrup = [SELECT ID, Group_Guid__c FROM Group__c Where Name = 'The Old Group'];
        newGrup.Group_guid__c = null;
        update newGrup;
        newGrup = [SELECT ID, Group_Guid__c FROM Group__c Where Name = 'The Old Group' LIMIT 1];
        System.assert(newGrup.Group_guid__c != null, 'Guid null when it shouldnt be');      
    }
}