public class SalesforceGatewayUserResponse {
    public List<detail> detail;
    public Boolean active;
    public String identity_user_id;
    public Integer acv_api_user_id;

    public class detail{
        public List<String> loc;
        public String msg;
        public String type;
    }
}