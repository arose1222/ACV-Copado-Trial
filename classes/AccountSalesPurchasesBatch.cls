global class AccountSalesPurchasesBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Buyer_Dealership__c, Seller_Dealership__C FROM Auction__C WHERE Status__c LIKE \'%_Accepted\' AND (End_Time__c = LAST_N_DAYS:90) ';
        System.debug(query); 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Auction__C> auctionList = (List<Auction__C>)scope;
		system.debug(auctionList);

        Set<Id> sellerIDs = new Set<Id> ();
        Set<Id> buyerIDs= new Set<Id> ();

        for(Auction__c a : auctionList){
            if (a.Buyer_Dealership__c != null) {
                buyerIDs.add(a.Buyer_Dealership__c);
            }
            if (a.Seller_Dealership__c != null) {
                sellerIDs.add(a.Seller_Dealership__c);
            }
        }

        //Update all the sales made by the seller accounts using the sellerIDs set
        List<Account> sellerList = [SELECT Id, Last_90_Days_Sold__C FROM Account WHERE Id IN :sellerIDs ]; 
        Map<Id, Integer> auctionTotals = new Map<Id, Integer>();

        for(Id x : sellerIDs){
            List<Auction__c> amt = [SELECT Id, Seller_Dealership__C 
                                    FROM Auction__C 
                                    WHERE Status__c LIKE '%_Accepted' 
                                    AND (end_time__c = LAST_N_DAYS:90) 
                                    AND (seller_dealership__C = :x)];
            auctionTotals.put(x,amt.size());
        }
		
        for(Account a : sellerList){
            a.Last_90_Days_Sold__C = auctionTotals.get(a.id); 
        }
        // system.debug(auctionTotals);
        // system.debug(sellerList);
        update sellerList;

        //Update all the purchases over the last 90 days for the dealers in the buyerIds
        List<Account> buyerAccountList = [SELECT Id, Last_90_Days_Bought__c FROM Account WHERE Id IN :buyerIDs ]; 
        Map<Id, Integer> buyerAuctionTotals = new Map<Id, Integer>();

        for(Id x : buyerIDs){
            List<Auction__c> amt = [SELECT Id, Buyer_Dealership__c 
                                    FROM Auction__c 
                                    WHERE Status__c LIKE '%_Accepted'  
                                    AND (end_time__c = LAST_N_DAYS:90) 
                                    AND (buyer_dealership__C = :x)];
            buyerAuctionTotals.put(x,amt.size());
        }

        for(Account a : buyerAccountList){
            a.Last_90_Days_Bought__c = buyerAuctionTotals.get(a.id); 
        }
        // system.debug(buyerAuctionTotals);
        // system.debug(buyerAccountList);
        update buyerAccountList;
    }

    global void finish(Database.BatchableContext BC){
        
    }
}