/**
 * Trigger Class to check for Major Account Badge Eligiblity
 * @author James Andre LaCour
 * @since Aug 10th, 2021
 */
public class MajorAccountBadgeLogic extends BadgeBannerInterface{
    /**
     * returns true or false based on if the Account is a Major Account
     * @param badgeDeveloperName - developer name of the custom metadata that drives this badge
     * @param recordId - recordId the LWC is running on
     * @return  `Boolean` - whether or not recordId has this badge
     */
    public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
        // Major Account Special Logic -  If the Group Affiliation record has the Major_Account__c Checkbox == true.
        // There are multiple badges using this class for different objects but all look for the same thing, just start at a different point to query for the Affiliation
        List<Group_Affiliation__c> grpAffilList = new List<Group_Affiliation__c>();
        switch on badgeDeveloperName {
            when 'Major_Account_Checkmark_Account'{
                grpAffilList = [ SELECT Id FROM Group_Affiliation__c WHERE Account__c = :recordId AND Active__c = True AND Group__r.Active__c = True AND Group__r.Major_Account__c = True ];
                // eligibleToAdd = grpAffilList.size() > 0 ? true : false;
            }
            when 'Major_Account_Checkmark_Case'{
                List<Case> thisCase = [ SELECT Id, AccountId FROM Case WHERE Id = :recordId LIMIT 1];   //This should always return 1 result as we are on the page
                if( String.isNotBlank(thisCase[0].AccountId) ){
                    grpAffilList = [ SELECT Id FROM Group_Affiliation__c WHERE Account__c = :thisCase[0].AccountId AND Active__c = True AND Group__r.Active__c = True AND Group__r.Major_Account__c = True ];
                    // eligibleToAdd = grpAffilList.size() > 0 ? true : false;
                }
            }
            when 'Major_Account_Checkmark_Contact'{
                List<Contact> thisContact = [ SELECT Id, AccountId FROM Contact WHERE Id = :recordId LIMIT 1];   //This should always return 1 result as we are on the page
                if( String.isNotBlank(thisContact[0].AccountId) ){
                    Set<Id> acctIds = new Set<Id>();
                    for( Affiliation__c affil : [ SELECT Id, Account__c FROM Affiliation__c WHERE Contact__c = :recordId AND Active__c = true ] ){
                        acctIds.add( affil.Account__c );
                    }
                    acctIds.add( thisContact[0]?.AccountId );
                    if( acctIds.size() > 0 ){
                        grpAffilList = [ SELECT Id FROM Group_Affiliation__c WHERE Account__c IN :acctIds AND Active__c = True AND Group__r.Active__c = True AND Group__r.Major_Account__c = True ];
                        // eligibleToAdd = grpAffilList.size() > 0 ? true : false;
                    }
                }
            }
            when 'Major_Account_Checkmark_Seller_Auction'{
                List<Auction__c> thisAuction = [ SELECT Id, Seller_Dealership__c FROM Auction__c WHERE Id = :recordId LIMIT 1];   //This should always return 1 result as we are on the page
                if( String.isNotBlank(thisAuction[0].Seller_Dealership__c) ){
                    grpAffilList = [ SELECT Id FROM Group_Affiliation__c WHERE Account__c = :thisAuction[0].Seller_Dealership__c AND Active__c = True AND Group__r.Active__c = True AND Group__r.Major_Account__c = True ];
                    // eligibleToAdd = grpAffilList.size() > 0 ? true : false;
                }
            }
            when 'Major_Account_Checkmark_Buyer_Auction'{
                List<Auction__c> thisAuction = [ SELECT Id, Buyer_Dealership__c FROM Auction__c WHERE Id = :recordId LIMIT 1];   //This should always return 1 result as we are on the page
                if( String.isNotBlank(thisAuction[0].Buyer_Dealership__c) ){
                    grpAffilList = [ SELECT Id FROM Group_Affiliation__c WHERE Account__c = :thisAuction[0].Buyer_Dealership__c AND Active__c = True AND Group__r.Active__c = True AND Group__r.Major_Account__c = True ];
                    // eligibleToAdd = grpAffilList.size() > 0 ? true : false;
                }
            }
        }
        return grpAffilList.size() > 0 ? true : false;
    }
}