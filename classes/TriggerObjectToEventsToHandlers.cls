public without sharing class TriggerObjectToEventsToHandlers {
    private Map<String, TriggerEventsToTriggerHandlers> typeToEventHandlers;

    public TriggerObjectToEventsToHandlers() {
        typeToEventHandlers = new Map<String, TriggerEventsToTriggerHandlers>();
    }

    public void putAll(List<TriggerHandler__mdt> triggerHandlers) {
        for(TriggerHandler__mdt thisTriggerHandler : triggerHandlers) {
            TriggerEventsToTriggerHandlers theseTriggerHandlers = typeToEventHandlers.get(thisTriggerHandler.sObject__c);

            if(theseTriggerHandlers == null) {
                theseTriggerHandlers = new TriggerEventsToTriggerHandlers();

                typeToEventHandlers.put(thisTriggerHandler.sObject__c, theseTriggerHandlers);
            }

            theseTriggerHandlers.put(thisTriggerHandler);
        }
    }

    public TriggerEventsToTriggerHandlers get(String sObjectName) {
        return typeToEventHandlers.get(sObjectName);
    }
}