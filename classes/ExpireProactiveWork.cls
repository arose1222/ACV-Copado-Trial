public class ExpireProactiveWork extends TriggerInterface {
    public override void afterInsert( Map<Id, SObject> newMap ) {

        List<Id> accountIdList = new List<Id>();
        List<String> statusToExpireList = new List<String>{'New', 'Scheduled', 'Dispatched'};

        List<Id> nonASIWTIdList = new List<Id>();
        for(WorkTypeGroupMember nonASIWorkType : [SELECT Id, WorkTypeId FROM WorkTypeGroupMember WHERE WorkTypeGroup.Work_Type_Group_Unique_ID__c = 'nonasi']){
            nonASIWTIdList.add(nonASIWorkType.WorkTypeId);
        }

        for(WorkOrder workOrderRec : (List<WorkOrder>) newMap.values()){
            if(nonASIWTIdList.contains(workOrderRec.WorkTypeId)){
                accountIdList.add(workOrderRec.AccountId);
            }
        }

        List<WorkOrder> workOrdersToExpireList = [SELECT Id, Status, (SELECT Id, Status FROM Service_Appointments__r)
                                                  FROM WorkOrder
                                                  WHERE AccountId IN :accountIdList
                                                    AND Proactive_Work__c = true
                                                    AND Status IN :statusToExpireList
                                                    AND Id NOT IN :newMap.keyset()];

        List<ServiceAppointment> serviceApptsToExpire = new List<ServiceAppointment>();
        for(WorkOrder workOrderToExpire : workOrdersToExpireList){
            workOrderToExpire.Status = 'Expired';
            for(ServiceAppointment saRec : workOrderToExpire.Service_Appointments__r){
                saRec.Status = 'Expired';
                serviceApptsToExpire.add(saRec);
            }
        }
        update workOrdersToExpireList;
        update serviceApptsToExpire;
    }
}