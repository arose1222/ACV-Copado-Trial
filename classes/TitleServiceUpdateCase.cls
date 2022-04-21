/**
 * @description Salesforce Auction Id is missing on Case when a digital Case is created before Auction.
 * This trigger will backfill the missing Acution Id on Case.
 * 
 * 
 * @author Manmeet Vaseer
 * @date 04/07/2022
 * 
 * @history
 * 		04/07/2022 Manmeet Vaseer - Initial Revision.
 * 
 */ 
public class TitleServiceUpdateCase extends TriggerInterface {
    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
    
    public override void afterInsert(List<SObject> newList){
        updateCases(newList);
    }
    
    /**
     * Update the salesforce Auction Id on Case (if missing) using the associated External Auction Id from Title__c.
     * 
     */
    private void updateCases(List<Auction__c> newAuctions)	{
        Map<String, Auction__c> externalAuctionNumbers = new Map<String, Auction__c>();
        for(Auction__c anAuction : newAuctions)	{
            externalAuctionNumbers.put(anAuction.Name, anAuction);
        }
        
        List<Title__c> titles = [SELECT Id, Legacy_Auction_Id__c, Case__c, Case__r.Auction_Number__c FROM Title__c 
                                 WHERE Legacy_Auction_Id__c IN :externalAuctionNumbers.keySet() AND Case__r.RecordTypeId = :caseRecordTypeId AND Case__r.Auction_Number__c = null];
        
        List<Case> updatedCases = new List<Case>();
        for(Title__c aTitle : titles)	{
            Auction__c auc = externalAuctionNumbers.get(aTitle.Legacy_Auction_Id__c);
            if(auc != null)	{
                aTitle.Case__r.Auction_Number__c = auc.Id;
                
                updatedCases.add(aTitle.Case__r);
            }
        }
        
        if(updatedCases.size() > 0) update updatedCases;
    }

}