public without sharing class AuctionKillAPI {
    @testVisible private static final String AUCTION_KILL_ENDPOINT_SUFFIX = '/api/v1/auctions/kill';
    @testVisible public static final String AUCTION_KILL_STATUS = 'ended_killed';

    private static Map <String, object> authorizeUAT(){
        //create the necessary objects for http request and response
        Http h = new Http();

        HttpRequest authRequest = new HttpRequest();
        HttpResponse authResponse = new HttpResponse();

        //set all parameters for POST request to authorize

        //Using named credentials from Salesforce, set all necesarry parameters for the request
        authRequest.setMethod('POST');
        authRequest.setEndpoint('callout:ACVAuth');
        Map <String, object> mapping = New Map<String, object>();
        mapping.put('email', '{!$Credential.Username}');
        mapping.put('password', '{!$Credential.Password}');
        mapping.put('web', true);
    
        authRequest.setBody(json.serialize(mapping));
        authRequest.setHeader('Content-Type', 'application/json');

        authResponse = h.send(authRequest);

        //if the response is 200 then put the response into a map
        Map<String, object> responseMap = new Map<String, object>();
        if (authResponse.getStatusCode() == 200){
            responseMap = (Map<String, object>)json.deserializeUntyped(authResponse.getBody());
        }
        return responseMap;
    }

    //this function takes the record Id of an auction and returns the auctionId used by the ACV API
    private static String auctionIdScan(String stringToCheck){
        
        //checks if you inputed a recordId and translates that to the auctionID
        if (stringToCheck.length() == 18){
            String auction = [SELECT Auction_Number__c FROM Case WHERE Id =: stringToCheck LIMIT 1].Auction_Number__c;
            String savedAuctionId = [SELECT Name FROM Auction__c WHERE Id =: auction LIMIT 1].Name;
            String stringRet = savedAuctionId;
            return stringRet;
        }
        //checks if you actually inputed a auctionID and if so it doesn't have to do anything besdies return it
        else {
            String stringRet = stringToCheck;
            return stringRet;
        }
    }
    @AuraEnabled(cacheable=true)
    // this function takes a record id of a auction and kills that auction
    public static String getSAPUrl(String recordId){

        //create the required objects for request and response

        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();


        //the authorize should return a map with a userId and sessionToken
        Map <String, object> authInfo = authorizeUAT();
        
        String userId;
        String sessionToken;

        // this if block takes the authInfo map and puts the corresponding variables into userId and sessionToken

        if(!authInfo.isEmpty()){
            if(authInfo.containsKey('user_id')){
                userId = String.valueOf(authInfo.get('user_id'));
            }else{
                userId = null;            
            }
                
            if(authInfo.containsKey('session_token')){
                sessionToken = String.valueOf(authInfo.get('session_token'));
            } else{
                sessionToken = null;
            }               
        }       
        
        String auctionId;
        auctionId = auctionIdScan(recordId);
        system.debug(auctionId);
        //this section builds the get request using the credentials from the authorize function and should use named credentials to be modular, currently the https:.... is hardcoded
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        final String CURRENT_USER_EMAIL = UserInfo.getUserEmail();
        request.setBody('{"auction_id": '+auctionId+', "authorized_by": "'+CURRENT_USER_EMAIL+'", "notes": "Auciton has been killed from counter sent status to ended killed status.", "user_id": '+userId+', "session_token": "'+sessionToken+'"}');
        //request.setEndpoint('https://auction-house-uat.acvauctions.com/v1/auctions/'+auctionId+'/kill');
        request.setEndpoint('http://auction-house-prod.acvauctions.com:4200/v1/auctions/'+auctionId+'/kill');

        response = h.send(request);

        List<Auction__c> auctionToKill = [SELECT ID, Status__c FROM Auction__c WHERE Name = :auctionId];

        ACVAPIHelper.Result apiLog = new ACVAPIHelper.Result( request, response, 'AuctionKill', auctionToKill[0].Id );

        if (response.getStatusCode() == 200){
            for(Auction__c a: auctionToKill){
                a.status__c = AUCTION_KILL_STATUS;
            }
            insert apiLog.toIR();
            update auctionToKill;
            return 'Auction #'+auctionId+' has succesfully been killed.';
        }
        else {
            insert apiLog.toIR();
            return 'Auction Failed To Kill';
        }
    }

    @InvocableMethod
    public static void endAuction(List<String> aucIds){
        String recordId = aucIds[0];
        getSAPUrl(recordId);
    }
    /**
     * creates the Salesforce Gateway Auction Kill request
     * @param auctionIds - a list of auctinoIds to kill
     * @param acvUserId - the ACV User Id that made this request
     * @param userEmail - the email address of the ACV User Id
     * @param notes - the reason why these auctions were ended
     * @return HttpRequest with the needed info for Auction Kill - Salesforce Gateway
     */
    public static HttpRequest createAuctionKillRequest(List<Integer> auctionIds, Integer acvUserId, String userEmail, String notes){
        AuctionKillApiRequest akReq = new AuctionKillApiRequest();
        akReq.auction_ids = auctionIds;
        akReq.user_id = acvUserId;
        akReq.notes = notes;
        akReq.authorized_by = userEmail;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint( 'callout:Salesforce_Gateway' + AUCTION_KILL_ENDPOINT_SUFFIX );
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody( AuctionKillApiRequest.compose(akReq) );

        return req;
    }
}