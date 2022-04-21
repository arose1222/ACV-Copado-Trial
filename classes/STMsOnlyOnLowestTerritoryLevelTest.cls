@isTest
public class STMsOnlyOnLowestTerritoryLevelTest {
    private final static String CHILD_NAME = 'vciParent';

    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'vciTest', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;

        ServiceTerritory childST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritory st2 = new ServiceTerritory( 
            Name = CHILD_NAME, OperatingHoursId = oh.Id, isActive = TRUE
        );
        insert st2;

        childST.ParentTerritoryId = st2.Id;
        update childST;

        FSLTestUtility.makeResourceData(); // Makes Service Resource as VCI
    }   

    @IsTest
    static void throwError(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory WHERE Name = :CHILD_NAME LIMIT 1 ];
        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            try {
                insert FSLTestUtility.makePrimarySTM( sr.Id, st.Id, oh.Id );
            } catch ( exception e ) {
                if ( e.getMessage().contains( STMsOnlyOnLowestTerritoryLevel.DONT_ALLOW_STM_ABOVE_LOWEST_LEVEL ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }

    // @IsTest
    // static void updateError(){
    //     ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];   
    //     ServiceTerritory st = [ SELECT Id, FSL__TerritoryLevel__c, ParentTerritoryId, Name FROM ServiceTerritory WHERE Name = :CHILD_NAME LIMIT 1 ];
    //     ServiceTerritory st2 = [ SELECT Id, FSL__TerritoryLevel__c, ParentTerritoryId, Name FROM ServiceTerritory WHERE Name != :CHILD_NAME LIMIT 1 ];
    //     OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];

    //     ServiceTerritoryMember stm = FSLTestUtility.makePrimarySTM( sr.Id, st2.Id, oh.Id );
    //     insert stm;
        
    //     Boolean errorThrown = FALSE;
    //     String errorMsg;
    //     Test.startTest();
    //         try {
    //             stm.ServiceTerritoryId = st.Id;
    //             update stm;
    //         } catch ( exception e ) {
    //             if ( e.getMessage().contains( STMsOnlyOnLowestTerritoryLevel.DONT_ALLOW_STM_ABOVE_LOWEST_LEVEL ) ) {
    //                 errorThrown = TRUE;
    //                 errorMsg = e.getMessage();
    //             }
    //         }
    //     Test.stopTest();

    //     System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    // }

    @IsTest
    static void normalCase(){
        ServiceResource sr = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory WHERE Name != :CHILD_NAME LIMIT 1 ];
        OperatingHours oh = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        
        Test.startTest();
            // If this fails, system will throw an error, no asset needed
            insert FSLTestUtility.makePrimarySTM( sr.Id, st.Id, oh.Id );
        Test.stopTest();      
    }
}