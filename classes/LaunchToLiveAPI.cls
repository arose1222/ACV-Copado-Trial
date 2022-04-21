public class LaunchToLiveAPI {
    /****************Class Variables**********************/
    @testVisible private static final String SEND_TO_LIVE_ENDPOINT_SUFFIX = '/api/v1/saved_auctions/launch/live';
    @testVisible public static final String LIVE_LAUNCHING_STATUS_SUFFIX = 'Live';
    /****************Helper Methods***********************/
    /**
     * creates the Salesforce Gateway Send To Live request
     * @param userId - ACV User Id
     * @param floorPrice - Floor Price for the Car
     * @param addressId - Address Id for where the car is (currently not used - set as null)
     * @param savedAuctionId - Saved Auction Id for the Condition report
     * @param auctionStartTime - String UTC datetime of when the auction will launch 
     * @return LiveAuctionLaunch that will represent a single run
     */
    public static LiveAuctionLaunch createLiveSend( Integer userId, Decimal floorPrice, Integer addressId, Integer savedAuctionId, String auctionStartTime ){
        LiveAuctionLaunch liveListLaunch = new LiveAuctionLaunch();
        liveListLaunch.user_id = userId;
        liveListLaunch.floor_price = floorPrice;
        liveListLaunch.address_id = addressId;
        liveListLaunch.saved_auction_id = savedAuctionId;
        liveListLaunch.auction_start_time = auctionStartTime;
        return liveListLaunch;
    }
    /**
     * creates the Salesforce Gateway Live request
     * @param savedAuctions - List cars we are trying to send
     * @return HttpRequest with the needed info for Send to Live - Salesforce Gateway
     */
    public static HttpRequest createLiveListRequest( List<LiveAuctionLaunch> savedAuctions ){
        LiveRequest liveSendReq = new LiveRequest();
        liveSendReq.saved_auctions = savedAuctions;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint( 'callout:Salesforce_Gateway' + SEND_TO_LIVE_ENDPOINT_SUFFIX );
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody( JSON.serialize(liveSendReq) );
        return req;
    }
    /****************Inner Classes************************/
    public class LiveAuctionLaunch extends AuctionLaunchExt.Request{
        // If specific Live Attributes are needed
    }
    /**
     * This class is used to JSON Serialize a request
     * to the Salesforce Gateway Bulk Send to Live
     * @author James Andre LaCour
     */
    public class LiveRequest{
        public List<LiveAuctionLaunch> saved_auctions;
    }
    /**
     * This class is used to JSON Serialize a Response
     * from the Salesforce Gateway Bulk Send to Live
     * @author James Andre LaCour
     */
    public class LiveResponse extends AuctionLaunchExt.Response{
        public String detail;
        public Response data;
    }
}