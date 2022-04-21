/**
 * Trigger Class to check for Private Sale Badge Eligiblity
 * @author Ravi Shukla
 * @since Jan 20th, 2022
 */
public class PrivateSaleCaseBadgeLogic extends BadgeBannerInterface {
     /**
     * returns true or false based on if the Case Auction's Private Lane
     * @param badgeDeveloperName - developer name of the custom metadata that drives this badge
     * @param recordId - recordId the LWC is running on
     * @return  `Boolean` - whether or not recordId has this badge
     */
    public override Boolean checkLogic( String badgeDeveloperName, Id recordId ){
        boolean status = false;
        switch on badgeDeveloperName {
            when 'Private_Sale_Case'{
                List<Case> caseList = new List<Case>();
                caseList = [ SELECT Id, Auction_Number__r.Private_Lane__c FROM Case WHERE Id = :recordId and RecordType.DeveloperName = 'Arbitration_Claim' LIMIT 1 ];
                if( caseList.size()>0 ){
                    if(caseList[0].Auction_Number__r.Private_Lane__c != null){
                        status = true;
                    }  
                } 
            }
            
        }
        return status;
    }
}