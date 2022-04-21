public class TrueFrameAccountSync {
    public static String endpointURL = '/api/dealer-proxy';
    
    @AuraEnabled
    public static boolean syncAccount(String jsonString){
        tfSync newRequest = (tfSync)JSON.deserializeStrict(jsonString, tfSync.class);

        // SI 370: Fetching GeoLocation(Compound) Fields in LWC is not working and hence moving this logic to Apex.
        List<Account> aList = [SELECT Id, BillingLatitude, BillingLongitude FROM Account WHERE Dealership_Id__c = :String.valueOf(newRequest.acv_id)];
        if(!aList.isEmpty() && aList[0].BillingLatitude!=null &&   aList[0].BillingLongitude!=null)
        {
            newRequest.latitude= String.valueOf(aList[0].BillingLatitude);
            newRequest.longitude= String.valueOf(aList[0].BillingLongitude);
        } 
        String updatedJsonString= JSON.serialize(newRequest);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(updatedJsonString);
        req.setMethod('POST');
        req.setEndpoint('callout:Trueframe'+endpointURL);
        req.setHeader('Authorization', 'Basic {!$Credential.Password}');
        req.setHeader('Content-Type', 'application/json');
        system.debug(req.getHeader('Authorization'));
        HttpResponse res = h.send(req);
        
        if(res.getStatusCode() == 200){
            generateLog(req, res, ACVUtility.currentLineNumber(), String.valueOf(newRequest.acv_id), aList[0].id);
            return true;
        }
        else{
            generateLog(req, res, ACVUtility.currentLineNumber(), String.valueOf(newRequest.acv_id), aList[0].id);
            return false;
        }
    }

    public class tfSync{
        public Integer info_id;
        public String name;
        public Integer acv_id;
        public String state;
        public String city;
        public String street;
        public String zip;
        public String latitude;
        public String longitude;

    }
 
    public static void generateLog(HttpRequest req, HttpResponse res, Integer linenumber, String acvID, Id aId){
        SplunkHelper.Log newLog = new SplunkHelper.Log();
        newLog.componentName = 'TrueFrameAccountSync';
        newLog.domainSet = new set<SplunkHelper.DOMAIN>();
        newLog.domainSet.add(SplunkHelper.DOMAIN.SALES);
        newLog.location = 'TrueFrameAccountSync: '+linenumber;
        newLog.logLevel = res.getStatusCode() == 200 ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR;
        newLog.sfRecordId = aId;
        newLog.sfObject = 'Account';
        newLog.stackTrace = 'TrueFrameAccountSync.syncAccount: '+linenumber;
        newLog.version = 'v1';
        newLog.message = res.getStatusCode() == 200 ? 'Success' : 'Error Check Response';
        SplunkHelper.processIntegrationLog(newLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
    }
}