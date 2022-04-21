public class AssociatedLocationAddressGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<AssociatedLocation> newLocs = (List<AssociatedLocation>) objectList;
        
            for ( AssociatedLocation newLoc : newLocs ) {
                if (string.isBlank(newLoc.Organization_Address_Guid__c)) {
                    newLoc.Organization_Address_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
}