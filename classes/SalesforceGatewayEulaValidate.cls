public class SalesforceGatewayEulaValidate{
    public string identity_user_id;
    public integer acv_user_id; //TODO: depricate after made nullable
    public string eula_id;
    public string organization_id;
    public datetime accepted_date;

    public SalesforceGatewayEulaValidate(String identityUserId, string acvUserId, String eulaId, String orgId, datetime acceptedDate){
        this.identity_user_id = identityUserId;
        this.acv_user_id = Integer.valueOf(acvUserId);
        this.eula_id = eulaId;
        this.organization_id = orgId;
        this.accepted_date = acceptedDate;
      }
}