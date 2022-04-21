public class CreditAdjustment {

	public class AdjustmentWrap {
		public Integer amount;
		public Integer authorizer_id;
		public String explanation;
		public String related_auction_id;
	}

	public AdjustmentWrap adjustment;
	public String session_token;
	public Integer user_id;

	
	public static CreditAdjustment parse(String json) {
		return (CreditAdjustment) System.JSON.deserialize(json, CreditAdjustment.class);
    }
    
    public static String compose(CreditAdjustment newCreditAdjustment) {
        return System.JSON.serialize(newCreditAdjustment);
    }
}