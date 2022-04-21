public class RevolvingAppointmentOwnerHandler extends TriggerInterface {



    public override void beforeInsert(List<SObject> newList){
        List<Timeline__c> revAppList = (List<Timeline__c>)newList;
        system.debug(revAppList[0]);
        revAppList = makeResourceOwner(revAppList);
        system.debug(revAppList[0]);

    }

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){

        Map<Id, Timeline__c> newRevAppMap = (Map<Id, Timeline__c>) newMap;
        Map<Id, Timeline__c> oldRevAppMap = (Map<Id, Timeline__c>) oldMap;
        
        List<Timeline__c> revAppOwnerUpdateList = makeNewResourceOwner(newRevAppMap, oldRevAppMap);

    }

    public static List<Timeline__c> makeNewResourceOwner(Map<Id, Timeline__c> newMap, Map<Id, Timeline__c> oldMap){

        List<Timeline__c> revAppOwnerUpdateList = new List<Timeline__c>();

        for(Timeline__c revApp : newMap.values()){
            if(revApp.Service_Resource__c != null){
                if (revApp.Service_Resource__c != oldMap.get(revApp.Id).Service_Resource__c){
                    revAppOwnerUpdateList.add(revApp);
                }
            }
        }

        return makeResourceOwner(revAppOwnerUpdateList);

    }

    public static List<Timeline__c> makeResourceOwner(List<Timeline__c> revAppList){
        Set<Id> srSet = new Set<Id>();
        for(Timeline__c revApp : revAppList){
            srSet.add(revApp.Service_Resource__c);
        }

        Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE id in : srSet]);

        for(Timeline__c revApp : revAppList){
            if(revApp.Service_Resource__c != null){
                if(srMap.get(revApp.Service_Resource__c).RelatedRecordId != null){
                    revApp.ownerId = srMap.get(revApp.Service_Resource__c).RelatedRecordId;
                }
            }

        }

        return revAppList;
    }

// 
}