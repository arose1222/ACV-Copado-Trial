/**
 * Standard Trigger to call TriggerFramework on Map (FSL) Polygon
 * @author Gerald McEvoy
 * @since 3/3/21
 * @group Triggers
 */
trigger ServiceTerritoryTrigger on ServiceTerritory ( before update, before insert, after insert, after update, before delete, after undelete ) {
    (new TriggerFrameWork()).handle();
}