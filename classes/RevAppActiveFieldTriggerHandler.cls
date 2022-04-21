public class RevAppActiveFieldTriggerHandler extends TriggerInterface{

    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        Map<Id, Timeline__c> newTimelineMap = (Map<Id, Timeline__c>) newMap;
        Map<Id, Timeline__c> oldTimelineMap = (Map<Id, Timeline__c>) oldMap;

        Map<Id, Timeline__c> deactivatedTimelines = new Map<Id, Timeline__c>();

        for(Id tlId : newTimelineMap.keyset()){
            if(newTimelineMap.get(tlId).Is_Active__c == false && oldTimelineMap.get(tlId).Is_Active__c != false){
                deactivatedTimelines.put(tlId, newTimelineMap.get(tlId));
            }
        }
        if(deactivatedTimelines.size() > 0){
            deactivateChildOccurrences(deactivatedTimelines);
        }
    }



    public void deactivateChildOccurrences(Map<Id, timeline__c> timelines){
        Map<Id, Occurrence__c> occMap = new Map<Id, Occurrence__c>([SELECT id, Is_Active__c, Timeline__c FROM Occurrence__c WHERE Timeline__c in : timelines.keyset()]);
        for (Occurrence__c occ : occMap.values()){
            occ.Is_Active__c = false;
        }
        update occMap.values();
    }
}