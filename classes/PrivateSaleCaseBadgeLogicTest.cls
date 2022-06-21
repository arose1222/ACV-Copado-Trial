/**
 * Test Class of PrivateSaleCaseBadgeLogic
 * @author Ravi Shukla
 * @since Jan 27th, 2022
 */
@isTest
public class PrivateSaleCaseBadgeLogicTest {
    @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        
      //Create new account record
        Account a = new Account (Name='Test Exceptions Update');
        insert a;
        Account b = new Account (Name='Buyer Test');
        insert b;
        
    //Create new Private Lane records    
        Private_Lane__c pl = TestUtility.createPrivateLane();
        insert pl;
        
    //Create new auction record
        Auction__c au = new Auction__c (Name='987654321', vin__c ='111',Private_Lane__c = pl.Id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id, ACV_Inop__c = false);
        insert au;
        
    //Create new case record
    	Id recordTypeCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();
        Case c = new Case (RecordTypeId=recordTypeCase, Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=b.id, Auction_number__c=au.id);
        insert c;
        
    }
    
    @isTest
    static void testCaseStatus(){
        
		boolean status = false;
        test.startTest();
        List<case> caseList = [select id,VIN__c, Auction_number__c from case limit 1];
        PrivateSaleCaseBadgeLogic psc = new PrivateSaleCaseBadgeLogic();
			status = psc.checkLogic('Private_Sale_Case',caseList[0].Id);        
        test.stopTest();

        system.assert(status, 'Case must be private sale');
    }
    
   
}