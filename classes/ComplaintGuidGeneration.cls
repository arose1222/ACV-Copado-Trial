public class ComplaintGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
        
        List<Complaint__c> newComplaint = (List<Complaint__c>) objectList;
        Id arbrecordTypeId = Schema.SObjectType.Complaint__c.getRecordTypeInfosByName().get('Arbitration Complaint').getRecordTypeId();

            for ( Complaint__c newCom : newComplaint ) {
                //check for title and arbitration
                if (string.isBlank(newCom.Complaint_guid__c) && 
                    newCom.RecordTypeId == arbrecordTypeId) {
                    newCom.Complaint_guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Complaint__c> newComList = (List<Complaint__c>)newList;
        Id arbrecordTypeId = Schema.SObjectType.Complaint__c.getRecordTypeInfosByName().get('Arbitration Complaint').getRecordTypeId();
        
            for ( Complaint__c com : newComList ) {
                if (string.isBlank(Com.Complaint_guid__c) && 
                    com.RecordTypeId == arbrecordTypeId) {
                    com.Complaint_guid__c = ACVUtility.NewGuid();
                }
        }
    }
}