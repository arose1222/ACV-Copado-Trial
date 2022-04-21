/**
 * This class holds the helper functions for the
 * RunListAPI - Salesforce Gateway
 * @author James Andre LaCour
 */
public class RunListAPI {
    /****************Class Variables**********************/
    @testVisible private static final String SEND_TO_RUN_LIST_ENDPOINT_SUFFIX = '/api/v1/saved_auctions/launch/run_list';
    @testVisible public static final String RUN_LIST_LAUNCHING_STATUS_SUFFIX = 'Run List';
    /****************Helper Methods***********************/
    /**
     * creates the Salesforce Gateway Send To Run List request
     * @param userId - ACV User Id
     * @param floorPrice - Floor Price for the Car
     * @param addressId - Address Id for where the car is (currently not used - set as null)
     * @param savedAuctionId - Saved Auction Id for the Condition report
     * @return RunListAuctionLaunch that will represent a single run
     */
    public static RunListAuctionLaunch createRunListSend( Integer userId, Decimal floorPrice, Integer addressId, Integer savedAuctionId ){
        RunListAuctionLaunch runListLaunch = new RunListAuctionLaunch();
        runListLaunch.user_id = userId;
        runListLaunch.floor_price = floorPrice;
        runListLaunch.address_id = addressId;
        runListLaunch.saved_auction_id = savedAuctionId;
        return runListLaunch;
    }
    /**
     * creates the Salesforce Gateway Send To Run List request. 2nd iteration that takes a runlist time
     * @param userId - ACV User Id
     * @param floorPrice - Floor Price for the Car
     * @param addressId - Address Id for where the car is (currently not used - set as null)
     * @param savedAuctionId - Saved Auction Id for the Condition report
     * @param auctionStartTime - String UTC datetime of when the auction will launch 
     * @return RunListAuctionLaunch that will represent a single run
     */
    public static RunListAuctionLaunch createRunListSend( Integer userId, Decimal floorPrice, Integer addressId, Integer savedAuctionId, String auctionStartTime ){
        RunListAuctionLaunch runListLaunch = new RunListAuctionLaunch();
        runListLaunch.user_id = userId;
        runListLaunch.floor_price = floorPrice;
        runListLaunch.address_id = addressId;
        runListLaunch.saved_auction_id = savedAuctionId;
        runListLaunch.auction_start_time = auctionStartTime;
        return runListLaunch;
    }
    /**
     * creates the Salesforce Gateway Send To Run List request
     * @param savedAuctions - List of Run List cars we are trying to send
     * @return HttpRequest with the needed info for Send to Run List - Salesforce Gateway
     */
    public static HttpRequest createSendToRunListlRequest( List<RunListAuctionLaunch> savedAuctions ){
        RunListRequest runListSendReq = new RunListRequest();
        runListSendReq.saved_auctions = savedAuctions;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint( 'callout:Salesforce_Gateway' + SEND_TO_RUN_LIST_ENDPOINT_SUFFIX );
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody( JSON.serialize(runListSendReq) );
        return req;
    }
    /****************Inner Classes************************/
    public class RunListAuctionLaunch extends AuctionLaunchExt.Request{
        // If specific Run List Attributes are needed
    }
    /**
     * This class is used to JSON Serialize a request
     * to the Salesforce Gateway Bulk Send to Run List
     * @author James Andre LaCour
     */
    public class RunListRequest{
        public List<RunListAuctionLaunch> saved_auctions;
    }
    /**
     * This class is used to JSON Serialize a Response
     * from the Salesforce Gateway Bulk Send to Run List
     * @author James Andre LaCour
     */
    public class RunListResponse extends AuctionLaunchExt.Response{
        public String detail;
        public Response data;
    }
}