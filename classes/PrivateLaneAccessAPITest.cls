/**
 * Test Class for the PrivateLaneAccessAPI
 * @author James Andre LaCour
 */
@isTest
public class PrivateLaneAccessAPITest {
    /********************Test Methods****************************/
    /**
     * This test makes sure the helper method to Create a Delete Request properly sets the
     * needed HttpRequest values
     * @return void
     */
    public static testMethod void createDeleteRequestTest(){
        String testLaneId = 'Test Lane Id';
        String testDealershipGroupId = 'Test Dealership Group Id';
        Test.startTest();
            HttpRequest req = PrivateLaneAccessAPI.createDeleteRequest( testLaneId, testDealershipGroupId );
        Test.stopTest();
        System.assertEquals( 'DELETE', req.getMethod(), 'Should be DELETE' );
        System.assert( req.getEndpoint().endsWithIgnoreCase(PrivateLaneAccessAPI.DELETE_PERMISSION_ENDPOINT.replace('{lane_id}', testLaneId).replace('{dealership_group_id}', testDealershipGroupId) ), 'Should end with the correct lane Id and dealership group Id added to the endpoint' );
        System.assertEquals( 'application/json', req.getHeader('Content-Type'), 'Content type should be application/json' );
    }
    /**
     * This test makes sure the helper method to Create a Set Request properly sets the
     * needed HttpRequest values
     * @return void
     */
    public static testMethod void createSetRequestTest(){
        String testLaneId = 'Test Lane Id';
        String testDealershipGroupId = 'Test Dealership Group Id';
        PrivateLaneAccessAPI.PermissionDetail pd = new PrivateLaneAccessAPI.PermissionDetail();
        pd.lane_id = testLaneId;
        pd.dealership_group_id = testDealershipGroupId;
        pd.can_buy = false;
        pd.can_sell = false;
        Test.startTest();
            HttpRequest req = PrivateLaneAccessAPI.createSetRequest( testLaneId, new List<PrivateLaneAccessAPI.PermissionDetail>{pd} );
        Test.stopTest();
        System.assertEquals( 'POST', req.getMethod(), 'Method should be POST' );
        System.assertEquals( 'application/json', req.getHeader('Content-Type'), 'Content type should be application/json' );
        System.assert( req.getEndpoint().endsWithIgnoreCase(PrivateLaneAccessAPI.SET_PERMISSION_ENDPOINT.replace('{lane_id}', testLaneId)) );
    }
    /**
     * This test makes sure the helper method to a PermissionDetail sets the proper values
     * @return void
     */
    public static testMethod void createPermissionDetailTest(){
        String testLaneId = 'Test Lane Id';
        String testDealershipGroupId = 'Test Dealership Group Id';
        Boolean canSellTest = false;
        Boolean canBuyTest = false;
        Test.startTest();
            PrivateLaneAccessAPI.PermissionDetail pd = PrivateLaneAccessAPI.createPermissionDetail( testLaneId, testDealershipGroupId, canBuyTest, canSellTest );
        Test.stopTest();
        System.assertEquals( testLaneId, pd.lane_id );
        System.assertEquals( testDealershipGroupId , pd.dealership_group_id );
        System.assertEquals( canSellTest, pd.can_sell );
        System.assertEquals( canBuyTest, pd.can_buy );
    }
}