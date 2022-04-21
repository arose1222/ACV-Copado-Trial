public class EngineAudioPlayerComponent {
    
    @AuraEnabled(cacheable=true)
    public static string getAudioLink(String caseId){
      List<Case> caseList = [select id, Auction_Number__r.vehicle_id__r.Vin__c from case where id = :caseId];
      Case currentCase = new Case();
      if(caseList.size() == 1){
          currentCase = caseList[0];
      }

      return callOutToAudioLink(currentCase.Auction_Number__r.vehicle_id__r.Vin__c);
    }

    public static String callOutToAudioLink(String Vin){
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://ent-micro-audio-prod.acvauctions.com/audio/vin/'+Vin+'/');
        req.setMethod('GET');
        req.setHeader('Authorization','-1:14f1b7dda4a834c711c52a72b003f744');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('X-Frame-Options','SAMEORIGIN');
        req.setTimeout(60000);

        HttpResponse res = h.send(req);

        if(res.getStatusCode() == 200){
            system.debug(res.getBody());
            EngineAudioParser eap = EngineAudioParser.parse(res.getBody());
            return eap.data.audio_files[0].Link;
        }
        else{
            system.debug('error from Audio End Point');
            throw new CustomException('Issue Getting Audio: '+res.getStatusCode()+' '+res.getStatus());   
        }
    }
}