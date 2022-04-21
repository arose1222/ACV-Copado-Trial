/**
 * Trigger Class to check for Capital Elite account badge Eligiblity
 * @author Naveen Varshney
 * @since Oct 26th, 2021
 */
public class CaptialEliteDealerBadgeLogic extends BadgeBannerInterface{
    /**
     * returns true or false based on if the Account is a Major Account
     * @param badgeDeveloperName - developer name of the custom metadata that drives this badge
     * @param recordId - recordId the LWC is running on
     * @return  `Boolean` - whether or not recordId has this badge
     */

    /**
     * String Containing the value of Capital_Dealer_Type__c
     */
    private final String DEALER_TYPE = 'Capital Orange Elite';


    public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
        // Account Capital Elite Dealer Special Logic -  If Account record has Capital_Dealer_Type__c == 'Capital Orange Elite'.

        String capitalDealerType = '';
        switch on badgeDeveloperName {
            when 'Capital_Orange_Elite_Dealers_Account'{
                List<Account> accList = [ SELECT Id, Capital_Dealer_Type__c FROM Account WHERE Id = :recordId LIMIT 1 ];
                if( !accList.isEmpty() ) capitalDealerType = accList[0].Capital_Dealer_Type__c == null ? '' : accList[0].Capital_Dealer_Type__c;
                
            }
            
        }
        return capitalDealerType.equalsIgnoreCase(DEALER_TYPE);
    }
}