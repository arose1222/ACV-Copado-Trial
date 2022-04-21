/**
 * Trigger Class to check for Major Account Badge Eligiblity
 * @author James Andre LaCour
 * @since Aug 10th, 2021
 */
public class CaliforniaBadgeLogic extends BadgeBannerInterface {
    /**
     * String containing the 2 character abbrivation for California
     */
    private final String CALIFORNIA_ABBRIEVATION = 'CA'; 
    /**
     * String Containing the name of California
     */
    private final String CALIFORNIA_NAME = 'California';
    /**
     * returns true or false based on if the Account is from California
     * @param badgeDeveloperName - developer name of the custom metadata that drives this badge
     * @param recordId - recordId the LWC is running on
     * @return  `Boolean` - whether or not recordId has this badge
     */
    public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
        String thisAccountState = '';
        // California Logic -  If the BillingState on Account = CA or California
        switch on badgeDeveloperName {
            when 'California_Seller_Case'{
                List<Case> cseList = [ SELECT Id, Seller_Dealership__c, Seller_Dealership__r.BillingState FROM Case WHERE Id = :recordId LIMIT 1 ];
                if( !cseList.isEmpty() ) thisAccountState = cseList[0].Seller_Dealership__r?.BillingState;
            }
            when 'California_Seller_Auction'{
                List<Auction__c> auctionList = [ SELECT Id, Seller_Dealership__c, Seller_Dealership__r.BillingState FROM Auction__c WHERE Id = :recordId LIMIT 1 ];
                if( !auctionList.isEmpty() ) thisAccountState = auctionList[0].Seller_Dealership__r?.BillingState;
            }
        }
        return thisAccountState.equalsIgnoreCase(CALIFORNIA_ABBRIEVATION) || thisAccountState.equalsIgnoreCase(CALIFORNIA_NAME);
    }
}