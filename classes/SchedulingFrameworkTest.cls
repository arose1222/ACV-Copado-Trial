@isTest
public class SchedulingFrameworkTest {
    private static final string SAMPLE_INTERFACE_CLASS = 'ClearIntegrationResultsBatch';
    private static final string SAMPLE_NAMESPACE_PREFIX = null; // No Namespace for current example

    @TestSetup
    static void makeData(){
        List<Integration_Result__c> createTestDataLst = new List<Integration_Result__c>();
        createTestDataLst.add( ClearIntegrationResultsBatchTest.makeIntLog( 1 ) );
        insert createTestDataLst;

        ClearIntegrationResultsBatchTest.adjustCreatedDate( createTestDataLst );
    }

    /**
     * Cover the Interface
     */
    @IsTest
    static void callInterfaceMethod(){
        Test.startTest();
            SchedulingInterface interfaceRec = new SchedulingInterface();
            interfaceRec.executeScheduledLogic();
        Test.stopTest();
        // Nothing happens, so nothing to assert
    }

    /**
     * No Interval Data Tests Below
     */

    @IsTest
    static void runBatchWithNoEntries() {
        // Specifically do not make any test data
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            null, // What interval are we testing? - For 5 Minutes, leaving blank is proper for test setup
            null, // Time doesn't matter for this test, leave blank
            null // Are we testing the earlier side of the interval?
        );
    }

    /**
     * Specific Time Interval Tests Below
     */

    @IsTest
    static void runSpecificIntervalBatch() {
        createData( SchedulingFramework.SPECIFIC_TIME, DateTime.now().time() );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            null, // What interval are we testing? - For 5 Minutes, leaving blank is proper for test setup
            null, // Time should be set to current time, so leaving blank will do this
            null // Are we testing the earlier side of the interval?
        );
    }

    /**
     * 5 Minute Interval Tests Below
     */

    @IsTest
    static void run5MinuteBatch() {
        createData( SchedulingFramework.EVERY_5_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            null, // What interval are we testing? - For 5 Minutes, leaving blank is proper for test setup
            null, // Time doesn't matter for this test, leave blank
            null // Are we testing the earlier side of the interval?
        );
    }

    /**
     * 10 Minute Interval Tests Below
     */

    @IsTest
    static void dontRunEarly10MinuteBatch() {
        createData( SchedulingFramework.EVERY_10_MINUTES );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_10_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.TEN_MINUTE_CHECK_SET )[(SchedulingFramework.TEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runEarly10MinuteBatch() {
        createData( SchedulingFramework.EVERY_10_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_10_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.TEN_MINUTE_CHECK_SET )[(SchedulingFramework.TEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runLate10MinuteBatch() {
        createData( SchedulingFramework.EVERY_10_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_10_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.TEN_MINUTE_CHECK_SET )[(SchedulingFramework.TEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void dontRunLate10MinuteBatch() {    
        createData( SchedulingFramework.EVERY_10_MINUTES );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_10_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.TEN_MINUTE_CHECK_SET )[(SchedulingFramework.TEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    /**
     * 15 Minute Interval Tests Below
     */

    @IsTest
    static void dontRunEarly15MinuteBatch() {
        createData( SchedulingFramework.EVERY_15_MINUTES );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_15_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET )[(SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runEarly15MinuteBatch() {
        createData( SchedulingFramework.EVERY_15_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_15_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET )[(SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runLate15MinuteBatch() {
        createData( SchedulingFramework.EVERY_15_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_15_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET )[(SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void dontRunLate15MinuteBatch() {    
        createData( SchedulingFramework.EVERY_15_MINUTES );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_15_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET )[(SchedulingFramework.FIFTEEN_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    /**
     * 30 Minute Interval Tests Below
     */

    @IsTest
    static void dontRunEarly30MinuteBatch() {
        createData( SchedulingFramework.EVERY_30_MINUTES );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_30_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.THIRTY_MINUTE_CHECK_SET )[(SchedulingFramework.THIRTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runEarly30MinuteBatch() {
        createData( SchedulingFramework.EVERY_30_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_30_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.THIRTY_MINUTE_CHECK_SET )[(SchedulingFramework.THIRTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runLate30MinuteBatch() {
        createData( SchedulingFramework.EVERY_30_MINUTES );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_30_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.THIRTY_MINUTE_CHECK_SET )[(SchedulingFramework.THIRTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void dontRunLate30MinuteBatch() {    
        createData( SchedulingFramework.EVERY_30_MINUTES );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_30_MINUTES, // What interval are we testing?
            new List<integer>( SchedulingFramework.THIRTY_MINUTE_CHECK_SET )[(SchedulingFramework.THIRTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    /**
     * 1 Hour Interval Tests Below
     */

    @IsTest
    static void dontRunEarly60MinuteBatch() {
        createData( SchedulingFramework.EVERY_HOUR );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_HOUR, // What interval are we testing?
            new List<integer>( SchedulingFramework.SIXTY_MINUTE_CHECK_SET )[(SchedulingFramework.SIXTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runEarly60MinuteBatch() {
        createData( SchedulingFramework.EVERY_HOUR );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_HOUR, // What interval are we testing?
            new List<integer>( SchedulingFramework.SIXTY_MINUTE_CHECK_SET )[(SchedulingFramework.SIXTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            true // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void runLate60MinuteBatch() {
        createData( SchedulingFramework.EVERY_HOUR );
        processTest(  
            0, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_HOUR, // What interval are we testing?
            new List<integer>( SchedulingFramework.SIXTY_MINUTE_CHECK_SET )[(SchedulingFramework.SIXTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    @IsTest
    static void dontRunLate60MinuteBatch() {    
        createData( SchedulingFramework.EVERY_HOUR );
        processTest(  
            1, // How many records should remain - 0 Means the Batch should have run and deleted them, 1 means the Batch should have not have run and the records are uneffected
            SchedulingFramework.EVERY_HOUR, // What interval are we testing?
            new List<integer>( SchedulingFramework.SIXTY_MINUTE_CHECK_SET )[(SchedulingFramework.SIXTY_MINUTE_CHECK_SET.size()-1)], // Dynamically get the last possible value within the selected interval for testing
            false // Are we testing the earlier side of the interval?
        );
    }

    private static void processTest( integer expectedQueryResults, string intervalToTest, integer minuteSlot, boolean isEarly ) {
        integer dynamicTimeRange = SchedulingFramework.MINUTE_ADJUSTMENT_RANGE;
        time timeToTest = intervalToTest != null ? Time.newInstance( 
            0, 
            isEarly ? ( minuteSlot - dynamicTimeRange - ( expectedQueryResults > 0 ? 1 : 0 ) ) : ( minuteSlot + dynamicTimeRange + ( expectedQueryResults > 0 ? 1 : 0 ) ), 
            0, 0 
        ) : DateTime.now().time(); // If intervalToTest is null, then set the current time to now as the time doesn't matter for this test

        Test.startTest();
            SchedulableContext sc = null;
            SchedulingFramework runFramework = new SchedulingFramework();
            SchedulingFramework.now = DateTime.newInstance( Date.today(), timeToTest );
            runFramework.execute( sc );
        Test.stopTest();

        integer integrationResultCount = [ SELECT Count() FROM Integration_Result__c WHERE Integration_Type__c = :ClearIntegrationResultsBatchTest.INTEGRATION_TYPE ];
        system.assertEquals( expectedQueryResults, integrationResultCount, 'The number of integration results was unexpected:' + integrationResultCount );
    }

    private static void createData( string intervalToTest ) {
        createData( intervalToTest, null );
    }

    private static void createData( string intervalToTest, time timeToRun ) {
        insert createSchEntry( 
            SAMPLE_INTERFACE_CLASS,
            SAMPLE_NAMESPACE_PREFIX,
            intervalToTest,
            timeToRun
        );
    }

    private static Scheduled_Entry__c createSchEntry( string className, string nameSpace, string intervalSelected, time specificTime ) {
        return new Scheduled_Entry__c(
            Class_Name__c = className,
            Namespace_Prefix__c = nameSpace,
            Interval__c = intervalSelected,
            Specific_Time__c = specificTime,
            Is_Active__c = TRUE
        );
    }
}