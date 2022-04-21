/**
 * Test Code for RemoveResourcePreferenceTest
 * @author Gerald McEvoy
 * @since 3/9/21
 */
@isTest
public class RemoveResourcePreferenceTest {

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
        ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ];

        System.assertEquals( 2, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :userResource.Id ], 'There was an unexpected amount of Service Resources in the system' );

        Test.startTest();
            userResource.isActive = FALSE;
            update userResource;
        Test.stopTest();

        System.assertEquals( 0, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :userResource.Id ], 'There was an unexpected amount of Service Resources in the system' );
    }

    /**
     * Turn a single Service Resource, of two, inactive, to ensure just those related Resource Preference are removed from the system, but not all
     */
    @isTest
    static void turnOneResourceInactive() {
        Test.startTest();
            ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource

            // Make a new Service Resource & Preference on same Account
            Account getAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
            FSLTestUtility.makePreferredResourceData( getAcct );

            ServiceResource newResource = [ SELECT Id FROM ServiceResource WHERE Id != :userResource.Id LIMIT 1 ];
            ServiceTerritory testTerr = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
            WorkType testWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType LIMIT 1 ];

            FSLTestUtility.generateWork( testWorkType, testWorkType, getAcct, '14209', testTerr, 1 );

            // Validate correct number of Resource Preferences beforehand
            System.assertEquals( 3, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :userResource.Id ], 'There was an unexpected amount of Service Resources in the system' );

            System.assertEquals( 3, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :newResource.Id ], 'There was an unexpected amount of Service Resources in the system' );


            userResource.isActive = FALSE;
            update userResource;
        Test.stopTest();

        System.assertEquals( 0, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :userResource.Id ], 'There was an unexpected amount of Service Resources in the system' );

        System.assertEquals( 3, [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :newResource.Id ], 'There was an unexpected amount of Service Resources in the system' );
    }
}