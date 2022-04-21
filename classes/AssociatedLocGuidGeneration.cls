public class AssociatedLocGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<AssociatedLocation> newLocs = (List<AssociatedLocation>) objectList;
        
            for ( AssociatedLocation newLoc : newLocs ) {
                if (string.isBlank(newLoc.Associated_Location_Guid__c)) {
                    newLoc.Associated_Location_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<AssociatedLocation> newLocs = (List<AssociatedLocation>) newlist;

            for ( AssociatedLocation newLoc : newLocs ) {
                if (string.isBlank(newLoc.Associated_Location_Guid__c)) {
                    newLoc.Associated_Location_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
}