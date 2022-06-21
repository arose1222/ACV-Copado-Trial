@isTest
public class SecondarySTMRequiresPrimarySTMTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;

        FSLTestUtility.makeResourceData(); // Makes Service Resource as VCI
    }   

    @IsTest
    static void throwError(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            try {
                insert FSLTestUtility.makeSTM( sr.Id, st.Id, oh.Id, SecondarySTMRequiresPrimarySTM.SECONDARY_STM, DateTime.now().addDays(-1), null );
            } catch ( exception e ) {
                if ( e.getMessage().contains( SecondarySTMRequiresPrimarySTM.DONT_ALLOW_SECONDARY_WITHOUT_PRIMARY ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }

    @IsTest
    static void updateError(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];

        ServiceTerritoryMember stm = FSLTestUtility.makeSTM( sr.Id, st.Id, oh.Id, 'P', DateTime.now().addDays(-1), null );
        insert stm;
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            try {
                stm.TerritoryType = SecondarySTMRequiresPrimarySTM.SECONDARY_STM;
                update stm;
            } catch ( exception e ) {
                if ( e.getMessage().contains( SecondarySTMRequiresPrimarySTM.DONT_ALLOW_SECONDARY_WITHOUT_PRIMARY ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }

    @IsTest
    static void normalCase(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];

        insert FSLTestUtility.makePrimarySTM( sr.Id, st.Id, oh.Id );

        ServiceTerritory st2 = new ServiceTerritory( 
            Name = 'Great Lakes', OperatingHoursId = oh.Id, isActive = TRUE
        );
        insert st2;
        
        Test.startTest();
            // If this fails, system will throw an error, no asset needed
            insert FSLTestUtility.makeSTM( sr.Id, st2.Id, oh.Id, SecondarySTMRequiresPrimarySTM.SECONDARY_STM, DateTime.now().addDays(-1), null );
        Test.stopTest();      
    }
}