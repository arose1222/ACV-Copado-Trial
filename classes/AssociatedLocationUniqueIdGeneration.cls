public class AssociatedLocationUniqueIdGeneration extends TriggerInterface {

    @TestVisible Private Static Boolean throwError = false;

    public override void afterInsert(List<sObject> objectList) {
    
        List<AssociatedLocation> newAssociatedLocations = (List<AssociatedLocation>) objectList;
        Map<id, String> idMap = new Map<id, String>();
        List<AssociatedLocation> updateList = new List<AssociatedLocation>();
        for(AssociatedLocation newAssLocs : newAssociatedLocations){
            idMap.put(newAssLocs.id, newAssLocs.Auto_Inc_Id__c);
        }
        List<AssociatedLocation> assLocLst = new List<AssociatedLocation>([Select id, Auto_Inc_Id__c, Organization_Address_Id__c
        From AssociatedLocation Where id IN: newAssociatedLocations]);

            for ( AssociatedLocation newAssLoc : assLocLst ) {
                if (newAssLoc.Organization_Address_Id__c == null) {
                    newAssLoc.Organization_Address_Id__c = integer.valueof(idMap.get(newAssLoc.id));
                    updateList.add(newAssLoc);
                }
            }
            try{
                if(!updateList.isempty()){
                    if(throwError) Decimal i = 1/0;
                    update updateList;
                }
            }
            catch(Exception e){
                IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                    'AssociatedLocationUniqueIdGeneration: Get AssociatedLocation Id failure: '+e.getStackTraceString(), 
                    SplunkHelper.LOGLEVEL.ERROR, 'AssociatedLocationUniqueIdGeneration', 
                    e.getMessage(), 
                    'AssociatedLocation');
                throw new CustomException(e);

            }
    }
}