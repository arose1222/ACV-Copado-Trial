public class SiaCrEvaluator extends ClassInterface{

    private static final String SIA_PATH = '/v1/arbguard/sia';

    public override Map<String, PrescreenServiceHelper.InspectionWrapper> handle(Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap, CR_Review_Trigger__mdt crt){
        
        Set<String> inspectionIds = wrapperMap.keySet();

        SiaCrEvaluator.SiaRequest siaReq = new SiaCrEvaluator.SiaRequest();
        siaReq.sia_guids = inspectionIds;
        String body = JSON.serialize(siaReq);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('callout:ArbGuard'+SIA_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('X-Frame-Options','SAMEORIGIN');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setBody(body);
        req.setTimeout(120000);
        HttpResponse res = http.send(req);

        try{
            SiaResponse response = (SiaResponse) JSON.deserialize(res.getBody(), SiaResponse.class);   

            if(response.data.message == 'OK' && response.data.tasks != null && !response.data.tasks.isEmpty()){
                List<SiaTask> tasks = response.data.tasks;
                for(SiaTask t : tasks){
                    if(t.detail != null &&  t.detail.categories != null && !t.detail.categories.isEmpty()){
                        wrapperMap.get(t.guid).prescreenReasons.add(crt.Prescreen_Reason__c);
                        wrapperMap.get(t.guid).prescreenReasonWrappers.add(new PrescreenServiceHelper.ReasonWrapper(crt.Prescreen_Reason__c, crt.Is_Aux_Reason__c));
                        wrapperMap.get(t.guid).siaCategories.addAll(t.detail.categories);
                    }
                }
            }
        
        }catch(Exception e){ System.debug('########## ERROR PARSING RESPONSE '+ e.getMessage());}
        
        return  wrapperMap;
    }

    public class SiaRequest{
        public Set<String> sia_guids;
    }

    public class SiaResponse{
        public Decimal api_version;
        public SiaData data;
    }

    public class SiaData{
        public String message;
        public String status;
        public SiaTask[] tasks;
    }

    public class SiaTask{
        public String guid;
        public String status;
        public SiaDetail detail;
    }

    public class SiaDetail{
        public Decimal totalDollarRisk;
        public SiaCategory[] categories;
    }

    public class SiaCategory{
        public String category;
        public String odds;
        public Decimal dollarRisk;
        public String note;
    }
}