/**
 * @description A batch process to backfill Title Due Date on Case.
 * 				Due to a bug, there were a lots of missing Title Due Date on Case. 
 * 				This batch file will recalcuate the Title Due Date on case based on the https://acvauctions.atlassian.net/browse/TDO-26 requirements.
 * 
 * To run this batch manually:
 * CalculateTitleDueDateBatch be = new CalculateTitleDueDateBatch(45);
 * database.executeBatch(be);
 * 
 * @author Manmeet Vaseer
 * @date 02/11/2022
 * 
 * @history
 * 
 */
@isTest
public class CalculateTitleDueDateBatchTest {
    
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
    static void testUpdateTitleDueDate() {        
        Auction__c auctionObj = [SELECT id,vehicle_id__c FROM Auction__c LIMIT 1];        
        Contact conObj = [SELECT id,AccountId FROM Contact LIMIT 1];
        Account acctObj = [SELECT id,BillingState, Legal_State__c FROM Account WHERE Id = :conObj.AccountId];
        
        Case testCase = TestUtility.createTitleCase(auctionObj, acctObj, conObj);
        testCase.Title_Attached__c = true;
        testCase.Seller_Dealership__c = acctObj.Id;
        testCase.Status = 'Working';
        
        /*
         * Disable all triggers so that it should not invoke CaseCalculateTitleDueDate handler in the Case trigger to update the Title Due Date.
         */ 
		TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>(); // disable all triggers
        insert testCase;

        // Ensure that the Title Due Date is still null.
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c == null); 
        
		// Run the Batch to Update Title Due Date
        CalculateTitleDueDateBatch batch = new CalculateTitleDueDateBatch(10);
        List<Case> qCases = Database.query(batch.getQuery());
        batch.calculateTitleDueDate(qCases);
        
		testCase = [Select id,Title_Due_Date__c, Title_Attached__c from Case where id=:testCase.ID];
		System.assert(testCase.Title_Due_Date__c!=null); 
        System.assertEquals(system.now().Date().addDays(44), testCase.Title_Due_Date__c.Date());
    }      
}