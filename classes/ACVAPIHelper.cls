global class ACVAPIHelper {
/*////////////////////////// private vars //////////////////*/
    private Credentails creds;
    private string hostURL;

/*////////////////////////// public methods //////////////////*/

    public ACVAPIHelper() {
        this.creds = new credentails();
    }

    public ACVAPIHelper(String hostUrl) {
        setHostURL(hostUrl);
        this.creds = new credentails();
    }

    public ACVAPIHelper(String hostURL, String userName, String password){
        setHostURL(hostURL);
        this.creds = login(userName, password);
    }

    public Credentails getCreds(){
        if(this.creds != null && this.creds.isValid()){
            return creds;
        }
        else{
            return null;
        }
    }

    public Credentails setCreds(String userId, String token){
        this.creds.userId = userId;
        this.creds.sessionToken = token;
        return this.creds;
    }

    public boolean setHostURL(String url){
        if(!String.isBlank(url)){
            this.hostURL = url;
            return true;
        }
        else{
            return false;
        }
    }

    public String getHostURL(){
        return this.hostURL;
    }

    public Credentails login(String userName, String password){
        return login(new IdenityInformation(userName, password));
    }

    public Credentails login(IdenityInformation loginCreds){
        //potentail improvement do a timeout check? like if the creds need to be re-established
        if(this.creds!= null && this.creds.isValid()){
            return this.creds;
        }
        else{
            if(isHostURLSet()){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndPoint(this.hostURL+'/login_acv');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept','application/json');
                req.setHeader('X-Frame-Options','SAMEORIGIN');
                req.setBody(JSON.serialize(loginCreds));
                req.setTimeout(60000);
                system.debug(req.getBody());
                HttpResponse res = h.send(req);
                //set integration result record
                //result r = new result(req,res,'ACV Login');
                //insert r.toIR();
                //handle success and errors
                if(isSuccess(res)){
                    this.creds = new Credentails(ACVLoginObject.parse(res.getBody()));
                    return this.creds;
                }
                else{
                    system.debug(res.getBody());
                    return null;
                }
                
            }
            else{
                throw new CustomException('Host URL is not set, can not make callout');
            }
        }
    }

    public Boolean isSuccess(HttpResponse res){
        if(res.getStatusCode() >= 200 && res.getStatusCode() <= 299){
            return true;
        }
        else{
            return false;
        }
    }

/*////////////////////////// Class Visable Helpers //////////////////*/
    private Boolean isHostURLSet(){
        return !String.isBlank(this.hostURL);
    }

/*///////////////////////// Data Structures ////////////////////////*/

    public class Result{
        public Id recordID{get;set;}
        public string request{get;set;}
        public string response{get;set;}
        public integer statusCode{get;set;}
        public string message{get;set;}
        public string integrationName{get;set;}
        public string integrationType{get;set;}
        public string endPointURL{get;set;}
        public string sObjectType{get;set;}

        public Result(){
            this.recordID = null;
            this.request = '';
            this.response = '';
            this.statusCode = null;
            this.message = '';
            this.integrationName = '';
            this.integrationType = '';
            this.endPointURL = '';
            this.sObjectType = '';
        }

        public Result(HttpRequest req, HttpResponse rep, String intName){
            this.request = req.getBody();
            this.response = rep.getBody();
            this.statusCode = rep.getStatusCode();
            this.message = rep.getStatus();
            this.integrationName = intName;
            this.integrationType = req.getMethod();
            this.endPointURL = req.getEndpoint();
        }

        public Result(HttpRequest req, HttpResponse rep, String intName, Id recordId){
            this.request = req.getBody();
            this.response = rep.getBody();
            this.statusCode = rep.getStatusCode();
            this.message = rep.getStatus();
            this.integrationName = intName;
            this.integrationType = req.getMethod();
            this.endPointURL = req.getEndpoint();
            this.recordID = recordID;
            this.sObjectType = String.isBlank(this.recordId) ? '' : String.valueOf(this.recordId.getSobjectType());
        }

        public Integration_Result__c toIR(){
            if(String.isBlank(this.endPointURL)||String.isBlank(this.integrationName)||String.isBlank(this.integrationType)||this.statusCode == null||String.isBlank(this.message)){
                system.debug('endpoint url :'+this.endPointURL);
                system.debug('inteagration name: '+this.integrationName);
                system.debug('int type: '+this.integrationType);
                system.debug('status code: '+this.statusCode);
                system.debug('message: '+this.message);
                throw new customException('Missing Required Data');
            }
            return new Integration_Result__c(
                        Integration_Name__c = this.IntegrationName,
                        Integration_Type__c = this.IntegrationType,
                        RecordId__c = String.ValueOf(this.recordId),
                        Request_Message__c = this.request,
                        Response_Message__c = this.response,
                        SObject_Name__c = this.sObjectType,
                        Status_Code__c = this.statusCode,
                        Status_Message__c = this.message.length() >= 255 ? this.message.subString( 0, 254 ) : this.message
                    );
        }
    }
    //Used to store the credentails for the code context
    public class Credentails{
        public string userId {get;set;}
        public string sessionToken {get;set;}

        public credentails(){
            this.userId = '';
            this.sessionToken = '';
        }

        public credentails(ACVLoginObject usr){
            this.userId = usr.data.user_id;
            this.sessionToken = usr.data.session_token;
        }

        public boolean isValid(){
            if(String.isBlank(this.sessionToken) || String.isBlank(this.userId)){
                return false;
            }
            else{
                return true;
            }
        }
    }

    public class IdenityInformation{
        public string email {get;set;}
        public string password {get;set;}

        public IdenityInformation(String ea, String pw){
            this.email = ea;
            this.password = pw;
        }
    }


    /////////////////////Custom SF Endpoint Structures///////////////////////
    global class SFResponse{
        public Integer statusCode;
        public String message;
        public Object apiResponse;
        public Object originalRequest;

        public SFResponse(Object requestObject, String m, Integer status){
            this.originalRequest =  requestObject;
            this.message = m;
            this.statusCode = status;
        }

        public SFResponse(Object requestObject, Object sres, String m, Integer status){
            this.originalRequest =  requestObject;
            this.apiResponse = sres;
            this.message = m;
            this.statusCode = status;
        }

        public void generateResponse() {
            setBaseResponse();
        }

        public void generateResponse( Map<String, String> headerMap ) {
            RestResponse response = setBaseResponse();
            for ( String key : headerMap.keySet() ) {
                response.headers.put( key, headerMap.get( key ) );
            }
        }

        public RestResponse setBaseResponse(){
            RestResponse response = RestContext.response;
            response.statusCode = this.statusCode;
            response.responseBody = Blob.valueOf(JSON.serialize(this));

            return response;
        }
    }
}