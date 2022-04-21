public class DealerDocAttachmentAdded extends TriggerInterface{
    
    public override void afterInsert(List<sObject> inputList){
        updateDealerDocWhenFileAttached((List<ContentDocumentLink>)inputList);
    }

    public override void afterUpdate(List<sObject> inputListOld, List<sObject> inputListNew){
        updateDealerDocWhenFileAttached((List<ContentDocumentLink>)inputListNew);
    }

    public override void afterDelete(List<sObject> inputList){
        updateDealerDocWhenFileDeleted((List<ContentDocumentLink>)inputList);
    }

    public void updateDealerDocWhenFileDeleted(List<ContentDocumentLink> inboundLinks){
        Map<ID,Dealer_Docs__c> updateList = new Map<ID,Dealer_Docs__c>();
        Set<Id> cdlIdSet = new Set<ID>();
        for(ContentDocumentLink cdl: inboundLinks){
            cdlIdSet.add(cdl.id);
            if(cdl.LinkedEntityId.getSobjectType() == Schema.Dealer_Docs__c.sObjectType){
                updateList.put(cdl.LinkedEntityId, new Dealer_Docs__c(Id = cdl.LinkedEntityId, File_Attached__c = FALSE));
            }
        }
        for(ContentDocumentLink cdl :[Select id, LinkedEntityId From ContentDocumentLink where LinkedEntityId in :updateList.keySet() AND ID NOT IN :cdlIdSet]){
            if(updateList.keySet().contains(cdl.LinkedEntityId)){
                updateList.remove(cdl.LinkedEntityId);
            }
        }
        if(updateList.size() > 0){
            update updateList.values();
        }   
    }

    public void updateDealerDocWhenFileAttached(List<ContentDocumentLink> inboundLinks){
       Map<ID,Dealer_Docs__c> updateList = new Map<ID,Dealer_Docs__c>();
        for(ContentDocumentLink cdl: inboundLinks){
            if(cdl.LinkedEntityId.getSobjectType() == Schema.Dealer_Docs__c.sObjectType){
                updateList.put(cdl.LinkedEntityId, new Dealer_Docs__c(Id = cdl.LinkedEntityId, File_Attached__c = TRUE));
            }
        }
        if(updateList.size() > 0){
            update updateList.values();
        }     
    }
}