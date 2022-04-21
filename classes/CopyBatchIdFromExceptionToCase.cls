public class CopyBatchIdFromExceptionToCase extends TriggerInterface{
    
    public override void beforeUpdate(Map<Id, SObject> oldMap,Map<Id, SObject> newMap){
        Map<Id, Exception__c> newEMap = (Map<Id,Exception__c>)newMap;
        Map<Id, Exception__c> oldEMap = (Map<Id,Exception__c>)oldMap;
        List<Case> caseUpdateList = new List<Case>();

        for(Exception__c e :newEMap.values()){
            if(e.Related_Case__c != oldEMap.get(e.id).Related_Case__c && (e.Batch_Id__c != null || e.Images_Location__c != null)){
                if(e.Related_Case__c != null){
                    caseUpdateList.add(new Case(Id = e.Related_Case__c, Batch_Id__c = e.Batch_Id__c, Image_Location__c = e.Images_Location__c));
                }
                //handle someone screwing up and putting in the wrong case, then going back to correct it
                if(oldEMap.get(e.id).Related_Case__c != null){
                    caseUpdateList.add(new Case(Id = oldEMap.get(e.id).Related_Case__c, Batch_Id__c = null));
                }
            }
        }

        if(caseUpdateList.size() > 0){
            update caseUpdateList;
        }
    }

    /** beforeInsert
     *  Update the Batch Id of the Related Case if the Batch Id is present on the Exception
     */
    public override void beforeInsert(List<SObject> newList){
        List<Exception__c> excList = (List<Exception__c>)newList;
        List<Case> caseUpdateList = new List<Case>();

        for (Exception__c exc : excList) {
            if (exc.Related_Case__c != null && (exc.Batch_Id__c != null || exc.Images_Location__c != null)) {
                caseUpdateList.add(new Case(Id = exc.Related_Case__c, Batch_Id__c = exc.Batch_Id__c, Image_Location__c = exc.Images_Location__c));
            }
        }

        if (caseUpdateList.size() > 0) {
            update caseUpdateList;
        }
    }
}