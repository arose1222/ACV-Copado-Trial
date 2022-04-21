@isTest
public class FSLExpirationBatchTest {
    // WorkType Names
    private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
    private final static String TRUE_360 = 'True 360';

    @TestSetup
    static void createTerritory() {
        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = new Affiliation__c(
            Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true, 
            Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
            type__c='rep'
        );
        insert aff;
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
    }

    @isTest
    public static void runScheduling() {
        Test.StartTest();
            FSLExpirationBatch batch = new FSLExpirationBatch();
            batch.executeScheduledLogic();
        Test.StopTest();
    }

    @isTest
    public static void expireSingleWOLI() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        insert wo;

        DateTime pastDate = DateTime.now().addDays( -30 );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;
        Test.setCreatedDate( woli.Id, pastDate );

        Test.StartTest();
            Database.executeBatch( new FSLExpirationBatch(), 200 );
        Test.StopTest();

        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' ], 'The Work Order Line Item was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was not expired as expected' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem WHERE Status != 'Expired' ], 'A Work Order Line Item exists that was not expired' );
    }

    @isTest
    public static void dontExpireNewWOLI() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        insert wo;

        DateTime pastDate = DateTime.now();

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;

        Test.StartTest();
            Database.executeBatch( new FSLExpirationBatch(), 200 );
        Test.StopTest();

        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' ], 'The Work Order Line Item was unexpectedly expired' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was unexpectedly expired' );
    }

    @isTest
    public static void expireSingleWOLIWithExtraLine() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        insert wo;

        DateTime pastDate = DateTime.now().addDays( -30 );

        List<WorkOrderLineItem> insertWOLILst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insertWOLILst.add( woli );

        WorkOrderLineItem woli2 = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234560',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02837'
        );
        insertWOLILst.add( woli2 );

        insert insertWOLILst;
        Test.setCreatedDate( woli.Id, pastDate );

        Test.StartTest();
            Database.executeBatch( new FSLExpirationBatch(), 200 );
        Test.StopTest();

        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' AND Id = :woli.Id ], 'The Work Order Line Item was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem WHERE Status != 'Expired' AND Id != :woli.Id ], 'A Work Order Line Item exists that was not expired' );
        
        woli2 = [ SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE Status != 'Expired' ];
        System.assertNotEquals( wo.Id, woli2.WorkOrderId, 'The Second Line Item was not reparented as expected' );
    }

    @isTest
    public static void expireMultiWOLIOnSameWO() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        insert wo;

        DateTime pastDate = DateTime.now().addDays( -30 );

        List<WorkOrderLineItem> insertWOLILst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insertWOLILst.add( woli );

        WorkOrderLineItem woli2 = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234560',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02837'
        );
        insertWOLILst.add( woli2 );

        insert insertWOLILst;
        Test.setCreatedDate( woli.Id, pastDate );
        Test.setCreatedDate( woli2.Id, pastDate );

        Test.StartTest();
            Database.executeBatch( new FSLExpirationBatch(), 200 );
        Test.StopTest();

        System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' ], 'The Work Order Line Item was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was not expired as expected' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem WHERE Status != 'Expired' ], 'A Work Order Line Item exists that was not expired' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder WHERE Status != 'Expired' ], 'An unexpected Work Order was generated' );
    }

    @isTest
    public static void expireMultiWOLIOnDifferentWO() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];

        List<WorkOrder> woLst = new List<WorkOrder>();
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        woLst.add( wo );
        WorkOrder wo2 = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        woLst.add( wo2 );
        insert woLst;

        DateTime pastDate = DateTime.now().addDays( -30 );

        List<WorkOrderLineItem> insertWOLILst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insertWOLILst.add( woli );

        WorkOrderLineItem woli2 = new WorkOrderLineItem(
            WorkOrderId = wo2.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234560',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02837'
        );
        insertWOLILst.add( woli2 );

        insert insertWOLILst;
        Test.setCreatedDate( woli.Id, pastDate );
        Test.setCreatedDate( woli2.Id, pastDate );

        Test.StartTest();
            Database.executeBatch( new FSLExpirationBatch(), 200 );
        Test.StopTest();

        System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' ], 'The Work Order Line Item was not expired as expected' );
        System.assertEquals( 2, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was not expired as expected' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem WHERE Status != 'Expired' ], 'A Work Order Line Item exists that was not expired' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder WHERE Status != 'Expired' ], 'An unexpected Work Order was generated' );
    }

    @isTest
    public static void expireMultiWOLIButNotAll() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        insert wo;

        DateTime pastDate = DateTime.now().addDays( -30 );

        List<WorkOrderLineItem> insertWOLILst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insertWOLILst.add( woli );

        WorkOrderLineItem woli2 = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234560',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02837'
        );
        insertWOLILst.add( woli2 );

        WorkOrderLineItem woli3 = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234560',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02838'
        );
        insertWOLILst.add( woli3 );

        insert insertWOLILst;
        Test.setCreatedDate( woli.Id, pastDate );
        Test.setCreatedDate( woli2.Id, pastDate );

        Test.StartTest();
            Database.executeBatch( new FSLExpirationBatch(), 200 );
        Test.StopTest();

        System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' ], 'The Work Order Line Item was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem WHERE Status != 'Expired' ], 'The amount of un-expired Work Order Line Items is incorrect' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder WHERE Status != 'Expired' AND Id != :wo.Id ], 'The amount of un-expired Work Orders is incorrect' );
    }

    @isTest
    public static void databaseRollback() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id
        );
        insert wo;

        DateTime pastDate = DateTime.now().addDays( -30 );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Status = 'New',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :TRUE_360 LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;
        Test.setCreatedDate( woli.Id, pastDate );

        Test.StartTest();
            FSLExpirationBatch batchRun = new FSLExpirationBatch();
            batchRun.returnInfo = new BatchUtilityClass.BatchReturn( TRUE );
            Database.executeBatch( batchRun, 200 );
        Test.StopTest();

        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem WHERE Status = 'Expired' ], 'The Work Order Line Item was not expired as expected' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder WHERE Status = 'Expired' ], 'The Work Order was not expired as expected' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem WHERE Status != 'Expired' ], 'A Work Order Line Item exists that was not expired' );
    }
}