/**
 * This class is used to JSON Serialize a Response
 * from the Salesforce Gateway Bulk Send to Run List
 * @author James Andre LaCour
 */
public class RunListSendApiResponse {
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
        public Integer saved_auction_id;
        public Integer status;
    }
    /****************Helper Methods***********************/
    /**
     * JSON Deserializes a JSON String
     * @param jsonString - a string Json stringyfied from the response
     * @return RunListSendApiResponse class
     */
    public static RunListSendApiResponse parse( String jsonString ){
        return (RunListSendApiResponse) JSON.deserialize(jsonString, RunListSendApiResponse.class);
    }
}