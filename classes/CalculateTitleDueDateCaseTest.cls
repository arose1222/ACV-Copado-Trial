/**
 * @description https://acvauctions.atlassian.net/browse/TDO-26 requirements.
 * 
 * @author Manmeet Vaseer
 * @date 05/10/2021
 * 
 * @history 06/09/2021 Manmeet Vaseer - Added logic to handle Legal vs Billing state.
 * 			01/11/2022 Manmeet Vaseer - Use Case.CreatedDate instead of Case.Auction_End__c date for the Due Date calculations (https://acvauctions.atlassian.net/browse/TDO-692).
 * 			02/21/2022 Manmeet Vaseer - Modify the Update Trigger to populate the Title Due Date, when Seller Dealership field changes. (https://acvauctions.atlassian.net/browse/TDO-731).
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
    static void testCreateCaseWithoutSeller() {
        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = true;
        testCase.Seller_Dealership__c = null;
        testCase.Status = 'New';
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Case trigger.
         * This should not populate the Title Due Date as the Seller Dealership is null.
         */ 
        insert testCase;
        
		testCase = [Select id, Title_Due_Date__c, Title_Attached__c, Seller_Dealership__c from Case where id=:testCase.ID];
		System.assert(testCase.Seller_Dealership__c == null); 
		System.assert(testCase.Title_Due_Date__c == null); 

        // This should invoke the Update Trigger to populate the Title Due Date.
        testCase.Seller_Dealership__c = acctObj.Id;
        update testCase;

		testCase = [Select id, Title_Due_Date__c, Title_Attached__c, Seller_Dealership__c from Case where id=:testCase.ID];
		System.assert(testCase.Seller_Dealership__c != null); 
		System.assert(testCase.Title_Due_Date__c != null); 
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());

        testCase.Status = 'Closed Unwound';
        update testCase;

		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());
        
        testCase.Title_Attached__c = false;
        update testCase;
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());
        
        /*
         * This should invoke CaseCalculateTitleDueDate handler in the Account trigger,
         * which will update the Title Due Date field in related Cases.
         */ 
        acctObj.BillingState = 'FL';
        update acctObj;

		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.now().Date().addDays(29), testCase.Title_Due_Date__c.Date());
        
        testCase.Title_Attached__c = false;
        update testCase;
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.now().Date().addDays(6), testCase.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(29), testCase.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(6), testCase.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(6), testCase1.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(44), testCase1.Title_Due_Date__c.Date());
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
        System.assertEquals(system.now().Date().addDays(29), testCase1.Title_Due_Date__c.Date());
    } 

}