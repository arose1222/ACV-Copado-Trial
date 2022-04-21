/**
 * This class holds the helper functions for the
 * PrivateLaneAccessAPI - Salesforce Gateway
 * @author James Andre LaCour
 */
public  class PrivateLaneAccessAPI {
    /****************Class Variables**********************/
    @testVisible private static final String DELETE_PERMISSION_ENDPOINT = '/api/v1/lane/{lane_id}/permission/{dealership_group_id}';
    @testVisible private static final String SET_PERMISSION_ENDPOINT = '/api/v1/lane/{lane_id}/permission';
    /****************Helper Methods***********************/
    /**
     * creates the Salesforce Gateway Delete Permission request
     * @param laneId - id of the Private Lane
     * @param dealershipGroupId - Group_Guid__c of the Organization Group
     * @return HttpRequest with the needed info for Delete Private Lane Permission - Salesforce Gateway
     */
    public static HttpRequest createDeleteRequest( String laneId, String dealershipGroupId ){
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setEndpoint( 'callout:Salesforce_Gateway' + DELETE_PERMISSION_ENDPOINT.replace('{lane_id}', laneId).replace('{dealership_group_id}', dealershipGroupId) );
        return req;
    }
    /**
     * creates the Salesforce Gateway Set Permission request
     * @param laneId - id of the Private Lane
     * @param permissions - List of PermissionDetails that will be used for the JSON body
     * @return HttpRequest with the needed info for Set Private Lane Permission - Salesforce Gateway
     */
    public static HttpRequest createSetRequest( String laneId, List<PermissionDetail> permissions ){
        SetRequest spr = new SetRequest();
        spr.permissions = permissions;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setEndpoint( 'callout:Salesforce_Gateway' + SET_PERMISSION_ENDPOINT.replace('{lane_id}', laneId) );
        req.setBody( JSON.serialize(spr) );
        return req;
    }
    /**
     * 
     * @param laneId - id of the Private Lane
     * @param dealershipGroupId - GUID of the Organization Group
     * @param canBuy - whether this group can buy a car on this lane
     * @param canSell - whether this group can sell a car on this lane
     * @return PermissionDetail record
     */
    public static PermissionDetail createPermissionDetail( String laneId, String dealershipGroupId, Boolean canBuy, Boolean canSell ){
        PermissionDetail pd = new PermissionDetail();
        pd.lane_id = laneId;
        pd.dealership_group_id = dealershipGroupId;
        pd.can_buy = canBuy;
        pd.can_sell = canSell;
        return pd;
    }
    /****************Inner Classes***********************/
    public class SetRequest{
        public List<PermissionDetail> permissions;
    }
    public class SetResponse{
        public List<ErrorDetail> detail;
    }
    public class DeleteRequest{
        // Not Used currently - everything needed is in URL
    }
    public class DeleteResponse{
        public List<ErrorDetail> detail;
    }

    public class PermissionDetail{
        public String lane_id;
        public String dealership_group_id;
        public Boolean can_buy;
        public Boolean can_sell;
    }
    public class ErrorDetail{
        public List<String> loc;
        public String msg;
        public String type;
    }
}