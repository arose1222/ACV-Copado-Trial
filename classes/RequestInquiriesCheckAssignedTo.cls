public without sharing class RequestInquiriesCheckAssignedTo extends TriggerInterface {
    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {

        List<Salesforce_Request__c> oldReqInq = (List<Salesforce_Request__c>)oldList;
        List<Salesforce_Request__c> newReqInq = (List<Salesforce_Request__c>)newList;

        Map<Id, Salesforce_Request__c> oldMap = new Map<Id, Salesforce_Request__c>();

        // Get the old version of the current record
        for (Salesforce_Request__c osr : oldReqInq) {
            //creating a map
            oldMap.put(osr.Id, osr);
        }

        Id recordTypeId = Schema.SObjectType.Salesforce_Request__c.getRecordTypeInfosByDeveloperName().get('Ops_Help').getRecordTypeId();

        for (Salesforce_Request__c nsr : newReqInq) {
        
            // Did the Assigned To field get updated
            if (oldMap.get(nsr.Id).Assigned_To__c != nsr.Assigned_To__c && oldMap.get(nsr.Id).Assigned_To__c != null && nsr.RecordTypeId == recordTypeId && nsr.My_Request_Is_Related_To__c == 'Re-Run, Pricing or Trim') {

                // Check if the Assigned To Flag is False
                if(oldMap.get(nsr.Id).Assigned_To_Flag__c == false) {
                    // Set the Assigned To Flag to True
                    nsr.Assigned_To_Flag__c = true;
                } else {
                    // If the Assigned To Field was updated AND the Assigned To Flag is already True, then send an Error Message
                    nsr.addError('Assigned To field was modified during your edit session.  Refresh your page.');
                }
            }
        }
    }
}