public class MarkPrescreenAsLaunched  extends TriggerInterface{
    
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id, SObject> newMap){
        Map<Id, Condition_Report__c> oldCRMap = (Map<Id, Condition_Report__c>)oldMap;
        Map<Id, Condition_Report__c> newCRMap = (Map<Id, Condition_Report__c>)newMap;
        Set<Id> crIdSet = new Set<Id>();
        List<Condition_Report_Prescreen__c> updateList = new List<Condition_Report_Prescreen__c>();
        for(Condition_Report__c cr :newCRMap.values()){
            if(!String.isBlank(cr.ACV_Auction_Id__c) && String.isBlank(oldCRMap.get(cr.id).ACV_Auction_Id__c)){
                crIdSet.add(cr.Id);
            }
        }

        if(crIdSet.size() > 0){
            for(Condition_Report_Prescreen__c crp :[select Id, Launched_Before_Prescreen__c from Condition_Report_Prescreen__c where Condition_Report__c in :crIdSet AND Status__c = 'New']){
                crp.Launched_Before_Prescreen__c = true;
                updateList.add(crp);
            }
        }

        if(updateList.size() > 0){
            update updateList;
        }
    }
}