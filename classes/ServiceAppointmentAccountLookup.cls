public class ServiceAppointmentAccountLookup extends TriggerInterface {
    public override void beforeInsert(List<SObject> newMap) {
        List<ServiceAppointment> saList = (List<ServiceAppointment>)newMap;
        Set<Id> woSet = new SEt<Id>();
        for (ServiceAppointment sa : saList){
            if(sa.ParentRecordId != null){
                woSet.add(sa.ParentRecordId);
            }
        }

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT AccountId FROM WorkORder WHERE id in :woSEt]);
        for(ServiceAppointment sa : saList){
            if(sa.AccountId != null){
                sa.Account__c = sa.AccountId;
            }
            else if (sa.Work_Order__r.AccountId != null){
                sa.Account__c = sa.Work_Order__r.AccountId;
            }
            else if (sa.ParentRecordId != null && woMap.get(sa.ParentRecordId) != null && woMap.get(sa.ParentRecordId).AccountID != null){
                sa.Account__c = woMap.get(sa.ParentRecordId).AccountId;
            }
        }
        
    }
}