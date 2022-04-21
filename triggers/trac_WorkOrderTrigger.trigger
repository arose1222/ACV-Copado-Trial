/**
 * @description Work Order Trigger, Updated By Bill Sutton on 2/23/2021
 * @author Isaiah Cummins, Traction on Demand
 * @date 9/16/2019
 */

trigger trac_WorkOrderTrigger on WorkOrder (before insert, before update, before delete, after insert, after update, after delete, after undelete )
{
    (new TriggerFrameWork()).handle();
}