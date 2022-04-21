public class ConditionReportReviewCompletedECont {

    //public List<ContentDistribution> relatedData {get;set;}
    public set<id> distroIdSet = new set<id>();
    public Id parentId {get;set;}

    public ConditionReportReviewCompletedECont() {
        
    }

    public List<ContentDistribution> getRelatedData(){
        runContentDocLogic();
        List<ContentDistribution> returnList = [Select Id, ContentDownloadUrl from ContentDistribution where ContentVersionId in :distroIdSet];
        return returnlist;
    }

    public void runContentDocLogic(){
        list<id> testList = new List<id>();
        List<ContentDistribution> newLinkList = new List<ContentDistribution>();
        Map<Id, ContentDocumentLink> linkMap = new Map<Id, ContentDocumentLink>();
        if(parentId != null){
            for(ContentDocumentLink cdl :[select ContentDocumentId,ContentDocument.Title from contentdocumentlink where LinkedEntityId = :parentId]){
                linkMap.put(cdl.ContentDocumentId,cdl);
            }
            if(linkMap.keyset().size()>0){
                for(ContentVersion cv :[SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :linkMap.keySet() AND IsLatest = true]){
                    distroIdSet.add(cv.id);
                }
            }
        }
    }
}