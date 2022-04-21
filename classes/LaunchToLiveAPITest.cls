@isTest
public class LaunchToLiveAPITest {
    /* This test the creation of an LaunchToLive.LiveRequest method
     * which uses the Salesforce Gateway named Crednetial
     * @return void
    */
    public static testMethod void createLaunchToLiveRequestTest(){
        LaunchToLiveApi.LiveRequest rlalListReq = new LaunchToLiveApi.LiveRequest();
        LaunchToLiveApi.LiveAuctionLaunch LiveAuctionLaunch = new LaunchToLiveApi.LiveAuctionLaunch();
        LiveAuctionLaunch.saved_auction_id = 1234;
        LiveAuctionLaunch.floor_price = 1000;
        LiveAuctionLaunch.address_id = 5678;
        LiveAuctionLaunch.user_id = 1111;
        LiveAuctionLaunch.auction_start_time = '1961-08-04 12:00:00.000Z';
        rlalListReq.saved_auctions = new List<LaunchToLiveApi.LiveAuctionLaunch>{LiveAuctionLaunch};
        Test.startTest();
            HttpRequest reqTest = LaunchToLiveApi.createLiveListRequest(rlalListReq.saved_auctions);
        Test.stopTest();
        System.assertEquals('POST', reqTest.getMethod(), 'This should be a POST method');
        System.assertEquals('application/json', reqTest.getHeader('Content-Type'), 'This should be a JSON Content-Type');
        System.assert(reqTest.getHeader('Authorization') != null, 'Authorization should be populated');
        System.assert(reqTest.getEndpoint().endsWith(LaunchToLiveApi.SEND_TO_LIVE_ENDPOINT_SUFFIX), 'Endpoint is not correct');
        System.assertEquals('{"saved_auctions":[{"user_id":1111,"saved_auction_id":1234,"floor_price":1000,"auction_start_time":"1961-08-04 12:00:00.000Z","address_id":5678}]}', reqTest.getBody());
    }
    /* This test the createLiveListSend function
     * in the LaunchToLiveApi which is a child of the parent class
     * Test 2nd iteration with a datetime to launch at
     * @return void
    */
    public static testMethod void createLiveListSendDateTimeTest(){
        Integer userId = 123;
        Decimal floorPrice = 1000;
        Integer addressId = 456;
        Integer savedAuctionId = 789;
        String dateTimeToLaunch = '1961-08-04 12:00:00.000Z';
        Test.startTest();
            LaunchToLiveApi.LiveAuctionLaunch rls = LaunchToLiveApi.createLiveSend(userId, floorPrice, addressId, savedAuctionId, dateTimeToLaunch);
        Test.stopTest();
        System.assertEquals(userId, rls.user_id, 'User Id is not correct');
        System.assertEquals(floorPrice, rls.floor_price, 'Floor Price is not correct');
        System.assertEquals(addressId, rls.address_id, 'Address Id is not correct');
        System.assertEquals(savedAuctionId, rls.saved_auction_id, 'Saved Auction Id is not correct');
        System.assertEquals(dateTimeToLaunch, rls.auction_start_time, 'Saved Auction Id is not correct');
    }
}