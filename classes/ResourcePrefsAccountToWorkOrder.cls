public class ResourcePrefsAccountToWorkOrder extends TriggerInterface {

    List<String> statusAllowedList = new List<String> { 'New', 'Offer Attempted', 'Scheduled', 'Dispatched' };

    public override void afterInsert( List<SObject> newList ) {

        List<ResourcePreference> resPrefToSyncList = getResPrefsToSync(newList);

        if(resPrefToSyncList.size() > 0){
            upsert resPrefToSyncList;
        }
    }


    public override void afterUpdate(List<SObject> oldList, List<SObject> newList){

        List<ResourcePreference> resPrefToSyncList = getResPrefsToSync(newList, oldList);

        if(resPrefToSyncList.size() > 0){
            upsert resPrefToSyncList;
        }
    }


    public override void afterDelete(List<SObject> oldList){

        List<ResourcePreference> resPrefToSyncList = getResPrefsToSync(oldList);

        if(resPrefToSyncList.size() > 0){
            delete resPrefToSyncList;
        }
    }

    public List<ResourcePreference> getResPrefsToSync(List<SObject> newResourcePrefList, List<SObject> oldResourcePrefList){

        Map<Id,ResourcePreference> accountIdNewResPrefMap = new Map<Id,ResourcePreference>();
        for ( ResourcePreference newResPrefRec : (List<ResourcePreference>) newResourcePrefList ) {
            if ( newResPrefRec.RelatedRecordId != null && newResPrefRec.RelatedRecordId.getSObjectType() == Schema.Account.SObjectType ) {
                accountIdNewResPrefMap.put(newResPrefRec.RelatedRecordId, newResPrefRec);
            }
        }

        Map<Id,ResourcePreference> accountIdOldResPrefMap = new Map<Id,ResourcePreference>();
        for ( ResourcePreference oldResPrefRec : (List<ResourcePreference>) oldResourcePrefList ) {
            if ( oldResPrefRec.RelatedRecordId != null && oldResPrefRec.RelatedRecordId.getSObjectType() == Schema.Account.SObjectType ) {
                accountIdOldResPrefMap.put(oldResPrefRec.RelatedRecordId, oldResPrefRec);
            }
        }

        List<ResourcePreference> resourcePrefToSyncList = new List<ResourcePreference>();

        for(WorkOrder wo : [SELECT Id,
                                   Status,
                                   AccountId,
                                   Occurrence__c,
                                   (SELECT Id, RelatedRecordId, PreferenceType, ServiceResourceId FROM ResourcePreferences)
                            FROM WorkOrder
                            WHERE AccountId IN :accountIdNewResPrefMap.keySet()
                                AND Id IN (SELECT Work_Order__c FROM ServiceAppointment WHERE Account__c IN :accountIdNewResPrefMap.keySet() AND Status IN :statusAllowedList)])
        {
            if(wo.Occurrence__c == null
                || (wo.Occurrence__c != null && (accountIdNewResPrefMap.get(wo.AccountId).PreferenceType == 'Excluded'
                    || (accountIdOldResPrefMap.containsKey(wo.AccountId) && accountIdOldResPrefMap.get(wo.AccountId).PreferenceType == 'Excluded'))))
            {
                Boolean foundExistingResourcePref = false;
                for(ResourcePreference existingResPref : wo.ResourcePreferences){
                    if(existingResPref.ServiceResourceId == accountIdNewResPrefMap.get(wo.AccountId).ServiceResourceId){
                        existingResPref.PreferenceType = accountIdNewResPrefMap.get(wo.AccountId).PreferenceType;
                        resourcePrefToSyncList.add(existingResPref);
                        foundExistingResourcePref = true;
                    }
                }

                if(!foundExistingResourcePref && !Trigger.IsDelete){
                    ResourcePreference resourcePref = new ResourcePreference(
                        RelatedRecordId = wo.Id,
                        PreferenceType = accountIdNewResPrefMap.get(wo.AccountId).PreferenceType,
                        ServiceResourceId = accountIdNewResPrefMap.get(wo.AccountId).ServiceResourceId
                        );
                        resourcePrefToSyncList.add(resourcePref);
                }
            }

        }
        return resourcePrefToSyncList;

    }

    public List<ResourcePreference> getResPrefsToSync(List<SObject> newResourcePrefList){
        return getResPrefsToSync(newResourcePrefList, new List<SObject>());
    }

}