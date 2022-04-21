@isTest
public class Arbitration_Trigger_Test {
@testSetup
    public static void createData(){
        Account actObj = TestUtility.createAccount();
        insert actObj;
        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        Insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
    	insert auctionObj;
        System.debug('After auction Object');
		Case CaseObj = TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj);
    	insert CaseObj;
    }
    public testmethod static void updateArb(){
       case caseObj = [select id,status from Case limit 1];
        caseObj.Status = 'Closed';
        update caseObj;
    }
}