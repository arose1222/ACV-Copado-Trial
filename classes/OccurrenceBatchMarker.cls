public with sharing class OccurrenceBatchMarker extends TriggerInterface{

    // private final static List<String> OCCURRENCE_CLEANUP_FIELDS = new List<String> {'Start_Time__c', 'Day__c', 'End_Time__c', 'Is_Active__c', 'Week_Number__c', 'Every__c'};

    // public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
    //     Map<Id, Occurrence__c> oldOccurrences = (Map<Id, Occurrence__c>)oldMap;
    //     Map<Id, Occurrence__c> newOccurrences = (Map<Id, Occurrence__c>)newMap;
    //     markCleanup(newOccurrences, oldOccurrences);
    // }

    // private void markCleanup(Map<Id,Occurrence__c> newOccurrences, Map<Id,Occurrence__c> oldOccurrences){
    //     Occurrence__c oldOcc;

    //     for(Occurrence__c newOcc : newOccurrences.values()){
    //         if(oldOccurrences.get(newOcc.id) != null){
    //             oldOcc = oldOccurrences.get(newOcc.id);

    //             for(String field : OCCURRENCE_CLEANUP_FIELDS){
    //                 if(newOcc.get(field) != oldOcc.get(field)){
    //                         newOcc.Cleanup_Marker__c = true;
    //                         break;
    //                 }
    //             }
    //         }
    //     }
    // }
}