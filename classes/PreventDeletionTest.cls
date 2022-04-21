/**
 * Test class for PreventDeletion, PreventFSLPolygonDeletion, & PreventServiceTerritoryDeletion
 * @author Gerald McEvoy
 * @since 3/3/21
 */
@isTest
public class PreventDeletionTest {

    /**
     * Method Creates, then attempts to delete a FSL Polygon in an effort to get the proper, prevention error message during the failed attempt to delete
     */
    @isTest
    static void deletePolygon() {
        FSL__Polygon__c testGon = FSLTestUtility.createPolygon( 'Test Polygon' );
        insert testGon;

        Boolean checkGonDeleteFlag = FALSE;
        Test.startTest();
            checkGonDeleteFlag = checkError( testGon );
        Test.stopTest();

        System.assertEquals( TRUE, checkGonDeleteFlag, 'No error (or a different error) was thrown when attempting to delete the record' );
    }

    /**
     * Method Creates, then attempts to delete a Service Territory in an effort to get the proper, prevention error message during the failed attempt to delete
     */
    @isTest
    static void deleteTerritory() {
        FSLTestUtility.createAllStructureWithParentST( 'Test Territory', '14209' );
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        Boolean checkSTDeleteFlag = FALSE;
        Test.startTest();
         checkSTDeleteFlag = checkError( st );
        Test.stopTest();

        System.assertEquals( TRUE, checkSTDeleteFlag, 'No error (or a different error) was thrown when attempting to delete the record' );
    }

    /**
     * Method to check if an object throws a proper error when attempting to be deleted
     * @param obj Any Object that a test method wishes to attempt to delete
     * @return  A boolean where TRUE indicates the proper error message has been thrown when attempting to delete
     */
    private static Boolean checkError( sObject obj ) {
        Boolean threwError = FALSE;
        try {
            delete obj;
        } catch ( exception e ) {
            if ( e.getMessage().contains( PreventDeletion.DELETION_ERROR_MESSAGE ) ) {
                threwError = TRUE;
            }
        }
        return threwError;
    }
}