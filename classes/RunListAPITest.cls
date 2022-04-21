/**
 * Test Class for the RunListApi
 * @author James Andre LaCour
 */
@isTest
public class RunListAPITest {
    /* This test the creation of an RunListAPI.RunListRequest method
     * which uses the Salesforce Gateway named Crednetial
     * @return void
    */
    public static testMethod void createSendToRunListRequestTest(){
        RunListAPI.RunListRequest rlalListReq = new RunListAPI.RunListRequest();
        RunListAPI.RunListAuctionLaunch runListAuctionLaunch = new RunListAPI.RunListAuctionLaunch();
        runListAuctionLaunch.saved_auction_id = 1234;
        runListAuctionLaunch.floor_price = 1000;
        runListAuctionLaunch.address_id = 5678;
        runListAuctionLaunch.user_id = 1111;
        runListAuctionLaunch.auction_start_time = '1961-08-04 12:00:00.000Z';
        rlalListReq.saved_auctions = new List<RunListAPI.RunListAuctionLaunch>{runListAuctionLaunch};
        Test.startTest();
            HttpRequest reqTest = RunListAPI.createSendToRunListlRequest(rlalListReq.saved_auctions);
        Test.stopTest();
        System.assertEquals('POST', reqTest.getMethod(), 'This should be a POST method');
        System.assertEquals('application/json', reqTest.getHeader('Content-Type'), 'This should be a JSON Content-Type');
        System.assert(reqTest.getHeader('Authorization') != null, 'Authorization should be populated');
        System.assert(reqTest.getEndpoint().endsWith(RunListAPI.SEND_TO_RUN_LIST_ENDPOINT_SUFFIX), 'Endpoint is not correct');
        System.assertEquals('{"saved_auctions":[{"user_id":1111,"saved_auction_id":1234,"floor_price":1000,"auction_start_time":"1961-08-04 12:00:00.000Z","address_id":5678}]}', reqTest.getBody());
    }
    /* This test the createRunListSend function
     * in the RunListAPI which is a child of the parent class
     * @return void
    */
    public static testMethod void createRunListSendTest(){
        Integer userId = 123;
        Decimal floorPrice = 1000;
        Integer addressId = 456;
        Integer savedAuctionId = 789;
        Test.startTest();
            RunListAPI.RunListAuctionLaunch rls = RunListAPI.createRunListSend(userId, floorPrice, addressId, savedAuctionId);
        Test.stopTest();
        System.assertEquals(userId, rls.user_id, 'User Id is not correct');
        System.assertEquals(floorPrice, rls.floor_price, 'Floor Price is not correct');
        System.assertEquals(addressId, rls.address_id, 'Address Id is not correct');
        System.assertEquals(savedAuctionId, rls.saved_auction_id, 'Saved Auction Id is not correct');
    }
    /* This test the createRunListSend function
     * in the RunListAPI which is a child of the parent class
     * Test 2nd iteration with a datetime to launch at
     * @return void
    */
    public static testMethod void createRunListSendDateTimeTest(){
        Integer userId = 123;
        Decimal floorPrice = 1000;
        Integer addressId = 456;
        Integer savedAuctionId = 789;
        String dateTimeToLaunch = '1961-08-04 12:00:00.000Z';
        Test.startTest();
            RunListAPI.RunListAuctionLaunch rls = RunListAPI.createRunListSend(userId, floorPrice, addressId, savedAuctionId, dateTimeToLaunch);
        Test.stopTest();
        System.assertEquals(userId, rls.user_id, 'User Id is not correct');
        System.assertEquals(floorPrice, rls.floor_price, 'Floor Price is not correct');
        System.assertEquals(addressId, rls.address_id, 'Address Id is not correct');
        System.assertEquals(savedAuctionId, rls.saved_auction_id, 'Saved Auction Id is not correct');
        System.assertEquals(dateTimeToLaunch, rls.auction_start_time, 'Saved Auction Id is not correct');
    }
}