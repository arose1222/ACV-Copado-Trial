public class CloseWonDealmakerOpportunities {
    // public static final List<String> triggeringStatuses = new List<String> {'counter_accepted', 'counter_original_accepted'};
    public static final List<String> triggeringStatuses = new List<String> {'counter_accepted', 'ended_accepted'};
    // public static final List<String> triggeringFailedStatuses = new List<String> {'counter_declined', 'counter_original_declined', 'ended_declined'};
    public static final List<String> triggeringFailedStatuses = new List<String> {'awaiting_acceptance', 'counter_original_declined', 'counter_sent', 'ended_declined'};

    public static void Run(Map<Id,Auction__c> auctionMap, Map<Id,Auction__c> auctionMapOld) {
        Set<Id> soldAuctionIdSet = new Set<Id>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();

        for (Auction__c a :auctionMap.Values()) {

            // find auctions that have failed, then capture the ID and related account IDs
            if (triggeringStatuses.contains(a.status__c) && triggeringFailedStatuses.contains(auctionMapOld.get(a.id).status__c)) {
                soldAuctionIdSet.add(a.id);
            }
        }

        for (Opportunity o :[Select id, StageName, Auction_ID__c from Opportunity where Auction__c in :soldAuctionIdSet AND isClosed = FALSE]) {
            o.StageName = 'Closed Won';
            o.Auction_ID__c = '';
            updateOpportunityList.add(o);
        }

        if (updateOpportunityList.size() > 0) {
            update updateOpportunityList;
        }
    }
}