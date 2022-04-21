@isTest
public class BatchTransportationCasesforCDTest {

	@TestSetup static void createData(){
		test.startTest();
			Account actObj = TestUtility.createAccount();
	        insert actObj;
			Contact contactObj = TestUtility.createContact(actObj);
	        insert contactObj;
			Vehicle__c vehicleObj = TestUtility.createVehicle();
	        insert vehicleObj;
			Auction__c auctionObj = TestUtility.createAuction(actObj, contactObj, vehicleObj);
	        auctionObj.Payment_Status__c = 'Paid';
	        insert auctionObj;
	        Account tAcctObj = TestUtility.createTransportAcct();
	        insert tAcctObj;
	        Transportation_Address__c addressObj = TestUtility.createAddress();
	        insert addressObj;
			Case tCaseObj = TestUtility.createTransportCase(addressObj, actObj, contactObj, auctionObj);
	        tCaseObj.Transporter_Account__c = tAcctObj.Id;
	        tCaseObj.Expected_Delivery__c = Date.Today() - 7;
	        tCaseObj.Status = 'Posted';
	        tCaseObj.Send_to_Central_Dispatch__c = true;
	        insert tCaseObj;
	    test.stopTest();

	}

	@isTest static void BatchTransportationCasesforCDTest() {
		Test.startTest();
			BatchTransportationCasesforCD testClass = new BatchTransportationCasesforCD(); //Bill Updated this since it was failing on test deployments
			testClass.executeScheduledLogic();
			Case testTransportCase = [SELECT Id, Status FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
		Test.stopTest();

		System.assertEquals('Posted', testTransportCase.Status);

		
	}
}