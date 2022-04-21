@isTest
public class createPrescreenForVirtualLiftCRTest {

    private static string vLRuleData = '[{"DeveloperName":"createPrescreenForVirtualLiftCR","NamespacePrefix":"","Active__c":true,"Class_Name__c":"createPrescreenForVirtualLiftCR","Is_Advanced_Logic__c":true}]';
    private static string vLRuleData2Entries = '[{"DeveloperName":"createPrescreenForVirtualLiftCR","NamespacePrefix":"","Active__c":true,"Class_Name__c":"createPrescreenForVirtualLiftCR","Is_Advanced_Logic__c":true},{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"421","Value_Type__c":"String","Prescreen_Reason__c":"auction420"}]';
    
    @TestSetup
    static void makeData(){
        // String disableTrigger = '[{"DeveloperName": "TestHandler", "NamespacePrefix": "","After_Insert__c": "true","After_Update__c": "true","sObject__c": "Condition_Report__c", "Class_Name__c": "ConditionReportReviewGeneration"}]';
        // TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(disableTrigger, List<TriggerHandler__mdt>.class);
        Account a = TestUtility.createAccount('BillTest');
        a.Active__c = true;
        insert a;
        Contact c = TestUtility.createContact(a);
        c.FirstName = 'Bill';
        c.LastName = 'Test';
        c.Virtual_Lift_Enabled__c = true;
        c.Successful_Virtual_Lift_Prescreens__c = 0;
        c.Identity_Id__c = '123456789';
        insert c;
    }

    @isTest
    static void testSimpleGenerate(){
        Contact c = [select id from Contact where Virtual_Lift_Enabled__c = true limit 1];
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432234","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf3245432234&recent_days_back=90', uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(VLRuleData, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
        Test.startTest();
        insert cr;
        Test.stopTest();
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testInspectionWrapperHandle(){
        
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432234","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf3245432234&recent_days_back=90', uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(VLRuleData, List<CR_Review_Trigger__mdt>.class);
        
        //make map of inspection wrappers

        InspectionDefinition idef = PrescreenServiceInspectionReviewTest.defaultIDef();
        idef.inspectedVehicle.vin = '123jf3245432234';
        idef.inspectorIdentityId = '123456789';

        Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();

        wrapperMap.put(idef.inspectionID, new PrescreenServiceHelper.InspectionWrapper(idef, new Set<String>()));

        CR_Review_Trigger__mdt crt = new CR_Review_Trigger__mdt();
        crt.Prescreen_Reason__c = 'Test Reason';

        createPrescreenForVirtualLiftCR testObject = new createPrescreenForVirtualLiftCR();
        Test.startTest();

        for(PrescreenServiceHelper.InspectionWrapper wrapper: testObject.handle(wrapperMap, crt).values()){
            system.assert(wrapper.prescreenReasons.contains('Test Reason'));
        }

        Test.stopTest();

    }

    // @isTest
    // static void testForDuplicateReasons(){
    //     Contact c = [select id from Contact where Virtual_Lift_Enabled__c = true limit 1];
    //     TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
    //     TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432234","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
    //     Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
    //     multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
    //     multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf3245432234&recent_days_back=90', uactiveRes);
    //     Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
    //     ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(VLRuleData, List<CR_Review_Trigger__mdt>.class);
    //     Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
    //     insert v;
    //     Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
    //     Test.startTest();
    //     insert cr;
    //     cr.Name ='testCr1';
    //     update cr;
    //     Test.stopTest();
    //     List<Condition_Report_Prescreen__c> crrList = [select id,(Select ID from Prescreen_Reasons__r where name like '%Virtual Lift%') from Condition_Report_Prescreen__c];
    //     System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    //     System.assertEquals(1, crrList[0].Prescreen_Reasons__r.size(), 'Expected 1 VL Prescreen Reason');
    // }

    @isTest
    static void testSimpleGenerateNullOnContact(){
        Contact c = [select id,Successful_Virtual_Lift_Prescreens__c from Contact where Virtual_Lift_Enabled__c = true limit 1];
        c.Successful_Virtual_Lift_Prescreens__c = null;
        update c;
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432234","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf3245432234&recent_days_back=90', uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(VLRuleData, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
        Test.startTest();
        insert cr;
        Test.stopTest();
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testNoMatch(){
        Contact c = [select id from Contact where Virtual_Lift_Enabled__c = true limit 1];
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432244","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf3245432234&recent_days_back=90', uactiveRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(VLRuleData, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
        Test.startTest();
        insert cr;
        Test.stopTest();
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(0, crrList.size(),'Expected 0 Condition Report Review, found: '+crrList.size());
    }

    // @isTest
    // static void testSimpleGenerate2Rules(){
    //     Contact c = [select id from Contact where Virtual_Lift_Enabled__c = true limit 1];
    //     TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
    //     TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432234","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
    //     Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
    //     multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
    //     multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf3245432234&recent_days_back=90', uactiveRes);
    //     Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
    //     ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(vLRuleData2Entries, List<CR_Review_Trigger__mdt>.class);
    //     Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
    //     insert v;
    //     Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
    //     Test.startTest();
    //     insert cr;
    //     Test.stopTest();
    //     List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
    //     System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review');
    //     List<Prescreen_Reason__c> prList = [Select id, Name from Prescreen_Reason__c where Condition_Report_Prescreen__c = :crrList[0].id];
    //     System.assert(prList.size() == 2, 'More or less than 2 Prescreen Reason was found');
    // }

    // @isTest
    // static void testSimpleGenerate2RulesVLInvalid(){
    //     Contact c = [select id from Contact where Virtual_Lift_Enabled__c = true limit 1];
    //     TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
    //     TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "123jf3245432234543543","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
    //     Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
    //     multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
    //     multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=123jf324543223333&recent_days_back=90', uactiveRes);
    //     Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
    //     ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(vLRuleData2Entries, List<CR_Review_Trigger__mdt>.class);
    //     Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf324543223333');
    //     insert v;
    //     Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf324543223333');
    //     Test.startTest();
    //     insert cr;
    //     Test.stopTest();
    //     List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
    //     System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review');
    //     List<Prescreen_Reason__c> prList = [Select id, Name from Prescreen_Reason__c where Condition_Report_Prescreen__c = :crrList[0].id];
    //     System.assert(prList.size() == 1, 'More or less than 1 Prescreen Reason was found');
    // }
}