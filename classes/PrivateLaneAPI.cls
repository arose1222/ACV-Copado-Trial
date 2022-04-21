/**
 * This class holds the helper functions for the
 * PrivateLaneAPI - Salesforce Gateway
 * @author James Andre LaCour
 */
public class PrivateLaneAPI {
    /****************Class Variables**********************/
    /** 
     * The type value we are looking for S3 Reference records when it comes to branding
    */
    public static final String BRANDING_TYPE_NAME = 'Private Lane - Branding';
    /** 
     * the suffix to the SF gateway endpoint we need to hit the Private Lane api
    */
    @testVisible private static final String PRIVATE_LANE_ENDPOINT_SUFFIX = '/api/v1/lane';
    /** 
     * Translator for Picklist to API needed values when it comes to Custom Start Price Type
    */
    @testVisible private static final Map<String, String> CUSTOM_PRICE_API_TRANSLATOR_MAP = new Map<String, String>{ 'Default'=>'DEFAULT', 'Dollars' => 'SUBTRACT_FROM_FLOOR_PRICE', 'Percent' => 'PERCENT_OF_FLOOR_PRICE' };
    /****************Helper Methods***********************/
    /**
     * Returns a single entity of a PrivateLaneRequest object
     * @param pl - private lane for this record
     * @param userId - ACV User Id of running user
     * @param typeToURLMap - S3 Reference Name to its S3 URL
     * @param feeNameToAmountMap - Name of the Fee to its Integer Amount. No cents
     * @param cronSchedule - the schedule to run in the acv api
     * @return PrivateLaneRequest record
     */
    public static PrivateLaneRequest createPrivateLaneRequestObj( Private_Lane__c pl, Integer userId, Map<String,String> typeToURLMap, Map<String,Integer> feeNameToAmountMap, String cronSchedule ){
        PrivateLaneRequest plReq = new PrivateLaneRequest();
        plReq.display_name = pl.Name;
        plReq.status = pl.Status__c;
        plReq.creator_id = pl?.CreatedBy?.Id__c != null ? Integer.valueOf(pl.CreatedBy.Id__c) : userId;
        plReq.logo_url = typeToURLMap.get(BRANDING_TYPE_NAME) == null ? '' : typeToURLMap.get(BRANDING_TYPE_NAME);
        plReq.make_offer_duration_seconds = Integer.valueOf(pl.Make_Offer_Duration__c);
        plReq.duration_seconds = Integer.valueOf(pl.Auction_Duration__c);
        plReq.buy_fee = feeNameToAmountMap.get('Buy Fee');
        plReq.sell_fee = feeNameToAmountMap.get('Sell Fee');
        plReq.vci_fee = feeNameToAmountMap.get('VCI Launch Fee');
        plReq.green_light_fee = feeNameToAmountMap.get('Go Green Fee');
        plReq.pack_fee = feeNameToAmountMap.get('Pack Fee');
        plReq.cron_schedule = cronSchedule;
        plReq.no_payment = pl.Payment_Options__c == 'No Payment' ? true : false;
        plReq.start_price_type = CUSTOM_PRICE_API_TRANSLATOR_MAP.get(pl.Custom_Start_Price_Type__c);
        plReq.start_price_modifier = Integer.valueOf(pl.Custom_Start_Price_Value__c);
        plReq.user_id = userId;
        plReq.purchase_now = pl.Sale_Format__c == 'Purchase Now' ? true : false;
        plReq.make_offer_type  = pl.Make_Offer_Type__c;
        plReq.no_title = pl.Title_Option__c == 'No Title' ? true : false;
        plReq.preview_duration = Integer.valueOf(pl.Preview_Duration__c);
        plReq.preview_proxy_bidding = pl.Preview_Proxy_Bidding__c;
        plReq.preview_start_price = pl.Preview_Start_Price__c;
        return plReq;
    }
    /**
     * Returns the HttpRequest for a New Private Lane request
     * @param plReq - a instance of the PrivateLaneRequest
     * @return PermissionDetail record
     */
    public static HttpRequest createPrivateLaneNewRequest( PrivateLaneRequest plReq ){
        HttpRequest req = createBasePrivateLaneRequest( plReq );
        req.setEndpoint( 'callout:Salesforce_Gateway' + PRIVATE_LANE_ENDPOINT_SUFFIX );
        return req;
    }
    /**
     * Returns the HttpRequest for a Update Private Lane request
     * @param plReq - a instance of the PrivateLaneRequest
     * @param laneId - the lane id for this Private Lane
     * @return PermissionDetail record
     */
    public static HttpRequest createPrivateLaneUpdateRequest( PrivateLaneRequest plReq, String laneId ){
        HttpRequest req = createBasePrivateLaneRequest( plReq );
        req.setEndpoint( 'callout:Salesforce_Gateway' + PRIVATE_LANE_ENDPOINT_SUFFIX + '/' + laneId );
        return req;
    }
    /**
     * A helper function that creates the base Private Lane Request New and Update use
     * @param plReq - a instance of the PrivateLaneRequest
     * @return PermissionDetail record
    */
    @testVisible
    private static HttpRequest createBasePrivateLaneRequest( PrivateLaneRequest plReq ){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setBody(JSON.serialize(plReq));
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setTimeout(120000);
        return req;
    }
    /****************Inner Classes***********************/
    /**
     * This class is the JSON structure for Private Lane Request
     * @author James Andre LaCour
     */
    public class PrivateLaneRequest{
        public String cron_schedule;
        public String display_name;
        public String status;
        public Integer creator_id;
        public Integer duration_seconds;
        public String logo_url;
        public Integer make_offer_duration_seconds;
        public Integer buy_fee;
        public Integer sell_fee;
        public Integer vci_fee;
        public Integer green_light_fee;
        public Integer pack_fee;
        public Boolean no_payment;
        public String start_price_type;               //DEAFULT, PERCENT_OF_FLOOR_PRICE, SUBTRACT_FROM_FLOOR_PRICE
        public Integer start_price_modifier;
        public Integer user_id;
        public Boolean purchase_now;
        public String make_offer_type;
        public Boolean no_title;
        public Integer preview_duration;
        public Boolean preview_proxy_bidding;
        public Boolean preview_start_price;
    }
    /** 
     * This is the JSON Structire for Private Lane Response
    */
    public class PrivateLaneResponse{
        public String lane_id;
        public List<ErrorDetail> detail;
    }
    /** 
     * This is the Error Detail structure for Private Lane Response
    */
    public class ErrorDetail{
        public List<String> loc;
        public String msg;
        public String type;
    }
}