public class ResolutionGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Resolution__c> newResolutions = (List<Resolution__c>) objectList;
        
            for ( Resolution__c newRec : newResolutions ) {
                if (string.isBlank(newRec.Resolution_guid__c )) {
                        newRec.Resolution_guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Resolution__c> newResList = (List<Resolution__c>)newlist;
        
            for ( Resolution__c newRes : newResList ) {
                if (string.isBlank(newRes.Resolution_guid__c)) {
                    newRes.Resolution_guid__c = ACVUtility.NewGuid();
                }
            }
    }
}