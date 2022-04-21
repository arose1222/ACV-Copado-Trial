@isTest
public class ComplaintTrigger_Test {
    
    @TestSetup static void createData(){
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock());
        Account actObj = TestUtility.createAccount();
        insert actObj;
        Contact contactObj = TestUtility.createContact(actObj);
        insert contactObj;
        Vehicle__c vehicleObj = TestUtility.createVehicle();
        Insert vehicleObj;
        Auction__c auctionObj = TestUtility.createAuction(vehicleObj);
        insert auctionObj;
        Case CaseObj = TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj);
        insert CaseObj;
        complaint__c complaintObj = TestUtility.createComplaint(CaseObj);
        insert complaintObj;
    }
    
    @isTEst public static void testComplaint(){
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock());
        complaint__c complaintObj = [select id,description__c from complaint__c limit 1]; 
        complaintObj.description__c = 'Test Description';
        update complaintObj;
    }
}