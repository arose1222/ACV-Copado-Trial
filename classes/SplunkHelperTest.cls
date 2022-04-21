@IsTest
public class SplunkHelperTest {
    
    public static SplunkHelper.Log setupLog() {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1';
        infoLog.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        infoLog.location = 'assignmentManagerCreateWorkLinesCont:340';
        infoLog.message = 'Null Pointer Exception';
        infoLog.stackTrace = 'AnonymousBlock: line 3, column 1';
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'Anonymous Apex';
        infoLog.sfObject = 'User';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS };

        return infoLog;
    }

    @isTest
    public static void createLog() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        Test.startTest();
            SplunkHelper.processLog( infoLog );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createFutureLog() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        Test.startTest();
            infoLog.setContext( SplunkHelper.CONTEXT_TYPE.APEX_TRIGGER );
            SplunkHelper.buildandProcessLog( infoLog );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }


    @Future(callout=true)
    private static void futureContextMethodSwitch(Integer i){

        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();
        infoLog.setContext( SplunkHelper.CONTEXT_TYPE.APEX_CODE );

        switch on i {
            when 1 {		
                SplunkHelper.buildAndProcessLog(infoLog);
            }	
            when 2 {
                SplunkHelper.logWrapper logWrap =  new SplunkHelper.logWrapper();
                logWrap.l = infoLog;
                SplunkHelper.processBulkLog(new List<SplunkHelper.logWrapper>{logWrap});
            }
            when 3 {
                SplunkHelper.buildAndProcessLog(infoLog, new List<SplunkHelper.SFErrorRecord>(), new Set<String>());
            }
            when 4 {
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint( 'https:www.google.com' );
                req.setMethod( 'GET' );

                HTTPResponse res = new HTTPResponse();
                res.setStatusCode( 400 );


                SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
                
            }
            when 5{
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint( 'https:www.google.com' );
                req.setMethod( 'GET' );

                HTTPResponse res = new HTTPResponse();
                res.setStatusCode( 400 );

                SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
                
            }
        }
    }
    @isTest
    public static void futureContextLog(){
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        

        Test.startTest();
            futureContextMethodSwitch(1);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    
    }
    @isTest
    public static void futureContextBulkLog(){
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        

        Test.startTest();
            futureContextMethodSwitch(2);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    
    }
    @isTest
    public static void futureContextLogWithRecords(){
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        

        Test.startTest();
            futureContextMethodSwitch(3);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    
    }
    @isTest
    public static void futureContextIntegrationLog(){
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        

        Test.startTest();
            futureContextMethodSwitch(4);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    
    }
    @isTest
    public static void futureContextIntegrationLogWithRecords(){
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        

        Test.startTest();
            futureContextMethodSwitch(5);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    
    }

    @isTest
    public static void createLogWithMultileResults() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        Test.startTest();
            SplunkHelper.processLog( infoLog, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createFutureLogWithMultipleResults() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        Test.startTest();
            infoLog.setContext( SplunkHelper.CONTEXT_TYPE.APEX_TRIGGER );
            SplunkHelper.buildAndProcessLog( infoLog, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createBatchLog() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        Account acct = new Account(
            Name = 'Johnson Workshop'
        );
        insert acct;

        Test.startTest();
            SplunkHelper.processBatchLog( infoLog, new List<SplunkHelper.SFErrorRecord>{ new SplunkHelper.SFErrorRecord( JSON.serialize( acct ), 'Testing Error' ) }, new Set<String>{} );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createIntegrationLog() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint( 'https:www.google.com' );
        req.setMethod( 'GET' );

        HTTPResponse res = new HTTPResponse();
        res.setStatusCode( 400 );

        Test.startTest();
            SplunkHelper.processIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createFutureIntegrationLog() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint( 'https:www.google.com' );
        req.setMethod( 'GET' );

        HTTPResponse res = new HTTPResponse();
        res.setStatusCode( 400 );

        Test.startTest();
            SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }



    @isTest
    public static void createIntegrationLogWithMultipleResults() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint( 'https:www.google.com' );
        req.setMethod( 'GET' );

        HTTPResponse res = new HTTPResponse();
        res.setStatusCode( 400 );

        Test.startTest();
            SplunkHelper.processIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createFutureIntegrationLogWithMultipleResults() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        HTTPRequest req = new HTTPRequest();
        req.setEndpoint( 'https:www.google.com' );
        req.setMethod( 'GET' );

        HTTPResponse res = new HTTPResponse();
        res.setStatusCode( 400 );

        Test.startTest();
            SplunkHelper.buildAndProcessIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createVisualComponentLog() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        String userInput = '{ "button" : "Kill Auction" }';
        String jsEvent = '{ "event" : { "userId" : "01" } }';

        Test.startTest();
            SplunkHelper.processVisualComponentLog( infoLog, userInput, jsEvent );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void createVisualComponentLogWithMultipleResults() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );
        SplunkHelper.Log infoLog = SplunkHelperTest.setupLog();

        String userInput = '{ "button" : "Kill Auction" }';
        String jsEvent = '{ "event" : { "userId" : "01" } }';

        Test.startTest();
            SplunkHelper.processVisualComponentLog( infoLog, userInput, jsEvent, new List<SplunkHelper.SFErrorRecord>(), new Set<String>() );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    
    }

    @isTest
    public static void processBulkLog(){
        Test.setMock(HTTPCalloutMock.class, new SplunkMock());

        List<SplunkHelper.LogWrapper> wrapperList = new List<SplunkHelper.LogWrapper>();

		SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'TestBulkLog';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
        log.location = 'SplunkHelperTest';
        log.logLevel = SplunkHelper.LOGLEVEL.INFO;
        log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log.stackTrace = 'SplunkHelperTest: '+ACVUtility.currentLineNumber();
        log.version = '1.0';
		
		SplunkEngine.SFDetails sfd = new SplunkEngine.SFDetails();
        sfd.integrationType = SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND.name();
        sfd.requestBody = 'testreqbody';
        sfd.responseBody = 'testresbody';
        sfd.statusMessage = 'bad status';
		sfd.userInput = 'good input';
		sfd.jsEvent = 'Test event';
        sfd.sfFailedRecords = new List<SplunkHelper.SFErrorRecord>();
        SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
        errRec.errorMessage = 'error';
        sfd.sfFailedRecords.add(errRec);
        String successString = 'success!';
        sfd.sfSuccessfulRecords = new Set<String>();
        sfd.sfSuccessfulRecords.add(successString);
        
        
        
        SplunkHelper.logWrapper lw = new SplunkHelper.logWrapper();
        lw.l = log;
		lw.sfDetails = sfd;

		wrapperList.add(lw);

		SplunkHelper.Log log2 = new SplunkHelper.Log();
        log2.componentName = 'TestBulkLog';
        log2.domainSet = new Set<SplunkHelper.DOMAIN>();
        log2.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
        log2.location = 'Execute Anonymous';
        log2.logLevel = SplunkHelper.LOGLEVEL.INFO;
        log2.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log2.stackTrace = 'Execute Anonymous: '+ACVUtility.currentLineNumber();
        log2.version = '1.0';
		
		SplunkEngine.SFDetails sfd2 = new SplunkEngine.SFDetails();
		sfd2.integrationType = SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND.name();
        sfd2.requestBody = 'testreqbody';
        sfd2.responseBody = 'testresbody';
        sfd2.statusMessage = 'bad status';
		sfd2.userInput = 'good input';
		sfd2.jsEvent = 'Test event';
        sfd2.sfFailedRecords = new List<SplunkHelper.SFErrorRecord>();
        sfd2.sfFailedRecords.add(errRec);
        sfd2.sfSuccessfulRecords = new Set<String>();
        sfd2.sfSuccessfulRecords.add(successString);
        
        
        
        SplunkHelper.logWrapper lw2 = new SplunkHelper.logWrapper();
        lw2.l = log2;
		lw2.sfDetails = sfd2;

		wrapperList.add(lw2);

        Test.startTest();
            SplunkHelper.ProcessBulkLog(wrapperList);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
        
    }

    public static void processBulkLogNonFuture(){
        Test.setMock(HTTPCalloutMock.class, new SplunkMock());

        List<SplunkHelper.LogWrapper> wrapperList = new List<SplunkHelper.LogWrapper>();

		SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'TestBulkLog';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
        log.location = 'SplunkHelperTest';
        log.logLevel = SplunkHelper.LOGLEVEL.INFO;
        log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log.stackTrace = 'SplunkHelperTest: '+ACVUtility.currentLineNumber();
        log.version = '1.0';
		
		SplunkEngine.SFDetails sfd = new SplunkEngine.SFDetails();
        sfd.integrationType = SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND.name();
        sfd.requestBody = 'testreqbody';
        sfd.responseBody = 'testresbody';
        sfd.statusMessage = 'bad status';
		sfd.userInput = 'good input';
		sfd.jsEvent = 'Test event';
        sfd.sfFailedRecords = new List<SplunkHelper.SFErrorRecord>();
        SplunkHelper.SFErrorRecord errRec = new SplunkHelper.SFErrorRecord();
        errRec.errorMessage = 'error';
        sfd.sfFailedRecords.add(errRec);
        String successString = 'success!';
        sfd.sfSuccessfulRecords = new Set<String>();
        sfd.sfSuccessfulRecords.add(successString);
        
        
        
        SplunkHelper.logWrapper lw = new SplunkHelper.logWrapper();
        lw.l = log;
		lw.sfDetails = sfd;

		wrapperList.add(lw);

		SplunkHelper.Log log2 = new SplunkHelper.Log();
        log2.componentName = 'TestBulkLog';
        log2.domainSet = new Set<SplunkHelper.DOMAIN>();
        log2.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
        log2.location = 'Execute Anonymous';
        log2.logLevel = SplunkHelper.LOGLEVEL.INFO;
        log2.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log2.stackTrace = 'Execute Anonymous: '+ACVUtility.currentLineNumber();
        log2.version = '1.0';
		
		SplunkEngine.SFDetails sfd2 = new SplunkEngine.SFDetails();
		sfd2.integrationType = SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND.name();
        sfd2.requestBody = 'testreqbody';
        sfd2.responseBody = 'testresbody';
        sfd2.statusMessage = 'bad status';
		sfd2.userInput = 'good input';
		sfd2.jsEvent = 'Test event';
        sfd2.sfFailedRecords = new List<SplunkHelper.SFErrorRecord>();
        sfd2.sfFailedRecords.add(errRec);
        sfd2.sfSuccessfulRecords = new Set<String>();
        sfd2.sfSuccessfulRecords.add(successString);
        
        
        
        SplunkHelper.logWrapper lw2 = new SplunkHelper.logWrapper();
        lw2.l = log2;
		lw2.sfDetails = sfd2;

		wrapperList.add(lw2);

        Test.startTest();
            SplunkHelper.processNonFutureBulkLog(wrapperList);
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
        
    }

    public class SplunkMock implements HTTPCalloutMock {
        public HTTPResponse respond( HttpRequest req ) {
            HTTPResponse res = new HttpResponse();
            res.setHeader( 'Content-Type', 'application-json' );
            res.setBody( '{ success }' );
            res.setStatusCode( 200 );

            return res;
        }
    }
}