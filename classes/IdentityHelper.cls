global class IdentityHelper {
    //TODO: update splunk helper to account for I&O Domain
    private static final Map<String, String> AccountTypeMap = new Map<String,String>{'unknown'=>'0', 'franchise'=>'1', 'independent'=>'2', 'wholesaler'=>'3', 'acv certified independent'=>'4', 'commercial'=>'5'};

    public static string createAffiliationId(String dealerId, String AcvUserId){
        if(String.isBlank(dealerId) || String.isBlank(AcvUserId)){
            throw new customException('Could not generate Affiliation Id because Dealer or User ID was null');
        }
        return 'OrganizationId:' + dealerId + '_' + 'UserId:' + AcvUserId;
    }
    
    public static Integer getNextID(String fieldAPIName, String objectName){
        String queryString = 'SELECT ID, '+fieldAPIName+' FROM '+objectName+' WHERE '+fieldAPIName+' != null ORDER BY '+fieldAPIName+' DESC LIMIT 1 ALL ROWS';
        List<SObject> resultList = Database.query(queryString);
        Integer defaultInteger = -1;
        if(resultList.size() < 1){
            defaultInteger = 1;
        }
        if(String.isBlank(String.valueOf(resultList[0].get(fieldAPIName))) || resultList[0].get(fieldAPIName) == null){
            throw new CustomException('Blank Value Returned');
        }
        if(!String.valueOf(resultList[0].get(fieldAPIName)).isnumeric()){
            throw new CustomException('Non-Numeric Field Returned');
        }
        else{
            List<Salesforce_Setting__mdt> baseLine = [Select id, value__c From Salesforce_Setting__mdt Where Label = :fieldAPIName];
            if(defaultInteger < 0){
                if(baseLine.size() > 0 && Integer.valueOf(baseLine[0].Value__c) > Integer.valueOf(resultList[0].get(fieldAPIName))){
                    return Integer.valueOf(baseLine[0].Value__c);
                }
                system.debug(resultList[0].get(fieldAPIName));
                return Integer.valueOf(resultList[0].get(fieldAPIName))+1;
            }
            else{
                return defaultInteger;
            }
        }
    }
    public static void makeLog(Object newUser, ACVAPIHelper.SFResponse output, Integer lineNumber, String endpoint, String methodType, String stackTrace, SplunkHelper.LOGLEVEL LogLevel, Integer statusCode){
        HttpRequest req = new HttpRequest();
        req.setBody(JSON.serialize(newUser));
        req.setMethod(methodType);
        req.setEndpoint(endpoint);
        HttpResponse res = new HttpResponse();
        res.setBody(JSON.serialize(output));
        res.setStatus(output.message);
        res.setStatusCode(statusCode);
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'IdentityService:' + lineNumber;
        infoLog.message = output.message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'IdentityService';
        infoLog.sfObject = 'Account, Contact';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }
    public static void makeApexLog(Integer lineNumber,String stackTrace, SplunkHelper.LOGLEVEL LogLevel, String Location, String Message, String sfObject){
        SplunkHelper.Log infolog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = Location+ ':' + lineNumber;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = Location;
        infoLog.sfObject = sfObject;
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        System.debug(stackTrace);
        SplunkHelper.buildAndProcessLog(infolog);
    }

    public static ACVAPIHelper.SFResponse validateDealerUpdateData(dealerRequest dealer, List<Account> accList, ACVAPIHelper.SFResponse identityResult){
        if(accList.isEmpty()){
            identityResult.message = 'Dealership Does Not Exist';
            identityResult.statusCode = 501;
        }
        if(!String.isBlank(dealer.phone) && !ACVUtility.isValidPhone(dealer.phone)){
            identityResult.message = 'Phone is in a bad format';
            identityResult.statusCode = 409;
        }
        return identityResult;
    }
    public static List<Account> processDealerUpdateData(dealerRequest dealer, List<Account> accList, String statusNumber){
        AddressHelper.AddressWrapper aw = new AddressHelper.AddressWrapper();
        String compondPhone = String.isBlank(dealer.phoneExt) ? dealer.Phone : dealer.Phone+';'+dealer.phoneExt;
        accList[0].Phone =  String.isBlank(compondPhone) ? accList[0].Phone : compondPhone;
        accList[0].cell__c = String.isBlank(dealer.cell) ? accList[0].cell__c : dealer.cell;
        accList[0].Dealer_Type__c = String.isBlank(dealer.dealership_type)? accList[0].Dealer_Type__c : AccountTypeMap.get(dealer.Dealership_Type.toLowerCase());
        
        aw.Street =  String.isBlank(dealer.address) ? accList[0].BillingStreet : dealer.address;
        aw.City =  String.isBlank(dealer.city) ? accList[0].BillingCity : dealer.city;
        aw.State =  String.isBlank(dealer.state) ? accList[0].BillingState : dealer.state;
        aw.PostalCode =  String.isBlank(dealer.zip_code) ? accList[0].BillingPostalCode : dealer.zip_code;
        aw.Country = 'US'; //hardcoded because why would we get this from the consumers?!
        aw.type = 'billing';
        accList[0].Tax_Id__c =  String.isBlank(dealer.federal_tax_id) ? accList[0].Tax_Id__c : dealer.federal_tax_id;
        accList[0].License_Number__c = String.isBlank(dealer.license_number) ? accList[0].License_Number__c : dealer.license_number;
        if(!String.isBlank(statusNumber)){
            accList[0].Status__c = statusNumber;    
        }

        //TODO: figuer out why I did this or remove it
        try{
            
            //Doing this assignment in a try catch becasue the calling classs will not always have these fields
             accList[0].legal_name__c =  String.IsBlank(dealer.legalName) ? accList[0].legal_name__c :  dealer.legalName.replaceAll('`','\'');
             accList[0].dba_trade_name__c = String.IsBlank(dealer.dbaName) ? accList[0].dba_trade_name__c : dealer.dbaName.replaceAll('`','\'');
            //accList[0].Name = String.isBlank(dealer.legalName) ? accList[0].Name : dealer.legalName;

        }
        catch(Exception e){
            //do nothing, we are expecting this to fail and do not need an alert
        }
        if(!String.isBlank(dealer.address) || !String.isBlank(accList[0].BillingStreet)){
            insert AddressHelper.generateAddressStack(aw, accList[0].Id);
        }
        return accList;
    }

    global class dealerRequest{
        public string dealer_id;
        public string user_id;
        public string address;
        public string city;
        public string federal_tax_id;
        public string license_number;
        public string phone;
        public string phoneExt;
        public string cell;
        public string state;
        public string zip_code;
        public string legalName;
        public string dbaName;
        public string dealership_type;
    }

    global class dealerResponse{
        public string dealer_id;
        public string sanitized_legal_Name;
        public string sanitized_dba_Name;


        public dealerResponse(String dId, String sanitizedLegalName, String sanitizedDBAName){
            this.dealer_id = dId;
            this.sanitized_legal_Name= sanitizedLegalName;
            this.sanitized_dba_Name= sanitizedDBAName;
        }
    }
}