trigger Inventory_Life_Cycle_Trigger on Inventory_Life_Cycle__c (before insert, after update) {
    (new TriggerFrameWork()).handle();
}