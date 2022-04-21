public class VirtualLiftAPIHelper {

    public ACVAPIHelper api;

    public VirtualLiftAPIHelper() {
        api = new ACVAPIHelper('callout:R_D_MicroService','{!$Credential.UserName}','{!$Credential.Password}');
    }

    public List<VLVinObject.Virtual_lift_list> getVLsFromListOfVins(List<String> vinList){
        System.debug(api);
        if(api.getCreds() != null && api.getCreds().isValid()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndPoint(api.getHostURL()+'/virtual_lift/vin/batch/?vins='+string.join(vinList,',')+'&recent_days_back=90');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('X-Frame-Options','SAMEORIGIN');
            req.setHeader('Authorization', api.getCreds().userId+':'+api.getCreds().sessionToken);
            req.setTimeout(60000);
            HttpResponse res = h.send(req);
            if(api.isSuccess(res)){
                VLVinObject vl = VLVinObject.parse(res.getBody());
                if(vl.data.virtual_lift_list.size() > 0){
                    return vl.data.virtual_lift_list;
                }
                else {
                    return null;
                }
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }

    public Boolean whiteListUser(List<String> userIdList){
        system.debug('made it to user whitelist');
        system.debug(api.getCreds());
        if(api.getCreds() != null && api.getCreds().isValid()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndPoint(api.getHostURL()+'/virtual_lift/whitelist/activate/');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('X-Frame-Options','SAMEORIGIN');
            req.setHeader('Authorization', api.getCreds().userId+':'+api.getCreds().sessionToken);
            req.setBody('{"user_ids":"'+string.join(userIdList,',')+'"}');
            req.setTimeout(60000);
            HttpResponse res = h.send(req);
            system.debug(req.getBody());
            system.debug(res.getBody());
            if(api.isSuccess(res)){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }

    public Boolean deactivateUser(List<String> userIdList){
       if(api.getCreds() != null && api.getCreds().isValid()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndPoint(api.getHostURL()+'/virtual_lift/whitelist/deactivate/');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('X-Frame-Options','SAMEORIGIN');
            req.setHeader('Authorization', api.getCreds().userId+':'+api.getCreds().sessionToken);
            req.setBody('{"user_ids":"'+string.join(userIdList,',')+'"}');
            req.setTimeout(60000);
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            if(api.isSuccess(res)){
                return true;
            }
            else{
                return false;
            }
        } 
        else{
            return false;
        }
    }

    public Boolean checkUserVLStatus(String userId){
       if(api.getCreds() != null && api.getCreds().isValid()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndPoint(api.getHostURL()+'/virtual_lift/whitelist/check/'+userId+'/');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('X-Frame-Options','SAMEORIGIN');
            req.setHeader('Authorization', api.getCreds().userId+':'+api.getCreds().sessionToken);
            //req.setBody('{"user_id":"'+userId+'"}');
            req.setTimeout(60000);
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            if(api.isSuccess(res)){
                return true;
            }
            else{
                return false;
            }
        } 
        else{
            return false;
        }
    }

    public Boolean deactivateVLImagesByVin(String vin){
       if(api.getCreds() != null && api.getCreds().isValid()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndPoint(api.getHostURL()+'/virtual_lift/deactivate/');
            req.setMethod('DELETE');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept','application/json');
            req.setHeader('X-Frame-Options','SAMEORIGIN');
            req.setHeader('Authorization', api.getCreds().userId+':'+api.getCreds().sessionToken);
            req.setBody('{"vin":"'+vin+'"}');
            req.setTimeout(60000);
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            if(api.isSuccess(res)){
                return true;
            }
            else{
                return false;
            }
        } 
        else{
            return false;
        }
    }
}