@isTest
public class ClearOptimizationDataBatchTest {

    private static Integer totalRun = 10;
    
    @TestSetup
    static void makeData(){
        List<FSL__Optimization_Data__c> lst = new List<FSL__Optimization_Data__c>();
        for ( Integer index = 0; index < totalRun; index++ ) {
            lst.add( new FSL__Optimization_Data__c(
                FSL__Identifier__c = String.valueOf( index )
            ) );
        }
        insert lst;

        for ( FSL__Optimization_Data__c rec : lst ) {
            Test.setCreatedDate( rec.Id, DateTime.now().addDays( ClearOptimizationDataBatch.DEFAULT_DAY_RANGE + ( -1 ) ) );
        }
    }

    @isTest
    static void runBatch() {
        Integer recordCount = [ SELECT Count() FROM FSL__Optimization_Data__c ];
        system.assertEquals( totalRun, recordCount, 'The number of Optimization Data Records was unexpected' );

        Test.startTest();

            ClearOptimizationDataBatch batch = new ClearOptimizationDataBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        recordCount = [ SELECT Count() FROM FSL__Optimization_Data__c ];
        system.assertEquals( 0, recordCount, 'The number of Optimization Data Records was unexpected' );
    }

    @isTest
    static void runSpecificTimeBatch() {
        Integer recordCount = [ SELECT Count() FROM FSL__Optimization_Data__c ];
        system.assertEquals( totalRun, recordCount, 'The number of Optimization Data Records was unexpected' );

        Test.startTest();

            ClearOptimizationDataBatch batch = new ClearOptimizationDataBatch( DateTime.now().addDays( -1 ) );
            batch.executeScheduledLogic();

        Test.stopTest();

        recordCount = [ SELECT Count() FROM FSL__Optimization_Data__c ];
        system.assertEquals( 0, recordCount, 'The number of Optimization Data Records was unexpected' );
    }

    @isTest
    static void newRecordBatch() {
        FSL__Optimization_Data__c irRecord = new FSL__Optimization_Data__c(
            FSL__Identifier__c = String.valueOf( totalRun+1 )
        );
        insert irRecord;

        Integer recordCount = [ SELECT Count() FROM FSL__Optimization_Data__c ];
        system.assertEquals( totalRun+1, recordCount, 'The number of Optimization Data Records was unexpected' );

        Test.startTest();

            ClearOptimizationDataBatch batch = new ClearOptimizationDataBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        List<FSL__Optimization_Data__c> intResultLst = [ SELECT Id FROM FSL__Optimization_Data__c ];
        system.assertEquals( 1, intResultLst.size(), 'The number of Optimization Data Records was unexpected' );
        system.assertEquals( irRecord.Id, intResultLst[0].Id, 'The record in the system was not the expected one' );
    }

    @isTest
    static void runErrorBatch() { // Method hits error class, no actual way to confirm as it does not actually prevent deletion
        Integer recordCount = [ SELECT Count() FROM FSL__Optimization_Data__c ];
        system.assertEquals( totalRun, recordCount, 'The number of Optimization Data Records was unexpected' );

        Test.startTest();

            ClearOptimizationDataBatch batch = new ClearOptimizationDataBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}