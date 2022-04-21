/**
 * This class is the base Auction Launch class
 * that sending to RunList, Live, and Private Lane will use
 * @author James Andre LaCour
 */
public virtual class AuctionLaunchExt {
    /****************Class Variables**********************/
    public static final String SCHEDULING_PREFIX = 'Scheduling to ';
    /****************Inner Classes************************/
    public virtual class Request{
        public Integer user_id;
        public Decimal floor_price;
        public Integer address_id;
        public Integer saved_auction_id;
        public String auction_start_time;
    }
    public virtual class Response{
        public List<ResponseData> successes;
        public List<ResponseData> errors;
    }
    public virtual class ResponseData{
        public String message;
        public Integer saved_auction_id;
        public Integer status;
    }
}