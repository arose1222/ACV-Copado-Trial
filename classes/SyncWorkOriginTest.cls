@isTest
public class SyncWorkOriginTest {

     // WorkType Names
     private final static String INSPECTION = 'Standard Inspection';
     private final static String ASSET = 'Asset Verification';
     private final static String TRUE_360 = 'True 360';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
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
    static void originFill(){
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id
        );
        insert wo;

        wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
        System.AssertEquals( wo.Origin__c, null, 'The Work Order\'s Origin wasn\'t blank as expected' );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            Origin__c = 'Text',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );

        Test.startTest();
            insert woli;
        Test.stopTest();

        wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
        System.AssertEquals( woli.Origin__c, wo.Origin__c, 'The Work Order\'s Origin didn\'t get updated as expected from the new Work Order Line Item!' );
    }

    @isTest
    static void originUpdate(){
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id
        );
        insert wo;

        wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
        System.AssertEquals( wo.Origin__c, null, 'The Work Order\'s Origin wasn\'t blank as expected' );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            Origin__c = 'Text',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;

        wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
        System.AssertEquals( woli.Origin__c, wo.Origin__c, 'The Work Order\'s Origin didn\'t get updated as expected from the new Work Order Line Item!' );

        Test.startTest();
            wo.Origin__c = null;
            update wo;
    
            wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
            System.AssertEquals( wo.Origin__c, null, 'The Work Order\'s Origin wasn\'t blank as expected' );

        
            woli.Origin__c = 'Email';
            update woli;

            wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
            System.AssertEquals( woli.Origin__c, wo.Origin__c, 'The Work Order\'s Origin didn\'t get updated as expected from the new Work Order Line Item!' );
        Test.stopTest();
    }

    @isTest
    static void originDontFill(){
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Origin__c = 'Email',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id
        );
        insert wo;

        wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
        System.AssertEquals( wo.Origin__c, 'Email', 'The Work Order\'s Origin wasn\'t blank as expected' );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            Origin__c = 'Text',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );

        Test.startTest();
            insert woli;
        Test.stopTest();

        wo = [ SELECT Id, Origin__c FROM WorkOrder WHERE Id = :wo.Id LIMIT 1 ];
        System.AssertNotEquals( woli.Origin__c, wo.Origin__c, 'The Work Order\'s Origin unexpectedly got updated as expected from the new Work Order Line Item!' );
    }
}