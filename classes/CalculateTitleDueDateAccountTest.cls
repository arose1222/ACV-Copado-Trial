/**
 * @description https://acvauctions.atlassian.net/browse/TDO-26 requirements.
 * 
 * @author Amul
 * @date 05/10/2021
 * 
 * @history 06/09/2021 Manmeet Vaseer - Added logic to handle Legal vs Billing state.
 * 
 */
@isTest
public class CalculateTitleDueDateAccountTest {
    @TestSetup static void createData(){
        Test.startTest();    
        Account actObj = TestUtility.createAccount();
        actObj.BillingState='CA';
        insert actObj;  

        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        Insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(actObj, contactObj, vehicleObj);
        auctionObj.end_time__c= system.today();
        insert auctionObj;
        Test.stopTest();
    }
    
    @isTest
    static void testStateChangeInAccountTitleAttachedTrue() {        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = true;
        testCase.Seller_Dealership__c = acctObj.Id;        
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Case trigger,
         * which will use related Account to check if the Legal/Billing State has changed and
         * then populate the value of Title Due Date field in Case.
         */ 
        insert testCase;
        
		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.BillingState = 'FL';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(29), testCase.Title_Due_Date__c);        

        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.Legal_State__c = 'CA';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);        

        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.Legal_State__c = 'NY';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(29), testCase.Title_Due_Date__c);                
    }  
    
    @isTest
    static void testStateChangeInAccountTitleAttachedFalse() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = false;
        testCase.Seller_Dealership__c = acctObj.Id;        
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Case trigger,
         * which will use related Account to check if the Legal/Billing State has changed and
         * then populate the value of Title Due Date field in Case.
         */ 
        insert testCase;
        
		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(6), testCase.Title_Due_Date__c);
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.BillingState = 'FL';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(6), testCase.Title_Due_Date__c);        

        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.Legal_State__c = 'CA';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(6), testCase.Title_Due_Date__c);        

        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.Legal_State__c = 'NY';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(6), testCase.Title_Due_Date__c);                
    }      
}