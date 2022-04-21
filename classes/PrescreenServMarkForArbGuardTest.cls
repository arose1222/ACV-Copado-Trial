@isTest
private  class PrescreenServMarkForArbGuardTest {
    
    @isTest static void newConditionReport(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();

        System.assertNotEquals(null, [SELECT Arb_Risk_Categories__c FROM Condition_Report__c LIMIT 1][0].Arb_Risk_Categories__c);
    }

    @isTest static void existingConditionReport(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();
    }

    @isTest static void existingConditionReportWithArbGuardReason(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        insert prescreen;

        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Arb Guard';
        reason.Condition_Report_Prescreen__c = prescreen.Id;
        insert reason;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();
    }

    @isTest static void existingConditionReportNewPrescreen(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        prescreen.Status__c = 'New';
        insert prescreen;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();

    }

    @isTest static void existingConditionReportAuxPendingPrescreen(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        prescreen.Aux_Prescreen_Status__c = 'Pending';
        insert prescreen;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();
    }

    @isTest static void existingConditionReportAuxUnderReviewPrescreen(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        prescreen.Aux_Prescreen_Status__c = 'Under Review';
        insert prescreen;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();
    }

    @isTest static void existingConditionReportPendingPrescreen(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        prescreen.Status__c = 'Pending';
        insert prescreen;

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/loan/';
        request.httpMethod = 'POST';

        String body = '{"arbGuard" : [{"Saved_Auction_Id" : 1638529,"totalDollarRisk" : 167.87,"display" : true,"categories" : [{"category" : "Transmission","odds" : "1 in 9","dollarRisk" : 100,"note" : "Cleared monitors, indep. dealer"}]}]}';

        request.requestBody = Blob.valueof(body);
        
        RestContext.request = request;
        RestContext.response= response;
        
        Test.startTest();
        PrescreenServiceMarkForArbGuardPrescreen.arbGuardRequest();
        Test.stopTest();
    }

}