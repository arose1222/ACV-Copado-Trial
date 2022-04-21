@isTest
public class PreventDownDaySchedulingTest {

    private static DateTime now = System.now();

    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;

        // FSLTestUtility.makePreferredResourceData( acct );

        WorkType cpoWT = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_Id__c = 'CPOBM' LIMIT 1 ];

        insert new Down_Day__c(
            Start__c = now,
            End__c = now,
            Name = 'Test Down Day for CPO',
            Work_Type__c = cpoWT.Id
        );
    }   

    @IsTest
    static void throwError(){
        // ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory testST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType cpoWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'CPOBM' LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            FSLTestUtility.generateWork( cpoWT, cpoWT, testAcct, '14209', testST, 1 );
            ServiceAppointment saTestRec = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];

            try {
                saTestRec.SchedStartTime = now; // Has to trigger change for code
                saTestRec.SchedEndTime = now.addMinutes( Integer.valueOf( cpoWT.EstimatedDuration ) );
                update saTestRec;
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventDownDayScheduling.CANT_SCHEDULE_ON_DOWN_DAY_ERROR ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }
}