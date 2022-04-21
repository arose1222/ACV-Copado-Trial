@isTest
public class RemoveInactiveResourcePrefsTest {
    /**
     * Test Setup Method to make a Account, Preferred Resource, & General FSL Data including Work Order
     */
    @TestSetup
    static void makeData(){
        Account acct = TestUtility.createAccount();
        insert acct;

        FSLTestUtility.makePreferredResourceData( acct );
        FSLTestUtility.createData( acct, 2 );
    }

    /**
     * Turn a Service Resource Inactive to ensure both Resource Preferences are removed from the system
     */
    @isTest
    static void turnResourceInactive() {
        ServiceResource userResource = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];

        System.assertEquals( 2, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :userResource.Id ], 'There was an unexpected amount of Service Resources in the system' );

        Test.startTest();
            User resourceUser = [ SELECT Id FROM User WHERE ID = :userResource.RelatedRecordId LIMIT 1 ];

            resourceUser.isActive = FALSE;
            update resourceUser;
        Test.stopTest();

        System.assertEquals( 0, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :userResource.Id ], 'There was an unexpected amount of Service Resources in the system' );
    }
}