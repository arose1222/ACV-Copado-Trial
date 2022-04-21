public class WisconsinBadgeLogic extends BadgeBannerInterface{
    /**
     * String containing the 2 character abbrivation for Wisconsin
     */
    private final String WISCONSIN_ABBRIEVATION = 'WI'; 
    /**
     * String Containing the name of Wisconsin
     */
    private final String WISCONSIN_NAME = 'Wisconsin';
    /**
     * returns true or false based on if the Account is from Wisconsin
     * @param badgeDeveloperName - developer name of the custom metadata that drives this badge
     * @param recordId - recordId the LWC is running on
     * @return  `Boolean` - whether or not recordId has this badge
     */
    public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
        String thisAccountState = '';
        // Wisconsin Logic -  If the BillingState on Account = WI or Wisconsin
        switch on badgeDeveloperName {
            when 'Wisconsin_Account'{
                List<Account> acctList = [ SELECT Id, BillingState FROM Account WHERE Id = :recordId LIMIT 1 ];
                if( !acctList.isEmpty() ) thisAccountState = acctList[0].BillingState;
            }
            when 'Wisconsin_Case'{
                List<Case> cseList = [ SELECT Id, AccountId, Account.BillingState FROM Case WHERE Id = :recordId LIMIT 1 ];
                if( !cseList.isEmpty() ) thisAccountState = cseList[0].Account?.BillingState;
            }
            when 'Wisconsin_Auction_Seller'{
                List<Auction__c> auctionList = [ SELECT Id, Seller_Dealership__c, Seller_Dealership__r.BillingState FROM Auction__c WHERE Id = :recordId LIMIT 1 ];
                if( !auctionList.isEmpty() ) thisAccountState = auctionList[0].Seller_Dealership__r?.BillingState;
            }
            when 'Wisconsin_Auction_Buyer'{
                List<Auction__c> auctionList = [ SELECT Id, Seller_Dealership__c, Seller_Dealership__r.BillingState FROM Auction__c WHERE Id = :recordId LIMIT 1 ];
                if( !auctionList.isEmpty() ) thisAccountState = auctionList[0].Seller_Dealership__r?.BillingState;
            }
        }
        return thisAccountState.equalsIgnoreCase(WISCONSIN_ABBRIEVATION) || thisAccountState.equalsIgnoreCase(WISCONSIN_NAME);
    }
}