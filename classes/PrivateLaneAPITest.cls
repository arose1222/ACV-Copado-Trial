/**
 * Test Class for the PrivateLaneAPI
 * @author James Andre LaCour
 */
@isTest
public class PrivateLaneAPITest {
    /********************Test Methods****************************/
    /** This test that the creation of a PrivateLAneRequest object is properly set
     * from the passed in values
     * @return void
     */
    public static testMethod void createPrivateLaneRequestObjTest(){
        Private_Lane__c pl = new Private_Lane__c();
        pl.Name = 'Test Lane Name';
        pl.Status__c = 'Open';
        pl.Make_Offer_Duration__c = 1200;
        pl.Auction_Duration__c = 1200;
        pl.Sale_Format__c = 'Purchase Now';
        pl.Title_Option__c = 'No Title';
        pl.Make_Offer_Type__c = 'SHOW_RESERVE';
        Integer testUserId = 1234;
        Map<String,String> testTypeToURLMap = new Map<String,String>{ PrivateLaneApi.BRANDING_TYPE_NAME => 'www.testurl.com' };
        Map<String,Integer> testfeeNameToAmountMap = new Map<String,Integer>{ 'Buy Fee' => 100, 'Sell Fee' => 100, 'Pack Fee' => 222, 'Go Green Fee' => 222, 'VCI Launch Fee' => 222 };
        String testCronSchedule = '* * * * * *';
        Test.startTest();
            PrivateLaneAPI.PrivateLaneRequest plr = PrivateLaneAPI.createPrivateLaneRequestObj(pl, testUserId, testTypeToURLMap, testFeeNameToAmountMap, testCronSchedule);
        Test.stopTest();
        System.assertEquals( plr.display_name, pl.Name );
        System.assertEquals( plr.status, pl.Status__c );
        System.assertEquals( plr.creator_id, testUserId );
        System.assertEquals( plr.logo_url, 'www.testurl.com' );
        System.assertEquals( plr.make_offer_duration_seconds, pl.Make_Offer_Duration__c );
        System.assertEquals( plr.duration_seconds, pl.Auction_Duration__c );
        System.assertEquals( plr.buy_fee, 100 );
        System.assertEquals( plr.sell_fee, 100 );
        System.assertEquals( plr.cron_schedule, testCronSchedule );
        System.assertEquals( plr.purchase_now, true );
        System.assertEquals( plr.vci_fee, 222 );
        System.assertEquals( plr.pack_fee, 222 );
        System.assertEquals( plr.green_light_fee, 222 );
        System.assertEquals( plr.no_title, true );
        System.assertEquals( plr.make_offer_type, 'SHOW_RESERVE' );
    }
    /** This test that the HttpRequest for a new request is properly created
     * @return void
     */
    public static testMethod void createPrivateLaneNewRequestTest(){
        PrivateLaneAPI.PrivateLaneRequest plr = createPrivateLaneRequestHelper();
        Test.startTest();
            HttpRequest req = PrivateLaneAPI.createPrivateLaneNewRequest( plr );
        Test.stopTest();
        System.assertEquals( 'POST', req.getMethod() );
        System.assertEquals( JSON.serialize(plr), req.getBody() );
        System.assert( req.getEndpoint().endsWithIgnoreCase(PrivateLaneAPI.PRIVATE_LANE_ENDPOINT_SUFFIX) );
    }
    /** This test that the HttpRequest for a new request is properly created
     * @return void
     */
    public static testMethod void createPrivateLaneUpdateRequestTest(){
        PrivateLaneAPI.PrivateLaneRequest plr = createPrivateLaneRequestHelper();
        String laneId = 'Test_Lane_Id';
        Test.startTest();
            HttpRequest req = PrivateLaneAPI.createPrivateLaneUpdateRequest( plr, laneId );
        Test.stopTest();
        System.assertEquals( 'POST', req.getMethod() );
        System.assertEquals( JSON.serialize(plr), req.getBody() );
        System.assert( req.getEndpoint().endsWithIgnoreCase(PrivateLaneAPI.PRIVATE_LANE_ENDPOINT_SUFFIX + '/' + laneId) );
    }
    /** This test that the HttpRequest for a base request is set
     * used for New and Update
     * @return void
     */
    public static testMethod void createBasePrivateLaneRequestTest(){
        PrivateLaneAPI.PrivateLaneRequest plr = createPrivateLaneRequestHelper();
        Test.startTest();
            HttpRequest req = PrivateLAneApi.createBasePrivateLaneRequest( plr );
        Test.stopTest();
        System.assertEquals( 'POST', req.getMethod() );
        System.assertEquals( JSON.serialize(plr), req.getBody() );
    }
    /********************Helper Methods**************************/
    /** Creates a test PrivateLaneAPI.PrivateLaneRequest for the test methods
     * @return PrivateLaneAPI.PrivateLaneRequest obj
     */
    private static PrivateLaneAPI.PrivateLaneRequest createPrivateLaneRequestHelper(){
        PrivateLaneAPI.PrivateLaneRequest plr = new PrivateLaneAPI.PrivateLaneRequest();
        plr.cron_schedule = '* * * * * *';
        plr.display_name = 'Test Name';
        plr.status = 'Open';
        plr.creator_id = 1234;
        plr.duration_seconds = 1200;
        plr.logo_url = 'www.testurl.com';
        plr.make_offer_duration_seconds = 1200;
        plr.buy_fee = 100;
        plr.sell_fee = 100;
        plr.purchase_now = true;
        return plr;
    }
}