/**
 * This class is used to JSON Serialize a request
 * to the Salesforce Gateway Bulk Auction Kill
 * @author James Andre LaCour
 */
public class AuctionKillApiRequest {
    /****************Class Variables**********************/
    public Integer user_id;
    public String notes;
    public String authorized_by;
    public List<Integer> auction_ids;
    /****************Helper Methods***********************/
    /**
     * JSON Serializes an AuctionKillApiRequest
     * @param auctionKillReq - a class of AuctionKillApiRequest
     * @return string JSON Serialized of AuctionKillAPIRequest
     */
    public static String compose( AuctionKillApiRequest auctionKillReq ){
        return JSON.serialize(auctionKillReq);
    }
}