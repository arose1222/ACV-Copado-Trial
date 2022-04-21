public class PredictedPriceComponent {
    
    /**
     *  Fetches the predicted ceiling and floor price for a give auction ID.  
     *
     *  @param auctionId - The 'id__c' auction Id, which is used in the web/mobile app.
     *
     *  @return A <code>String</code> object that is formatted as json object containing the floor and ceiling price
     *          with the keys "floor_price" and "ceiling_price"
     **/    
    @AuraEnabled(cacheable=false)
    public static String getPredictedCeilingAndFloorPrice(String auctionId) {
        system.debug('Getting predicted price for auction: ' + auctionId);
        return fetchPredictedCeilingAndFloorPrice(auctionId);
    }

    /**
     *  Fetches the predicted high bid for a give auction ID.  
     *
     *  @param auctionObjectId - The 'id' for the Auctions__c salesforce object.
     *
     *  @return A Decimal of the predicted high bid for the auction.  If the auction is not found, the this will return -1.  
     *          If there is an error fetching the information, then this returns the status code as a negative number.
     **/    
    @AuraEnabled(cacheable=true)
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
        req.setEndPoint('https://price-prediction-production.acvauctions.com/api/ml/highBid/v1?auctionId='+auctionId);
        req.setMethod('GET');
        req.setHeader('ML-SECURITY-KEY','UYB1PASES5L7MXEZPAFOLV84F2GCUNQINH1CL6N1VD2K8NF4SPOHWX9XK6JD838NMKUAP4UZNRLANA4F4A4TSD11HSPJD9UIUCXYO2');
        req.setHeader('Accept','application/json');
        req.setTimeout(60000);

        HttpResponse res = h.send(req);

        if(res.getStatusCode() == 200){
            system.debug(res.getBody());
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            return ((PredictedHighBidResponse)parser.readValueAs(PredictedHighBidResponse.class)).highBid;
        } else {
            system.debug('Non-normal service response for auction: ' + auctionId + '. Response: '+res.getStatusCode()+' '+res.getStatus() + ' for auction: ' + auctionId);
            return res.getStatusCode() * -1;
        }
    }

    public static String fetchPredictedCeilingAndFloorPrice(String auctionId){
        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndPoint('https://price-prediction-production.acvauctions.com/api/ml/floorCeilingPrice/v1?auctionId='+auctionId);
        req.setMethod('GET');
        req.setHeader('ML-SECURITY-KEY','UYB1PASES5L7MXEZPAFOLV84F2GCUNQINH1CL6N1VD2K8NF4SPOHWX9XK6JD838NMKUAP4UZNRLANA4F4A4TSD11HSPJD9UIUCXYO2');
        req.setHeader('Accept','application/json');
        req.setTimeout(60000);

        HttpResponse res = h.send(req);

        if(res.getStatusCode() == 200){
            system.debug(res.getBody());
            return res.getBody();
        } else {
            system.debug('Non-normal service response for auction: ' + auctionId + '. Response: '+res.getStatusCode()+' '+res.getStatus() + ' for auction: ' + auctionId);
            return null;
        }
    }
}