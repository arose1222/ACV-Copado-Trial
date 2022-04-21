/**
 * This class is used to JSON deerialize a response
 * from the Salesforce Gateway Bulk Auction Kill
 * @author James Andre LaCour
 */
public class AuctionKillApiResponse {
    /****************Class Variables**********************/
    public String detail;
    public Response data;
    /****************Inner Classes************************/
    public class Response{
        public List<Data> successes;
        public List<Data> errors;
    }
    public class Data{
        public String message;
        public Integer auctionid;
        public Integer status;
    }
    /****************Helper Methods***********************/
    /**
     * JSON Deserializes a JSON String
     * @param jsonString - a string Json stringyfied from the response
     * @return AuctionKillApiResponse class
     */
    public static AuctionKillApiResponse parse( String jsonString ){
        return (AuctionKillApiResponse) JSON.deserialize(jsonString, AuctionKillApiResponse.class);
    }
}