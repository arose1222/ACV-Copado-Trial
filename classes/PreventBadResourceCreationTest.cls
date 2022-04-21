@isTest
public class PreventBadResourceCreationTest {
    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '1';
        insert a;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
    }

    @IsTest
    static void createBadResource(){
        Account acct = [ SELECT Id FROM Account LIMIT 1 ];
        
        Test.startTest();
            Profile p = [ SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector' LIMIT 1 ];
            User u = TestUtility.createUser( p.Id );
            insert u;

            Boolean threwError = FALSE;
            try {
                System.runAs( u ) {
                    insert FSLTestUtility.makePermissionSet( u.Id );
                }
                ServiceResource testSR = FSLTestUtility.createResource( u.Id, 'Johnny Tester' );
                insert testSR;
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventBadResourceCreation.INVALID_RESOURCE_CONFIG_ERROR ) ) {
                    threwError = TRUE;
                }
            }

        Test.stopTest();
        
        System.assertEquals( TRUE, threwError );
    }
}