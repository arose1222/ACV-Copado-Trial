@isTest
public class TriggerErrorLoggingTest {

    @isTest
    public static void generateEvent() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );

        String className = 'TriggerErrorLoggingTest';
        String stackTrace = className + ' : ' + ACVUtility.currentLineNumber();
        
        Test.startTest();
            EventBus.publish( new List<Trigger_Event__e>{ 
                new Trigger_Event__e (
                    Message__c = 'Testing an Error from Case',
                    Version__c = 'v1',
                    Location__c = stackTrace,
                    Stack_Trace__c = stackTrace,
                    SF_Record_Id__c = UserInfo.getUserId(),
                    Component_Name__c = className,
                    SF_Object__c = 'Case'
                ) 
            } );
        Test.stopTest();

        System.assertEquals( [ SELECT COUNT() FROM Integration_Result__c ], 0, 'An integration result was created, an error occurred while trying to process the Splunk Log' );
    }

    @isTest
    public static void runFrameworkWithoutMetadata() {
        Test.setMock( HTTPCalloutMock.class, new SplunkMock() );

        String mockMetaDataString = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"After_Update__c": "true", '
                + '"sObject__c": "Account", "Class_Name__c": "NoSuchClass"}]';

        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        TriggerFrameWork manager = new TriggerFrameWork(Account.sObjectType);

        String lastName = 'Simpson';

        List<Account> AccountList = new List<Account>{new Account(name = lastName)};
        insert AccountList;
        Map<Id, Account> AccountMap = new Map<Id, Account>(AccountList);
        try {
            manager.handle(false, true, false, false, false, AccountList, AccountList,AccountMap,AccountMap);
        } catch(TriggerFrameWork.TriggerException e) {
            // expected this!
            return;
        }
        System.assert(false, 'Expected a TriggerException');

        // Verify there was no issue with creating a splunk log
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