@isTest
public class RemoveVLFromPrescreenControllerTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = new Account(Name = 'ACV');
        insert a;
        Contact c = new Contact(FirstName = 'Bill', LastName = 'Best VCI',AccountId = a.id);
        insert c;
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
        insert cr;
        Condition_Report_Prescreen__c crp = new Condition_Report_Prescreen__c(Condition_Report__c = cr.id, VCI__c = c.id,Seller_Dealership__c = a.id,Vehicle__c = v.id);
        insert crp;
        //doing this to prevent call out in setup method
        c.Virtual_Lift_Enabled__c = true;
        update c;
    }    

    @isTest
    public static void testCancleIfNoPrescreenProvided(){
        System.assert(!RemoveVLFromPrescreenController.removeVLFromVin(''),'True Provided improperly');
    }
    @isTest
    public static void testCancleBadPrescreenProvided(){
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(401,'OK','{"api_version": 2,"data": {"vin": "48394","code": "200"}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Condition_Report_Prescreen__c crp = [Select Id from Condition_Report_Prescreen__c limit 1];
        Test.startTest();
        System.assert(!RemoveVLFromPrescreenController.removeVLFromVin(crp.id),'True Provided improperly');
        Test.stopTest();
    }

    @isTest
    public static void testCancleIfBadPrescreenProvided(){
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"vin": "123jf3245432234","code": "200"}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Condition_Report_Prescreen__c crp = [Select Id from Condition_Report_Prescreen__c limit 1];
        Test.startTest();
        System.assert(RemoveVLFromPrescreenController.removeVLFromVin(crp.id),'False Provided improperly');
        Test.stopTest();
    }
}