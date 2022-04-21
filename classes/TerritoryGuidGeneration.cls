public class TerritoryGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<maps__ShapeLayer__c> newShapeGeos = (List<maps__ShapeLayer__c>) objectList;
        
            for ( maps__ShapeLayer__c newRec : newShapeGeos ) {
                if (string.isBlank(newRec.Territory_Guid__c )) {
                        newRec.Territory_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<maps__ShapeLayer__c> newShapeList = (List<maps__ShapeLayer__c>)newlist;
            for ( maps__ShapeLayer__c newRec : newShapeList ) {
                if (string.isBlank(newRec.Territory_Guid__c)) {
                    newRec.Territory_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
}