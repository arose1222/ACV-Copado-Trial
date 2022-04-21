public class ChangedOccurenceRecord extends TriggerInterface {
    // public override void beforeUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
    //     for ( Occurrence__c occurRec : (List<Occurrence__c>) newMap.values() ) {
    //         Occurrence__c oldOccurRec = (Occurrence__c) oldMap.get( occurRec.Id );
    //         if ( occurRec.Day__c != oldOccurRec.Day__c ||
    //             occurRec.Start_Time__c != oldOccurRec.Start_Time__c ||
    //             occurRec.End_Time__c != oldOccurRec.End_Time__c ) {
    //                 occurRec.Cleanup_Marker__c = TRUE;
    //         }
    //     }
    // }
}