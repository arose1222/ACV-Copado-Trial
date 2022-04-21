public class TimelineBatchMarker extends TriggerInterface{
    // private final static List<String> TIMELINE_CLEANUP_FIELDS = new List<String> {'Is_Active__c', 'Service_Resource__c', 'Average_Number_Cars__c', 'End_Date__c', 'Start_Date__c', 'Work_Type__c'};


    // public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
    //     Map<id, Timeline__c> newTimelines = (Map<Id, Timeline__c>)newMap;
    //     Map<id, Timeline__c> oldTimelines = (Map<Id, Timeline__c>)oldMap;
    //     markCleanup(newTimelines, oldTimelines);
    // }

    // private void markCleanup(Map<Id,Timeline__c> newTimelines, Map<Id,Timeline__c> oldTimelines){
    //     List<Id> timelinesToUpdate = new List<Id>();

    //     for(Timeline__c newTimeline : newTimelines.values()){
    //         if(oldTimelines.get(newTimeline.id) != null){
    //             Timeline__c oldTimeline = oldTimelines.get(newTimeline.id);

    //             for(String field : TIMELINE_CLEANUP_FIELDS){
    //                 if(newTimeline.get(field) != oldTimeline.get(field)){
    //                         timelinesToUpdate.add(newTimeline.id);
    //                         break;
    //                 }
    //             }
    //         }
    //     }

    //     //grab all children of marked timelines, flag them for cleanup, and update
    //     List<Occurrence__c> occsToUpdate = new List<Occurrence__c>();
    //     for(Occurrence__c occ : [SELECT Id FROM Occurrence__c WHERE Is_Active__c = true AND Timeline__c in : timelinesToUpdate ]){
    //         occ.Cleanup_Marker__c = true;
    //         occsToUpdate.add(occ);
    //     }
    //     Database.update(occsToUpdate, false);
    // }
}