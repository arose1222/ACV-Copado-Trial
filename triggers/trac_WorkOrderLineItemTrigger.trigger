/**
 * Created by icummins on 9/19/2019.
 */

trigger trac_WorkOrderLineItemTrigger on WorkOrderLineItem (after insert, after delete) {
        if (Trigger.isAfter && Trigger.isInsert) {
            //if ( isBeta( Trigger.new ) ) {
                trac_WorkOrderLineItemHandler.filterAndUpdateRollupDurations(Trigger.new);
            //}
        }
        if (Trigger.isAfter && Trigger.isDelete) {
            //if ( isBeta( Trigger.old ) ) {
                trac_WorkOrderLineItemHandler.filterAndUpdateRollupDurations(Trigger.old);
            //}
        }
    }