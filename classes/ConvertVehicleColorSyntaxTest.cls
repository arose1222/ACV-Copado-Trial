@isTest
public class ConvertVehicleColorSyntaxTest {
	@TestSetup
    public static void makeData() {
        Account a = TestUtility.createAccount();
        a.Dealership_Id__c = '1';
        insert a;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
    }
    
    @isTest
    public static void createUnWindWork() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Work_Type_Unique_ID__c = 'unwind inspection' LIMIT 1 ].Id
        );
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Color__c = '1',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'unwind inspection' LIMIT 1 ].Id
        );
		Test.startTest();
	        insert woli;
       	Test.stopTest();
        
        woli = [ SELECT Id, Color__c FROM WorkOrderLineItem LIMIT 1 ];
        system.assertEquals( 'Black', woli.Color__c, 'The color was not converted as expected' );
    }
    
    @isTest
    public static void createArbWork() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Work_Type_Unique_ID__c = 'arbitration inspection' LIMIT 1 ].Id
        );
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            Color__c = '1',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'arbitration inspection' LIMIT 1 ].Id
        );
		Test.startTest();
	        insert woli;
       	Test.stopTest();
        
        woli = [ SELECT Id, Color__c FROM WorkOrderLineItem LIMIT 1 ];
        system.assertEquals( 'Black', woli.Color__c, 'The color was not converted as expected' );
    }
}