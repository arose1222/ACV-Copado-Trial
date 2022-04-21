public class PredictedHighBidComponent {
    
    @AuraEnabled
    public static Decimal getPredictedHighBid(String auctionObjectId){
        List<Auction__c> auctions = [select id, Name from Auction__c where id = :auctionObjectId];
        Auction__c currentAuction = new Auction__c();
        if(auctions.size() == 1){
            return fetchPredictedHighBid(auctions[0].Name);
        }
        return -1;
    }

    public static Decimal fetchPredictedHighBid(String auctionId){
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://high-bid-prediction-latest.acvauctions.com/api/ml/highBid/v1?auctionId='+auctionId);
        req.setMethod('GET');
        req.setHeader('ML-SECURITY-KEY','UYB1PASES5L7MXEZPAFOLV84F2GCUNQINH1CL6N1VD2K8NF4SPOHWX9XK6JD838NMKUAP4UZNRLANA4F4A4TSD11HSPJD9UIUCXYO2');
        req.setHeader('Accept','application/json');
        req.setTimeout(60000);

        HttpResponse res = h.send(req);

        if(res.getStatusCode() == 200){
            system.debug(res.getBody());
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            return ((PredictionResponse)parser.readValueAs(PredictionResponse.class)).highBid;
        } else {
            system.debug('Non-normal service response for auction: ' + auctionId + '. Response: '+res.getStatusCode()+' '+res.getStatus() + ' for auction: ' + auctionId);
            return res.getStatusCode() * -1;
        }
    }
}