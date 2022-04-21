@isTest
public class PreventSTMWithoutOperatingHoursTest {

    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        FSLTestUtility.makeResourceData(); // Makes Service Resource as VCI
    }

    @IsTest
    static void makeIllegalSTM(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            try {
                insert FSLTestUtility.makePrimarySTM( sr.Id, st.Id, null );
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventSTMWithoutOperatingHours.DONT_ALLOW_EMPTY_HOURS ) ) {
                    errorThrown = TRUE;
                }
                errorMsg = e.getMessage();
            }
        Test.stopTest();
        
        System.assert( errorThrown, 'The expected error was not thrown. Instead, the following error was thrown: ' + errorMsg );
    }

    @IsTest
    static void updateToIllegalSTM(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        
        ServiceTerritoryMember stm = FSLTestUtility.makePrimarySTM( sr.Id, st.Id, oh.Id );
        insert stm;

        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            stm.OperatingHoursId = null;
            try {
                update stm;
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventSTMWithoutOperatingHours.DONT_ALLOW_EMPTY_HOURS ) ) {
                    errorThrown = TRUE;
                }
                errorMsg = e.getMessage();
            }
        Test.stopTest();
        
        System.assert( errorThrown, 'The expected error was not thrown. Instead, the following error was thrown: ' + errorMsg );
    }
    
}