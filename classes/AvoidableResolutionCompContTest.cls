@isTest
public class AvoidableResolutionCompContTest {
	
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
        Resolution__c r = new Resolution__c(Case__c = ca.id, complaint_id__c = com.id,amount__c = 600.00);
        insert r;
    }

    public static testMethod void TestGetAvoidableInformation(){
        ID resID = [SELECT ID FROM Resolution__c LIMIT 1].id;
        AvoidableResolutionCompCont arc = new AvoidableResolutionCompCont();
        arc.resId = resID;
        arc.getNewRes();  
      
      
    }
}