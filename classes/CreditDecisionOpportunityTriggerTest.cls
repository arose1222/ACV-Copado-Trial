@isTest
public class CreditDecisionOpportunityTriggerTest {
    public static Opportunity testOpportunity;
   
    @isTest static void checkOpportunityModifiesByApexTrigger(){
        
        Account account = TestUtility.createAccount('TEST Experian ACCOUNT');
        User salesRep = TestUtility.createSystemAdministratorUser();
        insert salesRep;
        account.ACV_Capital_Sales_Rep__c = salesRep.Id;
        account.BillingStreet = 'Test Business Street'; 
        account.BillingState = 'TX';
        account.BillingCity = 'Test Business City';
        account.BillingPostalCode = '123456';
        account.Phone = '123456789';
        account.Tax_ID__c = '123456789';
        account.OwnerId = salesRep.Id;
        insert account;
      	CreditDecisionOpportunityTriggerTest.testOpportunity = new Opportunity();
		CreditDecisionOpportunityTriggerTest.testOpportunity.Name = 'TEST Experian ACCOUNT';
        CreditDecisionOpportunityTriggerTest.testOpportunity.CloseDate = system.today();
        CreditDecisionOpportunityTriggerTest.testOpportunity.StageName = 'New';
        CreditDecisionOpportunityTriggerTest.testOpportunity.Capital_Credit_Decisioning__c = False;

        CreditDecisionOpportunityTriggerTest.testOpportunity.OwnerId = salesRep.Id;
        CreditDecisionOpportunityTriggerTest.testOpportunity.AccountId=account.Id;
        CreditDecisionOpportunityTriggerTest.testOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ACV_Capital_Referral').getRecordTypeId();
        insert CreditDecisionOpportunityTriggerTest.testOpportunity;   
        
        
        test.startTest();
        Boolean opportunityFounded = False;
        //CreditDecisionOpportunityTriggerTest.testOpportunity.StageName = 'Underwriting';
        CreditDecisionOpportunityTriggerTest.testOpportunity.Capital_Credit_Decisioning__c = True;
        update CreditDecisionOpportunityTriggerTest.testOpportunity;
       
        Opportunity affectedOpportunity = [SELECT Id, AdditionalComments__c FROM Opportunity 
                                            WHERE Id= :CreditDecisionOpportunityTriggerTest.testOpportunity.Id];
		
        if(affectedOpportunity.AdditionalComments__c == 'Credit Decision Proccess Initiated'){
            opportunityFounded = True;
        }
        
        system.assertEquals(True,opportunityFounded);
        test.stopTest();
    }


}