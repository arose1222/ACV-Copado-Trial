@RestResource(urlMapping='/AccountOwnerLookup/*')
global without sharing class AccountOwnerLookup {

    /**
     * Created just so I can track if we hit the multiple account use case to return null to HOVER
     */ 
    private static boolean multipleAccountFound = false;
    
    @HTTPGet
    global static returnStructure getAccountOwner(){
        RestRequest request = RestContext.request;
        String input = request.params.get( 'input' );
        String requestType = request.params.get( 'type' );
        String callerType = request.params.get('callerType');
        orginialRequestObject reqObj = new orginialRequestObject(callerType, input, requestType);
        if(requestType.toLowerCase() == 'phonesearch'){
            AccountOwnerLookupWrapper aw = new AccountOwnerLookupWrapper(searchForAccount(input));
            makeLog( ACVUtility.currentLineNumber(), 'phonesearch', new returnStructure(aw, aw.accountId != null ? 'OK' : multipleAccountFound ? 'Multiple Accounts Found' : 'Account Not Found',reqObj));
            return new returnStructure(aw, aw.accountId != null ? 'OK' : 'Account Not Found',reqObj);
        }
        else if(requestType.toLowerCase() == 'auctionsearch'){
            AccountOwnerLookupWrapper aw = new AccountOwnerLookupWrapper(searchForAuction(input,callerType));
            makeLog( ACVUtility.currentLineNumber(), 'auctionsearch', new returnStructure(aw, aw.accountId != null ? 'OK' : 'Account Not Found',reqObj));
            return new returnStructure(aw, aw.accountId != null ? 'OK' : 'Account Not Found',reqObj);
        }
        makeLog( ACVUtility.currentLineNumber(), 'Incorrect Request Type Provided', new returnStructure(new AccountOwnerLookupWrapper(null), 'Incorrect Request Type Provided',reqObj));
        return new returnStructure(new AccountOwnerLookupWrapper(null), 'Incorrect Request Type Provided',reqObj);
    }

    /**
     * makeLog
     * Created to make logging to splunk simple for this class
     * @param  message      
     * @param  rs           void return
     */
    public static void makeLog( Integer lineLocation, String message, returnStructure rs ) {
        String endpoint =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/AccountOwnerLookup?type='+rs.originalRequest.type+'&input='+rs.originalRequest.input;
        endpoint += rs.originalRequest.callerType != null ? '&callerType='+rs.originalRequest.callerType : '';
        HttpRequest req = new HttpRequest();
        req.setBody(JSON.serialize(rs.originalRequest));
        req.setMethod('GET');
        req.setEndpoint(endpoint);

        HttpResponse res = new HttpResponse();
        res.setBody(JSON.serialize(rs.AccountOwnerData));
        res.setStatus(rs.Status);
        res.setStatusCode(200);

        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
        infoLog.location = 'AccountOwnerLookup:' + lineLocation;
        infoLog.message = message;
        infoLog.stackTrace = 'AccountOwnerLookup:' + lineLocation;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'AccountOwnerLookup';
        infoLog.sfObject = 'Account, Contact, User';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.CUSTOMER_CHURN_PREVENTION, SplunkHelper.DOMAIN.POST_TRANSACTION };
        
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    } 

    global static Account searchForAccount(String searchString){
        set<String> searchSet = ACVUtility.generatePhoneFormatSet(searchString);
        if(searchSet.isEmpty()){
            return null;
        }
        List<Contact> contactList = [Select Id, AccountId from Contact where Phone IN :searchSet OR phone__c IN :searchSet OR OtherPhone IN :searchSet OR HomePhone IN :searchSet OR AssistantPhone IN :searchSet OR MobilePhone IN :searchSet];
        String accountId;
        if(ContactList.size() > 0){
            //TODO Fix how this look up operates
            accountId = ContactList[0].AccountId;
        }
        List<Account> aList = [Select Id, IST_Account_Owner__r.Hover_Id__c from Account where Id = :accountId OR (Phone IN :searchSet OR cell__c IN :searchSet OR ALT_PHONE__c IN :searchSet)];
        if(aList.size() == 1){
            return aList[0];
        }
        else if(aList.size() > 1){
            multipleAccountFound = true;
        }
        return null;
    }

    //IST Account Rep 

    global static Account searchForAuction(String searchString, String callerType){
        List<Auction__c> auctionList = [Select id, buyer_dealership__c, Seller_Dealership__c from Auction__c where id__c = :searchString];
        if(auctionList.size() > 0){
            For(Account a :[Select Id, IST_Account_Owner__r.Hover_Id__c from Account where id = :auctionList[0].buyer_dealership__c OR id = :auctionList[0].Seller_Dealership__c]){
                if(callerType.toLowerCase() == 'seller' && a.Id == auctionList[0].Seller_Dealership__c){
                    return a;
                }
                else if(callerType.toLowerCase() == 'buyer' && a.Id == auctionList[0].buyer_dealership__c){
                    return a;
                }
            }
        }
            return null;
    }

    global class returnStructure{
        global AccountOwnerLookupWrapper AccountOwnerData;
        global orginialRequestObject originalRequest;
        global String Status;

        returnStructure(AccountOwnerLookupWrapper a, String s, orginialRequestObject oro){
            this.AccountOwnerData = a;
            this.Status = s;
            this.originalRequest = oro;
        }
    }

    global class orginialRequestObject{
        String callerType;
        String input;
        String type;

        orginialRequestObject(String ct, String i, String t){
            this.callerType = ct;
            this.input = i;
            this.type = t;
        }
    }

    global class AccountOwnerLookupWrapper {
        global string userId;
        global string accountId;
    
        global AccountOwnerLookupWrapper(Account a){
            if(a != null){
                this.userId = a.IST_Account_Owner__r.Hover_Id__c;
                this.accountId = a.Id;
            }
        }
    }
}