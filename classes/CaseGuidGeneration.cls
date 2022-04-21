public class CaseGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Case> newCase = (List<Case>) objectList;
        Id arbrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        
            for ( Case newRec : newCase ) {
                if (string.isBlank(newRec.Case_guid__c ) && 
                    (newrec.RecordTypeId == arbrecordTypeId || 
                    newrec.RecordTypeId == titlerecordTypeId)) {
                        newRec.Case_guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Case> newCaseList = (List<Case>)newlist;
        Id arbrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        
            for ( Case newCase : newCaseList ) {
                if (string.isBlank(newCase.Case_guid__c) && 
                    (newCase.RecordTypeId == arbrecordTypeId || 
                    newCase.RecordTypeId == titlerecordTypeId)) {
                    newCase.Case_guid__c = ACVUtility.NewGuid();
                }
            }
    }
}