public class TitleCheckForAuctionPayment extends TriggerInterface{
    
    public override void afterUpdate(Map<Id,Sobject> oldMap, Map<Id,sObject> newMap){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        Map<Id, Auction__c> newAuctionMap = (Map<Id, Auction__c>)newMap;
        Map<Id, Auction__c> oldAuctionMap = (Map<Id, Auction__c>)oldMap;
        List<Case> caseUpdateList = new List<Case>();

        List<Id> auctionIdList = new List<Id>();
        for(Auction__c a :newAuctionMap.values()){
            // Compare Payment Status and ensure auction is paid for
            if(a.payment_status__c != oldAuctionMap.get(a.id).payment_status__c && TitlesShippingAutomation.isPaidFor(a.payment_status__c, a.payment_method__c)){
                auctionIdList.add(a.id);
            }
        }

        if(auctionIdList.size() > 0){
            // Clear the Hold for Payment field
            for(Case c :[select id, Hold_For_Payment__c from Case where Auction_Number__c in :auctionIdList AND recordTypeId = :recordTypeId AND Hold_For_Payment__c != null]){
                c.Hold_For_Payment__c = null;
                caseUpdateList.add(c);
            }
        }

        if(caseUpdateList.size() > 0){
            update caseUpdateList;
        }
    }
}