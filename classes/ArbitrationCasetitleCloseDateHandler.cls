public class ArbitrationCasetitleCloseDateHandler extends TriggerInterface {
    
    /* This method is used to update "Arb Close Date for Titles" field on Titile Information Case when 
		its associated Auction Number's Arbitration Claim Case record is Closed. */
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        
        Map<Id,Case> caseIdToNewCase = (Map<Id,Case>)newMap;
        Map<Id,Case> caseIdToOldCase = (Map<Id,Case>)oldMap;
        Map<Id, Datetime> auctionIdToCloseDate = new Map<Id, Datetime>();
        List<Case> casesToUpdate = new List<Case>();
        Id arbrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();
        Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        
        
        for(Case caseRec : caseIdToNewCase.values()){
            if(caseRec.RecordTypeId == arbrecordTypeId &&
               caseRec.Status != caseIdToOldCase.get(caseRec.Id).Status &&
               (caseRec.Status.contains('Closed') || caseRec.Status.contains('Not Arbitration')) &&
               caseRec.Auction_Number__c != NULL &&
               caseRec.ClosedDate != NULL)
            {
                auctionIdToCloseDate.put(caseRec.Auction_Number__c ,caseRec.ClosedDate);
            }
        }
        if(!auctionIdToCloseDate.isEmpty()){
            for(Case tfCase : [Select Id,
                               Status,
                               Auction_Number__c,
                               Arb_Close_Date_for_Titles__c 
                               FROM Case 
                               WHERE RecordTypeId =: titleRecordTypeId 
                               AND Auction_Number__c IN :auctionIdToCloseDate.keySet()]
                
               ){
                   if(auctionIdToCloseDate.containsKey(tfCase.Auction_Number__c)){
                       tfCase.Arb_Close_Date_for_Titles__c = auctionIdToCloseDate.get(tfCase.Auction_Number__c);
                       casesToUpdate.add(tfCase);
                   }
               }
        }
        if(!casesToUpdate.isEmpty()){
            update casesToUpdate;
        }
    }
}