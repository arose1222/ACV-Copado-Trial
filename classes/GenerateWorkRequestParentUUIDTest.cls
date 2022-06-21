@isTest
public class GenerateWorkRequestParentUUIDTest {
    final static String TERRITORY_NAME = 'Buffalo';
    final static String ZIPCODE = '14209';
    final static String INSPECTION = 'Standard Inspection';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createAllStructureWithParentST( TERRITORY_NAME, ZIPCODE );
    }

    @IsTest
    static void createWorkOrder(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        WorkType wtRec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ];
        
        Test.StartTest();
            WorkOrder testWork = FSLTestUtility.createWorkOrder( wtRec, testAcct, ZIPCODE, stRec, null );
            testWork.Created_Without_Line_Items__c = TRUE;
            insert testWork;
        Test.StopTest();

        System.assert( [ SELECT Id, External_Record_Guid__c FROM WorkOrder WHERE Id = :testWork.Id ][0]?.External_Record_Guid__c != null, 'The External GUID was not created as expected' );
    }
}