@isTest
public class ClearIntegrationResultsBatchTest {

    public static boolean BatchTestFlag = FALSE;
    public final static String INTEGRATION_TYPE = 'Create Case';

    @TestSetup
    static void makeData(){
        List<Integration_Result__c> integrationLst = new List<Integration_Result__c>();
        for ( Integer index = 0; index < 10; index++ ) {
            integrationLst.add( makeIntLog( index ) );
        }
        insert integrationLst;
        adjustCreatedDate( integrationLst );
    }

    public static void adjustCreatedDate( List<Integration_Result__c> integrationLst ) {
        for ( Integration_Result__c irRecord : integrationLst ) {
            Test.setCreatedDate( irRecord.Id, DateTime.now().addDays( ClearIntegrationResultsBatch.DEFAULT_DAY_RANGE + ( -1 ) ) );
        }
    }

    public static Integration_Result__c makeIntLog( integer index ) {
        return new Integration_Result__c(
            Integration_Type__c = INTEGRATION_TYPE,
            SObject_name__c = 'Case',
            Integration_Name__c = 'Test Integration',
            Status_Code__c = 404,
            recordId__c = String.valueOf( index ),
            Status_Message__c = 'Issue with Gateway'
        );
    }

    @isTest
    static void runBatch() {
        Integer integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 10, integrationResultCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearIntegrationResultsBatch batch = new ClearIntegrationResultsBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 0, integrationResultCount, 'The number of integration results was unexpected' );
    }

    @isTest
    static void runSpecificTimeBatch() {
        Integer integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 10, integrationResultCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearIntegrationResultsBatch batch = new ClearIntegrationResultsBatch( DateTime.now().addDays( -1 ) );
            batch.executeScheduledLogic();

        Test.stopTest();

        integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 0, integrationResultCount, 'The number of integration results was unexpected' );
    }

    @isTest
    static void newRecordBatch() {
        Integration_Result__c irRecord = new Integration_Result__c(
            Integration_Type__c = 'Create Case',
            SObject_name__c = 'Case',
            Integration_Name__c = 'Test Integration',
            Status_Code__c = 404,
            recordId__c = '11',
            Status_Message__c = 'Issue with Gateway'
        );
        insert irRecord;

        Integer integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 11, integrationResultCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearIntegrationResultsBatch batch = new ClearIntegrationResultsBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        List<Integration_Result__c> intResultLst = [ SELECT Id FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 1, intResultLst.size(), 'The number of integration results was unexpected' );
        system.assertEquals( irRecord.Id, intResultLst[0].Id, 'The record in the system was not the expected one' );
    }

    @isTest
    static void runErrorBatch() {  // Method hits error class, no actual way to confirm as it does not actually prevent deletion
        Integer integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :INTEGRATION_TYPE ];
        system.assertEquals( 10, integrationResultCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearIntegrationResultsBatch batch = new ClearIntegrationResultsBatch();

            ClearIntegrationResultsBatchTest.BatchTestFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}