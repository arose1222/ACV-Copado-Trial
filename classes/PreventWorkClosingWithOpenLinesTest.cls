@isTest
public class PreventWorkClosingWithOpenLinesTest {
    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Completed' );
    }   

    @IsTest
    static void throwError(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory testST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType promoWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'promo work' LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            FSLTestUtility.generateWork( promoWT, promoWT, testAcct, '14209', testST, 1 );
            WorkOrder woTestRec = [ SELECT Id FROM WorkOrder LIMIT 1 ];

            try {
                woTestRec.Status = 'Completed';
                update woTestRec;
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventWorkClosingWithOpenLines.CANNOT_MARK_COMPLETE_ERROR ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thrown: ' + errorMsg );        
    }

    @IsTest
    static void validRun(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory testST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType promoWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'promo work' LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            FSLTestUtility.generateWork( promoWT, promoWT, testAcct, '14209', testST, 1 );
            WorkOrder woTestRec = [ SELECT Id FROM WorkOrder LIMIT 1 ];

            List<WorkOrderLineItem> woliLst = [ SELECT Id FROM WorkOrderLineItem ];
            for ( WorkOrderLineItem woliRec : woliLst ) {
                woliRec.Status = 'Completed';
            }
            update woliLst;
 
            woTestRec.Status = 'Completed';
            update woTestRec; // Just verifying no error is thrown, no assert needed
        Test.stopTest();
    }
}