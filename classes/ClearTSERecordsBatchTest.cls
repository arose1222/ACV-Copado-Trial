@isTest
public class ClearTSERecordsBatchTest {

    public static boolean BatchTestFlag = FALSE;

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<TSE_Request__c> tserLst = new List<TSE_Request__c>();
        for ( Integer index = 0; index < 10; index++ ) {
            tserLst.add( new TSE_Request__c(
                Action__c = 'Work Entry', 
                Type__c = 'Work In Progress'
            ) );
        }

        insert tserLst;

        for ( TSE_Request__c tseRecord : tserLst ) {
            Test.setCreatedDate( tseRecord.Id, DateTime.now().addDays( ClearTSERecordsBatch.DEFAULT_DAY_RANGE + ( -1 ) ) );
        }
    }

    @isTest
    static void runBatch() {
        Integer tseResultCount = [ SELECT Count() FROM TSE_Request__c ];
        system.assertEquals( 10, tseResultCount, 'The number of TSE records was unexpected' );

        Test.startTest();

            ClearTSERecordsBatch batch = new ClearTSERecordsBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        tseResultCount = [ SELECT Count() FROM TSE_Request__c ];
        system.assertEquals( 0, tseResultCount, 'The number of TSE records was unexpected' );
    }

    @isTest
    static void runSpecificTimeBatch() {
        Integer tseResultCount = [ SELECT Count() FROM TSE_Request__c ];
        system.assertEquals( 10, tseResultCount, 'The number of TSE records was unexpected' );

        Test.startTest();

            ClearTSERecordsBatch batch = new ClearTSERecordsBatch( DateTime.now().addDays( -1 ) );
            batch.executeScheduledLogic();

        Test.stopTest();

        tseResultCount = [ SELECT Count() FROM TSE_Request__c ];
        system.assertEquals( 0, tseResultCount, 'The number of TSE records was unexpected' );
    }

    @isTest
    static void newRecordBatch() {
        TSE_Request__c tseRecord = new TSE_Request__c(
            Action__c = 'Work Entry', 
            Type__c = 'Work In Progress'
        );
        insert tseRecord;

        Integer tseResultCount = [ SELECT Count() FROM TSE_Request__c ];
        system.assertEquals( 11, tseResultCount, 'The number of TSE records was unexpected' );

        Test.startTest();

            ClearTSERecordsBatch batch = new ClearTSERecordsBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        List<TSE_Request__c> tseResultLst = [ SELECT Id FROM TSE_Request__c ];
        system.assertEquals( 1, tseResultLst.size(), 'The number of TSE records was unexpected' );
        system.assertEquals( tseRecord.Id, tseResultLst[0].Id, 'The record in the system was not the expected one' );
    }

    @isTest
    static void runErrorBatch() {  // Method hits error class, no actual way to confirm as it does not actually prevent deletion
        Integer tseResultCount = [ SELECT Count() FROM TSE_Request__c ];
        system.assertEquals( 10, tseResultCount, 'The number of TSE records was unexpected' );

        Test.startTest();

            ClearTSERecordsBatch batch = new ClearTSERecordsBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}