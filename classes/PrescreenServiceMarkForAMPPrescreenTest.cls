@isTest
public class PrescreenServiceMarkForAMPPrescreenTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Condition_Report__c cr = TestUtility.createCr(v);
        insert cr;
    }

    @isTest
    static void testNoExistingCR(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest a = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        a.VIN='1231231231231231';
        a.Saved_Auction_Id = 333;
        a.model_score = 100;
        a.display = true;
        a.audio_sample_url = 'test.googgle.com';
        ampReq.add(a);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([SELECT COUNT() FROM Condition_Report__c WHERE ACV_Saved_Auction_Id__c = '333'] == 1, 'No CR Shell was found');
    }

    @isTest
    static void testExistingCR(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c FROM Condition_Report__c];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest a = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        a.VIN='1231231231231231';
        a.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        a.model_score = 95;
        a.display = true;
        a.audio_sample_url = 'test.googgle.com';
        ampReq.add(a);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert(resultList[0].AMP_ML_Score__c == 95, 'Model Score Was Not Updated');
    }

    @isTest
    static void testExistingPrescreen(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c, Vehicle__c FROM Condition_Report__c];
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(crList[0],a,c);
        insert crp;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Condition_Report_Prescreen__c = crp.Id, Name = 'VCI');
        insert pr;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest ar = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        ar.VIN='1231231231231231';
        ar.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        ar.model_score = 100;
        ar.display = true;
        ar.audio_sample_url = 'test.googgle.com';
        ampReq.add(ar);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() FROM Prescreen_Reason__c] == 2, 'Not Enough Preascreen Reasons Found');
    }

    @isTest
    static void testExistingPrescreenWithAMPReason(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c, Vehicle__c FROM Condition_Report__c];
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(crList[0],a,c);
        insert crp;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Condition_Report_Prescreen__c = crp.Id, Name = 'AMP');
        insert pr;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest ar = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        ar.VIN='1231231231231231';
        ar.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        ar.model_score = 100;
        ar.display = true;
        ar.audio_sample_url = 'test.googgle.com';
        ampReq.add(ar);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() FROM Prescreen_Reason__c] == 1, 'Not Enough Preascreen Reasons Found');
    }

    @isTest
    static void testExistingPrescreenBadStatus(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c, Vehicle__c FROM Condition_Report__c];
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(crList[0],a,c);
        crp.Status__c = 'Closed';
        crp.CR_Update_by_pre_Screener__c = 'yes';
        insert crp;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Condition_Report_Prescreen__c = crp.Id, Name = 'VCI');
        insert pr;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest ar = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        ar.VIN='1231231231231231';
        ar.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        ar.model_score = 100;
        ar.display = true;
        ar.audio_sample_url = 'test.googgle.com';
        ampReq.add(ar);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() FROM Prescreen_Reason__c] == 1, 'Not Enough Preascreen Reasons Found');
    }

    @isTest
    static void testMultipleRecords(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c FROM Condition_Report__c];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest a = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        a.VIN='1231231231231231';
        a.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        a.model_score = 20;
        a.display = true;
        a.audio_sample_url = 'test.googgle.com';
        ampReq.add(a);

        PrescreenServiceMarkForAMPPrescreen.ampRequest a2 = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        a2.VIN='1231231231231231';
        a2.Saved_Auction_Id = 300;
        a2.model_score = 200;
        a2.display = true;
        a2.audio_sample_url = 'test.googgle.com';
        ampReq.add(a2);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ORDER BY AMP_ML_Score__c];
        System.Assert(resultList.size() == 2, 'Too Many CRs Found: '+resultList.size());
        System.Assert(resultList[0].AMP_ML_Score__c == 20, 'Model Score Was Not Updated');
        System.Assert(resultList[1].AMP_ML_Score__c == 200, 'Model Score Was Not Updated');
    }

    @isTest
    static void testExistingPrescreenInsertFailure(){
        PrescreenServiceMarkForAMPPrescreen.causeInsertFailure = true;
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c, Vehicle__c FROM Condition_Report__c];
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(crList[0],a,c);
        insert crp;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Condition_Report_Prescreen__c = crp.Id, Name = 'VCI');
        insert pr;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest ar = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        ar.VIN='1231231231231231';
        ar.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        ar.model_score = 100;
        ar.display = true;
        ar.audio_sample_url = 'test.googgle.com';
        ampReq.add(ar);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() FROM Prescreen_Reason__c] == 1, 'Not Enough Preascreen Reasons Found');
    }

    @isTest
    static void testExistingPrescreenBadScore(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c, Vehicle__c FROM Condition_Report__c];
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(crList[0],a,c);
        insert crp;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Condition_Report_Prescreen__c = crp.Id, Name = 'VCI');
        insert pr;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest ar = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        ar.VIN='1231231231231231';
        ar.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        ar.model_score = 1;
        ar.display = true;
        ar.audio_sample_url = 'test.googgle.com';
        ampReq.add(ar);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() FROM Prescreen_Reason__c] == 1, 'Not Enough Preascreen Reasons Found');
    }

    @isTest
    static void testExistingCRNoPrescreenGenerate(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c,Floor_Price__c FROM Condition_Report__c];
        crList[0].Floor_Price__c = 1;
        crList[0].CR_Doc_Complete__c = true;
        update crList;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest a = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        a.VIN='1231231231231231';
        a.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        a.model_score = 95;
        a.display = true;
        a.audio_sample_url = 'test.googgle.com';
        ampReq.add(a);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() From Condition_Report_Prescreen__c] ==1, 'bad number of prescreens');
        System.Assert([SELECT COUNT() From Prescreen_Reason__c] ==1, 'bad number of reasons');
    }

    @isTest
    static void testExistingCRNoPrescreenGenerateMultipleRuns(){
        List<Condition_Report__c> crList = [SELECT ID, ACV_Saved_Auction_Id__c,Floor_Price__c FROM Condition_Report__c];
        crList[0].Floor_Price__c = 1;
        crList[0].CR_Doc_Complete__c = true;
        update crList;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        List<PrescreenServiceMarkForAMPPrescreen.ampRequest> ampReq = new List<PrescreenServiceMarkForAMPPrescreen.ampRequest>();
        PrescreenServiceMarkForAMPPrescreen.ampRequest a = new PrescreenServiceMarkForAMPPrescreen.ampRequest();
        a.VIN='1231231231231231';
        a.Saved_Auction_Id = Integer.valueOf(crList[0].ACV_Saved_Auction_Id__c);
        a.model_score = 95;
        a.display = true;
        a.audio_sample_url = 'test.googgle.com';
        ampReq.add(a);

        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        PrescreenServiceMarkForAMPPrescreen.amprequest(ampReq);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        List<Condition_Report__c> resultList = [SELECT Id, AMP_ML_Score__c FROM Condition_Report__c ];
        System.Assert(resultList.size() == 1, 'Too Many CRs Found: '+resultList.size());
        System.Assert([SELECT COUNT() From Condition_Report_Prescreen__c] ==1, 'bad number of prescreens');
        System.Assert([SELECT COUNT() From Prescreen_Reason__c] ==1, 'bad number of reasons');
    }
}