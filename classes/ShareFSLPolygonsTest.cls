/**
 * Class to test Polygon creation to verify sharing rules are created from the live sharing metadata definitions
 * @group Test
 * @author Gerald McEvoy
 * @since 2/25/21
 */
@isTest
public class ShareFSLPolygonsTest {
    private final static String POLYGON_API_NAME = 'FSL__Polygon__c';
    private final static String POLYGON_EXTERNAL_ID_FIELD_API_NAME = 'Polygon_Unique_Id__c';

    /**
     * Test Setup Method that simply generated Generic FSL Setup Data
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
    }

    /**
     * Test Method creates a Polygon, using live metadata (if said data exists) and then checks every Polygon Share Record to verify it exists for each metadata record (if possible)
     */
    @isTest
    static void createPolygon() {
        Apex_Sharing_Rule__mdt selectedRuleToTest;
        List<Apex_Sharing_Rule__mdt> aprLst = [ SELECT Field_Name__c, Value__c, Object_API_Name__c, Operation__c,
                                        ( SELECT Name_of_Entity__c, Type_of_Entity__c, Access_Level__c, Sharing_Cause__c FROM Apex_Sharing_Entities__r
                                        WHERE Active__c = TRUE ) 
                                        FROM Apex_Sharing_Rule__mdt
                                        WHERE Active__c = TRUE 
                                        AND Object_API_Name__c = :POLYGON_API_NAME
                                        AND Field_Name__c = :POLYGON_EXTERNAL_ID_FIELD_API_NAME ];

        FSL__Polygon__c testPolygonRec = FSLTestUtility.createPolygon( 'Test Record' );

        // Dynamically find a rule using the field we are trying to test with, to future proof
        if ( !aprLst.isEmpty() ) {
            for ( Apex_Sharing_Rule__mdt apSharingRule : aprLst ) {      
                if ( !apSharingRule.Apex_Sharing_Entities__r.isEmpty() ) {
                    selectedRuleToTest = apSharingRule;
                    break;
                }
            }
            testPolygonRec.Polygon_Unique_Id__c = selectedRuleToTest.Operation__c == 'Equals' ? selectedRuleToTest.Value__c.replace( '%%', ' ' ) : selectedRuleToTest.Value__c.replace( '%%', ' Test Record' );          
        }

        Test.startTest();
            insert testPolygonRec;
        Test.stopTest();

        if ( selectedRuleToTest != null ) { // Only validate if metadata is found
            List<FSL__Polygon__Share> polygonSharingRuleLst = [ SELECT Id, AccessLevel, UserOrGroupId, RowCause FROM FSL__Polygon__Share WHERE ParentId = :testPolygonRec.Id AND RowCause != 'Owner' ];
            Set<Id> userOrGroupIdSet = new Set<Id>();
            for ( FSL__Polygon__Share polyRec : polygonSharingRuleLst ) {
                userOrGroupIdSet.add( polyRec.UserOrGroupId );
            }

            Map<Id, User> userLst = new Map<Id, User>( [ SELECT Id, Name FROM User WHERE Id IN :userOrGroupIdSet ] );
            Map<Id, Group> groupLst = new Map<Id, Group>( [ SELECT Id, Name FROM Group WHERE Id IN :userOrGroupIdSet ] );

            List<Apex_Sharing_Entity__mdt> checkPolygonSharingLst = new List<Apex_Sharing_Entity__mdt>();
            for ( Apex_Sharing_Entity__mdt sharingEntity : selectedRuleToTest.Apex_Sharing_Entities__r ) {
                checkPolygonSharingLst.add( sharingEntity );
            }

            List<Apex_Sharing_Entity__mdt> convertedLst = new List<Apex_Sharing_Entity__mdt>();
            for ( FSL__Polygon__Share sharingRec : polygonSharingRuleLst ) {
                for ( Integer index = 0; index < checkPolygonSharingLst.size(); index++ ) {
                    Apex_Sharing_Entity__mdt checkMetadataRec = checkPolygonSharingLst[index];
                    if ( ( ( userLst.get( sharingRec.UserOrGroupId ) != null && userLst.get( sharingRec.UserOrGroupId ).Name == checkMetadataRec.Name_of_Entity__c )
                        || ( groupLst.get( sharingRec.UserOrGroupId ) != null && groupLst.get( sharingRec.UserOrGroupId ).Name == checkMetadataRec.Name_of_Entity__c ) )
                        && sharingRec.AccessLevel == checkMetadataRec.Access_Level__c ) {
                        convertedLst.add( checkPolygonSharingLst.remove( index ) );
                        index--;
                    }
                }
            }

            System.assertEquals( selectedRuleToTest.Apex_Sharing_Entities__r.size(), convertedLst.size(), 'There was an unexpected amount of sharing rules generated' );
            System.assertEquals( 0, checkPolygonSharingLst.size(), 'There was an unexpected amount of sharing rules that did not generate a record' );
        }
    }
}