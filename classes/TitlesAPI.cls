public class TitlesAPI {

    private static List<String> stateList;

    public static List<String> getAllBlockedRegions(){
        if(stateList != null){
            return stateList;
        }
        else{
            ACVAPIHelper.Credentails creds = new ACVAPIHelper.Credentails();
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndPoint('callout:ACVAuth2');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('X-Frame-Options','SAMEORIGIN');
            req.setTimeout(60000);
            Map <String, object> mapping = New Map<String, object>();
            mapping.put('email', '{!$Credential.Username}');
            mapping.put('password', '{!$Credential.Password}');
            mapping.put('web', true);    
            req.setBody(json.serialize(mapping));
            HttpResponse res = h.send(req);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                creds = new ACVAPIHelper.Credentails(ACVLoginObject.parse(res.getBody()));
                stateList = getBlockedRegions('callout:ACVAuctionData', creds.userId, creds.sessionToken);
                if(stateList != null){
                    return stateList;
                }
                else{
                    return null;
                }
            }
            else{
                system.debug(res.getBody());
                return null;
            }
        }
    }
    
    public static Boolean isInBlockedRegion(String state){
        if(stateList != null){
            return stateList.contains(state);
        }
        else{
            getAllBlockedRegions();
            if(stateList != null){
                return stateList.contains(state);
            }
            else{
                return false;
            }
        }
    }

    public static List<String> getBlockedRegions(String baseUrl, String userId, String sessionToken){
        String enpointUrl = baseUrl+'/v2/auctions/launch_blocked_regions?user_id='+userId+'&session_token='+sessionToken;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(enpointUrl);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 200){
            BlockedRegions br = BlockedRegions.parse(res.getBody());
            return br.data;
        }
        else{
            return null;
        }
    }
}