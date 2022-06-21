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
public class CalculateTitleDueDateCaseTest {
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
    static void testTitleAttachedChangeAndStatusClose() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = true;
        testCase.Seller_Dealership__c = acctObj.Id;
        testCase.Status = 'Working';
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Case trigger,
         * which will use related Account to check if the Legal/Billing State has changed and
         * then populate the value of Title Due Date field in Case.
         */ 
        insert testCase;
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);

        testCase.Status = 'Closed Unwound';
        update testCase;

		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);
        
        testCase.Title_Attached__c = false;
        update testCase;
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);            
    }  
    
    @isTest
    static void testTitleAttachedChange() {
        
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
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.BillingState = 'FL';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(29), testCase.Title_Due_Date__c);    
        
        testCase.Title_Attached__c = false;
        update testCase;
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(6), testCase.Title_Due_Date__c);            
    }  

    @isTest
    static void testOtherStateTitleAttachedTrueLegalState() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        acctObj.Legal_State__c = 'FL';
        update acctObj;
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = true;
        testCase.Seller_Dealership__c = acctObj.Id;
        
        Test.startTest();
        insert testCase;
        Test.stopTest();
        
		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(29), testCase.Title_Due_Date__c);
    }  

    @isTest
    static void testCaliforniaTitleAttachedTrueLegalState() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        acctObj.Legal_State__c = 'CA';
        acctObj.BillingState='FL';
        update acctObj;
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = true;
        testCase.Seller_Dealership__c = acctObj.Id;
        
        Test.startTest();
        insert testCase;
        Test.stopTest();
        
		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.today().addDays(44), testCase.Title_Due_Date__c);
    }  
    
    @isTest
    static void testCaliforniaTitleAttachedFalse() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = false;
        testCase.Seller_Dealership__c = acctObj.Id;
        
        Test.startTest();
        insert testCase;
        Test.stopTest();
        
		testCase = [Select id,Title_Due_Date__c from Case where id=:testCase.ID];
		system.assert(testCase.Title_Due_Date__c!=null); 
        system.assert(testCase.Title_Due_Date__c == system.today().addDays(6));
    }  
    
    @isTest
    static void testOtherStateTitleAttachedFalse() {
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        update new account(id=conObj.AccountId,BillingState = 'FL');
        
        Case testCase1 = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase1.Title_Attached__c = false;
        testCase1.Seller_Dealership__c = acctObj.Id;
  		
        Test.startTest();
        insert testCase1;
        Test.stopTest();
        
        testCase1 = [Select id,Title_Due_Date__c from Case where id=:testCase1.ID];
		system.assert(testCase1.Title_Due_Date__c!=null); 
        system.assert(testCase1.Title_Due_Date__c == system.today().addDays(6)); 
    }  
    
    @isTest
    static void testCaliforniaTitleAttachedTrue() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];

        Case testCase1 =TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase1.Title_Attached__c = true;
        testCase1.Seller_Dealership__c = acctObj.Id;
        
        Test.startTest();
        insert testCase1;
        Test.stopTest();
        
        testCase1 = [Select id,Title_Due_Date__c from Case where id=:testCase1.ID];
        system.assert(testCase1.Title_Due_Date__c!=null); 
        system.assert(testCase1.Title_Due_Date__c == system.today().addDays(44));
    }  
    
    @isTest
    static void testOtherStateTitleAttachedTrue() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
		update new account(id=conObj.AccountId,BillingState = 'FL');
        Case testCase1 =TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase1.Title_Attached__c = true;
        testCase1.Seller_Dealership__c = acctObj.Id;
        
        Test.startTest();
        insert testCase1;
        Test.stopTest();
        
        testCase1 = [Select id,Title_Due_Date__c from Case where id=:testCase1.ID];
		system.assert(testCase1.Title_Due_Date__c!=null); 
        system.assert(testCase1.Title_Due_Date__c == system.today().addDays(29)); 
    } 

}