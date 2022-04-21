public class TimeSheetEntryFieldsTriggerHandler  extends TriggerInterface{
    override public void beforeInsert(List<SObject> newList){
        List<TimeSheetEntry> tseNewList = (List<TimeSheetEntry>)newList;
        updateAccountFromWorkOrder(tseNewList);
        //add Account if work order exists
    }
    override public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        Map<Id, TimeSheetEntry> tseNewMap = (Map<Id, TimeSheetEntry>)newMap;
        Map<Id, TimeSheetEntry> tseOldMap = (Map<Id, TimeSheetEntry>)oldMap;
        //add account if it is missing or if work order changed and work order exists
        List<TimeSheetEntry> tseUpdateList = new List<TimeSheetEntry>();
        for(TimeSheetEntry tse : tseNewMap.values()){
            if(tse.Work_Order__c != null && (tseOldMap.get(tse.id).Work_Order__c == null || tse.Work_Order__c != tseOldMap.get(tse.id).Work_Order__c)){
                tseUpdateList.add(tse);
            }
        }
        updateAccountFromWorkOrder(tseUpdateList);
    }

    public List<TimeSheetEntry> updateAccountFromWorkOrder(List<TimeSheetEntry> tseList){
        Set<Id> workOrderIdSet = new Set<Id>();
        for(TimeSheetEntry tse : tseList){
            workOrderIdSet.add(tse?.Work_Order__c	);
        }
        workOrderIdSet.remove(null);

        List<TimeSheetEntry> tseUpdateList = new List<TimeSheetEntry>();

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT Id, AccountId FROM WorkOrder WHERE id in : workOrderIdSet AND AccountId != null]);
        for(TimeSheetEntry tse : tseList){
            if(woMap.containsKey(tse?.Work_Order__c)){
                system.debug('tse account update');
                tse.Account__c = woMap.get(tse.Work_Order__c).AccountId;
                tseUpdateList.add(tse);
            }
        }
        return tseUpdateList;
    }

}