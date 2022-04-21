@isTest
public class HandleWorkAddressChangeTest {

    // WorkType Names
    private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
    private final static String TRUE_360 = 'True 360';

    @TestSetup
    static void createTerritory() {
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );

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
    static void changeSingleLine() {
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
        ServiceAppointment sa = [ SELECT Id, Street FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1 ];

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;

        Test.startTest();
            woli.Street = '102 Main Street';
            update woli;
        Test.stopTest();

        woli = [ SELECT Id, WorkOrderId, WorkOrder.Street FROM WorkOrderLineItem LIMIT 1 ];
        System.assertEquals( woli.WorkOrderId, wo.Id, 'The Work Order did not change as expected' );
        System.assertNotEquals( woli.WorkOrder.Street, wo.Street, 'The Work Order\'s Address did not properly get updated' );

        ServiceAppointment sa2 = [ SELECT Id, Street FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1 ];
        System.assertNotEquals( sa.Street, sa2.Street, 'The Service Appointment\'s Address did not properly get updated' );
    }

    @isTest
    static void changeInProgressLine() {
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
        ServiceAppointment sa = [ SELECT Id, Street FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1 ];

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            Status = 'In Progress',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;

        Boolean testError = FALSE;
        Test.startTest();
            woli.Street = '102 Main Street';
            try { 
                update woli;
            } catch ( exception e ) {
                if ( e.getMessage().contains( HandleWorkAddressChange.ERROR_MSG ) ) {
                    testError = TRUE;
                }
            }
        Test.stopTest();

        System.assert( testError, 'The expected error message was not thrown' );
        
    }

    @isTest
    static void changeGroupedLine() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Status = 'New',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id
        );
        insert wo;

        List<WorkOrderLineItem> testLineLst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        testLineLst.add( woli );

        WorkOrderLineItem woli2 = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Status = 'In Progress',
            VIN__c = '1234567890123450',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02830'
        );
        testLineLst.add( woli2 );

        insert testLineLst;

        Test.startTest();
            woli.Street = '102 Main Street';
            update woli;
        Test.stopTest();

        woli = [ SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE Id != :woli2.Id LIMIT 1 ];
        System.assertNotEquals( woli.WorkOrderId, wo.Id, 'The Work Order Line Item was not reparented as expected' );
        
    }

    @isTest
    static void changeASIStreet() {
        final String FBI = 'fbi';
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Status = 'New',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Work_Type_Unique_ID__c = :FBI LIMIT 1 ].Id
        );
        insert wo;

        List<WorkOrderLineItem> testLineLst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = :FBI LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        testLineLst.add( woli );
        insert testLineLst;

        String adjustedStreet = '102 Main Street';

        Test.startTest();
            woli.Street = adjustedStreet;
            update woli;
        Test.stopTest();

        woli = [ SELECT Id, Street, WorkOrderId, WorkOrder.Street FROM WorkOrderLineItem WHERE Id = :woli.Id LIMIT 1 ];
        System.assertEquals( woli.WorkOrderId, wo.Id, 'The Work Order Line Item was not reparented as expected' );
        System.assertEquals( woli.WorkOrder.Street, adjustedStreet, 'The Work Order Street was not changed as expected' );
        System.assertEquals( woli.Street, adjustedStreet, 'The Work Order Street was not changed as expected' );
    }

     /*  2/16/2022 - COMMENTED OUT - Work Type Validation Rule prevents changes.
    @isTest
    static void changeASIWorkType() {
        final String FBI = 'fbi';
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Status = 'New',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Work_Type_Unique_ID__c = :FBI LIMIT 1 ].Id
        );
        insert wo;

        List<WorkOrderLineItem> testLineLst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = :FBI LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        testLineLst.add( woli );
        insert testLineLst;

        Id dealerWorkTypeId = [ SELECT ID FROM WorkType WHERE Work_Type_Unique_ID__c = 'dealer' LIMIT 1 ].Id;

        Test.startTest();
            woli.WorkTypeId = dealerWorkTypeId;
            update woli;
        Test.stopTest();

        woli = [ SELECT Id, WorkTypeId, WorkOrderId, WorkOrder.WorkTypeId FROM WorkOrderLineItem WHERE Id = :woli.Id LIMIT 1 ];
        System.assertEquals( woli.WorkOrderId, wo.Id, 'The Work Order Line Item was not reparented as expected' );
        System.assertEquals( woli.WorkOrder.WorkTypeId, dealerWorkTypeId, 'The Work Order WorkType was not changed as expected' );
        System.assertEquals( woli.WorkTypeId, dealerWorkTypeId, 'The Work Order WorkType was not changed as expected' );
    }
    */

    @isTest
    static void changeCanceledASIStreet() {
        final String FBI = 'fbi';
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Status = 'New',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Work_Type_Unique_ID__c = :FBI LIMIT 1 ].Id
        );
        insert wo;

        List<WorkOrderLineItem> testLineLst = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '1234567890123456',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = :FBI LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        testLineLst.add( woli );
        insert testLineLst;

        String adjustedStreet = '102 Main Street';

        Test.startTest();
            woli.Status = 'Canceled';
            woli.Street = adjustedStreet;
            update woli;
        Test.stopTest();

        woli = [ SELECT Id, Street, WorkOrderId, WorkOrder.Street FROM WorkOrderLineItem WHERE Id = :woli.Id LIMIT 1 ];
        System.assertEquals( woli.WorkOrderId, wo.Id, 'The Work Order Line Item was not reparented as expected' );
        System.assertEquals( woli.WorkOrder.Street, adjustedStreet, 'The Work Order Street was not changed as expected' );
        System.assertEquals( woli.Street, adjustedStreet, 'The Work Order Street was not changed as expected' );
    }
}