@isTest
public class GenerateWorkRequestUUIDTest {

    final static String TERRITORY_NAME = 'Buffalo';
    final static String ZIPCODE = '14209';
    final static String INSPECTION = 'Standard Inspection';

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

        FSLTestUtility.createAllStructureWithParentST( TERRITORY_NAME, ZIPCODE );
    }

    @IsTest
    static void createWorkOrder(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        WorkType wtRec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ];
        
        Test.StartTest();
            FSLTestUtility.WorkStruct workReturn = FSLTestUtility.generateWork( wtRec, wtRec, testAcct, ZIPCODE, stRec, 1 );
        Test.StopTest();

        System.assert( workReturn.wo.Id != null, 'The Id of the Work Order was not set' );

        System.assert( [ SELECT Id, External_Record_Guid__c FROM WorkOrderLineItem WHERE WorkOrderId = :workReturn.wo.Id ][0]?.External_Record_Guid__c != null, 'The External GUID was not created as expected' );
    }
}