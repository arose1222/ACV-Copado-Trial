@isTest
public class ClearEntitySubscriptionsBatchTest {    

    public static boolean BatchTestFlag = FALSE;
    
    public final static String INTEGRATION_TYPE = 'Create Case';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Account> acctLst = new List<Account>();
        for ( Integer index = 0; index < 10; index++ ) {
            acctLst.add( 
                TestUtility.createAccount( 'Account ' + ( index + math.random() ) + ' Name' )
            );
        }

        insert acctLst;

        List<EntitySubscription> esLst = new List<EntitySubscription>();
        for ( Account acct : acctLst ) {
            esLst.add( new EntitySubscription(
                ParentId = acct.Id,
                SubscriberId = UserInfo.getUserId()
            ) );
        }

        insert esLst;

        for ( EntitySubscription esRec : esLst ) {
            Test.setCreatedDate( esRec.Id, DateTime.now().addDays( ClearEntitySubscriptionsBatch.DEFAULT_DAY_RANGE + ( -1 ) ) );
        }
    }

    @isTest
    static void runBatch() {
        Integer resultCount = [ SELECT Count() FROM EntitySubscription ];
        system.assertEquals( 10, resultCount, 'The number of results was unexpected' );

        Test.startTest();

            ClearEntitySubscriptionsBatch batch = new ClearEntitySubscriptionsBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        resultCount = [ SELECT Count() FROM EntitySubscription ];
        system.assertEquals( 0, resultCount, 'The number of results was unexpected' );
    }

    @isTest
    static void runSpecificTimeBatch() {
        Integer resultCount = [ SELECT Count() FROM EntitySubscription ];
        system.assertEquals( 10, resultCount, 'The number of results was unexpected' );

        Test.startTest();

            ClearEntitySubscriptionsBatch batch = new ClearEntitySubscriptionsBatch( DateTime.now().addDays( -1 ) );
            batch.executeScheduledLogic();

        Test.stopTest();

        resultCount = [ SELECT Count() FROM EntitySubscription ];
        system.assertEquals( 0, resultCount, 'The number of results was unexpected' );
    }

    @isTest
    static void newRecordBatch() {
        Account testAcct = TestUtility.createAccount();
        insert testAcct;

        EntitySubscription esRec = new EntitySubscription(
            ParentId = testAcct.Id,
            SubscriberId = UserInfo.getUserId()
        );
        insert esRec;

        Integer resultCount = [ SELECT Count() FROM EntitySubscription ];
        system.assertEquals( 11, resultCount, 'The number of results was unexpected' );

        Test.startTest();

            ClearEntitySubscriptionsBatch batch = new ClearEntitySubscriptionsBatch();
            batch.executeScheduledLogic();

        Test.stopTest();

        List<EntitySubscription> esLst = [ SELECT Id FROM EntitySubscription ];
        system.assertEquals( 1, esLst.size(), 'The number of results was unexpected' );
        system.assertEquals( esRec.Id, esLst[0].Id, 'The record in the system was not the expected one' );
    }

    @isTest
    static void runErrorBatch() {  // Method hits error class, no actual way to confirm as it does not actually prevent deletion
        Integer resultCount = [ SELECT Count() FROM EntitySubscription ];
        system.assertEquals( 10, resultCount, 'The number of results was unexpected' );

        Test.startTest();

            ClearEntitySubscriptionsBatch batch = new ClearEntitySubscriptionsBatch();

            ClearEntitySubscriptionsBatchTest.BatchTestFlag = TRUE;
            batch.executeScheduledLogic();

        Test.stopTest();
    }
}