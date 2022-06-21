@isTest
public class UpdateSAExcludeFromOptimizationTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Cannot Complete' );

        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = TestUtility.createAffiliation( a, c );
        insert aff;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
    }

    @IsTest
    static void createLineItem() {
        Account a = [ SELECT Id, Name FROM Account LIMIT 1 ];
        WorkType fbiWT = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'fbi' LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        WorkOrder wo = FSLTestUtility.createWorkOrder(
            fbiWT, a, '14209', st, null
        );
        insert wo;

        Test.startTest();
            WorkOrderLineItem woli = FSLTestUtility.createWorkOrderLineItem( wo, fbiWT, 1 );
            woli.Exclude_From_Optimization__c = TRUE;
            
            insert woli;
        Test.stopTest();
        
        ServiceAppointment sa = [ SELECT Id, Exclude_From_Optimization__c FROM ServiceAppointment LIMIT 1 ];
        system.assertEquals( TRUE, sa.Exclude_From_Optimization__c, 'The Service Appointment was not excluded from Optimization as expected!' );
    }

    @IsTest
    static void createNegativeCaseLineItem() {
        Account a = [ SELECT Id, Name FROM Account LIMIT 1 ];
        WorkType fbiWT = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'fbi' LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        WorkOrder wo = FSLTestUtility.createWorkOrder(
            fbiWT, a, '14209', st, null
        );
        insert wo;

        Test.startTest();
            WorkOrderLineItem woli = FSLTestUtility.createWorkOrderLineItem( wo, fbiWT, 1 );
            woli.Exclude_From_Optimization__c = FALSE;
            
            insert woli;
        Test.stopTest();
        
        ServiceAppointment sa = [ SELECT Id, Exclude_From_Optimization__c FROM ServiceAppointment LIMIT 1 ];
        system.assertEquals( FALSE, sa.Exclude_From_Optimization__c, 'The Service Appointment was not excluded from Optimization as expected!' );
    }
}