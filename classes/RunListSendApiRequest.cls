/**
 * This class is used to JSON Serialize a request
 * to the Salesforce Gateway Bulk Send to Run List
 * @author James Andre LaCour
 */
public class RunListSendApiRequest {
    /****************Class Variables**********************/
    public List<RunListSend> saved_auctions;

    public class RunListSend{
        public Integer user_id;
        public Decimal floor_price;
        public Integer address_id;
        public Integer saved_auction_id;
        public String auction_start_time;
    }
    /****************Helper Methods***********************/
    /**
     * JSON Serializes an RunListSendApiRequest
     * @param runListSendReq - a class of RunListSendApiRequest
     * @return string JSON Serialized of RunListSendApiRequest
     */
    public static String compose( RunListSendApiRequest runListSendReq ){
        return JSON.serialize(runListSendReq);
    }
}