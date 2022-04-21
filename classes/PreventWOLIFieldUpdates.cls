public class PreventWOLIFieldUpdates extends TriggerInterface {

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        ACVUtility.identifyAndFlagChangedFields( newMap, oldMap, 'WorkOrderLineItem' );
    }
}