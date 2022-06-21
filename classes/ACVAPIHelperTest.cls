@isTest
public class ACVAPIHelperTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert new Account(Name='Test Account', Dealership_Id__c = '123',legal_Name__c='Test Account', dealer_type__c='1');
    }

    @isTest
    public static void testBlankInitializer(){
        ACVAPIHelper a = new ACVAPIHelper();
        system.assert(a != null, 'ACV API Helper is Null');
    }

    @isTest
    public static void testHostURLInitializer(){
        ACVAPIHelper a = new ACVAPIHelper('http://testURLThatDoesNothing.com');
        system.assert(a != null, 'ACV API Helper is Null - URL Init Test');
        system.assert(a.getHostURL() == 'http://testURLThatDoesNothing.com', 'Host URL dosen\' match');
    }

    @isTest
    public static void testHostURLInitializerBlank(){
        ACVAPIHelper a = new ACVAPIHelper('');
        system.assert(a != null, 'ACV API Helper is Null - URL Init Test');
        system.assert(a.getHostURL() == null, 'Host URL dosen\' match');
    }

    @isTest 
    public static void testSettingAndGettingCreds(){
        ACVAPIHelper a = new ACVAPIHelper();
        ACVAPIHelper.Credentails cr = a.setCreds('userId', 'token');
        System.assert(cr == a.getCreds(),'Creds dont match!');
    }

    @isTest
    public static void testGettingVoidCreds(){
        ACVAPIHelper a = new ACVAPIHelper();
        ACVAPIHelper.Credentails cr = a.getCreds();
        system.assert(cr == null, 'Creds were set :(');
    }

    @isTest
    public static void testIdenityWrapper(){
        ACVAPIHelper.IdenityInformation ii = new ACVAPIHelper.IdenityInformation('bill@email.com', 'terriblePassword');
        system.assert(ii.password == 'terriblePassword', 'Password was not set properly');
        System.assert(ii.email == 'bill@email.com','EmailAddress not set properly');
    }

    @isTest
    public static void testGoodLogin(){
        Test.setMock(HttpCalloutMock.class, new LoginMockCallGoodCode());
        Test.startTest();
        ACVAPIHelper a = new ACVAPIHelper('https://ACV.com/Login','bill@email.com','goodPassword');
        Test.stopTest();
        system.assert(a.getCreds().isValid(),'Invalid Creds Returned');
    }

    @isTest
    public static void testMultipleLogins(){
        Test.setMock(HttpCalloutMock.class, new LoginMockCallGoodCode());
        Test.startTest();
        ACVAPIHelper a = new ACVAPIHelper('https://ACV.com/Login','bill@email.com','goodPassword');
        Test.stopTest();
        a.login(new ACVAPIHelper.IdenityInformation('bill@email.com','password'));
        system.assert(a.getCreds().isValid(),'Invalid Creds Returned');
    }

    @isTest
    public static void testLoginWithNoHostURL(){
        Test.setMock(HttpCalloutMock.class, new LoginMockCallGoodCode());
        Test.startTest();
        ACVAPIHelper a = new ACVAPIHelper();
        try{
            a.login(new ACVAPIHelper.IdenityInformation('bill@email.com','password'));
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Host URL is not set'),'Error Message is not good');
        }
        Test.stopTest();
    }

    @isTest
    public static void testBadLogin(){
        Test.setMock(HttpCalloutMock.class, new LoginMockCallBadCode());
        Test.startTest();
        ACVAPIHelper a = new ACVAPIHelper('https://ACV.com/Login','bill@email.com','goodPassword');
        Test.stopTest();
        system.assert(a.getCreds() == null,'Creds Returned :(');
    }

    @isTest
    public static void testResultObject3Initializers(){
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Content-Type', 'application-json');
        req.setBody('{"api_version":"2","data":{"user_id":"123","session_token":"hjkfdkhjdfjkhfdjhkdf","code":"200"}}');
        req.setMethod('POST');
        req.setEndpoint('https://test.com/endpoint');
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application-json');
        res.setBody('{"api_version":"2","data":{"user_id":"123","session_token":"hjkfdkhjdfjkhfdjhkdf","code":"200"}}');
        res.setStatus('OK');
        res.setStatusCode(200);
        Account a = [select id from Account limit 1];
        ACVAPIHelper.Result r = new ACVAPIHelper.Result(req,res,'TEST',a.id);
        System.assert(r.integrationName == 'TEST' && r.integrationType == 'POST', 'Data did not translate properly');
    }

    @isTest
    public static void testResultObjectBlankInit(){
        ACVAPIHelper.Result r = new ACVAPIHelper.Result();
        System.assert(r != null, 'Results is not when it shouldnt be');
    }

    @isTest
    public static void testResultObjectToIRError(){
        ACVAPIHelper.Result r = new ACVAPIHelper.Result();
        try{
            r.toIr();
        }
        catch(Exception e){
            system.assert(e.getMessage().contains('Missing Required Data'),'Error Message is not good');
        }
    }

    @isTest
    public static void createSFResponse() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        String errorMessage = 'This address is missing a zipcode';
        Integer statusCode = 300;

        Test.startTest();
            ACVAPIHelper.SFResponse responseMessage = new ACVAPIHelper.SFResponse( 
                new EasyPostAPI.OriginalAddressRequest(
                    'Test Buffalo Address',
                    '101 Main Street',
                    'Buffalo',
                    'New York',
                    'US',
                    ''
                ),
                errorMessage,
                statusCode
            );
            responseMessage.generateResponse();
        Test.stopTest();

        System.assert( RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.assertEquals( RestContext.response.StatusCode, statusCode, 'The expected status code was not provided (Expected:' + statusCode + '). The provided status code is as followed: ' + RestContext.response.StatusCode );
    }

    @isTest
    public static void createSFResponseWithMessage() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        EasyPostAPI.EasyPostReturn messageReturn = new EasyPostAPI.EasyPostReturn();
        messageReturn.trackingCode = 'T1H1I1S1A1T1R1A1C1K1I1N1G1C1O1D1E';
        messageReturn.link = 'https://acvauctions.com/';
        
        String errorMessage = 'This address is missing a zipcode';
        Integer statusCode = 300;

        Test.startTest();
            ACVAPIHelper.SFResponse responseMessage = new ACVAPIHelper.SFResponse( 
                new EasyPostAPI.OriginalAddressRequest(
                    'Test Buffalo Address',
                    '101 Main Street',
                    'Buffalo',
                    'New York',
                    'US',
                    ''
                ),
                messageReturn,
                errorMessage,
                statusCode
            );
            responseMessage.generateResponse();
        Test.stopTest();

        System.assert( RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );

        System.assertEquals( RestContext.response.StatusCode, statusCode, 'The expected status code was not provided (Expected:' + statusCode + '). The provided status code is as followed: ' + RestContext.response.StatusCode );
    }

    public class LoginMockCallGoodCode implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application-json');
            res.setBody('{"api_version":"2","data":{"user_id":"123","session_token":"hjkfdkhjdfjkhfdjhkdf","code":"200"}}');
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
    }

    public class LoginMockCallBadCode implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application-json');
            res.setBody('{"api_version":"2","data":{"user_id":"123","session_token":"hjkfdkhjdfjkhfdjhkdf","code":"500"}}');
            res.setStatus('ERROR');
            res.setStatusCode(500);
            return res;
        }
    }
}