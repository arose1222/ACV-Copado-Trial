public without sharing class TriggerEventsToTriggerHandlers {
    private Map<String, List<TriggerHandler__mdt>> triggerEventsToTriggerHandlers;

    public TriggerEventsToTriggerHandlers() {
        triggerEventsToTriggerHandlers = new Map<String, List<TriggerHandler__mdt>>();
    }
    public void addToContext(Map<String,List<TriggerHandler__mdt>> triggerEventsToTriggerHandlers, String context, TriggerHandler__mdt th){
        if(triggerEventsToTriggerHandlers.get(context) == null){
            triggerEventsToTriggerHandlers.put(context, new List<TriggerHandler__mdt>());
        }
        triggerEventsToTriggerHandlers.get(context).add(th);
    }
    public void put(TriggerHandler__mdt thisTriggerHandler) {
        if(thisTriggerHandler.Before_Insert__c){
            addToContext(triggerEventsToTriggerHandlers,'BeforeInsert', thisTriggerHandler); 
        }
        if(thisTriggerHandler.Before_Update__c){
            addToContext(triggerEventsToTriggerHandlers,'BeforeUpdate', thisTriggerHandler); 
        }
        if(thisTriggerHandler.Before_Delete__c){
            addToContext(triggerEventsToTriggerHandlers,'BeforeDelete', thisTriggerHandler); 
        }
        if(thisTriggerHandler.Before_Undelete__c){
            addToContext(triggerEventsToTriggerHandlers,'BeforeUndelete', thisTriggerHandler); 
        }
        if(thisTriggerHandler.After_Insert__c){
            addToContext(triggerEventsToTriggerHandlers,'AfterInsert', thisTriggerHandler);  
        }
        if(thisTriggerHandler.After_Update__c){
            addToContext(triggerEventsToTriggerHandlers,'AfterUpdate', thisTriggerHandler); 
        }
        if(thisTriggerHandler.After_Delete__c){
            addToContext(triggerEventsToTriggerHandlers,'AfterDelete', thisTriggerHandler); 
        }
        if(thisTriggerHandler.After_Undelete__c){
            addToContext(triggerEventsToTriggerHandlers,'AfterUndelete', thisTriggerHandler); 
        }
        system.debug(thisTriggerHandler);
    }

    public List<TriggerHandler__mdt> getTriggerHandlers(String event) {
        return triggerEventsToTriggerHandlers.get(event);
    }
}