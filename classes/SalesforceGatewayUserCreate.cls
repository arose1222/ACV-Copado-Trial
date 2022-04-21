public class SalesforceGatewayUserCreate {
    public string username;
    public string password; //TODO: depricate after made nullable
    public string full_name;
    public string zip_code;
    public string phone;
    public string user_agent;
    public string ip_address;
    public string requesting_identity_user_id;
    public string legacy_user_id;
    public List<string> roles;
    public string creation_source;
    public string user_guid;

    public SalesforceGatewayUserCreate(String un, String pw, String fn, String zc, String p, String ua, String ia, String uid, String lui, List<String> r, String cs, String ug){
        this.username = un;
        this.password = pw;
        this.full_name = fn;
        this.zip_code = zc;
        this.phone = p;
        this.user_agent = ua;
        this.ip_address = ia;
        this.requesting_identity_user_id = uid;
        this.legacy_user_id = lui;
        this.roles = r;
        this.creation_source = cs;
        this.user_guid = ug;
    }
}