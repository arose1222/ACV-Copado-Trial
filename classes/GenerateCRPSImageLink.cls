public without sharing class GenerateCRPSImageLink  extends TriggerInterface{
    
    
    public override void afterInsert(List<sObject> inputList){
        List<ContentDocumentLink> inboundLinks = (List<ContentDocumentLink>)inputList;
        List<ContentDistribution> newLinkList = new List<ContentDistribution>();
        Map<Id, ContentDocumentLink> linkMap = new Map<Id, ContentDocumentLink>();
        for(ContentDocumentLink cdl: inboundLinks){
            if(cdl.LinkedEntityId.getSobjectType() == Schema.Condition_Report_Prescreen__c.sObjectType){
                linkMap.put(cdl.ContentDocumentId,cdl);
            }
        }
        if(linkMap.keyset().size()>0){
            for(ContentVersion cv :[SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :linkMap.keySet() AND IsLatest = true]){
                ContentDistribution cd = new ContentDistribution();
                cd.ContentVersionId = cv.id;
                cd.name = 'CRR Image Id: '+linkMap.get(cv.ContentDocumentId).id;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                //cd.ExpiryDate = System.now().addHours(2);
                newLinkList.add(cd);
            }
        }
        if(newLinkList.size() > 0){
            insert newLinkList;
        }   
    }
}