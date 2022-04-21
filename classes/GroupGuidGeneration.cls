public class GroupGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Group__c> newGroups = (List<Group__c>) objectList;
        
            for ( Group__c newGrp : newGroups ) {
                if (string.isBlank(newGrp.Group_Guid__c )) {
                        newGrp.Group_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Group__c> newGrpList = (List<Group__c>)newlist;
        
            for ( Group__c newGrup : newGrpList ) {
                if (string.isBlank(newGrup.Group_Guid__c)) {
                    newGrup.Group_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
}