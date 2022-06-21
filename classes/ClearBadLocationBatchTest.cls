@isTest
public class ClearBadLocationBatchTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Schema.Location l0 = new Schema.Location(
            Name = 'Bad Location'
        );
        insert l0;
    }

    @isTest
    static void runBatch() {
        System.assertEquals( 1, [ SELECT Count() FROM Location ], 'There was an unexpected amount of Locations' );

        Test.startTest();
            SchedulableContext sc = null;
            ClearBadLocationBatch batch = new ClearBadLocationBatch();
            batch.execute( sc );
        Test.stopTest();

        System.assertEquals( 0, [ SELECT Count() FROM Location ], 'There was an unexpected amount of Locations after the batch ran' );
    }

    @isTest
    static void runBatchWithValidLocation() {
        Schema.Location l1 = new Schema.Location(
            Name = 'Good Location'
        );
        insert l1;

        Schema.Address a1 = new Schema.Address(ParentId = l1.id, Street = '123 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        insert a1;

        l1.VisitorAddressId = a1.Id;
        update l1;

        System.assertEquals( 2, [ SELECT Count() FROM Location ], 'There was an unexpected amount of Locations' );

        Test.startTest();
            SchedulableContext sc = null;
            ClearBadLocationBatch batch = new ClearBadLocationBatch();
            batch.execute( sc );
        Test.stopTest();

        System.assertEquals( 1, [ SELECT Count() FROM Location ], 'There was an unexpected amount of Locations after the batch ran' );
    }

    @isTest
    static void runErrorBatch() {  // Method hits error class, no actual way to confirm as it does not actually prevent deletion
        System.assertEquals( 1, [ SELECT Count() FROM Location ], 'There was an unexpected amount of Locations' );

        Test.startTest();

            SchedulableContext sc = null;
            ClearBadLocationBatch batch = new ClearBadLocationBatch();

            BatchUtilityClass.testingFlag = TRUE;
            batch.execute( sc );

        Test.stopTest();
    }

    @isTest
    static void checkRescheduleJob() {
        System.assertEquals( 1, [ SELECT Count() FROM Location ], 'There was an unexpected amount of Locations' );

        Test.startTest();

            SchedulableContext sc = null;
            ClearBadLocationBatch batch = new ClearBadLocationBatch();
            batch.execute( sc );

        Test.stopTest();

        System.assertEquals( 4, [ SELECT Count() FROM AsyncApexJob ], 'There was an unexpected amount of Scheduled Jobs' );
    }
}