public class SalesforceGatewaySendEmail{
    public string username;
    public string user_agent;
    public string ip_address;
    public string requesting_identity_user_id;
   
    public SalesforceGatewaySendEmail(String un, string ua, String ip, String uid){
        this.username = un;
        this.user_agent = ua;
        this.ip_address = ip;
        this.requesting_identity_user_id = uid;
    }
}