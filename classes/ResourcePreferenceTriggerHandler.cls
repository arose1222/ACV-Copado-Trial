/**
 * Created by zdeng on 9/24/2019.
 */

public with sharing class ResourcePreferenceTriggerHandler extends TriggerInterface {

    public override void beforeInsert(List<SObject> newList){
        updateParentWO((List<ResourcePreference>)newList);
    }

    private void updateParentWO(List<ResourcePreference> context){
        Set<Id> woIds = new Set<Id>();
        for (ResourcePreference rp : context){
            if (rp.PreferenceType != null && rp.PreferenceType == 'Required'){

                if (rp.RelatedRecordId != null && rp.RelatedRecordId.getSobjectType() == WorkOrder.getSObjectType()){
                    woIds.add(rp.RelatedRecordId);
                }
            }
        }

        List<WorkOrder> wos = [SELECT Has_Required_Resource__c, Id FROM WorkOrder WHERE Id IN :woIds];
        for (WorkOrder wo : wos){
            wo.Has_Required_Resource__c = true;
        }
        update wos;
    }

}