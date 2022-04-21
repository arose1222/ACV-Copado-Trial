public class CreditPost {

    public class CreditWrap {
        public Integer account_id;
        public Integer amount;
        public Integer authorizer;
        public String credit_cause_type;
        public Integer expires_after;
        public String salesforce_id;
    }

    public List<CreditWrap> credits;
    public String session_token;
    public Integer user_id;

    
    public static CreditPost parse(String json) {
        return (CreditPost) System.JSON.deserialize(json, CreditPost.class);
    }

    public static String compose(CreditPost newCreditPost) {
        return System.JSON.serialize(newCreditPost);
    }
}