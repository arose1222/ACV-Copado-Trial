public class PreventWOLIFieldUpdates extends TriggerInterface {

    public static Boolean skipTrigger = false;

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        if(!skipTrigger) {
            ACVUtility.identifyAndFlagChangedFields( newMap, oldMap, 'WorkOrderLineItem' );
        }
    }
}