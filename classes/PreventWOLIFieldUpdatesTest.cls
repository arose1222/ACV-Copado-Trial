@isTest
public class PreventWOLIFieldUpdatesTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account acct = TestUtility.createAccount();
        FSLTestUtility.createData( acct, 1 );
    }

    @IsTest
    static void changeLineItemId() {
        WorkOrderLineItem woli = [ SELECT Id FROM WorkOrderLineItem LIMIT 1 ];

        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            woli.External_Record_Guid__c = ACVUtility.NewGuid();
            try {
                update woli;
            } catch ( Exception e ) {
                errorMsg = e.getMessage();
                if ( e.getMessage().contains( ACVUtility.MODIFIED_LOCKED_FIELD_ERROR ) ) {
                    errorThrown = TRUE;
                }
            }
        Test.stopTest();

        System.assertEquals( TRUE, errorThrown, 'Unexpected Error Message Thrown: ' + errorMsg );
        
    }
}