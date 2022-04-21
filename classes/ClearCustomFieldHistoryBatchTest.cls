@isTest
public class ClearCustomFieldHistoryBatchTest {
    
    @TestSetup
    static void makeData(){
        List<Field_History__c> integrationLst = new List<Field_History__c>();
        for ( Integer index = 0; index < 10; index++ ) {
            integrationLst.add( new Field_History__c(
                Field__c = 'Status',
                New_Value__c = 'Closed',
                Old_Value__c = 'New'
            ) );
        }

        insert integrationLst;

        for ( Field_History__c irRecord : integrationLst ) {
            Test.setCreatedDate( irRecord.Id, DateTime.now().addDays( ClearCustomFieldHistoryBatch.DEFAULT_DAY_RANGE + ( -1 ) ) );
        }
    }

    @isTest
    static void runBatch() {
        Integer fieldCount = [ SELECT Count() FROM Field_History__c ];
        system.assertEquals( 10, fieldCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearCustomFieldHistoryBatch batch = new ClearCustomFieldHistoryBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        fieldCount = [ SELECT Count() FROM Field_History__c ];
        system.assertEquals( 0, fieldCount, 'The number of integration results was unexpected' );
    }

    @isTest
    static void runSpecificTimeBatch() {
        Integer fieldCount = [ SELECT Count() FROM Field_History__c ];
        system.assertEquals( 10, fieldCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearCustomFieldHistoryBatch batch = new ClearCustomFieldHistoryBatch( DateTime.now().addDays( -1 ) );
            batch.executeScheduledLogic();

        Test.stopTest();

        fieldCount = [ SELECT Count() FROM Field_History__c ];
        system.assertEquals( 0, fieldCount, 'The number of integration results was unexpected' );
    }

    @isTest
    static void newRecordBatch() {
        Field_History__c irRecord = new Field_History__c(
            Field__c = 'Status',
            New_Value__c = 'Closed',
            Old_Value__c = 'New'
        );
        insert irRecord;

        Integer fieldCount = [ SELECT Count() FROM Field_History__c ];
        system.assertEquals( 11, fieldCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearCustomFieldHistoryBatch batch = new ClearCustomFieldHistoryBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        List<Field_History__c> intResultLst = [ SELECT Id FROM Field_History__c ];
        system.assertEquals( 1, intResultLst.size(), 'The number of integration results was unexpected' );
        system.assertEquals( irRecord.Id, intResultLst[0].Id, 'The record in the system was not the expected one' );
    }

    @isTest
    static void runErrorBatch() { // Method hits error class, no actual way to confirm as it does not actually prevent deletion
        Integer fieldCount = [ SELECT Count() FROM Field_History__c ];
        system.assertEquals( 10, fieldCount, 'The number of integration results was unexpected' );

        Test.startTest();

            ClearCustomFieldHistoryBatch batch = new ClearCustomFieldHistoryBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}