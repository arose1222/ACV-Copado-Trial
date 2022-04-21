public without sharing class TriggerFrameWork {

    public class ClassNotFoundException extends Exception {}
    public class TriggerException extends Exception {}

    @TestVisible
    private static List<TriggerHandler__mdt> mockMetadata;

    private TriggerEventsToTriggerHandlers theseEventsToTriggerHandlers;
    private static TriggerObjectToEventsToHandlers sObjectNameToEventsToTriggerHandlers =
            new TriggerObjectToEventsToHandlers();

    public TriggerFrameWork() {
        if(Trigger.new != null) {
            init(Trigger.new.getSObjectType());
        } else {
            init(Trigger.old.getSObjectType());
        }
    }

    public TriggerFrameWork(sObjectType objectType) {
        init(objectType);
    }

    public void init(sObjectType objectType) {
        String sObjectName = objectType.getDescribe().getName();

        theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(sObjectName);

        if(theseEventsToTriggerHandlers == null) {
            if(Test.isRunningTest() && mockMetadata != null) {
                sObjectNameToEventsToTriggerHandlers.putAll(mockMetadata);
            } else {
                sObjectNameToEventsToTriggerHandlers.putAll(
                [SELECT DeveloperName, NamespacePrefix, sObject__c, Class_Name__c, Order__c, Before_Insert__c, Before_Update__c, Before_Delete__c, Before_Undelete__c,
                After_Insert__c, After_Update__c, After_Delete__c, After_Undelete__c
                FROM TriggerHandler__mdt
                WHERE sObject__c = :sObjectName AND Active__c = true
                ORDER BY Order__c ASC]);
            }
            theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(objectType.getDescribe().getName());
        }
    }

    public static String triggerFlagsToString(boolean isBefore, boolean isUpdate, boolean isInsert, boolean isDelete, boolean isUndelete) {
        String returnVal = isBefore ? 'Before' : 'After';

        if(isInsert) {
            returnVal += 'Insert';
        } else if(isUpdate) {
            returnVal += 'Update';
        } else if(isDelete) {
            returnVal += 'Delete';
        } else {
            returnVal += 'Undelete';
        }

        return returnVal;
    }

    public void handle() {
        handle(Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete, Trigger.isUndelete, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    public void handle(boolean isBefore, boolean isUpdate, boolean isInsert, boolean isDelete, boolean isUndelete, List<sObject> oldList, List<sObject> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
        if(theseEventsToTriggerHandlers == null) {
            return;
        }
        String eventString = triggerFlagsToString(isBefore, isUpdate, isInsert, isDelete, isUndelete);
        List<TriggerHandler__mdt> theseTriggerHandlers = theseEventsToTriggerHandlers.getTriggerHandlers(eventString);

        if(theseTriggerHandlers == null) {
            return;
        }

        for(TriggerHandler__mdt thisTriggerHandler : theseTriggerHandlers) {
            Type handlerType = Type.forName(thisTriggerHandler.NamespacePrefix, thisTriggerHandler.Class_Name__c);
            try {         
                if(handlerType == null) {
                    throw new ClassNotFoundException('TriggerFrameWork: handler class not found for ' + thisTriggerHandler);
                } else {
                    if(isBefore) {
                        if(isUpdate) {
                            ((TriggerInterface)handlerType.newInstance()).beforeUpdate(oldList, newList);
                            ((TriggerInterface)handlerType.newInstance()).beforeUpdate(oldMap, newMap);
                        } else if(isInsert) {
                            ((TriggerInterface)handlerType.newInstance()).beforeInsert(newList);
                        } else if(isDelete) {
                            ((TriggerInterface)handlerType.newInstance()).beforeDelete(oldList);
                            ((TriggerInterface)handlerType.newInstance()).beforeDelete(oldMap);
                        } else if(isUndelete) {
                            ((TriggerInterface)handlerType.newInstance()).beforeUndelete(newList);
                            ((TriggerInterface)handlerType.newInstance()).beforeUndelete(newMap);
                        }
                    } else {
                        if(isUpdate) {
                            ((TriggerInterface)handlerType.newInstance()).afterUpdate(oldList, newList);
                            ((TriggerInterface)handlerType.newInstance()).afterUpdate(oldMap, newMap);
                        } else if(isInsert) {
                            ((TriggerInterface)handlerType.newInstance()).afterInsert(newList);
                            ((TriggerInterface)handlerType.newInstance()).afterInsert(newMap);
                        } else if(isDelete) {
                            ((TriggerInterface)handlerType.newInstance()).afterDelete(oldList);
                            ((TriggerInterface)handlerType.newInstance()).afterDelete(oldMap);
                        } else if(isUndelete) {
                            ((TriggerInterface)handlerType.newInstance()).afterUndelete(newList);
                            ((TriggerInterface)handlerType.newInstance()).afterUndelete(newMap);
                        }
                    }
                }
            } catch ( exception e ) {
                try {
                    String objectType;
                    if ( !newList.isEmpty() ) {
                        objectType = String.valueOf( newList[0].Id.getSobjectType() );
                    } else {
                        objectType = String.valueOf( oldList[0].Id.getSobjectType() );
                    }

                    EventBus.publish( new List<Trigger_Event__e>{ new Trigger_Event__e(
                        Message__c = e.getMessage(),
                        Version__c = 'v1',
                        Location__c = e.getStackTraceString().split( '\n' )[0],
                        Stack_Trace__c = e.getStackTraceString(),
                        SF_Record_Id__c = UserInfo.getUserId(),
                        Component_Name__c = thisTriggerHandler.Class_Name__c,
                        SF_Object__c = objectType
                    ) } );

                } catch ( exception ex ) {
                    // If a log fails, don't do anything - Logging framework handles errors already within
                }

                // Ensure Error is thrown to top level        
                throw new TriggerException( e.getMessage() );
            }
        }
    }
}