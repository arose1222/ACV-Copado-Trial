@isTest
public class ResolutionTrigger_Test {
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
        List<Integration_Result__c> integrationTest= [Select id, Status_Code__c, Integration_Name__c From Integration_Result__c];
        System.Debug(integrationTest);
        System.assertEquals(1, integrationTest.size());
    }
    
    @isTest public static void testResolution(){
        Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock());
        complaint__c complaintObj = [select id,description__c, arbitration_id__c from complaint__c limit 1]; 
        Resolution__c res = New Resolution__c(Amount__c=1000,Resolution__c='ACV Issue Check',Goodwill__c=True, Case__c = complaintObj.arbitration_id__c,complaint_id__c = complaintObj.Id);
        insert res;
    }

    @isTest public static void testResolutionCount(){
        //Investigate why Queablejob writeback is not populating in test code
        //Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock(200, 'OK', '{"status":"ok","adjustment_id":42121}', new Map<String,String>{'Content-Type' => 'application/json'}));
        List<Integration_Result__c> integrationTest= [Select id, Status_Code__c, Integration_Name__c From Integration_Result__c];
        complaint__c complaintObj = [select id,description__c, arbitration_id__c from complaint__c limit 1]; 
        Resolution__c res = New Resolution__c(Amount__c=1000,Resolution__c='ACV Issue Check',Goodwill__c=True, Case__c = complaintObj.arbitration_id__c,complaint_id__c = complaintObj.Id);
        Test.startTest();
        insert res;
        Test.stopTest();
        integrationTest= [Select id, Status_Code__c, Integration_Name__c, Integration_Type__c, recordId__c, SObject_Name__c, Status_Message__c, Request_Message__c, Response_Message__c From Integration_Result__c WHERE Integration_Name__c = 'Create Adjustment'];
        System.Debug(integrationTest);

	    List<String> userNames = new List<String>();
        List<Integration_User_Name__mdt> lACVIntegrationObj = [select MasterLabel from Integration_User_Name__mdt];
		userNames = new List<String>();
		for(Integration_User_Name__mdt obj :lACVIntegrationObj ){
		    userNames.add(obj.MasterLabel);
		}

        If(userNames.contains(UserInfo.getUsername())){
            System.assertEquals(0, integrationTest.size(), 'Expect result was 0 records, the following records were actually returned: ' + integrationTest );
        } else{
            System.assertEquals(1, integrationTest.size(), 'Expect result was 1 record, the following records were actually returned: ' + integrationTest );
        }
    }
}