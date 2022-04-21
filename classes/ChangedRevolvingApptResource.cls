public class ChangedRevolvingApptResource extends TriggerInterface {
    // public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
    //     Set<Id> revolApptIdSet = new Set<Id>();
    //     for ( Timeline__c revolvingAppt : (List<Timeline__c>) newMap.values() ) {
    //         Timeline__c oldRevAppt = (Timeline__c) oldMap.get( revolvingAppt.Id );
    //         if ( revolvingAppt.Service_Resource__c != oldRevAppt.Service_Resource__c ) {
    //                 revolApptIdSet.add( revolvingAppt.Id );
    //         }
    //     }

    //     if ( !revolApptIdSet.isEmpty() ) {
    //         List<Occurrence__c> updateOccurrenceLst = [ SELECT Id FROM Occurrence__c WHERE Timeline__c IN :revolApptIdSet ];
    //         for ( Occurrence__c occurRec : updateOccurrenceLst ) {
    //             occurRec.Cleanup_Marker__c = TRUE;
    //         }

    //         if ( updateOccurrenceLst != null && !updateOccurrenceLst.isEmpty() ) {
    //             update updateOccurrenceLst;
    //         }
    //     }
    // }
}