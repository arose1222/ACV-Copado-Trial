@isTest
public class PreventCannotCompleteWorkEarlyTest {
    
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

        FSLTestUtility.createData( a, 1 );
    }

    @IsTest
    static void throwError(){
        ServiceAppointment testSA = [ SELECT Id FROM ServiceAppointment ];
        
        Boolean catchProperErrorMsg = FALSE;
        String errorMsg;
        Test.startTest();
            try {
                testSA.Status = 'Cannot Complete';
                update testSA;
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventCannotCompleteWorkEarly.CANNOT_COMPLETE_ERROR ) ) {
                    catchProperErrorMsg = TRUE;
                }
                errorMsg = e.getMessage();
            }
        Test.stopTest();
        System.assert( catchProperErrorMsg, 'An incorrect error message (or no error message) was caught when attempting to update the Service Appointment to an invalid Status: ' + errorMsg );
    }
}