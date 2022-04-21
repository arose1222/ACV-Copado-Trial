/**
 * Holds Helper function related to Rate Card endpoints
 * @author James Andre LaCour
 * @since May 4th, 2021
 */
public class RateCardApi {
    @testVisible private static final String PUBLISH_RATE_CARD_ENDPOINT_SUFFIX = '/api/v1/ratecards';
    /**
     * 
     * @param rc 
     * @return  `HttpRequest` request for Publishing a Rate Card
     */
    public static HttpRequest createHttpRequestPublishRateCard( Rate_Card__c rc, String acvId ){
        HttpRequest req = new HttpRequest();
        req.setHeader( 'Content-Type', 'application/json');
        req.setEndpoint('callout:Salesforce_Gateway' + PUBLISH_RATE_CARD_ENDPOINT_SUFFIX);
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setBody( JSON.serialize( createPublishRateCard(rc, acvId) ) );
        req.setMethod('POST');
        req.setTimeout(120000);
        return req;
    }
    /**
     * Returns a PublishRateCard instance for the Publish Rate Card Endpoint
     * @param rc Rate Card record
     * @return  `PublishRateCard`
     */
    public static PublishRateCard createPublishRateCard( Rate_Card__c rc, String acvId ){
        PublishRateCard prc = new PublishRateCard(rc, acvId);
        return prc;
    }
    /**
     * Data Structure for Publishing a Rate Card request
     */
    public class PublishRateCard{
        public String name;
        public String feeType;
        public Boolean shared;
        public Integer approvedBy;
        public Integer createdBy;
        public List<PublishRateCardFee> pricePoints;
        public PublishRateCard(){
            pricePoints = new List<PublishRateCardFee>();
        }
        public PublishRateCard( Rate_Card__c rc, String acvId ){
            name = rc.Display_Name__c;
            feeType = rc.Fee_Type__c;
            shared = true;
            approvedBy = Integer.valueOf(acvId);
            createdBy = Integer.valueOf(rc.CreatedBy.Id__c);
            pricePoints = new List<PublishRateCardFee>();
            for( Rate_Card_Fee__c rcf : rc.Rate_Card_Fees__r ){
                pricePoints.add( new PublishRateCardFee(rcf) );
            }   
        }
    }
    /**
     * The response data structure for Publish Rate Card
     * which gives us back the PublishRateCard object and an Id
     */
    public class PublishRateCardResponse{
        public ResponseData data;
        public PublishRateCardResponse(){
            data = new ResponseData();
        }
    }
    /**
     * Data Structure for Publishing Rate Card child Rate Fees
     */
    public class PublishRateCardFee{
        public PublishRateCardFeeDetail minimumPrice;
        public PublishRateCardFeeDetail rate;
        public PublishRateCardFee(){ 
            minimumPrice = new PublishRateCardFeeDetail();
            rate = new PublishRateCardFeeDetail();
        }
        public PublishRateCardFee( Rate_Card_Fee__c rcf ){
            minimumPrice = new PublishRateCardFeeDetail( Integer.valueOf(rcf.Price_Min__c) );
            rate = new PublishRateCardFeeDetail( Integer.valueOf(rcf.Fee_Charged__c) );
        }
    }
    /**
     * Data Structure for Publish Rate Card Child Rate Fees child object
     */
    public class PublishRateCardFeeDetail{
        public Integer amount;
        public PublishRateCardFeeDetail(){ /*Default Constructor*/ }
        public PublishRateCardFeeDetail( Integer value ){
            amount = value;
        }
    }
    /**
     * the child data structure for Publish Card Response
     */
    public class ResponseData{
        public Integer id;
    }
}