@isTest
public class PrescreenServiceInspectionReviewTest {
 
    //integer string boolean double
    //advanced logic 
    private static string mockDataString = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Inspection_Field__c":"inspectedVehicle.model","Trigger_Value__c":"StringTest","Value_Type__c":"String","Comma_Seperated_Inspection_Types__c":"OFF_LEASE","Prescreen_Reason__c":"test"}]';
    private static string mockDataInteger = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Inspection_Field__c":"dealershipId","Trigger_Value__c":"100","Value_Type__c":"Integer","Comma_Seperated_Inspection_Types__c":"OFF_LEASE","Prescreen_Reason__c":"test"}]';
    private static string mockDataBoolean = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Inspection_Field__c":"carfaxAlert.isValid","Trigger_Value__c":"true","Value_Type__c":"Boolean","Comma_Seperated_Inspection_Types__c":"OFF_LEASE","Prescreen_Reason__c":"test"}]';
    //double checks for greater than
    //private static string mockDataDouble = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Inspection_Field__c":"inspectedVehicle.model","Trigger_Value__c":"DoubleTest","Value_Type__c":"Double"}]';
    private static string mockDataAdvancedLogic = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Inspection_Field__c":"inspectedVehicle.model","Trigger_Value__c":"AdvancedLogic","Value_Type__c":"String","Comma_Seperated_Inspection_Types__c":"OFF_LEASE","Prescreen_Reason__c":"test"}]';
    
    @TestSetup
    static void makeData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        Account account = TestUtility.createAccount();
        account.Dealership_Id__c = '2147479405';
        Account account2 = TestUtility.createAccount();
        account2.Dealership_Id__c = '100';
        account2.Name = 'Test2';
        insert account;
        insert account2;
        List<Contact> cList = new List<Contact>();
        Contact contact = TestUtility.createContact(account);
        contact.Identity_Id__c = '40dc053e-d826-4b28-b911-759e5c145759';
        contact.CR_Review__c = false;
        contact.Virtual_Lift_Enabled__c = true;
        cList.add(contact);
        Contact reviewContact = TestUtility.createContact(account);
        reviewContact.Identity_Id__c = '40dc053e-d826-4b28-b911-759e5c145758';
        reviewContact.CR_Review__c = true;
        reviewContact.Prescreen_Type__c = 'New';
        
        cList.add(reviewContact);
        insert cList;
    }
    public static InspectionDefinition defaultIDef(){
        InspectionDefinition idef = new InspectionDefinition();
        idef.inspectionID = 'acf0652d-3bf1-4efd-8d79-5876aa55bcf11';
        idef.inspectorIdentityId = '40dc053e-d826-4b28-b911-759e5c145759';
        idef.dealershipId = 2147479405;
        idef.inspectionType = 'test';
        idef.inspectedVehicle = new InspectionDefinition.vehicle();
        idef.inspectedVehicle.vehicleId = 'd8ac3b68-be53-4c8c-97e7-7ee630392151';
        idef.inspectedVehicle.driveTrain = 'FWD';
        idef.inspectedVehicle.make = 'Ferrari';
        idef.inspectedVehicle.model = 'Roma';
        idef.inspectedVehicle.trim = 'Base 2D Coupe';
        idef.inspectedVehicle.cylinders = '4';
        idef.inspectedVehicle.engineDisplacement ='2.0L';
        idef.inspectedVehicle.fuelType ='Gas';
        idef.inspectedVehicle.turbo = null;
        idef.inspectedVehicle.transmission = 'Automatic';
        idef.inspectedVehicle.year = '2002';
        idef.inspectedVehicle.vin = 'JH4DC54802C546089';
        idef.type = new InspectionDefinition.inspectionType();
        idef.type.id = '7fe18960-0917-4368-ad47-1f79e07524ed';
        idef.type.type = 'OFF_LEASE';
        idef.type.name = 'Off-Lease Inspection';
        idef.carfaxAlert = new InspectionDefinition.carfax();
        
        idef.carfaxAlert.isValid = true;
        idef.carfaxAlert.reportedDate = DateTime.parse('03/24/2021 05:31 PM');
        idef.carfaxAlert.odometerDiscrepancies = new List<String>();
        idef.carfaxAlert.carfaxExceptions = new List<String>();
        idef.images = new List<InspectionDefinition.ImageMap>();
        idef.wasManuallyCreated = false;
        
        idef.region = 'Test Region';
        return idef;
    }
    public static InspectionDefinition badIDef1(){
        InspectionDefinition idef = new InspectionDefinition();
        idef.inspectionID = 'acf0652d-3bf1-4efd-8d79-5876aa55bcf11';
        idef.inspectorIdentityId = '40dc053e-d826-4b28-b911-759e5c145759';
        idef.inspectionType = 'test';
        idef.inspectedVehicle = new InspectionDefinition.vehicle();
        idef.inspectedVehicle.vehicleId = 'd8ac3b68-be53-4c8c-97e7-7ee630392151';
        idef.inspectedVehicle.driveTrain = 'FWD';
        idef.inspectedVehicle.make = 'Ferrari';
        idef.inspectedVehicle.model = 'Roma';
        idef.inspectedVehicle.trim = 'Base 2D Coupe';
        idef.inspectedVehicle.cylinders = '4';
        idef.inspectedVehicle.engineDisplacement ='2.0L';
        idef.inspectedVehicle.fuelType ='Gas';
        idef.inspectedVehicle.turbo = null;
        idef.inspectedVehicle.transmission = 'Automatic';
        idef.inspectedVehicle.year = '2002';
        idef.inspectedVehicle.vin = 'JH4DC54802C546089';
        idef.type = new InspectionDefinition.inspectionType();
        idef.type.id = '7fe18960-0917-4368-ad47-1f79e07524ed';
        idef.type.type = 'OFF_LEASE';
        idef.type.name = 'Off-Lease Inspection';
        idef.completedCount = 1;
        idef.carfaxAlert = new InspectionDefinition.carfax();
        
        idef.carfaxAlert.isValid = true;
        idef.carfaxAlert.reportedDate = DateTime.parse('03/24/2021 05:31 PM');
        idef.carfaxAlert.odometerDiscrepancies = new List<String>();
        idef.carfaxAlert.carfaxExceptions = new List<String>();
        idef.images = new List<InspectionDefinition.ImageMap>();
        return idef;
    }
    public static InspectionDefinition badIDef2(){
        InspectionDefinition idef = new InspectionDefinition();
        idef.inspectionID = 'acf0652d-3bf1-4efd-8d79-5876aa55bcf11';
        idef.dealershipId = 2147479405;
        idef.inspectionType = 'test';
        idef.inspectedVehicle = new InspectionDefinition.vehicle();
        idef.inspectedVehicle.vehicleId = 'd8ac3b68-be53-4c8c-97e7-7ee630392151';
        idef.inspectedVehicle.driveTrain = 'FWD';
        idef.inspectedVehicle.make = 'Ferrari';
        idef.inspectedVehicle.model = 'Roma';
        idef.inspectedVehicle.trim = 'Base 2D Coupe';
        idef.inspectedVehicle.cylinders = '4';
        idef.inspectedVehicle.engineDisplacement ='2.0L';
        idef.inspectedVehicle.fuelType ='Gas';
        idef.inspectedVehicle.turbo = null;
        idef.inspectedVehicle.transmission = 'Automatic';
        idef.inspectedVehicle.year = '2002';
        idef.inspectedVehicle.vin = 'JH4DC54802C546089';
        idef.type = new InspectionDefinition.inspectionType();
        idef.type.id = '7fe18960-0917-4368-ad47-1f79e07524ed';
        idef.type.type = 'OFF_LEASE';
        idef.type.name = 'Off-Lease Inspection';
        idef.completedCount = 1;
        idef.carfaxAlert = new InspectionDefinition.carfax();
        
        idef.carfaxAlert.isValid = true;
        idef.carfaxAlert.reportedDate = DateTime.parse('03/24/2021 05:31 PM');
        idef.carfaxAlert.odometerDiscrepancies = new List<String>();
        idef.carfaxAlert.carfaxExceptions = new List<String>();
        idef.images = new List<InspectionDefinition.ImageMap>();
        return idef;
    }
    @IsTest
    public static void testIsOnlyAux(){
        
        PrescreenServiceHelper.InspectionWrapper iWrapper1 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper1.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper1.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', true));
        iWrapper1.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason2', false));
        System.assertEquals(false, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper1), 'iWrapper1 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper2 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper2.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper2.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', true));
        iWrapper2.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason2', true));
        iWrapper2.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason3', true));
        System.assertEquals(true, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper2), 'iWrapper2 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper3 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper3.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        System.assertEquals(false, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper3), 'iWrapper3 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper4 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper4.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper4.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', false));
        iWrapper4.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason2', true));
        System.assertEquals(false, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper4), 'iWrapper4 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper5 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper5.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper5.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', false));
        iWrapper5.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason2', false));
        iWrapper5.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason3', false));
        System.assertEquals(false, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper5), 'iWrapper5 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper6 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper6.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper6.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', true));
        System.assertEquals(true, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper6), 'iWrapper6 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper7 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper7.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper7.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', false));
        System.assertEquals(false, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper7), 'iWrapper7 had incorrect boolean value');
        
        PrescreenServiceHelper.InspectionWrapper iWrapper8 = new PrescreenServiceHelper.InspectionWrapper();
        iWrapper8.prescreenReasonWrappers = new Set<PrescreenServiceHelper.ReasonWrapper>();
        iWrapper8.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason1', true));
        iWrapper8.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason2', false));
        iWrapper8.prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper('Reason3', true));
        System.assertEquals(false, PrescreenServiceHelper.isOnlyAuxReasons(iWrapper8), 'iWrapper8 had incorrect boolean value');
    }
    @isTest
    public static void negativeMetadataTest(){
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataString, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.inspectedVehicle.model = 'StringTest';
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper.errors == false);
        system.assertEquals(1,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen Count Wrong');
    }
    @isTest
    public static void integerMetadataPostive(){
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataInteger, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.dealershipId = 100;
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper.errors == false);
        system.assertEquals(1,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen Count Wrong');
    }
    @isTest
    public static void reviewTestPositive(){
        
        Test.startTest();
        //PrescreenServiceInspectionReview.inspectionReview();
        Test.stopTest();
    }
    @isTest
    public static void stringMetadataPostive(){
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataString, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.inspectedVehicle.model = 'StringTest';
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper.errors == false);
        system.assertEquals(1,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen Count Wrong');
    }
    @isTest
    public static void booleanMetadataPostive(){
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataBoolean, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.carfaxAlert.isValid = true;
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        list<Condition_Report_Prescreen__c> prescreenList= [SELECT OwnerId FROM Condition_Report_Prescreen__c];
        Id queueId = [select Id from Group where  Type = 'Queue' AND NAME = 'SIA Prescreen' LIMIT 1].id;
        system.debug(prescreenList);
        system.debug(queueId);
        system.assert(wrapper.errors == false);
        system.assertEquals(1,prescreenList.size(), 'Prescreen Count Wrong');
        system.assertEquals(queueId,prescreenList[0].OwnerId, 'Wrong Queue');
    }

    @isTest
    public static void queueTest(){
        //PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataBoolean, List<CR_Review_Trigger__mdt>.class);
        TestingUtility.SingleRequestMock loginResp = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [],"code": "200"}}',null);
        
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins=JH4DC54802C546089&recent_days_back=90', uactiveRes);
        multiCall.put('callout:ArbGuard/v1/arbguard/sia', new SiaCrEvaluatorMock());
        
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        
        InspectionDefinition idef = defaultIDef();
        idef.carfaxAlert.isValid = true;
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        Test.stopTest();
        
        
        Map<Id, Condition_Report_Prescreen__c> prescreenMap = new Map<Id, Condition_Report_Prescreen__c>([SELECT OwnerId, id FROM Condition_Report_Prescreen__c]);
        List<Prescreen_REason__c> reasonList = [SELECT id, Condition_Report_Prescreen__c, name FROM Prescreen_Reason__c WHERE Condition_Report_Prescreen__c in : prescreenMap.keyset()];
        
        Id queueId = [select Id from Group where  Type = 'Queue' AND NAME = 'CR Queue' LIMIT 1].id;
        for(PrescreenServiceInspectionReview.InspectionReviewResults result : wrapper.items){
            system.debug(result.message);
        }
        system.debug(wrapper.errors);
        system.assert(wrapper.errors == false);
        system.assertEquals(1,prescreenMap.size(), 'Prescreen Count Wrong');
         
        system.assertEquals(queueId,prescreenMap.values()[0].OwnerId, 'Wrong Queue');
    }

    @isTest
    public static void missingMetadataField(){
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataBoolean, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.carfaxAlert.isValid = null;
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        system.assert(wrapper.errors == true);
        system.assertEquals(0,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen Count Wrong');
    }
    @IsTest
    public static void missingData(){
        //check for missing dealer id, inspector id
        //should get 400 errors for these
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataBoolean, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef1 = badIDef1();
        idef1.carfaxAlert.isValid = true;
        InspectionDefinition idef2 = badIDef2();
        idef2.carfaxAlert.isValid = true;
        idefList.add(idef1);
        idefList.add(idef2);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper.errors == true);
        system.assertEquals(0,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen Count Wrong');
    }

    @isTest
    public static void dedupePrescreenTest(){

        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataInteger, List<CR_Review_Trigger__mdt>.class);

        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.dealershipId = 100;
        idefList.add(idef);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        
        Test.startTest();
            PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
            //PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper2 = PrescreenServiceInspectionReview.inspectionReview(idefList);
        Test.stopTest();
        system.assert(wrapper.errors == false);
        //system.assert(wrapper2.errors == false);
        system.assertEquals(1,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen Count Wrong');
    }

    @isTest
    public static void testCompletedCountPrescreen(){
        PrescreenServiceHelper.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataInteger, List<CR_Review_Trigger__mdt>.class);
        List<InspectionDefinition> idefList = new List<InspectionDefinition>();
        InspectionDefinition idef = defaultIDef();
        idef.dealershipId = 100;
        idef.completedCount = 2;
        idefList.add(idef);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper.errors == false);
        system.assertEquals(0,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'No Prescreen created if completedCount is 2');
        
        //case when completedCount is 1
        idefList[0].completedCount = 1;
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper1 = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper1.errors == false);
        system.debug(wrapper1);
        system.assertEquals(1,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen created if completedCount is 1');
        
        
        //case when completedCount is 1 but Prescreen exists and status is closed
        
        Condition_Report_Prescreen__c cr = [SELECT Id,Status__c FROM Condition_Report_Prescreen__c Limit 1];
        cr.Status__c = 'Closed';
        cr.CR_Update_by_pre_Screener__c ='Yes';
        update cr;
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper2 = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper2.errors == false);
        system.debug(wrapper2);
        system.assertEquals(2,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen created if completedCount is 1 and existing prescreen has closed status');
        
        //case when completedCount is 1 but Prescreens exists and not in closed status
        
        PrescreenServiceInspectionReview.InspectionReviewResultsWrapper wrapper3 = PrescreenServiceInspectionReview.inspectionReview(idefList);
        
        system.assert(wrapper3.errors == false);
        system.debug(wrapper3);
        system.assertEquals(2,[SELECT COUNT() FROM Condition_Report_Prescreen__c], 'Prescreen not created if completedCount is 1 and existing prescreen is not in closed status');
        
        
        

    }
}