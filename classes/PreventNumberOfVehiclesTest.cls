@isTest
public class PreventNumberOfVehiclesTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;
    }   

    @IsTest
    static void throwError(){
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType fbiWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'fbi' LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            try {
                WorkOrder fbiWork = FSLTestUtility.createWorkOrder( fbiWT, acct, '14209', st, null );
                fbiWork.Inspection_Number_Of_Vehicles__c = 4;
                
                insert fbiWork;
            } catch ( exception e ) {
                system.debug( e.getMessage() );
                if ( e.getMessage().contains( PreventNumberOfVehicles.DOES_NOT_RESPECT_VEHICLE_COUNT_ERR ) ) {
                    errorThrown = TRUE;
                }
                errorMsg = e.getMessage();
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }

    @IsTest
    static void testValidCase(){
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType standardInspect = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'inspection' LIMIT 1 ];
        
        Test.startTest();
            WorkOrder sinpectionWork = FSLTestUtility.createWorkOrder( standardInspect, acct, '14209', st, null );
            sinpectionWork.Inspection_Number_Of_Vehicles__c = 4;
            
            insert sinpectionWork;
        Test.stopTest();
        // Error will throw incorrectly if there is an issue, no assert needed      
    }
}